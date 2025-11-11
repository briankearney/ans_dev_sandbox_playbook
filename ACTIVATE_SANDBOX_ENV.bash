#!/usr/bin/bash

deactivate
export ROLE_PATH=~/Documents/GitHub/ans_dev_sandbox_playbook &&\
 cd $ROLE_PATH &&\
 source ./.venv/bin/activate &&\
 export ANSIBLE_DISPLAY_ARGS_TO_STDOUT=false &&\
 export ANSIBLE_CALLBACKS_ENABLED='profile_tasks' &&\
 export ANSIBLE_LOAD_CALLBACK_PLUGINS=true &&\
 export ANSIBLE_LOG_PATH=./ansible.log &&\
 export ANSIBLE_ROLES_PATH=roles &&\
 export ANSIBLE_FILTER_PLUGINS=plugins &&\
 export ANSIBLE_LIBRARY=library &&\
 export ANSIBLE_CALLBACK_RESULT_FORMAT=yaml &&\
 export ANSIBLE_VAULT_PASSWORD_FILE=$ROLE_PATH/vault-pw.txt &&\
 export SANDBOX_GITHUB_SSH_KEY=~/.ssh/id_rsa &&\
 alias avdad='python $ROLE_PATH/DECRYPT_VAULTED_ITEMS.py'
