#!/bin/sh
# Multiline Variable String
REASON="$(cat <<-EOF
Usage: ServiceAccountName LogFile
Where:
      ServiceAccountName - credentials being requested.
      LogFile            - Name of the log file
EOF
)"
echo "$REASON"
