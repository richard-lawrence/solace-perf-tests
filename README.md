# PubSub+ Baseline Performance Testing

Example SDK Perf test scripts for testing PubSub+ baseline performance.

## Setup

Download SDK perf: [https://solace.com/downloads/#other-software](https://solace.com/downloads/#other-software)

Edit env.sh configure the following variables according to your environment:

* HOST - PubSub+ broker/service hostname
* VPN - PubSub+ broker/service VPN name
* MSG_USER - application client username
* MSG_PASS - application client password
* SDK_PERF - Full path to SDK perf shell script

## Running Test Cases

Run each test case and record results in the xls file.

Edit the test case scripts to set the appropriate message size for your use case.

Experiment with different publish rates until you achieve the best overall subscriber performance.

Note: If you run test with higher numbers of connections you may need to use "-tm rtrperf" option to reduce the internal number of threads created with SDK Perf.


## Test Cases

The following test cases are supported:

1. Direct Messaging Topic Pub/Sub Baseline - single topic per subscriber
2. Direct Messaging Topic Pub/Sub Fan Out - subscribers subscribe to all topics
3. Persistent Messaging Topic Pub/Queue Read Baseline - single topic and queue per subscriber
4. Persistent Messaging Topic Pub/Queue Read Fan Out - each queue/subscriber subscribes to all topics


