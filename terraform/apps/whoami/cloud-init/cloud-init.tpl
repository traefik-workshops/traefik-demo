#cloud-config

ssh_pwauth: true
users:
  - name: traefiker
    groups: sudo
    shell: /bin/bash
    sudo: ["ALL=(ALL) NOPASSWD:ALL"]
    lock_passwd: false

chpasswd:
  expire: false
  list: |
    traefiker:topsecretpassword

write_files:
  - path: /etc/systemd/system/whoami.service
    content: |
      [Unit]
      Description=Traefik Whoami Service
      After=network.target

      [Service]
      ExecStart=/usr/local/bin/whoami --port ${port}
      Restart=always
      User=nobody
      AmbientCapabilities=CAP_NET_BIND_SERVICE

      [Install]
      WantedBy=multi-user.target
    owner: root:root
    permissions: "0644"

runcmd:
  # Install Docker based on distribution
  - |
    if command -v apt-get >/dev/null; then
      apt-get update -y
      apt-get install -y docker.io
      systemctl start docker
      systemctl enable docker
    elif command -v yum >/dev/null; then
      yum update -y
      yum install -y docker
      systemctl start docker
      systemctl enable docker
    fi

  # Extract binary from image
  - echo "Pulling image traefik/whoami:${whoami_version} for platform linux/${arch}"
  - docker pull --platform linux/${arch} traefik/whoami:${whoami_version}
  - id=$(docker create --platform linux/${arch} traefik/whoami:${whoami_version})
  - echo "Extracting binary..."
  - docker cp $id:/whoami /usr/local/bin/whoami
  - docker rm -v $id
  - chmod +x /usr/local/bin/whoami

  # Capabilities (Bind port 80 as non-root)
  - setcap 'cap_net_bind_service=+ep' /usr/local/bin/whoami

  # Start Service
  - systemctl daemon-reload
  - systemctl enable --now whoami.service

  # Signal readiness
  - echo "Whoami provisioning complete"
