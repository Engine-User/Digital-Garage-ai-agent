# Digital Garage@2026
#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SERVICE_FILE="$SCRIPT_DIR/digital_garage-ui.service"

if [ ! -f "$SERVICE_FILE" ]; then
  echo "Error: digital_garage-ui.service not found in $SCRIPT_DIR"
  exit 1
fi

echo "Installing DigitalGarage UI service..."
echo "Make sure you've edited digital_garage-ui.service with your username and paths first!"
echo ""

sudo cp "$SERVICE_FILE" /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable digital_garage-ui
sudo systemctl start digital_garage-ui
sudo systemctl status digital_garage-ui
