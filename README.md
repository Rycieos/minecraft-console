# minecraft-console
Bash scripts for managing Minecraft servers.

[![Build Status](https://travis-ci.org/Rycieos/minecraft-console.svg?branch=master)](https://travis-ci.org/Rycieos/minecraft-console)

## Unmaintained
I no longer have enough interest in Minecraft to keep this program up to date with Mojang's constant API changes. I have fixed all simple issues, and everything works on 1.14. But while checking for updates works, downloading an update does not, thanks to Mojang making the download locations complicated. This whole project should have been rewritten in Python a long time ago, and that is probably the only way to parse all the JSON needed to find the new download links.

## Console

`console` manages the server's startup, shutdown, backups, and much more. It works as a manager, leaving the server running as the daemon. It is designed to copy the syntax of init systems like init.d or systemd.

Everything is configured by running `console config`. It supports multiple servers, multiple worlds (maps) per server, and infinite backups.

Syntax: `console [command] [profile]`

`all` is a special profile keyword that runs the command for all configured profiles.

### start
Start the specified profile. Will report if the server fails to start.

### stop
Stop the specified profile. Will report if the server refuses to close. Will issue a warning to online players before closing the server, and wait for `default_time`, unless a time is specified.

### restart
Restart the specified profile. If the profile is not running, it will be started. Will issue a warning and wait like `stop`.

### try-restart
Restarts the specified profile, if it is running. If it not, it will do nothing. Will issue a warning and wait like `stop`.

### status
Prints the status of the specified profile, if it is running or not.

### backup
Uses `rsync` to backup the server. Handles the server running while backing up. It uses the diff backup feature of `rsync` to save space. Best used in a cron job or similar.

### restore
Uses `rsync` to restore a previous backup. It takes a datetime in the "YYYY-MM-DD HH:MM:SS" format to search from. It will select the closest backup older than that date to restore. Note that it will completely erase the current server state, so if you are not sure that you want to lose it, make a backup first.

### say
Sends a message to the server that is printed to all online uses. This is designed to be used in automatic scripts. To talk to users directly, it would be better to use `see`.

### command
Sends a command to the server. This is designed to be used in automatic scripts. To use many commands or see their output, it would be better to use `see`.

### update
Updates the version of Minecraft installed in the specified profile. It downloads the jar files from Mojang using their interface to figure out what is the latest version. Optionally, a version can be specified after the profile to update to that specific version. Will correctly handle running servers and also backup the server before updating.

### see
Creates an interface to chat and send commands to the server. The server can be connected to directly with `screen -r profile-name`, but this can cause problems if there are automatic scripts running using the `say` or `command` commands to control the server, since they use same text buffer. Using the `see` command removes the problem, as well as adding helpful shortcuts to controlling the server.

### shell
Used by the `see` command for its command line. It can be used by itself if wanted to make many commands in a row easier to use.
Commands:
* `c|command`   runs the command on the server. Also puts the shell into command mode.
* `s|say`       sends the text as text to players
* `nick`        sets the nickname for showing when text is sent to players
* `help`        display a quick list of commands
* `exit`        exits the shell/console

### listener-start
Will start the listener for the profile. Can be done automaticly if set in the config.

### listener-stop
Will stop the listener for the profile. Same as above.

### listener-restart
Restarts the listener for the profile. Good for loading new config changes.

### list
Lists the profiles that are configured

### config
Opens the config file for editing. After editing, it will check the config for errors and notify for any it finds.

### new
Adds a default profile to the config file. Takes a type argument for further customization.

### help
Displays a quick help text.


## Config
General config options (all are optional besides profile_list):
* `default_time`      the default time that stop will wait before closing the server
* `server_root`       the default root path where the servers are stored.
* `player_list_path`  the path where the minecraft files are stored for sharing with every server. If not specified, each server will use their own lists.
* `eula`              if true, console will set each server's eula to true to save time.
* `java`              the java command to use to launch the servers. Useful if you have a specific version of java for Minecraft.
* `profile_list`      the list of profiles used when `all` is specified instead of of profile name. If a profile is not in this list, it will work normally, but it will not be part of `all` nor scanned for config errors.

Profile specific:
* `type`              the type of server. Right now, only minecraft is supported.
* `autostart`         if the server should be started when `console start all` is run. This allows profiles to be configured without needing to run automatically.
* `server_path`       the location of the server directory. Where the server files are saved. If not specified, will default to `server_root/profile_name`.
* `backup_path`       the location of the backup directory. If not specified, backups will be disabled for that profile.
* `world`             the name of the world directory. This allows multiple worlds (maps) to be used per profile. Put a different server.properties file in each world directory, then change this `world` option to select the different world to use. If left empty, console will not copy or change the server.properties file.
* `jar_name`          the jar file to run for the profile. It accepts * wildcards for searching for a jar file. This allows for updating without changing the config.
* `server_command`    the command to run when starting the server. Probably want to have `${java}` at the beginning and `${jar_name}` after the -jar flag.
* `updateable`        the type of server if updating is wanted, false otherwise. This is used to discover what version to update the profile.
* `listener`          if the listener for the profile should be started when the server is started. Defaults to false.
* `login_message`     the message that the listener will print to a player when they login to the server. Defaults to empty.
* `info_text`         the array of strings that the listener will print to a player when they say `!info` in game. Defaults to empty.

## Error Codes
* 1:    No parameters specified
* 2:    Incorrect parameters specified
* 3:    Missing/incorrect profile config option
* 4:    Missing profile
* 5:    Missing config file
* 6:    Invalid command with profile "all"
* 7:    Profile already running
* 8:    Profile not running
* 9:    Profile failed to start
* 10:   Profile failed to shutdown
* 11:   Directory failed to be created
* 12:   Directory failed to be opened
* 13:   Jar failed to be set executable
* 14:   Backup failed
* 15:   Backups disabled for profile
* 16:   Restore failed
* 17:   No older backup found to restore
* 18:   Update failed
* 19:   Profile not set to be updated
* 20:   External program error
* 21:   Script run as root
* 22:   Missing dependency

## Listener

`minecraft-listener` will watch a log file, and perform actions based on what the server prints to the file.

It adds many nifty features, such as:
* Sending players messages when they login.
* Recording the logout times of players to tell them on login when they were last online.
* Responding to hello's, and simple questions
* Following simple commands, complete with error messages.
* Logging all chat to log/chat.log to have a log file without all of the crap.

Commands:
* !info - list customized info about the server
* !help - list server commands
* !playerlist - print the whitelist
* !playerinfo [playername] - show the last logout time of playername
