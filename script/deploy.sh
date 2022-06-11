#!/bin/bash
set -euo pipefail

cleanup() {
    if [[ -e ansible/inventory.ini ]]; then
        rm ansible/inventory.ini
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
    VARNAME=$(echo "$variable_declaration" | awk -F '=' '{ print $1 }')
    eval "$variable_declaration"
    if [[ -z "${!VARNAME}" ]]; then
        echo "Error: required variable '$VARNAME' is unset in PNASfile!"
        echo "Correct this and try again."
        exit -1
    fi
done < <(cat config/PNASfile)

cat > ansible/inventory.ini << EOF
[pnas_host]
${pnas_host}

[pnas_host:vars]
ansible_ssh_user=${pnas_user}
pnas_user=${pnas_user}
pnas_router_ip=${pnas_router_ip}
pnas_share_path=${pnas_share_path}
pnas_music_path=${pnas_music_path}
pnas_samba_user=${pnas_samba_user}
pnas_samba_user_passwd=${pnas_samba_user_passwd}
EOF
chmod 600 ansible/inventory.ini

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
