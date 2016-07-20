#!/bin/bash

# Generate configs before start up
confd -onetime -backend env

case $1 in
  master|regionserver)
    exec su -c "${HBASE_HOME}/bin/hbase $1 start" hbase
    ;;
  *)
    exec $@
    ;;
esac
