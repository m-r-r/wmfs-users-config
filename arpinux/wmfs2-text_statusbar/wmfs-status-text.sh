#!/bin/bash

#colors
green="#4E9A06"
grey="#7D7D7D"
dblue="#1874cd"
blue="#63b8ff"
red="#CC0000"
# mem section
memu(){
    memu="$(free -m | sed -n 's|^-.*:[ \t]*\([0-9]*\) .*|\1|gp')"
    echo "^s[right;$grey;mem]^s[right;$green;$memu]"
}
memt(){
    memt="$(free -m | sed -n 's|^M.*:[ \t]*\([0-9]*\) .*|\1|gp')"
    echo "^s[right;$green;/$memt  ]"
}
# cpu section
cpu(){
    cpu="$(eval $(awk '/^cpu /{print "previdle=" $5 "; prevtotal=" $2+$3+$4+$5 }' /proc/stat); sleep 0.4;
	      eval $(awk '/^cpu /{print "idle=" $5 "; total=" $2+$3+$4+$5 }' /proc/stat);
	      intervaltotal=$((total-${prevtotal:-0}));
	      echo "$((100*( (intervaltotal) - ($idle-${previdle:-0}) ) / (intervaltotal) ))")"
          if (( $cpu >= 70 ));then
              color="$red"
          else
              color="$green"
          fi

    echo "^s[right;$grey;cpu]^s[right;$color;$cpu%  ](1;spawn;urxvt -e htop)" 
}
load(){
    load="$(conky -c ~/.config/wmfs/conkyrc_load)"
    echo "^s[right;$green;$load  ]"
}
# hdd section
hdd(){
    hdd="$(df -h|grep sda3|awk '{print $5}' | cut -c1-2)"
    if (( $hdd >= 90 ));then
              color="$red"
          else
              color="$green"
          fi
    echo "^s[right;$grey;hdd]^s[right;$color;$hdd]^s[right;$grey;%  ](1;spawn;urxvt -e ncdu)"
}
# temperatures
tempcpu(){
    tempcpu="$(cat /sys/devices/platform/thinkpad_hwmon/temp1_input | awk '{print $1/1000}')"
    if (( $tempcpu >= 80 ));then
              color="$red"
          else
              color="$green"
          fi
    echo "^s[right;$grey;tmp]^s[right;$color;$tempcpu°]"
}
temphdd(){
    temphdd="$(cat /sys/devices/platform/thinkpad_hwmon/temp3_input | awk '{print $1/1000}')"
    if (( $temphdd >= 50 ));then
              color="$red"
          else
              color="$green"
          fi
    echo "^s[right;$color;$temphdd°]"
}
tempgpu(){
    tempgpu="$(cat /sys/devices/platform/thinkpad_hwmon/temp2_input | awk '{print $1/1000}')"
    if (( $tempgpu >= 60 ));then
              color="$red"
          else
              color="$green"
          fi
    echo "^s[right;$color;$tempgpu°  ]"
}
# wmfs version
vers(){
    vers="$(wmfs -v)"
    echo "^s[right;$grey;$vers  ]"
}
# distro
dist(){
    dist="livarp"
    echo "^s[right;$grey;debian]^s[right;$green;$dist]"
}
# date/time section
dte(){
    dte="$(date +"%a %d/%m")"
    echo "^s[right;$grey;$dte·]"
}
tme(){
    tme="$(date +"%H:%M")"
    echo "^s[right;$green;$tme ]"
}
# internet section
int(){ 
    int="$("$HOME/bin/speed-wmfs.sh")" 
    echo "^s[right;$grey;net] ^s[right;$green;$int  ](1;spawn;urxvt -e net-monitor)" 
}
# sound
volibm(){
    volume="$(conky -c ~/.config/wmfs/conkyrc_sound)"
    if [ "$volume" == "mute" ]; then
        volibm="mute"
    else
    volibm="ibm$(conky -c ~/.config/wmfs/conkyrc_sound | awk '{printf $1*100/14}' | cut -d . -f 1 $1)%"
    fi
    echo "^s[right;$blue;$volibm ]"
}
volpcm(){
    volpcm="$(amixer get PCM | tail -1 | sed 's/.*\[\([0-9]*%\)\].*/\1/')"
    echo "^s[right;$dblue;pcm$volpcm](1;spawn;urxvtc -T sound -e alsamixer)(4;spawn;amixer set PCM 2dB+)(5;spawn;amixer set PCM 2dB-)"
}
# music
music(){
    music="$(conky -c ~/.config/wmfs/conkyrc_mocp)"
    echo "$music"
}
# power
pwr(){
    pwrsta="$(cat /sys/class/power_supply/BAT0/status | cut -c 1)"
    pwrperc="$(awk 'sub(/,/,"") {print $4}' <(acpi -b) | cut -d , -f 1 $1)"
    if [ "$pwrsta" == "F" ]; then
        pwr="F"
    else
        pwr="$pwrsta·$pwrperc"
    fi
    echo "^s[right;$grey;bat]^s[right;$green;$pwr  ]"
}

TIMING=1

statustext()
{
    wmfs -c status "leftbar $(dist) $(vers) $(pwr) $(cpu) $(load) $(memu)$(memt) $(hdd) $(int) $(tempcpu) $(temphdd) $(tempgpu) $(dte) $(tme)"
     wmfs -c status "rightbar ^s[left;$dblue;  short>]^s[left;$grey;·todo·](1;spawn;dmenu-todo.sh)\
     ^s[left;$grey;wall·](1;spawn;randwalls_wmfs.sh)\
     ^s[left;$grey;home·](1;spawn;rox-filer)\
     ^s[left;$grey;www·](1;spawn;luakit)\
     ^s[left;$grey;vim·](1;spawn;urxvtc -T editor -e vim)\
     ^s[left;$grey;irc·](1;spawn;urxvtc -T irc -e screen irssi)\
     ^s[left;$grey;~git·](1;spawn;urxvtc -e ranger /home/arp/pkgs/wmfs/)\
     ^s[left;$grey;~cfg·](1;spawn;urxvtc -e ranger /home/arp/.config/wmfs/)\
     ^s[left;$dblue;         mocp>](1;spawn;urxvt -e mocp)\
     ^s[left;$blue;·prev·](1;spawn;mocp -r)\
     ^s[left;$blue;play·](1;spawn;mocp -p)\
     ^s[left;$blue;next·](1;spawn;mocp -f)\
     ^s[left;$blue;pause·](1;spawn;mocp -G)\
     ^s[left;$grey;<$(music)]\
     $(volpcm) $(volibm)"

}

while true;
do
    statustext
    sleep $TIMING
done
