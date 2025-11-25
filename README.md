# ans_dev_sandbox_playbook

[![Molecule Tests](https://github.com/briankearney/ans_dev_sandbox_playbook/actions/workflows/molecule.yml/badge.svg)](https://github.com/briankearney/ans_dev_sandbox_playbook/actions/workflows/molecule.yml)
[![Unit Tests](https://github.com/briankearney/ans_dev_sandbox_playbook/actions/workflows/unit-tests.yml/badge.svg)](https://github.com/briankearney/ans_dev_sandbox_playbook/actions/workflows/unit-tests.yml)

Ansible Playbook Sandbox

## Overview

An Ansible playbook sandbox that demonstrates running a GitHub-hosted role locally against `localhost`.

This repository is intentionally small and aims to provide a convenience environment for developing and testing the
`briankearney/ans_dev_sandbox_role` role. It emphasizes an enterprise-safe configuration style (environment variables over `ansible.cfg`), reproducible local testing (Molecule + unit tests), and secure vaulted variable handling.

**Quick Overview**
- **Playbook:** `playbooks/sample_playbook.yml`
- **Inventory:** `inventory/main.yml` (`local` group with `localhost`)
- **Role requirements:** `roles/requirements.yml` (used by `ansible-galaxy` to fetch the role)
- **Helper scripts:** `ACTIVATE_SANDBOX_ENV.bash`, `RUN_PLAYBOOK.bash`, `DECRYPT_VAULTED_ITEMS.py`
- **Testing:** Molecule scenarios (`molecule/`) + Bash & Python unit tests (`tests/`)
- **Linting configs:** `.ansible-lint`, `.yamllint`
- **Optional container workflow:** `containerfile` (build a reproducible image if desired)

## Design Philosophy

**Why No `ansible.cfg`?**

This repository intentionally does **not** include an `ansible.cfg` file. In enterprise environments (Fortune 100 companies, government agencies, etc.), configuration files like `ansible.cfg` are often prohibited by security policies due to concerns about:
- Unauthorized configuration changes
- Security policy bypasses
- Audit trail gaps
- Configuration drift across teams

**Environment Variable Approach**

Instead, this repository uses **environment variables** set by `ACTIVATE_SANDBOX_ENV.bash` to configure Ansible behavior. Example subset (actual script may export more):

```bash
export ANSIBLE_ROLES_PATH=roles
# (Plugins/library directories are optional; create `plugins/` or `library/` if you add custom content.)
export ANSIBLE_VAULT_PASSWORD_FILE="$PLAYBOOK_PATH/vault-pw.txt"
# ... and more
```

This approach provides:
- ✅ **Enterprise compatibility** - Works in environments that prohibit `ansible.cfg`
- ✅ **Explicit configuration** - All settings visible in one script
- ✅ **Session isolation** - Settings only apply to the current shell session
- ✅ **Easy auditing** - Configuration changes tracked in version control
- ✅ **No side effects** - Doesn't modify global Ansible behavior

**Note:** The `.gitignore` file explicitly excludes `ansible.cfg` to prevent accidental commits that could cause issues in enterprise environments.

**Prerequisites**
- Ansible (recommended: recent ansible-core >= 2.14)
- Python 3.10+ (matrix tests run 3.10–3.12)
- Optional: Docker/Podman (to use `containerfile`)
- Python dependencies (`requirements.txt`)

## Quick Commands

From repository root after cloning:

```bash
source ACTIVATE_SANDBOX_ENV.bash               # set env vars & create .venv
ansible-galaxy install -r roles/requirements.yml --roles-path roles
ansible-playbook -i inventory/main.yml playbooks/sample_playbook.yml

# Run all unit tests
bash tests/test_activate_sandbox_env.bash && \
  bash tests/test_run_playbook.bash && \
  python3 -m unittest -v test_DECRYPT_VAULTED_ITEMS.py

# Run Molecule default scenario
molecule test -s default

# Lint (Molecule >=25 removed built‑in lint stage)
yamllint . && ansible-lint playbooks/ molecule/
```

Quickstart (from repository root):

```bash
# Activate the sandbox environment using the helper script
source ACTIVATE_SANDBOX_ENV.bash

# Install the role into ./roles using the requirements file
ansible-galaxy install -r roles/requirements.yml --roles-path ./roles

# Run the sample playbook against the sample inventory
ansible-playbook -i inventory/main.yml playbooks/sample_playbook.yml
```

Alternate helper (wrapper):

```bash
# Make the wrapper executable then run it
chmod +x RUN_PLAYBOOK.bash
./RUN_PLAYBOOK.bash
```

**Python Dependencies:**

All Python dependencies are defined in `requirements.txt`. The `ACTIVATE_SANDBOX_ENV.bash` script automatically creates a virtual environment and installs these dependencies. You can also install them manually:

```bash
pip install -r requirements.txt
```

Testing:

This repository includes comprehensive unit tests for both helper scripts and Python utilities to ensure reliability. The tests are located in the `tests/` directory and run automatically via GitHub Actions on every push and pull request. See `tests/README.md` for detailed usage.

**Automated CI/CD:**
- All unit tests run automatically via GitHub Actions (see badges above)
- Matrix testing across Python 3.10, 3.11, and 3.12
- Test results visible in the [Actions tab](https://github.com/briankearney/ans_dev_sandbox_playbook/actions)

**Bash Script Tests:**

```bash
# Run unit tests for ACTIVATE_SANDBOX_ENV.bash
bash tests/test_activate_sandbox_env.bash

# Run unit tests for RUN_PLAYBOOK.bash
bash tests/test_run_playbook.bash
```

**Python Unit Tests:**

```bash
# Run unit tests for DECRYPT_VAULTED_ITEMS.py
python3 -m unittest test_DECRYPT_VAULTED_ITEMS.py

# Run with verbose output
python3 -m unittest -v test_DECRYPT_VAULTED_ITEMS.py
```

The tests verify:
- **Bash Scripts**:
  - **Python Version Selection**: Ensures the script correctly identifies and selects the newest Python version less than 3.14
  - **Directory Resolution**: Verifies that the script correctly resolves its own directory, even when sourced from other locations
  - **Playbook Execution**: Tests the playbook runner wrapper functionality

- **Python Utilities** (`DECRYPT_VAULTED_ITEMS.py`):
  - **Vault Content Extraction**: Tests extraction of vault content from YAML files with proper error handling
  - **Vault Decryption**: Mocks ansible-vault decryption for both success and failure scenarios
  - **Base64 Decoding**: Tests base64 decoding functionality with various input types
  - **Output Formatting**: Tests YAML output with and without syntax highlighting

**Molecule Tests (Ansible Playbook Testing):**

This repository includes comprehensive Molecule testing infrastructure for validating the Ansible playbook and role. Molecule tests are located in the `molecule/` directory.

```bash
# Activate sandbox environment
source ACTIVATE_SANDBOX_ENV.bash

# Run all Molecule tests (default scenario)
molecule test

# Run specific scenarios
molecule test -s localhost-only    # Test localhost connection
molecule test -s with-linting      # Syntax + converge only (lint run separately)

# Run linting separately (Molecule >=25 removed the built-in `lint` command)
yamllint .
ansible-lint playbooks/ molecule/
```

**Molecule Test Scenarios:**
- **default**: Full test sequence with idempotence checking
- **localhost-only**: Validates localhost connection configuration
- **with-linting**: Uses current Molecule without integrated lint stage; run `yamllint .` and `ansible-lint playbooks/ molecule/` manually.

**CI/CD Integration:**
- GitHub Actions workflow runs all Molecule scenarios on push/PR
- Matrix testing across Python 3.10, 3.11, and 3.12
- Automated linting validation

For detailed Molecule testing documentation, see `molecule/README.md`.
For detailed test documentation, see `tests/README.md`.

## Vault Decryption Utility

`DECRYPT_VAULTED_ITEMS.py` assists with inspecting encrypted variable blocks.

Usage examples:
```bash
# Extract and decrypt a vaulted block by vault id label
python3 DECRYPT_VAULTED_ITEMS.py --file path/to/vars.yml --vault-id dev

# Attempt base64 decode on decrypted content
python3 DECRYPT_VAULTED_ITEMS.py --file path/to/vars.yml --vault-id dev --decode

# Disable colorized output
python3 DECRYPT_VAULTED_ITEMS.py --file path/to/vars.yml --vault-id dev --no-color
```
Features:
- Graceful errors for missing files / vault id
- Optional base64 decoding
- Colorized YAML (pygments) unless `--no-color` passed

## Notes
- Vaulted variables: use the helper script instead of manually copying cipher text.
- Modify example variables in `defaults/main.yml` or in the `vars:` block of `playbooks/sample_playbook.yml`.
- The `defaults/` directory here is a convenience—not a role `defaults/`. Include it explicitly via `vars_files` if needed.

Files and directories
- `defaults/` : convenience defaults (not auto-loaded like role defaults)
- `inventory/` : sample inventory
- `playbooks/` : sample playbook(s) invoking the role
- `roles/requirements.yml` : role source list for `ansible-galaxy`
- `molecule/` : Molecule test scenarios
- `tests/` : unit tests
- `.ansible-lint`, `.yamllint` : lint configuration
- `containerfile` : optional container build file
- `ssh_keys/` : test-only SSH key material (see Security section)


## Troubleshooting

| Symptom | Likely Cause | Action |
|---------|--------------|--------|
| `molecule: command not found` | Virtual environment not activated | `source ACTIVATE_SANDBOX_ENV.bash` then retry |
| Lint failures | Style / best practice issues | Run `yamllint .` and `ansible-lint playbooks/ molecule/` and fix output |
| Idempotence fails | Task changes on second run | Add proper `changed_when` or ensure task state is declarative |
| Vault decrypt error | Wrong vault id or password file | Confirm `vault-pw.txt` contents and vault id label |
| Python version selection unexpected | Old interpreter first in PATH | Ensure newer Python (>=3.10) installed or adjust PATH |

## Security & Compliance
- No `ansible.cfg` to align with enterprises that restrict local config overrides.
- Test SSH keys in `ssh_keys/` are for local sandbox only; DO NOT reuse in production.
- Vault password file (`vault-pw.txt`) is demo-level only; rotate and secure in real environments.
- Environment variables are session-bound, reducing persistent configuration risk.

## Contributing
1. Fork & branch.
2. Make focused changes (docs, tests, role logic).
3. Run lint + unit + Molecule tests locally.
4. Open a PR with summary of changes.

---
If you’d like further documentation enhancements, open an issue or PR.
