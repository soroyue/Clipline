#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")"
exec bash scripts/test-install.sh
