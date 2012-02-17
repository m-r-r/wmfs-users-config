#!/bin/sh
#WMFS status.sh example file
TIMING=1
statustext()
{

#### Hora y Fecha

   # Hora
    sys_hour="`date '+%H:%M:%S'`"

   # Fecha
    sys_date="`date '+%a %d %b %Y'`"

   DATE="^s[right;#FFFFFF;$sys_date $sys_hour]\ "
####################

#### Memoria RAM

    sys_mem="`free -m | grep "buffers/" | awk {'print $3'}`"

    MEM="^s[right;#FFFFFF;$sys_mem"mb"]\ "
    MEM1="^s[right;#5D82B9;MEM:]\ "
####################

### Temperatura        #Requiere lm_sensors

    sys_temp=$(sensors |grep temp2 |cut -s -d+ -f2|cut -d. -f1)

    TEMP="^s[right;#FFFFFF;$sys_temp°]\ "
    TEMP1="^s[right;#5D82B9;TEMP:]\ "
####################

#### Procesador

    sys_cpu=$(eval $(awk '/^cpu0 /{print "previdle=" $5 "; prevtotal=" $2+$3+$4+$5 }' /proc/stat);
            sleep 0.4;
            eval $(awk '/^cpu0 /{print "idle=" $5 "; total=" $2+$3+$4+$5 }' /proc/stat);
            intervaltotal=$((total-${prevtotal:-0}));
            echo "$((100*( (intervaltotal) - ($idle-${previdle:-0}) ) / (intervaltotal) ))")


    CPU="^s[right;#FFFFFF;$sys_cpu% ]\ "
    CPU1="^s[right;#5D82B9;CPU:]\ "
####################

#### Kernel

    sys_ker="`uname -r`"
    KER=" ^s[right;#FFFFFF;$sys_ker]\ "
    KER1=" ^s[right;#5D82B9;KER:] "
####################
 

#### Separador
     SEP="^s[right;#D52E32; :: ]\ "
 ####################

#=============================================================
     wmfs -c status "default  $KER1$KER$SEP$CPU1$CPU$SEP$TEMP1$TEMP$SEP$MEM1$MEM$SEP$DATE1$DATE "
}
while true;
do
statustext
    sleep $TIMING
done
