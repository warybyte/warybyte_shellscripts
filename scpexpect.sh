#!/usr/bin/expect -f

set timeout -1

spawn /usr/bin/scp disk_secret_key youruser@ec2-20-20-20-20.us-east-2.compute.amazonaws.com:/home/youruser

expect "Passcode or option (1-3):"
send -- "1\r"
expect eof
