#!/bin/bash
#
# Fix permissions for OpenClaw directories
# Run this script if you encounter permission errors
#

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Fixing OpenClaw directory permissions...${NC}"

# Get the node user UID/GID (typically 1000:1000)
NODE_UID=${NODE_UID:-1000}
NODE_GID=${NODE_GID:-1000}

# Create directories if they don't exist
mkdir -p ~/.openclaw
mkdir -p ~/.openclaw/workspace
mkdir -p ~/.openclaw/canvas
mkdir -p ~/.openclaw/cron

# Fix ownership (adjust UID/GID if your node user is different)
if command -v sudo &> /dev/null; then
    echo "Setting ownership to UID $NODE_UID:GID $NODE_GID..."
    sudo chown -R $NODE_UID:$NODE_GID ~/.openclaw
    sudo chmod -R 755 ~/.openclaw
else
    echo "Setting ownership to current user..."
    chown -R $USER:$USER ~/.openclaw 2>/dev/null || true
    chmod -R 755 ~/.openclaw
fi

echo -e "${GREEN}✓ Permissions fixed!${NC}"
echo ""
echo "If you're using Dokploy or a different user, you may need to:"
echo "  1. Check the UID/GID of the container user: docker exec openclaw-gateway id"
echo "  2. Update NODE_UID and NODE_GID in this script if different from 1000:1000"
echo "  3. Run: NODE_UID=<uid> NODE_GID=<gid> ./fix-permissions.sh"

