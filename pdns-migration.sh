#/bin/bash
# This script was born from much pain and anguish. Perhaps it can help lead someone going through the same similar straights.
# General Logic: Dump the contents of a SQL backed PowerDNS, recreate each zone, then use PDNSUtil tool to cleanly import zone file.
# General Result: Success...given you don't have too much garbage in free form fields...like I did for most zones.
# PowerDNS Version: 2.9...yeah...that old (https://doc.powerdns.com/authoritative/changelog/pre-4.0.html#powerdns-authoritative-server-version-2-9-21)
#
# Variables
	curdate=$(date +%y%m%d)
	curuser=$(whoami)
	dnsimportlog=$curdate-import.log
# 
	echo "Dumping PDNS database of OLD system";
	ssh -p555 -o LogLevel=error -t OLD.SERVER "mysqldump --user=root --password=<YOUR PASSWORD> --databases pdns > origPDNS-$curdate.sql"

# Pull the old DNS database tables back to new DNS database, then clean them up on the other end.
	echo "Pulling PDNS dump from OLD / Cleaning up";
	scp -P555 YOUR.SERVER:/home/$curuser/origPDNS-$curdate.sql .
	ssh -p555 -o LogLevel=error -t OLD.SERVER "rm /home/$curuser/origPDNS-$curdate.sql";

# Dump new DNS database tables (gives you a working backup in case of failure...assuming there is any data)
	echo "Backup existing PDNS database on NEW.SERVER";
	mysqldump --user=root --password=<YOUR PASSWORD> pdns > newPDNS-$curdate.sql;

# Strip out domain data from old tables. I hope you can just comment this out, however everybody has their own garbage. 
  echo "Generating list of domains";
	sleep 3; # I forget wy I had this sleep...maybe because I'd be staring at the screen while all this was happening...or maybe because I was tanking the CPU...
	grep domains origPDNS-$curdate.sql | grep -v ldap | sed s/"),("/\\n/g | sed s/\'//g | sed s/")"/\\n/g | sed s/"("/\\n/g | grep NULL | sort | awk -F ',' '{print $2}' 2>&1 | tee ddata
	echo "IMPORTING ZONES" 2>&1 | tee $dnsimportlog;
#
# Create zones and rectify them for DNSSEC (if needed)
#
# pdnsutil create-zone ZONE NAMSERVER
# SAMPLE STRING:	1,local.com,NULL,NULL,NATIVE,NULL,NULL 
#			<id>,<name>,<master>,<lastcheck>,<type>,<notitified serial>.<account>

	for domwork in $(cat ddata)
	do
	# purge if exist
		echo "Purging zone if it already exists:";
		echo "$domwork";
		sudo pdnsutil delete-zone $domwork;
                echo "$domwork" 2>&1 | tee $dnsimportlog;
		echo "Creating zone $domwork";
		sudo pdnsutil create-zone $domwork <OLD.SERVER> 2>&1 | tee $dnsimportlog;
	done
#
# Create records list and dump them in zones
#
# pdnsutil add-record ZONE NAME TYPE TTL CONTENT
#
# SAMPLE DATE:		9994,431,test.server,A,192.168.1.1,86400,0,NULL
#			<id>,<domain-id>,<name>,<type>,<content>,<ttl>,<prio>,<change date>

	echo "Parsing out records from old database";
	sleep 3;
	grep records origPDNS-$curdate.sql | sed s/"),("/\\n/g | sed s/\'//g | sed s/")"/\\n/g | sed s/"("/\\n/g | sort 2>&1 | tee recstring
	echo "IMPORTING RECORDS" 2>&1 | tee ;

	for recwork in $(cat recstring)
	do
		recname=$(echo $recwork | awk -F ',' '{print $3}' | cut -d "." -f1);
		rectype=$(echo $recwork | awk -F ',' '{print $4}');
		recttl=$(echo $recwork | awk -F ',' '{print $6}');
		reccont=$(echo $recwork | awk -F ',' '{print $5}');
		# note that reczone depends on recname already being defined...
		reczone=$(echo $recwork | awk -F ',' '{print $3}' | sed s/$recname//g | cut -d '.' -f2-);
		# run this as sudo if pdns.conf is owned by root
		echo "$recwork" 2>&1 | tee rawdata.log;
		echo "$recwork" &>> $dnsimportlog;
		# tee off for logs
		sudo pdnsutil add-record $reczone $recname $rectype $recttl $reccont 2>&1 | tee $dnsimportlog;
	done
#
# rectify zones to make them compliant with DNSSEC...fills in some gaps
# UPDATE: This might cause some issues with PowerAdmin identifying zone owners...
# 
#	echo "RECTIFYING ZONES";
#	echo "RECTIFYING ZONES" &>> $dnsimportlog;
#        sudo pdnsutil rectify-all-zones &>> $dnsimportlog;
#
# CLEAN UP
#
#	rm *.sql
# END
