cd solanamonitoring
git checkout 830f7ddeca92924dc8e2c557770031c15b33553c
chmod +x monitor.sh

cat <<EOF | sudo tee /etc/telegraf/telegraf.conf
[agent]
  hostname = "$NODENAME-$CHAIN"
  flush_interval = "15s"
  interval = "15s"

# Input Plugins
[[inputs.cpu]]
    percpu = true
    totalcpu = true
    collect_cpu_time = false
    report_active = false
[[inputs.disk]]
    ignore_fs = ["devtmpfs", "devfs"]
#[[inputs.io]]
[[inputs.mem]]
[[inputs.net]]
[[inputs.system]]
[[inputs.swap]]
[[inputs.netstat]]
[[inputs.processes]]
[[inputs.kernel]]
[[inputs.diskio]]

# Output Plugin InfluxDB
[[outputs.influxdb]]
  database = "metricsdb"
  urls = [ "http://metrics.stakeconomy.com:8086" ]
  username = "metrics"
  password = "password"

[[inputs.exec]]
  commands = ["sudo su -c $HOME/solana/solanamonitoring/monitor.sh -s /bin/bash $USER"]
  interval = "30s"
  timeout = "30s"
  data_format = "influx"
  data_type = "integer"
EOF

sed -i.bak -e "s/^solanaPrice=\$(curl.*/solanaPrice=\$(curl -s \'https:\/\/api.margus.one\/solana\/price\/'| jq -r .price)/" $HOME/solana/solanamonitoring/monitor.sh

sudo systemctl enable --now telegraf
sudo systemctl is-enabled telegraf
sudo systemctl restart telegraf
