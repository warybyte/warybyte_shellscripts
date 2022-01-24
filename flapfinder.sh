# script to detect network load balancer flap (helpful when service health monitoring isn't configured on LB)
#!/bin/bash
LBIP=<ENTER LOADBALANCED IP>
LBPORT=<ENTER PORT>

# prime results
result=0; 
for count in $(echo {1..6}); 
do 
   nc -z -w2 $LBIP $LBPORT; 
   result=$(($result + $(echo $?))); 
done; 
if [ $result -gt 0 ]; 
then 
  echo "FLAPPING"; 
else 
  echo "CLEAN"; 
fi

# Logic: Script fires n number of connections to the LB over designated port, adding the return values together.

# Good connections will return a total of '0' (0+0+0+0...), meaning the LB is working properly.

# Flapping connections on the other hand indicate the LB is failing to detect services are down and only passing
# connections when it selects a working node. 

# ...obviously 100% failure means you have other gremlins to deal with...
