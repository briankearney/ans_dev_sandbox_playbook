#!/bin/bash

# Test harness with temporary file for cross-subshell communication
TEST_RESULTS=$(mktemp)
TEST_COUNT=0
FAIL_COUNT=0

assert_equals() {
    local expected="$1"
    local actual="$2"
    local message="${3:-}"
    if [[ "$expected" == "$actual" ]]; then
        echo "PASS: $message"
        echo "PASS" >> "$TEST_RESULTS"
    else
        echo "FAIL: $message"
        echo "  Expected: '$expected'"
        echo "  Actual:   '$actual'"
        echo "FAIL" >> "$TEST_RESULTS"
    fi
}

# Setup
TEST_DIR=$(mktemp -d)
ORIGINAL_DIR=$(pwd)
SCRIPT_PATH="$(pwd)/ACTIVATE_SANDBOX_ENV.bash"

cleanup() {
    rm -rf "$TEST_DIR"
    rm -f "$TEST_RESULTS"
}
trap cleanup EXIT

# Test 1: select_python logic
echo "Running Test 1: select_python logic"
(
    # Source the script with UNIT_TESTING set
    export UNIT_TESTING=true
    export TEST_RESULTS
    
    source "$SCRIPT_PATH"
    
    # Test select_python with valid input (Python 3.14 should be selected, NOT 3.15)
    # The script excludes Python >= 3.15.0
    input="
/usr/bin/python3.15:3.15.0
    /usr/bin/python3.14:3.14.2
/usr/bin/python3.12:3.12.0
/usr/bin/python3.11:3.11.5
"
    result=$(echo "$input" | select_python)
    assert_equals "/usr/bin/python3.14" "$result" "Select newest python < 3.15 (excludes 3.15+)"

    # Test with only Python < 3.15
    input="
/usr/bin/python3.12:3.12.5
/usr/bin/python3.11:3.11.0
/usr/bin/python3.10:3.10.12
"
    result=$(echo "$input" | select_python)
    assert_equals "/usr/bin/python3.12" "$result" "Select newest from valid candidates"

    # Test with Python >= 3.15 (should be ignored; 3.14 allowed)
    input="
/usr/bin/python3.14:3.14.0
/usr/bin/python3.15:3.15.1
/usr/bin/python3.12:3.12.0
"
    result=$(echo "$input" | select_python)
    assert_equals "/usr/bin/python3.14" "$result" "Ignore python >= 3.15"

    # Test with invalid input
    input="
invalid
"
    result=$(echo "$input" | select_python)
    # Should fail (exit 2)
    if [[ $? -ne 0 ]]; then
         echo "PASS: Handle invalid input"
         echo "PASS" >> "$TEST_RESULTS"
    else
         echo "FAIL: Should have failed on invalid input"
         echo "FAIL" >> "$TEST_RESULTS"
    fi
)

# Test 2: get_script_dir
echo "Running Test 2: get_script_dir logic"
(
    export UNIT_TESTING=true
    export TEST_RESULTS
    source "$SCRIPT_PATH"
    
    # Verify PLAYBOOK_PATH is set to the directory of the script
    # Since we sourced it using absolute path, it should resolve correctly.
    expected_dir=$(dirname "$SCRIPT_PATH")
    assert_equals "$expected_dir" "$PLAYBOOK_PATH" "PLAYBOOK_PATH set correctly"
)

# Summary
echo "------------------------------------------------"

# Count results from the temporary file
while IFS= read -r result; do
    TEST_COUNT=$((TEST_COUNT + 1))
    [[ "$result" == "FAIL" ]] && FAIL_COUNT=$((FAIL_COUNT + 1))
done < "$TEST_RESULTS"

echo "Tests run: $TEST_COUNT"
echo "Failures:  $FAIL_COUNT"

if [[ $FAIL_COUNT -eq 0 ]]; then
    echo "ALL TESTS PASSED"
    exit 0
else
    echo "SOME TESTS FAILED"
    exit 1
fi
