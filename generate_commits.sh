#!/usr/bin/env bash
set -eo pipefail

# Fetch mason-registry releases and create commits for each
API_URL="https://api.github.com/repos/mason-org/mason-registry/releases"
PLUGIN_FILE="lua/mason-registry-lock/init.lua"

# Get the latest release from the most recent commit
latest_commit_release=$(git log --oneline -1 --grep="Update mason-registry lock to" | grep -o 'to [^"]*' | cut -d' ' -f2 || echo "")

# Fetch releases from GitHub API with timestamps and sort by timestamp (oldest first)
all_releases=$(curl -s "$API_URL" | jq -r '.[] | "\(.published_at) \(.tag_name)"' | sort)

# If we have a latest release, find its timestamp and filter to only newer releases
if [ -n "$latest_commit_release" ]; then
    latest_timestamp=$(echo "$all_releases" | grep "$latest_commit_release" | cut -d' ' -f1 || echo "")
    if [ -n "$latest_timestamp" ]; then
        echo "Latest commit release: $latest_commit_release (timestamp: $latest_timestamp)"
        releases=$(echo "$all_releases" | awk -v ts="$latest_timestamp" '$1 > ts {print $2}')
    else
        releases=$(echo "$all_releases" | cut -d' ' -f2)
    fi
else
    releases=$(echo "$all_releases" | cut -d' ' -f2)
fi

for release in $releases; do
    echo "Processing new release: $release"

    # Update the plugin file with the new release
    cat > "$PLUGIN_FILE" << EOF
local M = {}

M.registry_release = "github:mason-org/mason-registry@$release"

return M
EOF

    # Add and commit the change
    git add "$PLUGIN_FILE"
    git commit -m "Update mason-registry lock to $release" || continue

    echo "Created commit for $release"
done

echo "All commits processed!"
