#!/bin/bash

# Usage: launch.sh <flow>
# Flows: vim, shell (default), container, server, client

FLOW="${1:-shell}"

# kitten @ launch --type=tab --keep-focus=yes --wait-for-child-to-exit=yes --no-response=yes --hold=yes --allow-remote-control=yes --hold-after-ssh=yes kitten ssh td-private
# kitten @ launch --type=tab --keep-focus=yes --wait-for-child-to-exit=yes --no-response=yes --hold=yes --allow-remote-control=yes --hold-after-ssh=yes nvim
ID=$(kitten @ launch --type=overlay-main --allow-remote-control=yes kitten ssh td-private)

# # Step 1: Always connect to remote machine first
# kitten @ action remote_ssh
TAB_MATCH="id:$ID"

sleep 1

# Step 2: Execute flow-specific actions
case "$FLOW" in
    vim)
        kitten @ set-tab-title -m "$TAB_MATCH" td_vim
        kitten @ send-text -m "$TAB_MATCH" 'nvim\n'
        ;;
    shell)
        kitten @ set-tab-title -m "$TAB_MATCH" td_shell
        ;;
    container)
        kitten @ set-tab-title -m "$TAB_MATCH" td_container
        kitten @ send-text -m "$TAB_MATCH" docker exec -i -t td_app ash "\r"
        ;;
    server)
        kitten @ set-tab-title -m "$TAB_MATCH" td_server
        kitten @ send-text -m "$TAB_MATCH" docker exec -i -t td_app ash "\r"
        kitten @ send-text -m "$TAB_MATCH" "pm2 kill && npm run dev:run-server-lite && pm2 logs \r"
        ;;
    client)
        kitten @ set-tab-title -m "$TAB_MATCH" td_client
        kitten @ send-text -m "$TAB_MATCH" docker exec -i -t td_app ash "\r"
        kitten @ send-text -m "$TAB_MATCH" "npm run dev:build-client \r"
        ;;
    *)
        echo "Unknown flow: $FLOW"
        echo "Available flows: vim, shell, container, server, client"
        exit 1
        ;;
esac
