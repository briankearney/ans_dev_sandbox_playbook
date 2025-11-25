# defaults/

This directory holds a convenience default variable file for playbooks in this repository. It is NOT a role `defaults/` directory and therefore is not auto-loaded by Ansible.

File of interest:
- `main.yml` — contains example/default variables consumed by the sample playbook (only if explicitly referenced).

Usage
- If you want these values applied, include them explicitly:
	```yaml
	# Inside a playbook
	- hosts: local
		vars_files:
			- ../defaults/main.yml
		roles:
			- ans_dev_sandbox_role
	```
- Otherwise rely on the role's own `defaults/` directory for intrinsic defaults.
- Edit `defaults/main.yml` to experiment with different values without modifying the role.

Notes
- Keep values minimal and non-sensitive; store secrets in vaulted host/group vars instead.
- To promote a value to true role defaults, move it into the role’s `defaults/main.yml`.
- Clarify precedence: if loaded via `vars_files`, these values outrank role defaults but are still below play and extra vars.
