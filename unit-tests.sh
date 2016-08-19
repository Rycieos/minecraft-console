#!/bin/bash

oneTimeSetUp() {
    set +o nounset
    startDir=$(pwd)
    cd "${startDir}"
    useDir="testDir"
    export CONFIG_FILE="${startDir}/config"
}

setUp() {
    profile="test"
    # This loads no config, just functions
    . console lib
}

tearDown() {
    cd "${startDir}"
    rm -rf "${useDir}" "/tmp/foo" "/tmp/bar"
}

# Tests

testCheckConfig() {
    check_config | grep -q 'default_time'
    assertTrue "Default time check failed" $?
    default_time=1

    player_list_path="/tmp/foo"
    check_config | grep -q 'player_list_path'
    assertTrue "Player list path location check failed" $?
    mkdir "${player_list_path}"

    check_config | grep -q 'type'
    assertTrue "Profile type check failed" $?
    type="minecraft"

    check_config | grep -q 'autostart'
    assertTrue "Profile autostart check failed" $?
    autostart="true"

    check_config | grep -q 'server_path'
    assertTrue "Profile server_path check failed" $?
    server_path="/tmp/bar"

    check_config | grep -q "server_path' that does not exist"
    assertTrue "Profile server_path existing check failed" $?
    mkdir "${server_path}"
    chmod 100 "${server_path}"

    check_config | grep -q "server_path' that is not readable"
    assertTrue "Profile server_path reading check failed" $?
    chmod 500 "${server_path}"

    check_config | grep -q "server_path' that is not writeable"
    assertTrue "Profile server_path writing check failed" $?
    chmod 700 "${server_path}"

    check_config | grep -q 'server_command'
    assertTrue "Profile server_command check failed" $?
    server_command="foo"

    check_config | grep -q 'updateable'
    assertTrue "Profile updateable check failed" $?
    updateable="true"
    check_config | grep -q 'updateable'
    assertTrue "Profile updateable check failed" $?
    updateable="vanilla"

    check_config strict | grep -q 'world'
    assertTrue "Profile world dir check failed" $?

}

testDefaults() {
    server_root="${startDir}"
    defaults
    assertEquals "Default server_path not set" "${startDir}/${profile}" ${server_path}
    assertEquals "Default java not set" 'java' ${java}
    assertEquals "Default time not set" 5 ${default_time}
}

testStart() {
    # Check server running check
    is_running() { return 0; }
    start >/dev/null 2>&1
    assertEquals "Start is_running failed" 7 $?
    is_running() { return 1; }

    # Check autorun check
    autostart="false"
    result=$(start auto)
    assertEquals "Autorun fail failed" 'The test server is not set to be autorun. Server not started' "${result}"

    # No server dir exists yet
    server_path="${useDir}"
    start >/dev/null 2>&1
    assertEquals "Start server path check failed" 12 $?
    cd "${startDir}"
    mkdir "${useDir}"

    # Test no file can't be exectuable
    jar_name="test.jar"
    start >/dev/null 2>&1
    assertEquals "Jar exectuable check failed" 13 $?
    cd "${startDir}"
    touch "${useDir}/test.jar"

    # Test server launch
    server_command="return 127"
    start debug >/dev/null 2>&1
    assertEquals "Server command run failed" 127 $?
    cd "${startDir}"

    # Test eula not existing
    assertFalse "eula.txt should not exist" '[ -e "${useDir}/eula.txt" ]'
    eula="true"

    # Test eula creation
    start debug >/dev/null 2>&1
    cd "${startDir}"
    assertTrue "eula.txt should exist" '[ -e "${useDir}/eula.txt" ]'
}

testStop() {
    # Check server running check
    is_running() { return 1; }
    stop >/dev/null 2>&1
    assertEquals "Stop is_running failed" 8 $?
}

if [ -e shunit2-2.0.3/src/shell/shunit2 ]; then
    . shunit2-2.0.3/src/shell/shunit2
else
    . shunit2
fi
