#!/usr/bin/env bash

# Copyright (c) 2021-2026 community-scripts ORG
# Author: arian-nasr
# License: MIT | https://github.com/community-scripts/ProxmoxVED/raw/main/LICENSE
# Source: https://github.com/Wind4/vlmcsd

source /dev/stdin <<<"$FUNCTIONS_FILE_PATH"
color
verb_ip6
catch_errors
setting_up_container
network_check
update_os

msg_info "Installing vlmcsd"
RELEASE=$(curl -fsSL https://api.github.com/repos/Wind4/vlmcsd/releases/latest | grep "tag_name" | awk '{print substr($2, 2, length($2)-3)}')
curl -fsSL "https://github.com/Wind4/vlmcsd/releases/download/${RELEASE}/binaries.tar.gz" -o /tmp/vlmcsd.tar.gz
tar -xzf /tmp/vlmcsd.tar.gz -C /tmp
cp /tmp/binaries/Linux/intel/static/vlmcsd-x64-musl-static /usr/local/bin/vlmcsd
chmod +x /usr/local/bin/vlmcsd
rm -rf /tmp/vlmcsd.tar.gz /tmp/binaries
echo "${RELEASE}" >/opt/vlmcsd_version.txt
msg_ok "Installed vlmcsd ${RELEASE}"

msg_info "Creating Service"
cat <<EOF >/etc/systemd/system/vlmcsd.service
[Unit]
Description=vlmcsd KMS Emulator
After=network.target

[Service]
Type=simple
ExecStart=/usr/local/bin/vlmcsd -D
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF
systemctl enable -q --now vlmcsd
msg_ok "Created Service"

motd_ssh
customize
cleanup_lxc
