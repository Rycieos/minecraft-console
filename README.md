# minecraft-console
Bash scripts for managing Minecraft servers.

These scripts can really manage any Java server, if they are configured correctly.

# Console

`console` manages the server's startup, shutdown, backups, and much more. It works as a manager, leaving the server running as the daemon. Everything is configured by running `console config`. It supports multiple servers, multiple worlds per server, and infinite backups. To change the world in a server, edit the world name in the config file, and have a separate server.properties file in each world folder.

**Backups**

To make backups regularly, add `console [profile] backup` to a cron job, like so:

`0 4 * * * cronic /home/mvndrstl/bin/console all backup`

cronic is a script meant to wrap cron jobs to make cron more sane. You can get it [here](http://habilis.net/cronic/).
`all` is a special keyword that runs the command (`backup`) for all configured profiles. It will only backup profiles configured to have a backup directory.

# Listener

`listener` will watch a log file, and perform actions based on what the server prints to the file. To use it, run something like:

`screen -dmS listener listener vanilla`

This will start it in background mode. To kill it, connect to the screen (`screen -r listener`) and Ctrl-C.

It adds many nifty features, such as:
* Sending players messages when they login.
* Recording the logout times of players to tell them on login when they were last online.
* Responding to hello's, and simple questions
* Following simple commands, complete with error messages.
* Logging all chat to log/chat.log to have a log file without all of the crap.

Commands such as:
* !info - list info about the server
* !help - list server commands
* !playerlist - print the whitelist
* !playerinfo [playername] - show the last logout time of playername
