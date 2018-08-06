# This file wipes out hbase distro default conf/hbase-env.sh
#
# Extra Java runtime options.
# Below are what we set by default.  May only work with SUN JVM.
# For more on why as well as other possible settings,
# see http://wiki.apache.org/hadoop/PerformanceTuning
export HBASE_OPTS="-XX:+UseConcMarkSweepGC"
export HBASE_MASTER_OPTS="$HBASE_MASTER_OPTS -javaagent:/jmx_prometheus_javaagent-0.3.1.jar=7071:/etc/hbase/hbase_jmx_config.yaml"
export HBASE_REGIONSERVER_OPTS="$HBASE_REGIONSERVER_OPTS -javaagent:/jmx_prometheus_javaagent-0.3.1.jar=7071:/etc/hbase/hbase_jmx_config.yaml"
