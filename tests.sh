#!/bin/bash

. assert.sh

# Setup
set +o nounset
startDir=$(pwd)
cd "${startDir}"
useDir="testDir"
export CONFIG_FILE="${startDir}/config"

reset() {
    cd "${startDir}"
    rm -rf "${useDir}" "/tmp/foo" "/tmp/bar"

    profile="test"
    # This loads no config, just functions
    . console lib
}

# Tests
reset

# Check config
  check_config | grep -q 'default_time'
  assert_raises "" $?
  default_time=1

  player_list_path="/tmp/foo"
  assert_raises "check_config | grep -q 'player_list_path'"
  mkdir "${player_list_path}"

  assert_raises "check_config | grep -q 'type'"
  type="minecraft"

  assert_raises "check_config | grep -q 'autostart'"
  autostart="true"

  assert_raises "check_config | grep -q 'server_path'"
  server_path="/tmp/bar"

  assert_raises "check_config | grep -q 'that does not exist'"
  mkdir "${server_path}"
  chmod 100 "${server_path}"

  assert_raises "check_config | grep -q 'that is not readable'"
  chmod 500 "${server_path}"

  assert_raises "check_config | grep -q 'that is not writeable'"
  chmod 700 "${server_path}"

  assert_raises "check_config | grep -q 'server_command'"
  server_command="foo"

  assert_raises "check_config | grep -q 'updateable'"
  updateable="true"
  assert_raises "check_config | grep -q 'updateable'"
  updateable="vanilla"

  #assert_raises "check_config strict | grep -q 'world'"

  assert_end config
reset

# Defaults
  server_root="${startDir}"
  defaults
  assert_equals "${startDir}/${profile}" ${server_path}
  assert_equals 'java' ${java}
  assert_equals 5 ${default_time}

  assert_end defaults
reset

# Start
  # Check server running check
  is_running() { return 0; }
  assert_raises "start" 7
  is_running() { return 1; }

  # Check autorun check
  autostart="false"
  assert "start auto" 'The test server is not set to be autorun. Server not started'

  # No server dir exists yet
  server_path="${useDir}"
  assert_raises "start" 12
  cd "${startDir}"
  mkdir "${useDir}"

  # Test no file can't be exectuable
  jar_name="test.jar"
  assert_raises "start" 13
  cd "${startDir}"
  touch "${useDir}/test.jar"

  # Test server launch
  server_command="return 127"
  assert_raises "start debug" 127
  cd "${startDir}"

  # Test eula not existing
  assert_raises '[ ! -e "${useDir}/eula.txt" ]'
  eula="true"

  # Test eula creation
  start debug >/dev/null 2>&1
  cd "${startDir}"
  assert_raises '[ -e "${useDir}/eula.txt" ]'

  assert_end start
reset

# Stop
  # Check server running check
  is_running() { return 1; }
  assert_raises "stop" 8

  assert_end stop
reset

