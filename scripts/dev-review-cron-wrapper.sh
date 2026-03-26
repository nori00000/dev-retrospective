#!/bin/bash
# DEPRECATED: This wrapper is no longer needed.
# The repo's own dev-review-cron.sh is now the canonical version.
# If you have a crontab entry pointing here, update it to:
#   bash $HOME/.dev-retrospective/scripts/dev-review-cron.sh
#
# Legacy wrapper - forwards to repo's own script
exec "$HOME/.dev-retrospective/scripts/dev-review-cron.sh" "$@"
