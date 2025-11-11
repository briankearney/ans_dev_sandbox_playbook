#!/usr/bin/bash

deactivate
export PLAYBOOK_PATH=~/Documents/GitHub/ans_dev_sandbox_playbook &&\
 cd $PLAYBOOK_PATH &&\
 if [ -d .venv ]
  then
   source ./.venv/bin/activate
  else
   python3 -m venv .venv &&\
   source ./.venv/bin/activate
   python -m pip install --upgrade pip &&\
   python -m pip install ansible-dev-tools
 fi
 export ANSIBLE_DISPLAY_ARGS_TO_STDOUT=false &&\
 export ANSIBLE_CALLBACKS_ENABLED='profile_tasks' &&\
 export ANSIBLE_LOAD_CALLBACK_PLUGINS=true &&\
 export ANSIBLE_LOG_PATH=./ansible.log &&\
 export ANSIBLE_ROLES_PATH=roles &&\
 export ANSIBLE_FILTER_PLUGINS=plugins &&\
 export ANSIBLE_LIBRARY=library &&\
 export ANSIBLE_CALLBACK_RESULT_FORMAT=yaml &&\
 export ANSIBLE_VAULT_PASSWORD_FILE=$PLAYBOOK_PATH/vault-pw.txt &&\
 export SANDBOX_GITHUB_SSH_KEY=~/.ssh/id_rsa &&\
 alias avdad='python $PLAYBOOK_PATH/DECRYPT_VAULTED_ITEMS.py'
