#!/bin/sh
## update-hosts.sh is used to substitute HBASE_USE_MASTERIP into /etc/hosts.
#  This scenario happens on non-DNS managed docker environment, ip address
#  substitution enables services (ex. regionserver) locate HBase master ip address.
#


## Connect to zookeeper and retrieve master hostname
active_master_hostname() {
  rs=1
  master=$(${HBASE_HOME}/bin/hbase-jruby ${HBASE_HOME}/bin/get-active-master.rb)

  echo "$master" | grep -q 'not running' || rs=0
  [ $rs -eq 0 ] && echo $master || \
      >&2 echo -e "==> HBase master hostname couldn't be fetched from zookeeper!\n"
  return $rs
}


## Resolve any of master ip addresses by doing a ping
resolve_master_ip() {
  rs=1
  host="$1"

  # DNS lookup for master has failed, i.e. we run on non-DNS managed environment
  address=$(ping -c1 -W1 $host | grep '(*)'); rs=$?
  [ $rs -ne 0 ] && return 1

  echo $address | awk -F '\[()\]' '{print $2}'
}


## Update active master hostname in /etc/hosts.
#     Use provided IP address if hostname is not resolvable,
#     i.e. non DNS-managed environment
update_hosts() {
  tag="$1"; shift
  hosts_record="$@"

  # Handle addition only.
  # Since update case can't be used since stopped/started container ENV can't be updated!
  echo -e "# ::${tag}::\n${hosts_record}\n# ::${tag}::" >> /etc/hosts
}


## HBase get hostname and return when hostname not fetched,
#  since there's no sense in updating /etc/hosts then.
master_hostname=$(active_master_hostname)
[ -z "${master_hostname}" ] && return 0

## Resolve HBase master IP address
echo "===================="
ping -c1 -W1 $master_hostname
master_ip=$(resolve_master_ip $master_hostname)

# Non-DNS environment
if [ -z "${master_ip}" ]; then
  : ${HBASE_USE_MASTERIP:?You must provide HBase master ip address in non-DNS managed environments!}

  update_hosts hbase-master ${HBASE_USE_MASTERIP} ${master_hostname}

# Otherwise 
else
  :
fi
