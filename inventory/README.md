# inventory/

This directory contains the sample inventory used by the example playbook.

File of interest:
- `main.yml` — a YAML inventory that defines `localhost` and a `local` group.

Current contents for quick reference:
```yaml
---
all:
	hosts:
		localhost:
			ansible_connection: local
			ansible_python_interpreter: auto_silent
	children:
		local:
			hosts:
				localhost:
```

Usage
- Run the sample playbook with this inventory:

```bash
ansible-playbook -i inventory/main.yml playbooks/sample_playbook.yml
```

Notes
- `ansible_connection: local` executes tasks on the control node (fast iteration, no SSH).
- `ansible_python_interpreter: auto_silent` defers interpreter selection to Ansible without noisy warnings.

Extending the inventory:
```yaml
all:
	hosts:
		localhost:
			ansible_connection: local
		myremote:
			ansible_host: 192.0.2.10
			ansible_user: devops
	children:
		local:
			hosts:
				localhost:
		sandbox:
			hosts:
				myremote:
```
Then target only remote hosts:
```bash
ansible-playbook -i inventory/main.yml playbooks/sample_playbook.yml -l sandbox
```

Troubleshooting:
| Issue | Cause | Resolution |
|-------|-------|------------|
| Python warning messages | Interpreter not auto-detected | Ensure `auto_silent` set or specify explicit path |
| Host unreachable | Network / SSH config | Verify host vars (`ansible_host`, user, keys) |
| Variable mismatch | Overlapping groups | Use `ansible-inventory --graph` to inspect structure |
