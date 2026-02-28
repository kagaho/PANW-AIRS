## Prompt injection

**Prompt injection**: attacker tries to override system/app instructions (e.g., “ignore all instructions”) to exfiltrate secrets or change behavior. Prisma AIRS detects this and can block the request.

### Exercise question
> Does the prompt attempt to override instructions / request secrets?

### Why it was blocked
> The prompt contains an injection pattern (“Ignore all instructions…”) → **PI detector** flags it → **action: block**.

### Scripts
- `prompt-injection-01.sh`

### Verify report
- `report_id_retrieval.sh <REPORT_ID>`

