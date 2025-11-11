#!/usr/bin/bash

podman build -t ansible_target . &&\
 podman run --hostname ansible_target --interactive --name ansible_target --publish 2222:22 --rm --tty --volume ~/.ssh:/root/.ssh:ro,z ansible_target:latest
