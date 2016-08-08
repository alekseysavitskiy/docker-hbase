#!/bin/sh
HBASE_USER=hbase
REQUIRES_ZK_RESOLVABLE="regionserver zkcli"

## Generate HBase configuration
confd -onetime -backend env


## Handle startup bahaviour
#
case $1 in
  hbase)
    shift
    cmdline="exec ${HBASE_HOME}/bin/hbase $@"

    # Check if commands requires access to Zookeeper
    if ( echo "$REQUIRES_ZK_RESOLVABLE" | grep -q "\b${1:-dummy.$$}\b" ); then

      # Try to resolve master node IP got from ZK, if it fails
      # add $HBASE_USE_MASTERIP into /etc/hosts.
      '/update-hosts.sh'
      [ "$?" -ne 0 ] && exit 1
    fi

    # Configure hbase from template (confd) and run hbase command
    exec su -c "${cmdline}" ${HBASE_USER}
    ;;
  *)
    # Start helper script if any
    [ -x "/$1.sh" ] && exec "/$1.sh"

    # Fallback for other commands
    cmdline="$@"
    exec ${cmdline:-/bin/bash}
    ;;
esac
