#!/bib/bash
echo "Building simple LBs"
MCTL_ROOT=/var/lib/machines

for i in hap1
do
  echo "Copying base container into ${MCTL_ROOT}/${i}"
  test ! -f "${MCTL_ROOT}/${i}/etc/haproxy/haproxy.cfg" && cp -r --preserve=all "${MCTL_ROOT}/srv1" "${MCTL_ROOT}/${i}"

done

echo "Building simple application servers"

for i in app1 app2
do
  echo "Copying base container into ${MCTL_ROOT}/${i}"
  test ! -f "${MCTL_ROOT}/${i}/etc/haproxy/haproxy.cfg" && cp -r --preserve=all "${MCTL_ROOT}/srv1" "${MCTL_ROOT}/${i}"

  echo "Done!"

  echo "Configuring Consul"
cat > "${MCTL_ROOT}/${i}/etc/consul.d/${i}" << EOF
{
    "service": {
        "name": "simpleapp",
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

done
