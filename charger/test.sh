#!/bin/bash
for f in *; do
    if [ -d ${f} ]; then
        # Will not run if no directories are available
        present_directory=$f
	output=`ls /home/gor/embd_logs/charger/$f/* | sort -n | xargs -d '\n' grep COMMIT`
	output_1=`ls /home/gor/embd_logs/charger/$f/* | sort -n | xargs -d '\n' grep Version`
	COMMIT_ID=`echo $output  | head -1 | sed -n -e 's/^.*INFO: //p'`
	Version=`echo $output_1  | head -1 | sed -n -e 's/^.*]: //p'`
	date=`echo $output  | sed 's/.*\[\([^]]*\)].*/\1/'`
	date_1=`echo $output_1  | sed 's/.*\[\([^]]*\)].*/\1/'`
	echo "##########################################################################################"
	echo "Charger_ID: $f"
	echo "DATE: $date , $COMMIT_ID"
	echo "DATE: $date_1, $Version"
    fi
done
