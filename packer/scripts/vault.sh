https://releases.hashicorp.com/vault/0.5.0/vault_0.5.0_linux_amd64.zip
set -e
echo "Installing Vault"

curl -sk "https://releases.hashicorp.com/vault/${VAULT_VERSION}/vault_${VAULT_VERSION}_linux_amd64.zip -o /root/vault.zip"
unzip /root/vault.zip -d /usr/local/bin

chmod 755 /usr/local/bin/vault
# cat > /etc/consul.json << EOF
# {
#   "datacenter": "test-lab1",
#   "data_dir": "/tmp/consul",
#   "log_level": "INFO",
#   "server": true,
#   "bootstrap_expect": 1,
#   "bind_addr": "0.0.0.0"
# }
# EOF
# 
# cat > /etc/systemd/system/vault.service << EOF
# [Unit]
# Description=Vault agent
# Requires=network-online.target
# After=network-online.target
# 
# [Service]
# Restart=on-failure
# ExecStart=/usr/local/bin/vault
# ExecReload=/bin/kill -HUP $MAINPID
# KillSignal=SIGINT
# 
# [Install]
# WantedBy=multi-user.target
# EOF
# 
# systemctl enable vault.service

