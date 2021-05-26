# this was a PoC which could actually prove useful for visual representation of loop status using mostly generic *Nix commands
#!/bin/bash
statu=0; 
remu=100;  
while [ $statu -le 100 ]; 
do 
  echo "[$(printf %"$statu"s | tr " " "|")$(printf %"$remu"s | tr " " " ")]"; 
  ((statu++)); 
  ((remu--)); 
done
#
# output should render something like this as the loop completes cycles...
#
# [                                                                                                    ]
# ...
# [||||                                                                                                ]
# ...
# [||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||| ]
# [||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||]
