#!/bin/bash
echo "Building simple LBs"
MCTL_ROOT=/var/lib/machines

for i in hap1 hap2
do
  echo "Copying base container into ${MCTL_ROOT}/${i}"
  test ! -f "${MCTL_ROOT}/${i}/etc/haproxy/haproxy.cfg" && cp -r --preserve=all "${MCTL_ROOT}/srv1" "${MCTL_ROOT}/${i}"
  echo "Configuring Consul"
cat > "${MCTL_ROOT}/${i}/etc/consul.d/haproxy.json" << EOF
{
    "service": {
        "name": "haproxy",
        "port": 9090,
        "tags": [
            "staging",
            "haproxy"
        ],
        "check": {
          "script": "curl localhost:9090 >/dev/null 2>&1",
           "interval": "10s"
        }
    }
}
EOF

echo "Configuring Consul Template"
  mkdir -p "${MCTL_ROOT}/${i}/etc/consul-template.d"

cat > "${MCTL_ROOT}/${i}/etc/consul-template.d/haproxy.cfg.ctmpl" << EOF
global
    log         127.0.0.1 local2
    chroot      /var/lib/haproxy
    pidfile     /var/run/haproxy.pid
    maxconn     4000
    user        haproxy
    group       haproxy
    daemon

    # turn on stats unix socket
    stats socket /var/lib/haproxy/stats

defaults
    mode                    http
    log                     global
    option                  httplog
    option                  dontlognull
    option http-server-close
    option forwardfor       except 127.0.0.0/8
    option                  redispatch
    retries                 3
    timeout http-request    10s
    timeout queue           1m
    timeout connect         10s
    timeout client          1m
    timeout server          1m
    timeout http-keep-alive 10s
    timeout check           10s
    maxconn                 3000

listen stats
  bind 127.0.0.1:9090
  mode  http
  stats  uri /

frontend www-http
    bind *:80
    default_backend simpleapp

backend simpleapp
  mode http
  balance roundrobin{{range service "simpleapp"}}
  server {{.Node}} {{.Address}}:{{.Port}}{{end}}
EOF
 
  echo "Generting configuration for Consul Template"
cat > "${MCTL_ROOT}/${i}/etc/consul-template.hcl" << EOF
consul = "0.0.0.0:8500"

template {
  source = "/etc/consul-template.d/haproxy.cfg.ctmpl"
  destination  = "/etc/haproxy/haproxy.cfg"
  command = "systemctl restart haproxy"
EOF

  echo "Configuring systemd service for Consul Template"

cat > /etc/systemd/system/consul-template.service << EOF
[Unit]
Description=consul-template agent
Requires=network-online.target
After=network-online.target

[Service]
Restart=on-failure
ExecStart=/usr/local/bin/consul-template -config /etc/consul-template.hcl
ExecReload=/bin/kill -HUP $MAINPID
KillSignal=SIGINT

[Install]
WantedBy=multi-user.target
EOF

systemd-nspawn -D "${MCTL_ROOT}/${i}" systemctl enable consul-template.service
sleep 5

done

echo "Building simple application servers"

for i in app1 app2
do
  echo "Copying base container into ${MCTL_ROOT}/${i}"
  test ! -f "${MCTL_ROOT}/${i}/etc/haproxy/haproxy.cfg" && cp -r --preserve=all "${MCTL_ROOT}/srv1" "${MCTL_ROOT}/${i}"

  echo "Done!"

  echo "Configuring Consul"
cat > "${MCTL_ROOT}/${i}/etc/consul.d/simpleapp.json" << EOF
{
    "service": {
        "name": "simpleapp",
        "port": 9090,
        "tags": [
            "prod",
            "app"
        ],
        "check": {
          "script": "curl localhost:9090 >/dev/null 2>&1",
           "interval": "10s"
        }
    }
}
EOF

done
