#!/bin/bash
# script to convert Linux kernal build time to standard epoch
#!/bin/bash
# uname -v | awk -F ' ' '{print $4"/"$5"/"$8" "$6 }'
buildday=$(uname -v | awk -F ' ' '{print $5}');
buildyear=$(uname -v | awk -F ' ' '{print $8}');
buildtime=$(uname -v | awk -F ' ' '{print $6}');
# month conversion
month=$(uname -v | awk -F ' ' '{print $4}');
if [[ $month = "Jan" ]]
then 
	month=01;
elif [[ $month = "Feb" ]]
then 
	month=02;
elif [[ $month = "Mar" ]]
then 
	month=03;
elif [[ $month = "Apr" ]]
then 
	month=04;
elif [[ $month = "May" ]]
then 
	month=05;
elif [[ $month = "Jun" ]]
then 
	month=06;
elif [[ $month = "Jul" ]]
then 
	month=07;
elif [[ $month = "Aug" ]]
then 
	month=08;
elif [[ $month = "Sep" ]]
then 
	month=09;
elif [[ $month = "Oct" ]]
then 
	month=10;
elif [[ $month = "Nov" ]]
then 
	month=11;
else 
	month=12;
fi

kernbuildtime="$month/$buildday/$buildyear $buildtime";
echo $kernbuildtime;
date -d "$kernbuildtime" +"%s";
