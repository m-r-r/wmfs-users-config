#!/bin/sh

TIMING=1

status()
{
    TEMP="`sensors -u | grep input | awk '{ print $2 }' | sed -e ':a;N;$!ba;s/\n/ - /g'`"
    IP="`ifconfig | grep broadcast | awk {'print $2'}` "

    SEP="^s[right;#0;  ]^R[right;6;4;#339933]^s[right;#0;  ]"
    SEPL="^s[left;#0;  ]^R[left;6;4;#339933]^s[left;#0;  ]"

    MEMU="$(free -m | sed -n 's|^-.*:[ \t]*\([0-9]*\) .*|\1|gp')"
    MEMT="$(free -m | sed -n 's|^M.*:[ \t]*\([0-9]*\) .*|\1|gp')"

    CPU="$(eval $(awk '/^cpu /{print "previdle=" $5 "; prevtotal=" $2+$3+$4+$5 }' /proc/stat); sleep 0.4;
      eval $(awk '/^cpu /{print "idle=" $5 "; total=" $2+$3+$4+$5 }' /proc/stat);
      intervaltotal=$((total-${prevtotal:-0}));
      echo "$((100*( (intervaltotal) - ($idle-${previdle:-0}) ) / (intervaltotal) ))")"
    BARCPU="\g[left;70;10;$CPU;100;#445544;#ee7778;cpu]"

    MPC="mpc -h 192.168.0.66"
    MPD="`$MPC current` "
    MPDPOS="`$MPC | grep \"#\" | awk {'print $4'} | cut -d % -f1 | sed -e 's/(//g'` "
    MPDVOL="`$MPC volume | awk {'print $2'} | cut -d% -f1`"

    DD="`df -h | grep rootfs | awk {'print $5'} | cut -d% -f1`"

    DATADEF="^s[right;#dddd55;$IP]
             $SEP ^s[right;#dd6666;$TEMP]
             $SEP ^s[right;#bbccbb;`date`]"

    DATAB="^s[left;#cccccc; cpu ] \g[left;125;14;$CPU;100;#444444;#ff5555;cpu] $SEPL
           ^s[left;#cccccc;mem ] ^p[left;70;8;1;$MEMU;$MEMT;#aaaaaa;#333333] $SEPL
           ^s[left;#cccccc;rootfs ] ^p[left;70;6;1;$DD;100;#aaaaaa;#333355] $SEPL
           ^s[left;#ffffff;|< ](1;spawn;$MPC prev)
           ^s[left;#ffffff;|| ](1;spawn;$MPC toggle)
           ^s[left;#ffffff;>| ](1;spawn;$MPC next)
           ^P[left;150;6;4;$MPDPOS;100;#444444;#11aa11](4;spawn;$MPC seek +1)(5;spawn;$MPC seek -1)
           ^s[left;#cccccc; - ]
           ^p[left;6;12;0;$MPDVOL;100;#555555;#DDDDDD](4;spawn;$MPC volume +2)(5;spawn;$MPC volume -2) ^s[left;#cccccc; - ]
           ^s[left;#dddd55;$MPD] $SEPL"

    wmfs -c status "default $DATADEF"
    wmfs -c status "bottom $DATAB"
}

while true
do
    status
    sleep $TIMING
done
