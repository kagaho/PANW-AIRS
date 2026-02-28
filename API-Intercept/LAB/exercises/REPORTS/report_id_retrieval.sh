#!/usr/bin/env bash
set -euo pipefail

API_BASE="${API_BASE:-https://service.api.aisecurity.paloaltonetworks.com}"
: "${PAN_TOKEN:?Set PAN_TOKEN env var first}"

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <REPORT_ID> [REPORT_ID ...]"
  exit 1
fi

REPORT_IDS_CSV="$(IFS=,; echo "$*")"

headers=(
  -H "Accept: application/json"
  -H "x-pan-token: ${PAN_TOKEN}"
)

fetch_reports() {
  curl -sS -G -L "${API_BASE}/v1/scan/reports" \
    "${headers[@]}" \
    --data-urlencode "report_ids=${REPORT_IDS_CSV}"
}

# Poll until contextual_grounding cg_report.status is not "pending" (or timeout)
MAX_TRIES="${MAX_TRIES:-20}"
SLEEP_SECS="${SLEEP_SECS:-1}"

reports_json=""
for ((i=1; i<=MAX_TRIES; i++)); do
  reports_json="$(fetch_reports)"

  pending="$(echo "$reports_json" | jq -r '
    [ .[]?.detection_results[]?
      | select(.detection_service=="contextual_grounding")
      | (.result_detail.cg_report.status // "")
    ] | any(.=="pending")
  ')"

  if [[ "$pending" == "false" ]]; then
    break
  fi
  sleep "$SLEEP_SECS"
done

echo
echo
echo "=== Detector breakdown (all topics) ==="
echo "$reports_json" | jq '
  map({
    report_id, req_id, session_id, transaction_id,
    detectors: (
      .detection_results
      | map({
          service: .detection_service,
          data_type,
          verdict,
          action,
          details: (
            .result_detail.pi_snippets
            // .result_detail.cg_report
            // .result_detail.dlp_report
            // .result_detail.tc_report
            // .result_detail.topic_guardrails_report
            // .result_detail.agent_report
            // .result_detail.mc_report
            // .result_detail.urlf_report
            // .result_detail
            // {}
          )
        })
    )
  })
'

echo
echo "=== Summary (what triggered the verdict) ==="
echo "$reports_json" | jq -r '
  .[] as $r |
  ($r.detection_results | map(select(.action=="block" or .verdict=="malicious"))) as $hits |
  "transaction_id=\($r.transaction_id) report_id=\($r.report_id)\n" +
  (
    if ($hits|length)==0 then
      "OK: no detector blocked\n"
    else
      "BLOCKED by: " + ($hits | map(.detection_service) | unique | join(", ")) + "\n" +
      (
        $hits
        | map(
            "- \(.detection_service) (\(.data_type)): " +
            (
              if .detection_service=="pi" then
                ("snippet=" + ((.result_detail.pi_snippets // []) | join(" | ")))
              elif .detection_service=="contextual_grounding" then
                ("status=" + ((.result_detail.cg_report.status // "")|tostring) +
                 (if (.result_detail.cg_report.category? // null) != null then
                   " category=" + (.result_detail.cg_report.category|tostring)
                 else "" end) +
                 (if (.result_detail.cg_report.explanation? // null) != null then
                   " explanation=" + (.result_detail.cg_report.explanation|tostring)
                 else "" end)
                )
              elif .detection_service=="dlp" then
                ("profile=" + ((.result_detail.dlp_report.dlp_profile_name // "")|tostring) +
                 " rule1=" + ((.result_detail.dlp_report.data_pattern_rule1_verdict // "")|tostring) +
                 (if (.result_detail.dlp_report.data_pattern_rule2_verdict // "") != "" then
                   " rule2=" + (.result_detail.dlp_report.data_pattern_rule2_verdict|tostring)
                 else "" end)
                )
              elif .detection_service=="topic_guardrails" then
                ("allowed=" + ((.result_detail.topic_guardrails_report.allowed_topic_list // "")|tostring) +
                 " blocked=" + ((.result_detail.topic_guardrails_report.blocked_topic_list // "")|tostring)
                )
              elif .detection_service=="tc" then
                ("verdict=" + ((.result_detail.tc_report.verdict // "")|tostring) +
                 " cats=" + ((.result_detail.tc_report.toxic_categories // [])|join(",")))
              elif .detection_service=="malicious_code" then
                ("verdict=" + ((.result_detail.mc_report.verdict // "")|tostring))
              elif .detection_service=="uf" then
                ("urlf_count=" + (((.result_detail.urlf_report // [])|length)|tostring))
              elif .detection_service=="agent_security" then
                ("model_verdict=" + ((.result_detail.agent_report.model_verdict // "")|tostring))
              else
                "blocked"
              end
            )
          )
        | join("\n")
      ) + "\n"
    end
  )
'

