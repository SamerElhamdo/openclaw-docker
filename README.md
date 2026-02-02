# OpenClaw (Clawbot) Docker Image

Pre-built Docker image for [OpenClaw](https://github.com/openclaw/openclaw) — run your AI assistant in seconds without building from source.

> 🔄 **Always Up-to-Date:** This image automatically builds daily and checks for new OpenClaw releases every 6 hours, ensuring you always have the latest version.

## One-Line Install (Recommended)

### Linux / macOS

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/phioranex/openclaw-docker/main/install.sh)
```

### Windows (PowerShell)

```powershell
irm https://raw.githubusercontent.com/phioranex/openclaw-docker/main/install.ps1 | iex
```

> **Note for Windows users:** Make sure Docker Desktop is installed and running. You can also use WSL2 with the Linux installation command.

This will:
- ✅ Check prerequisites (Docker, Docker Compose)
- ✅ Download necessary files
- ✅ Pull the pre-built image
- ✅ Run the onboarding wizard
- ✅ Start the gateway

### Install Options

**Linux / macOS:**

### Install Options

**Linux / macOS:**

```bash
# Just pull the image (no setup)
bash <(curl -fsSL https://raw.githubusercontent.com/phioranex/openclaw-docker/main/install.sh) --pull-only

# Skip onboarding (if already configured)
bash <(curl -fsSL https://raw.githubusercontent.com/phioranex/openclaw-docker/main/install.sh) --skip-onboard

# Don't start gateway after setup
bash <(curl -fsSL https://raw.githubusercontent.com/phioranex/openclaw-docker/main/install.sh) --no-start

# Custom install directory
bash <(curl -fsSL https://raw.githubusercontent.com/phioranex/openclaw-docker/main/install.sh) --install-dir /opt/openclaw
```

**Windows (PowerShell):**

```powershell
# Just pull the image (no setup)
irm https://raw.githubusercontent.com/phioranex/openclaw-docker/main/install.ps1 | iex -PullOnly

# Skip onboarding (if already configured)
irm https://raw.githubusercontent.com/phioranex/openclaw-docker/main/install.ps1 | iex -SkipOnboard

# Don't start gateway after setup
irm https://raw.githubusercontent.com/phioranex/openclaw-docker/main/install.ps1 | iex -NoStart

# Custom install directory
$env:TEMP_INSTALL_SCRIPT = irm https://raw.githubusercontent.com/phioranex/openclaw-docker/main/install.ps1; Invoke-Expression $env:TEMP_INSTALL_SCRIPT -InstallDir "C:\openclaw"
```

## Manual Install

### Quick Start

```bash
# Pull the image
docker pull ghcr.io/phioranex/openclaw-docker:latest

# Run onboarding (first time setup)
docker run -it --rm \
  -v ~/.openclaw:/home/node/.openclaw \
  -v ~/.openclaw/workspace:/home/node/.openclaw/workspace \
  ghcr.io/phioranex/openclaw-docker:latest onboard

# Start the gateway
docker run -d \
  --name openclaw \
  --restart unless-stopped \
  -v ~/.openclaw:/home/node/.openclaw \
  -v ~/.openclaw/workspace:/home/node/.openclaw/workspace \
  -p 18789:18789 \
  ghcr.io/phioranex/openclaw-docker:latest gateway start --foreground
```

### Using Docker Compose

```bash
# Clone this repo
git clone https://github.com/phioranex/openclaw-docker.git
cd openclaw-docker

# Run onboarding
docker compose run --rm openclaw-cli onboard

# Start the gateway
docker compose up -d openclaw-gateway
```

## Configuration

During onboarding, you'll configure:
- **AI Provider** (Anthropic Claude, OpenAI, etc.)
- **Channels** (Telegram, WhatsApp, Discord, etc.)
- **Gateway settings**

Config is stored in `~/.openclaw/` and persists across container restarts.

### Environment Variables

Create a `.env` file in the same directory as `docker-compose.yml` to configure gateway authentication:

```bash
# Copy the example file
cp env.example .env

# Edit .env and set your gateway token
# Generate a secure token: openssl rand -hex 32
OPENCLAW_GATEWAY_TOKEN=your-secure-token-here
```

**Required if gateway auth is set to token:**
- `OPENCLAW_GATEWAY_TOKEN` - Authentication token for the gateway API

**Optional:**
- `OPENCLAW_SKIP_SERVICE_CHECK` - Skip service check on startup (default: false)
- `NODE_ENV` - Node environment (default: production)
- `OPENCLAW_GATEWAY_BIND` - Gateway bind mode: loopback, lan, tailnet, auto, custom (default: lan)
- `OPENCLAW_GATEWAY_PORT` - Gateway port (default: 18789)

### Dokploy Configuration

For Dokploy deployments, use the example configuration:

```bash
# Copy the Dokploy example
cp dokploy.example.toml dokploy.toml
# Edit and customize for your Dokploy project
```

The `dokploy.example.toml` includes:
- Automatic token generation
- Domain configuration
- Environment variables setup

**Note:** The docker-compose.yml uses port-only format (`"18789"` instead of `"18789:18789"`) which is compatible with Dokploy's port management.

### Permission Issues

**Note:** Named volumes (default) automatically handle permissions - no manual fixes needed!

If you're using bind mounts and encounter permission errors like `EACCES: permission denied, mkdir '/home/node/.openclaw/canvas'`:

```bash
# Option 1: Use the fix script
./fix-permissions.sh

# Option 2: Manual fix (adjust UID/GID if needed)
sudo chown -R 1000:1000 ~/.openclaw
sudo chmod -R 755 ~/.openclaw

# Option 3: Switch to named volumes (recommended)
# Just use the default docker-compose.yml - no permission issues!
```

The container runs as user `node` (UID 1000). Named volumes eliminate permission issues entirely.

## Available Tags

| Tag | Description |
|-----|-------------|
| `latest` | Latest OpenClaw build (updated daily and on new releases) |
| `vX.Y.Z` | Specific version (if available) |
| `main` | Latest from main branch (cutting edge) |

> **Note:** The `latest` tag is automatically rebuilt daily at 00:00 UTC and whenever OpenClaw releases a new version.

## Volumes

The docker-compose.yml uses **named volumes** by default, which automatically handle permissions and are ideal for Docker deployments like Dokploy:

| Volume Name | Container Path | Purpose |
|-------------|----------------|---------|
| `openclaw-config` | `/home/node/.openclaw` | Config and session data |
| `openclaw-workspace` | `/home/node/.openclaw/workspace` | Agent workspace |

### Using Bind Mounts (Alternative)

If you prefer bind mounts (for easier host access), use the alternative compose file:

```bash
# Use the bind mounts version
docker compose -f docker-compose.bind-mounts.yml up -d
```

Or manually replace the volumes section in `docker-compose.yml`:

```yaml
volumes:
  - ~/.openclaw:/home/node/.openclaw
  - ~/.openclaw/workspace:/home/node/.openclaw/workspace
```

**Note:** With bind mounts, ensure proper permissions:
```bash
mkdir -p ~/.openclaw/{workspace,canvas,cron}
chmod -R 755 ~/.openclaw
```

### Migrating from Bind Mounts to Named Volumes

If you have existing data in `~/.openclaw` and want to migrate to named volumes:

```bash
# Stop the gateway
docker compose down

# Copy data to named volume
docker run --rm \
  -v ~/.openclaw:/source:ro \
  -v openclaw-config:/dest \
  alpine sh -c "cp -a /source/. /dest/"

# Restart with named volumes
docker compose up -d
```

## Ports

| Port | Purpose |
|------|---------|
| `18789` | Gateway API + Dashboard |

## Links

- [OpenClaw Website](https://openclaw.ai/)
- [OpenClaw Docs](https://docs.openclaw.ai)
- [OpenClaw GitHub](https://github.com/openclaw/openclaw)
- [Discord Community](https://discord.gg/clawd)

## YouTube Tutorial

📺 Watch the installation tutorial: [Coming Soon]

## License

This Docker packaging is provided by [Phioranex](https://phioranex.com).
OpenClaw itself is licensed under MIT — see the [original repo](https://github.com/openclaw/openclaw).
