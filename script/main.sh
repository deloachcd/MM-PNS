#!/bin/bash

# NOTE once everything is stablized and tested, I can cut all of this out
# and just have the user write directly to ./config/PNASfile.ini since they
# don't have to worry about committing passwords to the repo
if [[ ! -e vault/PNASfile.ini  ]]; then
    ./script/manager.sh create
    echo "You will now be taken to a text editor to set variables for deployment"
    echo "[Press any key to continue]"
    read -n 1
    ./script/manager.sh edit
fi

while read variable_declaration; do
    eval "$variable_declaration"
done < <(./script/manager.sh view)

cat << EOF
[pnas_host]
${pnas_host}

[pnas_host:vars]
ansible_ssh_user=${pnas_user}
pnas_router_ip=${pnas_router_ip}
pnas_share_path=${pnas_share_path}
pnas_music_path=${pnas_music_path}
pnas_samba_user=${pnas_samba_user}
pnas_samba_user_passwd=${pnas_samba_user_passwd}
EOF
