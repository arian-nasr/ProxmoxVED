#!/usr/bin/env bash
COMMUNITY_SCRIPTS_URL="${COMMUNITY_SCRIPTS_URL:-https://git.community-scripts.org/community-scripts/ProxmoxVED/raw/branch/main}"
source <(curl -fsSL "$COMMUNITY_SCRIPTS_URL/misc/build.func")
# Copyright (c) 2021-2026 community-scripts ORG
# Author: arian-nasr
# License: MIT | https://github.com/community-scripts/ProxmoxVED/raw/main/LICENSE
# Source: https://github.com/Wind4/vlmcsd

APP="vlmcsd"
var_tags="${var_tags:-network;kms}"
var_cpu="${var_cpu:-1}"
var_ram="${var_ram:-512}"
var_disk="${var_disk:-2}"
var_os="${var_os:-debian}"
var_version="${var_version:-13}"
var_unprivileged="${var_unprivileged:-1}"

header_info "$APP"
variables
color
catch_errors

function update_script() {
  header_info
  check_container_storage
  check_container_resources
  if [[ ! -f /usr/local/bin/vlmcsd ]]; then
    msg_error "No ${APP} Installation Found!"
    exit
  fi
  RELEASE=$(curl -fsSL https://api.github.com/repos/Wind4/vlmcsd/releases/latest | grep "tag_name" | awk '{print substr($2, 2, length($2)-3)}')
  if [[ ! -f /opt/${APP}_version.txt ]] || [[ "${RELEASE}" != "$(cat /opt/${APP}_version.txt)" ]]; then
    msg_info "Stopping ${APP}"
    systemctl stop vlmcsd
    msg_ok "Stopped ${APP}"

    msg_info "Updating ${APP} to ${RELEASE}"
    curl -fsSL "https://github.com/Wind4/vlmcsd/releases/download/${RELEASE}/binaries.tar.gz" -o /tmp/vlmcsd.tar.gz
    tar -xzf /tmp/vlmcsd.tar.gz -C /tmp
    cp /tmp/binaries/Linux/intel/static/vlmcsd-x64-musl-static /usr/local/bin/vlmcsd
    chmod +x /usr/local/bin/vlmcsd
    rm -rf /tmp/vlmcsd.tar.gz /tmp/binaries
    echo "${RELEASE}" >/opt/${APP}_version.txt
    msg_ok "Updated ${APP} to ${RELEASE}"

    msg_info "Starting ${APP}"
    systemctl start vlmcsd
    msg_ok "Started ${APP}"
    msg_ok "Updated successfully!"
  else
    msg_ok "No update required. ${APP} is already at ${RELEASE}"
  fi
  exit
}

start
build_container
description

msg_ok "Completed Successfully!\n"
echo -e "${CREATING}${GN}${APP} setup has been successfully initialized!${CL}"
echo -e "${INFO}${YW} KMS Server is listening on port:${CL} ${BGN}1688${CL}"
