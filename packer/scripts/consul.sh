#!/bin/bash
set -e
echo "Installing Consul and Consul Template"

curl -sk "https://releases.hashicorp.com/consul/${CONSUL_VERSION}/consul${CONSUL_VERSION}_linux_amd64.zip -o /root/consul.zip"
unzip /root/consul.zip -d /usr/local/bin

curl -sk "https://releases.hashicorp.com/consul-template/${CONSUL_TEMPLATE_VERSION}/consul-template_${CONSUL_TEMPLATE_VERSION}_linux_amd64.zip" -o /root/consul-template.zip
unzip /root/consul-template.zip -d /usr/local/bin

chmod 755 /usr/local/bin/consul
chmod 755 /usr/local/bin/consul-template
IP=`hostname -i`

cat > /etc/consul.json << EOF
{
  "datacenter": "test-lab1",
  "data_dir": "/tmp/consul",
  "log_level": "INFO",
  "server": true,
  "bootstrap_expect": 1,
  "bind_addr": "0.0.0.0"
}
EOF

mkdir /etc/consul.d


cat > /etc/systemd/system/consul.service << EOF
[Unit]
Description=consul agent
Requires=network-online.target
After=network-online.target

[Service]
Restart=on-failure
ExecStart=/usr/local/bin/consul agent -config-file /etc/consul.json -config-dir /etc/consul.d
ExecReload=/bin/kill -HUP $MAINPID
KillSignal=SIGINT

[Install]
WantedBy=multi-user.target
EOF

systemctl enable consul.service

# We do not need it for this Lab
systemctl disable firewalld.service

# cat > /etc/consul.d/foo << EOF
# {
#     "service": {
#         "name": "foo",
#         "port": 8080,
#         "tags": [
#             "staging",
#             "db",
#             "primary"
#         ]
#     }
# }
# EOF
