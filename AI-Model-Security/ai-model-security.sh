#!/bin/bash
#
# Model Security Private PyPI Authentication Script
# Authenticates with SCM and retrieves PyPI repository URL
#

set -euo pipefail

# Check required environment variables
echo "Step 1: Checking required environment variables..." >&2
: "${MODEL_SECURITY_CLIENT_ID:?Error: MODEL_SECURITY_CLIENT_ID not set}"
: "${MODEL_SECURITY_CLIENT_SECRET:?Error: MODEL_SECURITY_CLIENT_SECRET not set}"
: "${TSG_ID:?Error: TSG_ID not set}"
echo "  ✓ All required environment variables are set" >&2

# Set default endpoints
echo "Step 2: Setting API endpoints..." >&2

# Set default endpoints
API_ENDPOINT="${MODEL_SECURITY_API_ENDPOINT:-https://api.sase.paloaltonetworks.com/aims}"
TOKEN_ENDPOINT="${MODEL_SECURITY_TOKEN_ENDPOINT:-https://auth.apps.paloaltonetworks.com/oauth2/access_token}"

# API_ENDPOINT="${MODEL_SECURITY_API_ENDPOINT:-https://api.sase.paloaltonetworks.com/aims}"
# TOKEN_ENDPOINT="${MODEL_SECURITY_TOKEN_ENDPOINT:-https://auth.appsvc.paloaltonetworks.com/auth/v1/oauth2/access_token}"
echo "  ✓ Token endpoint: $TOKEN_ENDPOINT" >&2
echo "  ✓ API endpoint: $API_ENDPOINT" >&2

# Get SCM access token
echo "Step 3: Requesting SCM access token..." >&2
echo "  → Calling: POST $TOKEN_ENDPOINT" >&2
echo "  → Client ID: $MODEL_SECURITY_CLIENT_ID" >&2
echo "  → TSG ID: $TSG_ID" >&2

TOKEN_RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "$TOKEN_ENDPOINT" \
    -H "Content-Type: application/x-www-form-urlencoded" \
    -u "$MODEL_SECURITY_CLIENT_ID:$MODEL_SECURITY_CLIENT_SECRET" \
    -d "grant_type=client_credentials&scope=tsg_id:$TSG_ID")

# Extract status code and body
TOKEN_HTTP_CODE=$(echo "$TOKEN_RESPONSE" | tail -n1)
TOKEN_BODY=$(echo "$TOKEN_RESPONSE" | sed '$d')

echo "  → HTTP Status: $TOKEN_HTTP_CODE" >&2

if [[ "$TOKEN_HTTP_CODE" != "200" ]]; then
    echo "" >&2
    echo "  ✗ Error: Failed to obtain SCM access token (HTTP $TOKEN_HTTP_CODE)" >&2
    echo "  → Response: $TOKEN_BODY" >&2
    echo "" >&2
    echo "  Possible causes:" >&2
    echo "  - Invalid client credentials" >&2
    echo "  - Incorrect TOKEN_ENDPOINT" >&2
    echo "  - Network connectivity issues" >&2
    echo "" >&2
    exit 1
fi
echo "  ✓ SCM access token received" >&2

echo "Step 4: Extracting access token from response..." >&2
SCM_TOKEN=$(echo "$TOKEN_BODY" | jq -r '.access_token')
if [[ -z "$SCM_TOKEN" || "$SCM_TOKEN" == "null" ]]; then
    echo "  ✗ Error: Failed to extract access token from response" >&2
    echo "  → Response: $TOKEN_BODY" >&2
    exit 1
fi
echo "  ✓ Access token extracted successfully" >&2

# Get PyPI URL
echo "Step 5: Retrieving PyPI repository URL..." >&2
echo "  → Calling: GET $API_ENDPOINT/mgmt/v1/pypi/authenticate" >&2

# Create temp file for response headers
TEMP_HEADERS=$(mktemp)
trap "rm -f $TEMP_HEADERS" EXIT

# Make request and capture status code
PYPI_RESPONSE=$(curl -s -w "\n%{http_code}" -X GET "$API_ENDPOINT/mgmt/v1/pypi/authenticate" \
    -H "Authorization: Bearer $SCM_TOKEN" \
    -D "$TEMP_HEADERS")

# Extract status code (last line) and body (everything else)
HTTP_CODE=$(echo "$PYPI_RESPONSE" | tail -n1)
PYPI_BODY=$(echo "$PYPI_RESPONSE" | sed '$d')

echo "  → HTTP Status: $HTTP_CODE" >&2

# Check for errors
if [[ "$HTTP_CODE" == "403" ]]; then
    echo "" >&2
    echo "  ✗ Error: Access Denied (HTTP 403)" >&2
    echo "  → Response: $PYPI_BODY" >&2
    echo "" >&2
    echo "  Diagnosis:" >&2
    echo "  - Authentication succeeded (token obtained successfully)" >&2
    echo "  - Authorization failed (service account lacks permissions)" >&2
    echo "" >&2
    echo "  Solution:" >&2
    echo "  - The service account '$MODEL_SECURITY_CLIENT_ID' needs permissions" >&2
    echo "    to access the PyPI authentication endpoint" >&2
    echo "  - Contact your administrator to grant the required IAM permissions" >&2
    echo "  - Required permission scope: PyPI access for TSG $TSG_ID" >&2
    echo "" >&2
    exit 1
elif [[ "$HTTP_CODE" != "200" ]]; then
    echo "" >&2
    echo "  ✗ Error: HTTP $HTTP_CODE" >&2
    echo "  → Response: $PYPI_BODY" >&2
    echo "" >&2
    exit 1
fi

echo "  ✓ PyPI response received successfully" >&2

echo "Step 6: Extracting PyPI URL from response..." >&2
PYPI_URL=$(echo "$PYPI_BODY" | jq -r '.url')
if [[ -z "$PYPI_URL" || "$PYPI_URL" == "null" ]]; then
    echo "  ✗ Error: Failed to extract PyPI URL from response" >&2
    echo "  → Response: $PYPI_BODY" >&2
    exit 1
fi
echo "  ✓ PyPI URL extracted successfully" >&2

echo "$PYPI_URL"
