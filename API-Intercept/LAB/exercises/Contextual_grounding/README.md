## Contextual grounding

**Contextual grounding**: Prisma AIRS checks whether the model’s answer is supported by the supplied **context** (RAG / tool output / memory). It flags responses that introduce unsupported facts or drift off-topic.

- References: 

> https://docs.paloaltonetworks.com/whats-new/new-features/may-2025/prevent-inaccuracies-in-llm-outputs-with-contextual-grounding?utm_source=chatgpt.com
> https://docs.paloaltonetworks.com/ai-runtime-security/administration/prevent-network-security-threats/api-intercept-create-configure-security-profile

### Exercise question
> **Is the response supported/entailed by the provided context (source of truth), and does it stay on that topic?**

### Why request #2 violated
> The answer (“John Smith salary…”) is not present in the football context → **ungrounded** (hallucination / topic drift).

### Scripts
- `contextual_grounding.sh`
- `contextual_grounding_with_response.sh`

### Report verification
- `report_id_retrieval.sh`

