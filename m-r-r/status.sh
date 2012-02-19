#/bin/sh

while true; do
    wmfs -c status "default `date +'%Y-%m-%d %H:%M:%S'`"
    [ "$1" == '--loop' ] || break 
    sleep 1
done
