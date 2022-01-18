#!/bin/sh
#
# Setup env vars for running scripts
#

# set env variables for your PS+ Broker
export HOST=localhost
export VPN=default
export MSG_USER=default
export MSG_PASS=default

export SMF_URL=tcp://$HOST:55555
export SMFS_URL=tcps://$HOST:55443

# set SDK location
export SDK_PERF=/home/solace/sdkperf-jcsmp-8.4.0.17/sdkperf_java.sh 
