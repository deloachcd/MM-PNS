#!/bin/bash
set -euo pipefail

cleanup() {
    if [[ -e ansible/inventory.ini ]]; then
        rm ansible/inventory.ini
    fi
    if [[ -e ansible/inventory_vars ]]; then
        rm ansible/inventory_vars
    fi
}

trap cleanup EXIT

if [[ ! -e config/PNASfile ]]; then
    echo "Error: you need to set deployment variables in a live PNASfile first."
    echo "You can start by copying over the self-documenting template:"
    echo "./script/create-config.sh"
    echo
    echo "Refer to README.org for more information."
    exit -1
fi

while read variable_declaration; do
    if echo "$variable_declaration" | grep '^#' 1>/dev/null; then
        continue
    fi
    VARNAME=$(echo "$variable_declaration" | awk -F '=' '{ print $1 }')
    eval "$variable_declaration"
    if [[ -z "${!VARNAME}" ]]; then
        echo "Error: required variable '$VARNAME' is unset in PNASfile!"
        echo "Correct this and try again."
        exit -1
    fi
    echo "${VARNAME}=${!VARNAME}" >> ansible/inventory_vars
done < <(cat config/PNASfile | grep -v '^#' | grep '[a-z]')

cat > ansible/inventory.ini << EOF
[pnas_host]
${pnas_host}

[pnas_host:vars]
ansible_ssh_user=${pnas_user}
$(cat ansible/inventory_vars)
EOF
chmod 600 ansible/inventory.ini
rm ansible/inventory_vars

# create generic symlinks to actual certs in nginx
if [[ -e nginx/ssl/${pnas_host}.crt && ! -e nginx/ssl/live.crt ]]; then
    cd nginx/ssl
    ln -s ${pnas_host}.crt live.crt
    cd ../..
fi
if [[ -e nginx/certs/${pnas_host}.key  && ! -e nginx/ssl/live.key ]]; then
    cd nginx/ssl
    ln -s ${pnas_host}.key live.key
    cd ../..
fi

ansible-playbook --ask-become-pass -i ansible/inventory.ini ansible/provision.yml
