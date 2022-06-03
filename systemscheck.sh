#!/bin/bash
#
####### Description: 
# envcheck.sh is an indepth ad-hoc scanner for various pieces of the infrastructure. Hosts and applications are described as well as probed for system 
# status to quickly identify environment health issues or validate systems are up. 
#
####### Instructions: 
# The script is to be run from an Engineers workstation, VM, or VDI which has access to all the respective systems. Many connection are made over SSH, 
# so there is an assumption the user has their public keys already pushed to the systems. If not, please do so. Below is how in OpenSSH:
#
#     ssh-copy-id $servername
# 
# When prompted, type in password for the exchange. If all goes well you're keys should now be shared.
#
####### Output:
# The resulting output is color coded for readability, however this makes the output tricky to write to a file. I suggest simply cutting and pasting 
# the results to a text file if you need to have a CSV.
#
# There are a large number of student system apps that are probed, so a secondary report is generated to ease the processing. You'll see a prompt
# at the end to save this report. If you don't, it will be automatically deleted.
#######
#
RED='\033[0;31m';
GREEN='\033[1;32m';
BLUE='\033[1;34m';
NC='\033[0m'; # No Color
clear;
# ------------------------------------------------------
# ----------------- System sets ------------------------
# ------------------------------------------------------
INET="
   google.com
   warybyte.com
";

INTDNS="
   ns-int1.warylab.lcl
";

EXTDNS="
   8.8.8.8
   9.9.9.9
";

CUPS="
    cups.warylab.lcl
";

DEVLSYSPROXY="
   dproxy.warylab.lcl
";

QUALSYSPROXY="
   qproxy.warylab.lcl
";
PRODSYSPROXY="
   pproxy.warylab.lcl
";

PRODCAS="
   cas.warylab.lcl
";

STUDENTSERVICE="
   studentService
";
# VARS FOR Student Service CHECKS
REPORT=status_report_$(date +%Y%m%d).csv;              # Student service report
PQSR=8;                                                # Expected QA/PRD service count
OTHR=2;                                                # Expected other service count

# ------------------------------------------------------
# ----------------- Begin Scripts ----------------------
# ------------------------------------------------------

echo "-----------------------------------------";
printf "${BLUE}Beginning System Checks...${NC}\n";
printf "${BLUE}Date${NC}: $(date)\n";
echo "-----------------------------------------";

# DNS Checks
echo;
echo "-------------------------------";
echo "----- Internal DNS Checks -----";
echo "-------------------------------";

for targetsys in $(echo $INTDNS)
do
    dig @$targetsys <TEST> &>/dev/null;
    if [[ $? -eq 0 ]]
    then
        printf "INTDNS,${BLUE}$targetsys${NC},${GREEN}UP${NC}\n";
    else
        printf "INTDNS,${BLUE}$targetsys${NC},${RED}DOWN${NC}\n";
    fi
done

echo;
echo "-------------------------------";
echo "----- External DNS Checks -----";
echo "-------------------------------";
for targetsys in $(echo $EXTDNS)
do
    dig @$targetsys <TEST> &>/dev/null 
    if [[ $? -eq 0 ]]
    then
        printf "EXTDNS,${BLUE}$targetsys${NC},${GREEN}UP${NC}\n";
    else
        printf "EXTDNS,${BLUE}$targetsys${NC},${RED}DOWN${NC}\n";
    fi
done

# Internet checks
echo;
echo "-------------------------------";
echo "-----   Internet Checks   -----";
echo "-------------------------------";

for targetsys in $(echo $INET)
do
    nc -z $targetsys 443 &>/dev/null;
    if [[ $? -eq 0 ]]
    then
        printf "Internet,${BLUE}$targetsys${NC},${GREEN}UP${NC}\n";
    else
        printf "Internet,${BLUE}$targetsys${NC},${RED}DOWN${NC}\n";
    fi
done;
echo;

echo "-------------------------------";
echo "-----  JAVA APP Testing -----";
echo "-------------------------------";
result=$(ssh $JAVASYS 'ps -efl | grep java | grep -v grep | grep javauser | wc -l');
if [[ $result -eq 1 ]]
then
	printf "${BLUE}<TEST>${NC},$targetsys,${GREEN}UP${NC}\n";
else
	printf "${BLUE}<TEST>${NC},$targetsys,${RED}DOWN${NC}\n";
fi

# Check CAS
echo "-------------------------------";
echo "-----   CAS AUTH Checks   -----";
echo "-------------------------------";

