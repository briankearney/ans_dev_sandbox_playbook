# Tests

Unit tests for the project's helper scripts and automation tools.

This directory contains comprehensive test suites for verifying the functionality of both Bash scripts and Python utilities used in this repository.

## Test Overview

### Bash Script Tests
- **`test_activate_sandbox_env.bash`** - Tests for `ACTIVATE_SANDBOX_ENV.bash`
- **`test_run_playbook.bash`** - Tests for `RUN_PLAYBOOK.bash`

### Python Unit Tests
- **`test_DECRYPT_VAULTED_ITEMS.py`** - Unit tests for `DECRYPT_VAULTED_ITEMS.py`

## Running Tests

### Bash Script Tests

Run from the repository root:

```bash
# Test the environment activation script
bash tests/test_activate_sandbox_env.bash

# Test the playbook runner script
bash tests/test_run_playbook.bash
```

### Python Unit Tests

Run from the repository root:

```bash
# Run all Python unit tests
python3 -m unittest test_DECRYPT_VAULTED_ITEMS.py

# Run with verbose output
python3 -m unittest -v test_DECRYPT_VAULTED_ITEMS.py

# Run specific test class
python3 -m unittest test_DECRYPT_VAULTED_ITEMS.TestDecryptVaultedItems

# Run specific test method
python3 -m unittest test_DECRYPT_VAULTED_ITEMS.TestDecryptVaultedItems.test_extract_vault_content_success
```

## CI/CD Integration

All unit tests run automatically via GitHub Actions on every push and pull request to `main` and `develop` branches.

### GitHub Actions Workflow

**File**: [`.github/workflows/unit-tests.yml`](../.github/workflows/unit-tests.yml)

**Triggers**:
- Push to `main` or `develop` branches
- Pull requests to `main` or `develop`
- Manual workflow dispatch

**Matrix Testing**:
- Python versions: 3.9, 3.10, 3.11, 3.12
- All tests run across all Python versions

**Jobs**:
1. **bash-tests**: Runs both Bash script tests (`test_activate_sandbox_env.bash`, `test_run_playbook.bash`)
2. **python-tests**: Runs Python unit tests (`test_DECRYPT_VAULTED_ITEMS.py`) with verbose output
3. **test-summary**: Aggregates results from both jobs

**Artifacts**: Test logs are uploaded on failure and retained for 7 days for debugging.

**Viewing Results**:
- Check the [Actions tab](https://github.com/briankearney/ans_dev_sandbox_playbook/actions) in the repository
- View the status badges in the main [README.md](../README.md)
- Review workflow runs for detailed test output and logs


## Test Details

### `test_activate_sandbox_env.bash`

Tests the Python virtual environment activation script.

**What it tests:**
- **Python Version Selection**: Verifies the script correctly identifies and selects the newest Python version < 3.14
- **Directory Resolution**: Ensures `get_script_dir` correctly resolves the script's location even when sourced from different directories

**Framework:** Custom Bash-based assertion functions (`assert_equals`)

**Notes:**
- Uses `UNIT_TESTING` environment variable to source the script without executing side effects
- Output shows "ALL TESTS PASSED" on success

### `test_run_playbook.bash`

Tests the Ansible playbook runner wrapper script.

**What it tests:**
- **Argument Parsing**: Verifies correct handling of command-line arguments
- **Playbook Execution**: Tests the playbook running logic
- **Error Handling**: Ensures proper error messages and exit codes

**Framework:** Custom Bash-based testing harness

### `test_DECRYPT_VAULTED_ITEMS.py`

Comprehensive unit tests for the Ansible vault decryption utility using Python's `unittest` framework.

**Test Coverage (10 test cases):**

#### `extract_vault_content` Function
1. **`test_extract_vault_content_success`** - Verifies successful extraction of vault content from YAML files with proper indentation handling
2. **`test_extract_vault_content_id_not_found`** - Ensures `ValueError` is raised when vault ID is not found
3. **`test_extract_vault_content_file_not_found`** - Ensures `FileNotFoundError` is raised for missing files

#### `decrypt_vault` Function
4. **`test_decrypt_vault_success`** - Mocks `subprocess.run` to test successful ansible-vault decryption
5. **`test_decrypt_vault_failure`** - Tests error handling when decryption fails

#### `attempt_base64_decode` Function
6. **`test_attempt_base64_decode_valid`** - Tests decoding valid base64 encoded data
7. **`test_attempt_base64_decode_invalid`** - Tests handling of non-base64 data
8. **`test_attempt_base64_decode_bytes`** - Tests handling of bytes input

#### `format_output` Function
9. **`test_format_output_no_color`** - Tests YAML output without syntax highlighting
10. **`test_format_output_color`** - Tests YAML output with pygments syntax highlighting

**Key Features:**
- **Mocking Strategy**: Uses `unittest.mock` to mock external dependencies (`subprocess.run`, `pygments`)
- **Dependency Handling**: Automatically mocks `pygments` if not installed
- **Temporary Files**: Uses `tempfile` for creating test YAML files
- **Comprehensive Coverage**: Tests both success and failure scenarios

**Prerequisites:**
- Python 3.x
- `unittest` (standard library)
- `PyYAML` (for YAML parsing)
- `pygments` (optional - will be mocked if not available)

## Test Framework Details

### Bash Tests
- **Framework**: Custom lightweight assertion functions
- **Portability**: No external dependencies required
- **Isolation**: Uses environment variables to prevent side effects

### Python Tests
- **Framework**: Python's built-in `unittest`
- **Mocking**: Uses `unittest.mock` for external dependencies
- **Isolation**: Creates temporary directories for file-based tests
- **Cleanup**: Automatic cleanup via `setUp`/`tearDown` methods

## Prerequisites

### For Bash Tests
- Bash (standard on most Linux/macOS systems)
- Python 3 (for testing Python selection logic)

### For Python Tests
- Python 3.x
- Standard library modules: `unittest`, `tempfile`, `base64`, `subprocess`
- Project dependencies: `PyYAML`
- Optional: `pygments` (will be mocked if unavailable)

## Notes

- All tests are designed to run without modifying the system or creating persistent side effects
- Bash tests use `UNIT_TESTING` environment variable to prevent script execution during sourcing
- Python tests automatically clean up temporary files and directories
- Tests can be run individually or as a complete suite
- Exit codes: 0 = success, non-zero = failure
