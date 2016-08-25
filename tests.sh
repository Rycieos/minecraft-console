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
  assert_contains "check_config" "'default_time' is not set"
  default_time=1

  player_list_path="/tmp/foo"
  assert_contains "check_config" "'player_list_path' does not exist"
  mkdir "${player_list_path}"

  assert_contains "check_config" "unsupported 'type'"
  type="minecraft"

  assert_contains "check_config" "unsupported 'autostart'"
  autostart="true"

  assert_contains "check_config" "blank 'server_path'"
  server_path="/tmp/bar"

  assert_contains "check_config" "'server_path' that does not exist"
  mkdir "${server_path}"
  chmod 100 "${server_path}"

  assert_contains "check_config" "'server_path' that is not readable"
  chmod 500 "${server_path}"

  assert_contains "check_config" "'server_path' that is not writeable"
  chmod 700 "${server_path}"

  assert_contains "check_config" "blank 'server_command'"
  server_command="foo"

  assert_contains "check_config" "unsupported 'updateable'"
  updateable="true"
  assert_contains "check_config" "unsupported 'updateable'"
  updateable="vanilla"

  world="testWorld"
  assert_contains "check_config strict" "'world' that does not exist"
  mkdir "${server_path}/${world}"
  assert_contains "check_config strict" "has blank 'jar_name'"
  unset world

  assert_contains "check_config strict" "has blank 'jar_name'"
  jar_search="foo.jar"

  assert_contains "check_config strict" "has no jar file matching"
  jar_name="foo.jar bar.jar"

  assert_contains "check_config strict" "has multiple files matching"
  jar_name="foo.jar"

  assert_contains "check_config strict" "'jar_name' that does not exist"
  touch "${server_path}/${jar_name}"
  chmod 100 "${server_path}/${jar_name}"

  assert_contains "check_config strict" "'jar_name' that is not readable"
  chmod 500 "${server_path}/${jar_name}"

  assert_contains "check_config strict" "'jar_name' that is not writeable"
  chmod 600 "${server_path}/${jar_name}"

  assert_raises "check_config strict"

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
  # Test server running check
  is_running() { return 0; }
  assert_raises "start" 7
  is_running() { return 1; }

  # Test autorun check
  autostart="false"
  assert_contains "start auto" 'The test server is not set to be autorun'

  # No server dir exists yet
  server_path="${useDir}"
  assert_raises "start" 12
  cd "${startDir}"
  mkdir "${useDir}"

  # Test no file can't be executable
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
  # Test server running check
  is_running() { return 1; }
  assert_raises "stop" 8

  assert_end stop
reset

# Backup
  # Test backup_path check
  assert_raises "backup" 15
  backup_path="/tmp/foo"

  # Test not running check
  is_running() { return 1; }
  assert_contains "backup" "server is not running"

  # Test force backup
  assert_contains "backup force" "Backing up the"

  # Test actual backup
  test_file="foo"
  is_running() { return 0; }
  rm -rf "${backup_path}"
  mkdir "${server_path}"
  touch "${server_path}/${test_file}"
  assert_contains "backup" "The backup path ${backup_path}"

  # Test backup copied file
  assert_exists "${backup_path}/current/${test_file}"

  assert_end backup
reset

# Restore
  # Test backup_path check
  unset backup_path
  assert_raises "restore" 15
  backup_path="/tmp/foo"

  # Test backup_path existing
  assert_contains "restore" "'backup_path' that does not exist"
  mkdir "${backup_path}"

  # Test date format check
  assert_contains "restore '1970-01-01 101010'" "Incorrect date format"

  # Test backup opening
  chmod 000 "${backup_path}"
  assert_raises "restore '1970-01-01 01:00:00'" 12

  assert_end restore
reset

# Say
  is_running() { return 1; }
  assert_raises "say" 8

  assert_end say
reset

# Command
  is_running() { return 1; }
  assert_raises "command" 8

  assert_end command
reset

# See
  is_running() { return 1; }
  assert_raises "see" 8

  assert_end see
reset

# Update
  # Test update setting check
  updateable="false"
  assert_raises "update" 19
  updateable="true"

  # Test update type check
  type="foobar"
  assert_raises "update"
  type="minecraft"

  assert_contains "update" "Unsupported type of Minecraft"

  # Test updated needed check
  jar_name="minecraft_server.1.0.jar"
  assert_contains "update 1.0" "server is up to date"

  assert_end update
reset

# List
  profile_list=("foo" "bar")
  assert_contains "list" "foo bar"

  assert_end list
reset