for targetsys in $(echo $PRODCAS)
do
        ssh $targetsys '
        RED="\033[0;31m";
        GREEN="\033[1;32m";
        BLUE="\033[1;34m";
        NC="\033[0m"; # No Color
        TOMCATCOUNT=$(ps -elf | grep java | grep -v grep | grep tomcat | wc -l);

        if [[ $TOMCATCOUNT -eq 1 ]]
        then
                printf "${BLUE}CAS${NC},$(uname -n),${GREEN}UP${NC}\n"
        else
                printf "${BLUE}CAS${NC},$(uname -n),${RED}DOWN${NC}\n"
        fi
        '
done

# Check Proxies
echo;
echo "--------------------------------";
echo "----- Primary Proxy Checks -----";
echo "--------------------------------";
for targetsys in $(echo $QUALSYSPROXY $DEVLSYSPROXY $PRODSYSPROXY)
   do
      targetproc=httpd;
      remstat=$(ssh $targetsys "systemctl list-units --type=service --state=running | grep $targetproc");
      sysstat=$(echo $remstat | awk -F '.' '{print $1}');
      if [[ "$sysstat" == "$targetproc" || "$sysstat" == httpd24-httpd ]]
      then
         printf "${BLUE}$targetsys${NC},$sysstat,${GREEN}UP${NC}\n";
      else
         printf "${BLUE}$targetsys${NC},$sysstat,${RED}DOWN${NC}\n";
      fi;
done;
echo;

echo "-------------------------------";
echo "-----  Sys Manage Check  -----";
echo "-------------------------------";
for targetsys in $(echo $<SERVER>)
do
        nc -z $targetsys 443;
        if [[ $? -eq 0 ]]
        then
                printf "${BLUE}ISSM${NC},$targetsys,${GREEN}UP${NC}\n";
        else
                printf "${BLUE}ISSM${NC},$targetsys,${RED}DOWN${NC}\n";
        fi
done

echo "-------------------------------";
echo "----- Student Service Check -----";
echo "-------------------------------";
echo "Generating Student Service status report. Please wait...";
for targetsys in $(echo $DEVLSYS $QUALSYS $PRODSYS)
do
      ssh $targetsys '
          env=$(uname -n | awk -F "-" "{print \$2}");
          for servicename in $(ps -elf | grep <TEST> | awk -F " " "{print \$15}" | awk -F "/" "{print \$4}");
          do
		  echo "$servicename,$env,$(uname -n)";
          done
          ' >> sortme.csv
done;

sort -o $REPORT sortme.csv;
rm sortme.csv;

echo "Report $REPORT has been created/edited";
for APPNAME in $(echo $STUDENTSERVICE)
do
    PRODCOUNT=$(grep $APPNAME $REPORT | grep prd | wc -l);
    QUALCOUNT=$(grep $APPNAME $REPORT | grep qa | wc -l);
    DEVLCOUNT=$(grep $APPNAME $REPORT | grep dev | wc -l);

    if [[ "$APPNAME" == "StudentService" ]]
    then
	    if [[ "$PRODCOUNT" == "$PQSR" ]]
	    then
		    printf "${BLUE}$APPNAME${NC},PROD,${GREEN}UP${NC}\n";
	    elif [[ "$PRODCOUNT" < "$PQSR" && "$PRODCOUNT" > 1 ]]
	    then
		    printf "${BLUE}$APPNAME${NC},PROD,${YELLOW}DEGRADED${NC}\n";
	    else
		    printf "${BLUE}$APPNAME${NC},PROD,${RED}DOWN${NC}\n";
	    fi;

            if [[ "$QUALCOUNT" == "$PQSR" ]]
            then
		    printf "${BLUE}$APPNAME${NC},QUAL,${GREEN}UP${NC}\n";
	    elif [[ "$QUALCOUNT" < "$PQSR" && "$QUALCOUNT" > 1 ]]
	    then
		    printf "${BLUE}$APPNAME${NC},QUAL,${YELLOW}DEGRADED${NC}\n";
	    else
		    printf "${BLUE}$APPNAME${NC},QUAL,${RED}DOWN${NC}\n";
	    fi;
	    
	    if [[ "$DEVLCOUNT" == "$OTHR" ]]
	    then
		    printf "${BLUE}$APPNAME${NC},DEVL,${GREEN}UP${NC}\n";
	    elif [[ "$DEVLCOUNT" < "$OTHR" && "$DEVLCOUNT" > 1 ]]
	    then
		    printf "${BLUE}$APPNAME${NC},DEVL,${YELLOW}DEGRADED${NC}\n";
	    else
		    printf "${BLUE}$APPNAME${NC},DEVL,${RED}DOWN${NC}\n";
	    fi;
    else
	    if [[ "$PRODCOUNT" == "$OTHR" ]]
            then
                    printf "${BLUE}$APPNAME${NC},PROD,${GREEN}UP${NC}\n";
            elif [[ "$PRODCOUNT" < "$OTHR" && "$PRODCOUNT" > 1 ]]
            then
                    printf "${BLUE}$APPNAME${NC},PROD,${YELLOW}DEGRADED${NC}\n";
            else
                    printf "${BLUE}$APPNAME${NC},PROD,${RED}DOWN${NC}\n";
            fi;

            if [[ "$QUALCOUNT" == "$OTHR" ]]
            then
                    printf "${BLUE}$APPNAME${NC},QUAL,${GREEN}UP${NC}\n";
            elif [[ "$QUALCOUNT" < "$OTHR" && "$QUALCOUNT" > 1 ]]
            then
                    printf "${BLUE}$APPNAME${NC},QUAL,${YELLOW}DEGRADED${NC}\n";
            else
                    printf "${BLUE}$APPNAME${NC},QUAL,${RED}DOWN${NC}\n";
            fi;

            if [[ "$DEVLCOUNT" == "$OTHR" ]]
            then
                    printf "${BLUE}$APPNAME${NC},DEVL,${GREEN}UP${NC}\n";
            elif [[ "$DEVLCOUNT" < "$OTHR" && "$DEVLCOUNT" > 1 ]]
            then
                    printf "${BLUE}$APPNAME${NC},DEVL,${YELLOW}DEGRADED${NC}\n";
            else
                    printf "${BLUE}$APPNAME${NC},DEVL,${RED}DOWN${NC}\n";
            fi;
