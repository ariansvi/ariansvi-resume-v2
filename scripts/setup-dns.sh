#!/usr/bin/env bash
set -euo pipefail

# ─── DNS Setup Guide ────────────────────────────────────────────────
# Shows Cloud DNS nameservers to configure in GoDaddy

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}"
echo "  ╔══════════════════════════════════════╗"
echo "  ║  DNS Setup: GoDaddy → Cloud DNS      ║"
echo "  ╚══════════════════════════════════════╝"
echo -e "${NC}"

echo -e "${GREEN}[1]${NC} Getting Cloud DNS nameservers..."
echo ""

NS_SERVERS=$(cd terraform && terraform output -json dns_name_servers 2>/dev/null | python3 -c "import sys,json; [print(f'  {ns}') for ns in json.load(sys.stdin)]" 2>/dev/null) || true

if [[ -z "$NS_SERVERS" ]]; then
    echo -e "${YELLOW}Could not read from Terraform state. Getting from gcloud...${NC}"
    NS_SERVERS=$(gcloud dns managed-zones describe resume-zone-prod \
        --format="value(nameServers)" 2>/dev/null | tr ';' '\n' | sed 's/^/  /')
fi

echo "$NS_SERVERS"
echo ""

echo -e "${GREEN}[2]${NC} Go to GoDaddy DNS management for ariansvi.com"
echo ""
echo "  1. Log in to https://dcc.godaddy.com/domains/ariansvi.com/dns"
echo "  2. Click 'Nameservers' → 'Change Nameservers'"
echo "  3. Select 'Enter my own nameservers (advanced)'"
echo "  4. Enter the nameservers listed above"
echo "  5. Save and wait for propagation (up to 48h, usually ~1h)"
echo ""

echo -e "${GREEN}[3]${NC} Verify propagation:"
echo ""
echo "  dig ariansvi.com NS"
echo "  dig ariansvi.com A"
echo ""

echo -e "${GREEN}[4]${NC} After DNS propagates, verify HTTPS:"
echo ""
echo "  curl -I https://ariansvi.com"
echo ""
