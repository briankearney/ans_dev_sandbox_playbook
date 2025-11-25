# playbooks/

This directory contains example playbooks that consume roles and variables in this repo.

File of interest:
- `sample_playbook.yml` — applies the `ans_dev_sandbox_role` to hosts defined in `inventory/main.yml`.

Usage

```bash
# From repo root
source ACTIVATE_SANDBOX_ENV.bash
ansible-galaxy install -r roles/requirements.yml --roles-path roles
ansible-playbook -i inventory/main.yml playbooks/sample_playbook.yml
```

### Variable Precedence & Overrides

The playbook demonstrates overriding defaults supplied by the role or convenience `defaults/main.yml` in the repository root:

Order (simplified subset high → low):
1. Extra vars (`--extra-vars` / `-e`)
2. Play vars (`vars:` block inside playbook)
3. Role vars (`vars/` inside role)
4. Role defaults (`defaults/` inside role)
5. Convenience defaults file here (`../defaults/main.yml`) only if explicitly loaded

Example overriding with extra vars:
```bash
ansible-playbook -i inventory/main.yml playbooks/sample_playbook.yml \
	-e repo_clone_depth=1 -e enable_cleanup=true
```

### Adding Vaulted Variables

If you introduce vaulted variables referenced by this playbook:
```bash
ansible-vault encrypt_string 'supersecret' --name 'vault_example_password' > encrypted.txt
```
Then include the encrypted block in a vars file and decrypt for inspection with:
```bash
python3 DECRYPT_VAULTED_ITEMS.py --file path/to/vars.yml --vault-id dev
```

### Role Installation

The role is fetched via `roles/requirements.yml`:
```bash
ansible-galaxy install -r roles/requirements.yml --roles-path roles --force
```
Re-run this if you update `requirements.yml` or want the latest upstream version.

### Extra Vars File Example

```bash
cat > custom_vars.yml <<'EOF'
repo_clone_depth: 1
enable_cleanup: true
EOF

ansible-playbook -i inventory/main.yml playbooks/sample_playbook.yml -e @custom_vars.yml
```

Customization
- Edit the `vars:` block in `sample_playbook.yml` to override defaults or provide example inputs to the role.
- Use extra vars (`-e`) or vars files to parameterize runs for CI.
- The playbook includes a `post_tasks` step to clean up temporary work created by the role (idempotence readiness).

### Troubleshooting

| Issue | Cause | Resolution |
|-------|-------|------------|
| Role tasks not found | Role not installed | Re-run `ansible-galaxy install ...` |
| Variable not overridden | Precedence misunderstanding | Use `-e` or ensure vars block contains updated value |
| Vault decrypt failure | Wrong vault id/password | Verify `vault-pw.txt` and vault block label |
| Idempotence changes | Task not declarative | Add `changed_when: false` or use module state parameters |

