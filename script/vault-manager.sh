#!/bin/sh

ACTION="$1"
if [[ -z "$ACTION" || "$ACTION" == "-h" || "$ACTION" =~ "help" ]]; then
    echo "Usage: ./$(basename $0) {create|edit|view|status}"
    if [[ -z "$ACTION" ]]; then
        exit -1
    else
        exit 0
    fi
fi

PNASFILE=vault/PNASfile.ini
PASSFILE=vault/.passfile
if [[ $ACTION == "create" ]]; then
    if [[ ! -e $PNASFILE ]]; then
        PASSWD='!!!'
        PASSWD_CONFIRM=
        while [[ "$PASSWD" != "$PASSWD_CONFIRM" ]]; do
            if [[ "$PASSWD" != '!!!' ]]; then
                echo
                echo "Try again."
            fi
            printf "Enter a password for the PNASfile: "
            read -s PASSWD
            echo
            printf "Confirm you typed it correctly: "
            read -s PASSWD_CONFIRM
            echo
        done
        echo "$PASSWD" > $PASSFILE
        chmod 600 $PASSFILE
        cp templates/PNASfile.ini $PNASFILE
        ansible-vault encrypt --vault-password-file $PASSFILE $PNASFILE
    else
        echo "Nothing to do! (encrypted file already exists)"
    fi
elif [[ $ACTION == "edit" ]]; then
    ansible-vault edit --vault-password-file $PASSFILE $PNASFILE
elif [[ $ACTION == "view" ]]; then
    ansible-vault view --vault-password-file $PASSFILE $PNASFILE
elif [[ $ACTION == "status" ]]; then
    if [[ -e $PNASFILE ]]; then
        echo "Vaulted PNASfile appears to be present."
    else
        echo "No vaulted PNASfile found!"
    fi
else
    echo "I don't understand what you mean by '${ACTION}', sorry."
    exit -1
fi