fi;
done

echo;
echo "-------------------------------";
echo "-----   Printing Checks   -----";
echo "-------------------------------";
for targetsys in $(echo $CUPS)
   do
      targetproc=cups;
      remstat=$(ssh $targetsys "systemctl list-units --type=service --state=running | grep $targetproc");
      sysstat=$(echo $remstat | awk -F '.' '{print $1}');
      if [[ "$sysstat" == "$targetproc" ]]
      then
         printf "${BLUE}CUPS${NC},$targetsys,${GREEN}UP${NC}\n";
      else
         printf "${BLUE}CUPS${NC},$targetsys,${RED}DOWN${NC}\n";
      fi
done

echo "--------------------------------";
echo "----- PROD WARYBYTE Checks  -----";
echo "--------------------------------";
sysstat=$(curl -s https://warybyte.com | grep "<TEST>" &>/dev/null; echo $?);
if [[ $sysstat -eq 0 ]]; then
    printf "${BLUE}WARYBYTE WEB${NC},${GREEN}UP${NC}\n";
else
    printf "${BLUE}WARYBYTE WEB${NC},${RED}DOWN${NC}\n";
fi
echo;

echo "--------------------------------";
echo "----- TEST App Check -----";
echo "--------------------------------";

echo "TEST checks..."
for targetsys in $(echo $PRODPSPROXY)
do
    ssh $targetsys '
    RED="\033[0;31m";
    GREEN="\033[1;32m";
    BLUE="\033[1;34m";
    NC="\033[0m"; # No Color
    PROXYSYS=$(uname -n);
    for WEBENV in $(grep -r BalancerMember /etc/httpd/TEST.d/* | grep -v "#" | awk -F " " "{print \$1}" | cut -d ":" -f1 | sort -u);
    do
       for WEBBAL in $(grep BalancerMember $WEBENV | awk -F "/" "{print \$3}" | awk -F " " "{print \$1}" | sort -u);
               do
                       WEBAPP=$(echo $WEBBAL | cut -d ":" -f1);
                       WEBPRT=$(echo $WEBBAL | cut -d ":" -f2);

                       nc -z $WEBAPP $WEBPRT 2>/dev/null;
                       if [[ $? -eq 0 ]]
                       then
                               printf "${BLUE}$(echo $WEBENV | rev | awk -F "/" "{print \$1}" | rev | sed s/.TEST.conf//g)${NC},$WEBBAL,$PROXYSYS,${GREEN}UP${NC}\n";
                       else
                               printf "${BLUE}$(echo $WEBENV | rev | awk -F "/" "{print \$1}" | rev | sed s/.TEST.conf//g)${NC},$WEBBAL,$PROXYSYS,${RED}DOWN${NC}\n";
                       fi
               done;
     done;
    ';
    count=$(( $count + 1 ));
done
echo;

## PAUSE FOR USER
printf "${BLUE}Checks complete.${NC}\n";
read -p "Would you like to save report, $REPORT? [Yy] " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
        rm $REPORT;
        exit 1
fi
