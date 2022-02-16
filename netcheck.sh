#!/bin/bash
# Quick checkup on my DNS resolution, critcal system access, and internet access. Adjust accordingly :)
# Why? If I thought this was useful once, it could be useful again to me or to someone else...especially at scale.
RED='\033[0;31m';
GREEN='\033[1;32m';
NC='\033[0m'; # No Color
PRIMEDNS=8.8.8.8;
PRIMEWEB=warybyte.com;
clear;
dig @$PRIMEDNS $PRIMEWEB &>/dev/null && printf "Prime DNS ${GREEN}OK${NC}\n" || printf "Prime DNS ${RED}ERROR${NC}\n";
nc -z $PRIMEWEB 443 &>/dev/null && printf "$PRIMEWEB ${GREEN}OK${NC}\n" || printf "$PRIMEWEB ${RED}ERROR${NC}\n";
nc -z warybyte.com 443 &>/dev/null && printf "Internet ${GREEN}OK${NC}\n" || printf "Internet ${RED}ERROR${NC}\n";
