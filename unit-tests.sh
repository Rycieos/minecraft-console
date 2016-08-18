#!/bin/bash

oneTimeSetUp() {
    set +o nounset
    startDir="`pwd`"
    useDir="testDir"
}

setUp() {
    profile="test"
    . console lib
}

tearDown() {
    cd "$startDir"
    rm -rf "$useDir"
}

# Tests

testDefaults() {
    server_root="/tmp/testy"
    defaults
    assertEquals "Default server_path not set" '/tmp/testy/test' $server_path
    assertEquals "Default java not set" 'java' $java
    assertEquals "Default time not set" 5 $default_time
}

testStart() {
    # Check server running check
    is_running() { return 0; }
    start >/dev/null 2>&1
    assertEquals "Start is_running failed" 7 $?

    # Check autorun check
    is_running() { return 1; }
    autostart="false"
    result=`start auto`
    assertEquals "Autorun fail failed" 'The test server is not set to be autorun. Server not started' "$result"

    # No server dir exists yet
    server_path="$useDir"
    start >/dev/null 2>&1
    assertEquals "Start server path check failed" 12 $?

    cd "$startDir"
    mkdir "$useDir"

    # Test no file can't be exectuable
    jar_name="test.jar"
    start >/dev/null 2>&1
    assertEquals "Jar exectuable check failed" 13 $?

    cd "$startDir"
    touch "$useDir/test.jar"

    # Test server launch
    server_command="return 127"
    start debug >/dev/null 2>&1
    assertEquals "Server command run failed" 127 $?

    cd "$startDir"

    # Test eula creation
    assertFalse "eula.txt should not exist" '[ -e "$useDir/eula.txt" ]'

    eula="true"
    start debug >/dev/null 2>&1
    cd "$startDir"

    assertTrue "eula.txt should exist" '[ -e "$useDir/eula.txt" ]'
}


if [ -x shunit2-2.0.3/src/shell/shunit2 ]; then
    . shunit2-2.0.3/src/shell/shunit2
else
    . shunit2
fi
