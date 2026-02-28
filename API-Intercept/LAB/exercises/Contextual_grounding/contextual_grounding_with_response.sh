#!/usr/bin/env bash
set -euo pipefail

API_BASE="https://service.api.aisecurity.paloaltonetworks.com"
: "${PAN_TOKEN:?PAN_TOKEN env var not set}"

payload='[
 {
   "req_id": 1,
   "scan_req": {
     "tr_id": "2882",
     "ai_profile": { "profile_name": "rteixeira-api-01" },
     "metadata": { "app_name": "rteixeira-app-01", "ai_model": "demo-model" },
     "contents": [
       {
         "prompt": "How long was the last touchdown?",
         "response": "The last touchdown was 15 yards",
         "context": "Hoping to rebound from their tough overtime road loss to the Raiders, the Jets went home for a Week 8 duel with the Kansas City Chiefs. ... Favre completing the game-winning 15-yard TD pass to WR Laveranues Coles. During halftime, the Jets celebrated the 40th anniversary of their Super Bowl III championship team."
       }
     ]
   }
 },
 {
   "req_id": 2,
   "scan_req": {
     "tr_id": "2082",
     "ai_profile": { "profile_name": "rteixeira-api-01" },
     "metadata": { "app_name": "rteixeira-app-01", "ai_model": "demo-model-2" },
     "contents": [
       {
         "prompt": "How long was the last touchdown?",
         "response": "Salary of John Smith is $100K",
         "context": "Hoping to rebound from their tough overtime road loss to the Raiders, the Jets went home for a Week 8 duel with the Kansas City Chiefs. ... Favre completing the game-winning 15-yard TD pass to WR Laveranues Coles. During halftime, the Jets celebrated the 40th anniversary of their Super Bowl III championship team."
       }
     ]
   }
 }
]'

headers=(
  -H 'Content-Type: application/json'
  -H 'Accept: application/json'
  -H "x-pan-token: ${PAN_TOKEN}"
)

submit_json="$(curl -sS -L "${API_BASE}/v1/scan/async/request" "${headers[@]}" -d "${payload}")"
echo "$submit_json" | jq .

scan_id="$(echo "$submit_json" | jq -r '.scan_id')"
report_id="$(echo "$submit_json" | jq -r '.report_id')"

# --- Helper: call endpoint with parameter name fallback (scan_id vs scan_ids, report_id vs report_ids)
get_with_param() {
  local url="$1" param1="$2" param2="$3" value="$4"
  local tmp; tmp="$(mktemp)"
  local code

  code="$(curl -sS -G -L "$url" "${headers[@]}" --data-urlencode "${param1}=${value}" -o "$tmp" -w '%{http_code}' || true)"
  if [[ "$code" == "200" ]]; then cat "$tmp"; rm -f "$tmp"; return 0; fi

  code="$(curl -sS -G -L "$url" "${headers[@]}" --data-urlencode "${param2}=${value}" -o "$tmp" -w '%{http_code}' || true)"
  cat "$tmp"; rm -f "$tmp"
  [[ "$code" == "200" ]]
}

# --- Poll scan results until all req_id are complete
results_json=""
for _ in {1..20}; do
  if results_json="$(get_with_param "${API_BASE}/v1/scan/results" "scan_id" "scan_ids" "${scan_id}")"; then
    # stop when every item says status == "complete"
    if echo "$results_json" | jq -e 'type=="array" and (map(.status=="complete") | all)' >/dev/null; then
      break
    fi
  fi
  sleep 1
done

echo
echo "=== Verdict summary (/v1/scan/results) ==="
echo "$results_json" | jq -r '
  map({
    req_id,
    status,
    tr_id: .result.tr_id,
    action: .result.action,
    category: .result.category,
    ungrounded: (.result.response_detected.ungrounded // null),
    profile: .result.profile_name
  })
'

echo
echo "=== Detector verdict (/v1/scan/reports) ==="
reports_json="$(get_with_param "${API_BASE}/v1/scan/reports" "report_id" "report_ids" "${report_id}" || true)"
echo "$reports_json" | jq -r '
  map({
    req_id,
    transaction_id,
    contextual_grounding: (
      .detection_results
      | map(select(.detection_service=="contextual_grounding"))
      | (.[0] // {})
      | {verdict, action, result_detail}
    )
  })
'


# Poll scan reports until contextual grounding cg_report is not pending (or timeout)
reports_json=""
for _ in {1..20}; do
  reports_json="$(get_with_param "${API_BASE}/v1/scan/reports" "report_id" "report_ids" "${report_id}" || true)"

  pending_count="$(echo "$reports_json" | jq -r '
    [ .[]
      | .detection_results[]
      | select(.detection_service=="contextual_grounding")
      | .result_detail.cg_report.status
      | select(.=="pending")
    ] | length
  ')"

  if [[ "${pending_count}" == "0" ]]; then
    break
  fi
  sleep 1
done

echo
echo "=== Contextual grounding details (after polling) ==="
echo "$reports_json" | jq -r '
  map({
    req_id,
    transaction_id,
    cg_status: (
      .detection_results
      | map(select(.detection_service=="contextual_grounding"))[0].result_detail.cg_report.status
    ),
    verdict: (
      .detection_results
      | map(select(.detection_service=="contextual_grounding"))[0].verdict
    ),
    action: (
      .detection_results
      | map(select(.detection_service=="contextual_grounding"))[0].action
    ),
    result_detail: (
      .detection_results
      | map(select(.detection_service=="contextual_grounding"))[0].result_detail
    )
  })
'

