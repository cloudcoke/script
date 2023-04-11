#!/usr/bin/env bash

USER="test"
while getopts "u:" opt; do
    case $opt in
        u)
            USER=$OPTARG
            ;;
        \?)
            echo "Invalid option: -$OPTARG" >&2
            exit 1
            ;;
        :)
            echo "Option -$OPTARG requires an argumnet." >&2
            exit 1
            ;;
    esac
done

if id "$USER" > /dev/null 2>&1; then
        sudo rm -rf /home/$USER/* && su - $USER && clear
else
    sudo useradd -m $USER
    sudo usermod -aG sudo $USER
    sudo passwd -d $USER
    echo 'export PS1="\[\033[38;5;39m\]\u@\[\033[38;5;45m\]\W \[\033[38;5;214m\]$\[\033[0m\] "' | sudo tee -a /home/$USER/.bashrc
    su - $USER
   clear
fi