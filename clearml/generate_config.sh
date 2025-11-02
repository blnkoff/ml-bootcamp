#!/bin/bash
"""
Shell script to generate apiserver.conf with hashed passwords from environment variables.
This script reads CLEARML_USERNAME and CLEARML_PASSWORD from .env file and generates
apiserver.conf with bcrypt hashed password using the exact command provided.
"""

set -e

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="$SCRIPT_DIR/.env"
OUTPUT_FILE="$SCRIPT_DIR/apiserver.conf"

# Check if .env file exists
if [ ! -f "$ENV_FILE" ]; then
    echo "Error: .env file not found at $ENV_FILE"
    exit 1
fi

# Load environment variables from .env file
export $(grep -v '^#' "$ENV_FILE" | grep -v '^$' | xargs)

# Check if required environment variables are set
if [ -z "$CLEARML_USERNAME" ]; then
    echo "Error: CLEARML_USERNAME not found in .env file"
    exit 1
fi

if [ -z "$CLEARML_PASSWORD" ]; then
    echo "Error: CLEARML_PASSWORD not found in .env file"
    exit 1
fi

# Generate hashed password using the exact command provided
echo "Generating password hash..."
HASHED_PASSWORD=$(python3 -c "import bcrypt,base64; print(base64.b64encode(bcrypt.hashpw('$CLEARML_PASSWORD'.encode(), bcrypt.gensalt())).decode())")

# Generate apiserver.conf content
cat > "$OUTPUT_FILE" << EOF
auth {
    # Fixed users login credentials
    # No other user will be able to login
    fixed_users {
        enabled: true
        pass_hashed: true
        users: [
            {
                username: "$CLEARML_USERNAME"
                password: "$HASHED_PASSWORD"
                name: "$(echo $CLEARML_USERNAME | sed 's/.*/\u&/')"
            }
        ]
    }
}
EOF

echo "Successfully generated $OUTPUT_FILE"
echo "Username: $CLEARML_USERNAME"
echo "Password hash generated and saved"
