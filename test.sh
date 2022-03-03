#!/bin/sh



# screen -S scripttest /dev/tty.usbserial-14120

screen -S scripttest -X stuff 'show config'
`echo -ne '\015'`

screen -r scripttest
