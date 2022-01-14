#!/bin/bash
# automate the push of your SSH keys
# Assumes you have 'expect' installed and have the targets saved in your 'known_hosts'...otherwise you'll need to add another expect-send combo.
/usr/bin/expect <<EOL
spawn ssh-copy-id $1
expect '*?assword*'
send '<YOURPASSWORD>'
interact
EOL
