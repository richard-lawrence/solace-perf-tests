#!/bin/bash
#
# Run Direct messaging baseline performance test:
#
# - creates subscribers to receive messages, one topic for each subscriber
# - creates a single publisher that sends at rate x
# - calculates the total received message rate
#
# SDKPerf params:
#	-msa = message size
#	-ptl = publish topic list (, separated)
#	-stl = subscribe topic list (, separated)
#	-pql = publish queue list (, separated)
#	-sql = subscribe queue list (, separated)
#	-mn = number of messages
#	-mt = message type (persistent, direct)
#	-mr = message rate (per sec)
#	-cc = number of connections 
#
#
# Adjust test params as necessary:
#
# Total publisher message rate
messageRate=8000
# Number of Topic subscribers
subscriberCount=10
# Number of publisher connections
publisherConnections=2
# Test duration
durationInSec=60
# Message Size
messageSize=1000

source env.sh

topic=perf-topic

#reduce publish rate for each publisher to achieve total message rate
publishRate=$(($messageRate / $publisherConnections))
#calculate total message count
messageCount=$(( $messageRate * $durationInSec ))
subPids=()
pubPid=

rm *.out *.err >/dev/null 2>/dev/null

echo "========Perf Test Config========="
echo "Broker: $SMF_URL"
echo "Input Message Rate: $messageRate"
echo "Number of Subscribers: $subscriberCount"
echo "Number of publisher connections: $publisherConnections"
echo "Message Size: $messageSize"
echo "Test Duration (secs): $durationInSec"

echo "========Running Test ========="

echo "`date +%H:%M:%S` Starting test subscribers"
topicList=
for (( var = 0; var < $subscriberCount; var++))
do
	$SDK_PERF -cip="$SMF_URL" -cu=$MSG_USER@$VPN -cp=$MSG_PASS -stl=$topic$var >sub$var.out 2>sub$var.err &
	subPids+=($!)
	topicList+=$topic$var
	if [ $var -lt $(($subscriberCount -1)) ]
	then
	    topicList+=","
	fi
done

sleep 4

echo "`date +%H:%M:%S` Starting test publisher"
# run the publisher - run at rate and get the actual from the termination
$SDK_PERF -cip="$SMF_URL" -cu=$MSG_USER@$VPN -cp=$MSG_PASS -ptl=$topicList -mt=direct -msa=$messageSize -mn=$messageCount -mr=$publishRate -cc $publisherConnections>pub.out 2>pub.err &
pubPid=$!

# wait for all publisher pids to exit
wait $pubPid

echo "`date +%H:%M:%S` Publishing complete"

sleep 4

echo "`date +%H:%M:%S` Killing subscribers"
for (( var = 0; var < $subscriberCount; var++))
do
	#kill -s SIGINT ${subPids[$var]}

	# For java SDKPerf need to kill child pid
	kill -s SIGHUP `pgrep -P ${subPids[$var]}`
	#kill ${subPids[$var]}
done

sleep 4 #allow files to be written

#################
# get rates
#################

echo "========Test Results========="
msgs=`cat pub.out | grep 'Messages transmitted' | sed 's/.* = //'  `
echo "Total Messages transmitted: $msgs"
rate=`cat pub.out | grep 'publish rate' | sed 's/.* = //' `
echo "Computed publish rate (msg/sec): $rate"

msgs=`cat sub*.out | grep 'Messages received' | sed 's/.* = //' | paste -sd+ - | bc`
echo "Total Messages received: $msgs"
rate=`cat sub*.out | grep 'subscriber rate' | sed 's/.* = //' | paste -sd+ - | bc`
echo "Computed subscriber rate (msg/sec): $rate"


