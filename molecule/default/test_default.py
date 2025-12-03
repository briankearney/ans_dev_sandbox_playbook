"""
Testinfra tests for default Molecule scenario.

These tests verify the system state after the playbook execution,
providing more robust Python-based assertions compared to Ansible verify tasks.
"""

import pytest


# Use local backend for testinfra
@pytest.fixture
def host(request):
    """Return a testinfra host using local backend."""
    import testinfra
    return testinfra.get_host("local://")


def test_python_interpreter_available(host):
    """Verify Python interpreter is available and functional."""
    python_cmd = host.run("python3 --version")
    assert python_cmd.rc == 0, "Python3 should be available"
    assert "Python 3." in python_cmd.stdout, "Should be Python 3.x"


def test_ansible_is_functional(host):
    """Verify Ansible can execute basic operations."""
    # Test that we can run a simple Ansible ad-hoc command
    ping_result = host.run("ansible localhost -m ping -c local")
    assert ping_result.rc == 0, "Ansible ping should succeed"


def test_role_execution_artifacts(host):
    """Verify the role executed and left expected state."""
    # The role should have cloned to a fixed directory for idempotence testing
    # Check that the molecule test sandbox directory exists
    test_dir = host.file("/tmp/molecule_test_sandbox")
    assert test_dir.exists, "Test sandbox directory should exist"
    assert test_dir.is_directory, "Test sandbox should be a directory"
    
    # Verify the git repository was cloned successfully
    git_dir = host.file("/tmp/molecule_test_sandbox/.git")
    assert git_dir.exists, "Git repository should be cloned"
    assert git_dir.is_directory, ".git should be a directory"


def test_system_facts_gathering(host):
    """Verify system facts can be gathered successfully."""
    # Test that we can gather basic system information
    hostname = host.run("hostname")
    assert hostname.rc == 0, "Should be able to get hostname"
    assert len(hostname.stdout.strip()) > 0, "Hostname should not be empty"
    
    # Check we can detect OS family
    os_check = host.run("uname -s")
    assert os_check.rc == 0, "Should be able to detect OS"
    assert os_check.stdout.strip() in ["Linux", "Darwin"], "Should be Linux or Darwin"


def test_git_command_available(host):
    """Verify git is available (required by the role)."""
    git_cmd = host.run("git --version")
    assert git_cmd.rc == 0, "Git should be installed and available"
    assert "git version" in git_cmd.stdout, "Git version should be displayed"


@pytest.mark.parametrize("directory", ["/tmp", "/var/tmp"])
def test_temporary_directories_writable(host, directory):
    """Verify temporary directories are writable (role requirement)."""
    test_file = f"{directory}/testinfra_write_test"
    
    # Create a test file
    write_result = host.run(f"echo 'test' > {test_file}")
    assert write_result.rc == 0, f"{directory} should be writable"
    
    # Verify file exists and cleanup
    host.run(f"rm -f {test_file}")


def test_python_yaml_module_available(host):
    """Verify Python YAML module is available (used by Ansible)."""
    yaml_check = host.run("python3 -c 'import yaml; print(yaml.__version__)'")
    assert yaml_check.rc == 0, "PyYAML should be installed"
    assert len(yaml_check.stdout.strip()) > 0, "YAML version should be returned"
