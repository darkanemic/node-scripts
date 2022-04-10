sudo tee <<EOF >/dev/null /etc/prometheus/prometheus.yml
global:
  scrape_interval: 30s
  evaluation_interval: 30s
  external_labels:
    owner: '$OWNER'
    hostname: '$HOSTNAME'
scrape_configs:
  - job_name: "node_exporter"
    scrape_interval: 30s
    static_configs:
      - targets: ["localhost:9100"]
    relabel_configs:
      - source_labels: [__address__]
        regex: '.*'
        target_label: instance
        replacement: '$HOSTNAME'
EOF
