#!/bin/bash -x

# Use this script to test faster the functionalities
# - Turn on the machines
# - Test the reachability
# - Test the availability of the web server


BOLD=$(tput bold)
NORMAL=$(tput sgr0)

#Echo the command, then run it
exe() { echo "\$$BOLD $@ $NORMAL" ; "$@" ; }


#echo "---------- Destroy the machines if are already present"
#vagrant destroy -f --parallel

echo "--------- Start (or provision) the machines"
exe vagrant up

echo "--------- Testing if they are all running"

if [ `vagrant status |grep running |wc -l` -ne 6 ]; then
   echo "At least one machine is not running! " 1>&2
   echo "Exiting" 1>&2
   exit 1
fi

echo "All the machines are up !"

echo "--------- Test reachability between all hosts"

ping_test()
{
   exe vagrant ssh $1 -c "ping $3 -c 1" | tee test.out
   grep " 0% packet loss" test.out > /dev/null
   if [ $? -eq 0 ]; then
     echo ">>>>>>>>> $BOLD $1 $2  -> OK $NORMAL"
   else
     echo ">>>>>>>>> $BOLD $1 $2  -> ERROR  $NORMAL"
   fi
}

ping_test "host-1-a" "host-1-b" "10.0.1.2"
ping_test "host-1-a" "host-2-c" "10.0.1.34"
ping_test "host-1-b" "host-1-a" "10.0.0.2"
ping_test "host-1-b" "host-2-c" "10.0.1.34"
ping_test "host-2-c" "host-1-a" "10.0.0.2"
ping_test "host-2-c" "host-1-b" "10.0.1.2"

echo "--------- Test webserver availability"

web_test()
{
  exe vagrant ssh $1 -c "curl 10.0.1.34" |tee test.out
  grep "Just a test page!" test.out > /dev/null
  if [ $? -eq 0 ]; then
    echo ">>>>>>>>> $BOLD $1 -> OK $NORMAL"
  else
    echo ">>>>>>>>> $BOLD $1 -> ERROR  $NORMAL"
  fi
}

web_test "host-1-a"
web_test "host-1-b"
web_test "host-2-c"


echo "--------- Clean-up"
rm test.out
#vagrant suspend
#vagrant destroy

echo "--------- End of the testing script"
