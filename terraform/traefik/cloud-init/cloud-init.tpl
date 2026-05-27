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
  list:
    - traefiker:topsecretpassword

write_files:
  - path: /etc/ssh/sshd_config.d/99-traefik.conf
    owner: root:root
    permissions: "0644"
    content: |
      PasswordAuthentication yes

  - path: /etc/sysctl.d/99-traefik-perf.conf
    owner: root:root
    permissions: "0644"
    content: |
      net.ipv4.tcp_tw_reuse = ${performance_tuning.tcp_tw_reuse}
      net.ipv4.tcp_timestamps = ${performance_tuning.tcp_timestamps}
      net.core.rmem_max = ${performance_tuning.rmem_max}
      net.core.wmem_max = ${performance_tuning.wmem_max}
      net.core.somaxconn = ${performance_tuning.somaxconn}
      net.core.netdev_max_backlog = ${performance_tuning.netdev_max_backlog}
      net.ipv4.ip_local_port_range = ${performance_tuning.ip_local_port_range}

  - path: /etc/systemd/system/traefik-hub.service
    owner: root:root
    permissions: "0644"
    content: |
      [Unit]
      Description=Traefik Hub
      After=network-online.target
      Wants=network-online.target
%{ if dns_traefiker.enabled ~}
      After=dns-traefiker.service
      Wants=dns-traefiker.service
%{ endif ~}

      [Service]
      Type=simple
      EnvironmentFile=-/etc/traefik-hub/env
      EnvironmentFile=-/etc/traefik-hub/dns-traefiker.env
%{ if dns_traefiker.enabled ~}
      ExecStartPre=/bin/bash -c 'for i in $(seq 1 60); do grep -q CF_DNS_API_TOKEN /etc/traefik-hub/dns-traefiker.env && exit 0; sleep 5; done; echo "WARNING: CF token not found after 300s, starting anyway"; exit 0'
%{ endif ~}
      LimitNOFILE=${performance_tuning.limit_nofile}
      %{ if performance_tuning.gomaxprocs > 0 }
      Environment=GOMAXPROCS=${performance_tuning.gomaxprocs}
      %{ endif }
      Environment=GOGC=${performance_tuning.gogc}
      %{ if performance_tuning.numa_node >= 0 }
      NUMAPolicy=bind
      NUMAMask=${performance_tuning.numa_node}
      CPUAffinity=numa
      %{ endif }
      ExecStart=/usr/local/bin/traefik-hub --hub.token=$${HUB_TOKEN} ${join(" ", cli_arguments)}
      Restart=always
      RestartSec=10
      AmbientCapabilities=CAP_NET_BIND_SERVICE

      [Install]
      WantedBy=multi-user.target

%{ if dns_traefiker.enabled }
  - path: /etc/systemd/system/dns-traefiker.service
    owner: root:root
    permissions: "0644"
    content: |
      [Unit]
      Description=DNS Traefiker
      After=network-online.target
      Wants=network-online.target

      [Service]
      Type=simple
      EnvironmentFile=/etc/traefik-hub/dns-traefiker.env
      Environment=ENV_FILE_PATH=/etc/traefik-hub/dns-traefiker.env
      ExecStart=/usr/local/bin/dns-traefiker
      Restart=always
      RestartSec=30

      [Install]
      WantedBy=multi-user.target

  - path: /etc/traefik-hub/dns-traefiker.env
    owner: root:root
    permissions: "0600"
    content: |
      DOMAIN=${dns_traefiker.domain}
      UNIQUE_DOMAIN=${dns_traefiker.unique_domain}
      PROXIED=${dns_traefiker.proxied}
      ENABLE_AIRLINES_SUBDOMAIN=${dns_traefiker.enable_airlines_subdomain}
      IP_OVERRIDE=${dns_traefiker.ip_override}
%{ endif }

  - path: /etc/systemd/system/node_exporter.service
    owner: root:root
    permissions: "0644"
    content: |
      [Unit]
      Description=Node Exporter
      After=network.target

      [Service]
      User=root
      ExecStart=/usr/local/bin/node_exporter --collector.cpu --collector.schedstat --collector.perf --web.listen-address=:9102
      Restart=always

      [Install]
      WantedBy=multi-user.target

  - path: /etc/traefik-hub/env
    owner: root:root
    permissions: "0600"
    content: |
      %{ for env in env_vars ~}
      ${env.name}=${env.value}
      %{ endfor ~}

%{ if file_provider_config != "" ~}
  - path: /etc/traefik-hub/dynamic/dynamic.yaml
    owner: root:root
    permissions: "0644"
    content: |
      ${indent(6, file_provider_config)}
%{ endif ~}

%{ for f in extra_files ~}
  - path: ${f.path}
    owner: root:root
    permissions: "0644"
    content: |
      ${indent(6, f.content)}
%{ endfor ~}

%{ if dashboard_config != "" ~}
  - path: /etc/traefik-hub/dynamic/dashboard.yaml
    owner: root:root
    permissions: "0644"
    content: |
      ${indent(6, dashboard_config)}
%{ endif ~}

%{ if vip != "" ~}
  - path: /etc/keepalived/keepalived.conf
    owner: root:root
    permissions: "0644"
    content: |
      vrrp_instance VI_1 {
        state BACKUP
        interface ${network_interface}
        virtual_router_id 51
        priority ${keepalived_priority}
        advert_int 1
        authentication {
          auth_type PASS
          auth_pass 1111
        }
        virtual_ipaddress {
          ${vip}
        }
      }
%{ endif ~}

%{ if otlp_address != "" ~}
  - path: /etc/otelcol-contrib/config.yaml
    owner: root:root
    permissions: "0644"
    content: |
      receivers:
        prometheus:
          config:
            scrape_configs:
              - job_name: '${instance_name}'
                scrape_interval: 5s
                static_configs:
                  - targets: ['localhost:9101', 'localhost:9102']
      exporters:
        otlphttp:
          endpoint: "${otlp_address}"
          tls:
            insecure_skip_verify: true
      processors:
        resourcedetection:
          detectors: [env, system, ec2]
          timeout: 2s
          override: false
        batch:
          timeout: 5s
      service:
        pipelines:
          metrics:
            receivers: [prometheus]
            processors: [resourcedetection, batch]
            exporters: [otlphttp]
%{ endif ~}

runcmd:
  - sysctl -p /etc/sysctl.d/99-traefik-perf.conf
  - mkdir -p /etc/traefik-hub/dynamic
  - mkdir -p /data
  - echo "{}" > /data/acme.json && chmod 600 /data/acme.json
  - chmod 666 /etc/traefik-hub/dns-traefiker.env
  - sed -i 's/^PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
  - sed -i 's/^#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config
  - sysctl -w kernel.perf_event_paranoid=-1
  - echo "kernel.perf_event_paranoid = -1" > /etc/sysctl.d/99-perf.conf
  - systemctl restart ssh || systemctl restart sshd
  - |
    # Install Node Exporter v1.10.2
    if ! [ -f /usr/local/bin/node_exporter ]; then
      echo "Installing Node Exporter..."
      # Wait for network and retry download
      for i in {1..5}; do
        if curl -L --connect-timeout 10 --max-time 120 "https://github.com/prometheus/node_exporter/releases/download/v1.10.2/node_exporter-1.10.2.linux-amd64.tar.gz" -o /tmp/node_exporter.tar.gz; then
          mkdir -p /tmp/node_exporter-extract
          tar xvfz /tmp/node_exporter.tar.gz -C /tmp/node_exporter-extract
          BINARY=$(find /tmp/node_exporter-extract -type f -name "node_exporter" | head -n 1)
          if [ -n "$BINARY" ]; then
            mv "$BINARY" /usr/local/bin/node_exporter
            chmod +x /usr/local/bin/node_exporter
            echo "Node Exporter binary installed."
            break
          fi
        fi
        echo "Retrying Node Exporter download ($i/5)..."
        sleep 5
      done
      rm -rf /tmp/node_exporter-extract /tmp/node_exporter.tar.gz
    fi
    if [ -f /usr/local/bin/node_exporter ]; then
      systemctl daemon-reload
      systemctl enable node_exporter || true
      systemctl start node_exporter || true
    fi
%{ if enable_preview_mode ~}
  - |
    # Preview Mode: Install Docker, pull preview image, extract binary
    echo "Preview mode enabled - installing Docker to extract binary from container image..."

    # Install Docker
    apt-get update
    apt-get install -y ca-certificates curl gnupg
    install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    chmod a+r /etc/apt/keyrings/docker.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" > /etc/apt/sources.list.d/docker.list
    apt-get update
    apt-get install -y docker-ce docker-ce-cli containerd.io

    # Pull preview image and extract binary
    PREVIEW_IMAGE="${preview_image}"
    echo "Pulling preview image: $PREVIEW_IMAGE..."

    for i in {1..5}; do
      if docker pull "$PREVIEW_IMAGE"; then
        # Create temporary container and copy binary out
        CONTAINER_ID=$(docker create "$PREVIEW_IMAGE")
        if docker cp "$CONTAINER_ID:/usr/local/bin/traefik-hub" /usr/local/bin/traefik-hub 2>/dev/null || \
           docker cp "$CONTAINER_ID:/traefik-hub" /usr/local/bin/traefik-hub 2>/dev/null || \
           docker cp "$CONTAINER_ID:/usr/bin/traefik-hub" /usr/local/bin/traefik-hub 2>/dev/null; then
          chmod +x /usr/local/bin/traefik-hub
          echo "Traefik Hub preview binary extracted successfully."
        else
          echo "Searching for traefik-hub binary in container..."
          BINARY_PATH=$(docker run --rm --entrypoint="" "$PREVIEW_IMAGE" which traefik-hub 2>/dev/null || echo "")
          if [ -n "$BINARY_PATH" ]; then
            docker cp "$CONTAINER_ID:$BINARY_PATH" /usr/local/bin/traefik-hub
            chmod +x /usr/local/bin/traefik-hub
            echo "Traefik Hub preview binary found at $BINARY_PATH and extracted."
          fi
        fi
        docker rm "$CONTAINER_ID" 2>/dev/null || true
        break
      fi
      echo "Retrying preview image pull ($i/5)..."
      sleep 5
    done

    if [ ! -f /usr/local/bin/traefik-hub ]; then
      echo "ERROR: Failed to extract Traefik Hub binary from preview image"
      exit 1
    fi
%{ else ~}
  - |
    # Robust download and install
    ARCH="${arch}"
    VERSION="${traefik_hub_version}"
    [[ ! $VERSION =~ ^v ]] && VERSION="v$VERSION"
    DOWNLOAD_ARCH="amd64"
    [[ "$ARCH" == "aarch64" || "$ARCH" == "arm64" ]] && DOWNLOAD_ARCH="arm64"

    URL="https://github.com/traefik/hub/releases/download/$VERSION/traefik-hub_$${VERSION}_linux_$${DOWNLOAD_ARCH}.tar.gz"
    echo "Downloading Traefik Hub from $URL..."

    for i in {1..5}; do
      if curl -L --connect-timeout 10 --max-time 120 "$URL" -o /tmp/traefik-hub.tar.gz; then
        mkdir -p /tmp/traefik-hub-extract
        tar -xzf /tmp/traefik-hub.tar.gz -C /tmp/traefik-hub-extract
        BINARY=$(find /tmp/traefik-hub-extract -maxdepth 1 -type f -name "traefik-hub*" | head -n 1)
        if [ -n "$BINARY" ]; then
          mv "$BINARY" /usr/local/bin/traefik-hub
          chmod +x /usr/local/bin/traefik-hub
          echo "Traefik Hub binary installed."
          break
        fi
      fi
      echo "Retrying Traefik Hub download ($i/5)..."
      sleep 5
    done
    rm -rf /tmp/traefik-hub-extract /tmp/traefik-hub.tar.gz

    if [ ! -f /usr/local/bin/traefik-hub ]; then
      echo "ERROR: Failed to install Traefik Hub after retries"
      exit 1
    fi
%{ endif ~}

%{ if vip != "" ~}
  - |
    # Install Keepalived
    apt-get update && apt-get install -y keepalived
    systemctl enable --now keepalived
%{ endif ~}

  - systemctl daemon-reload
%{ if dns_traefiker.enabled ~}
  - |
    # Install dns-traefiker binary from GHCR
    if ! [ -f /usr/local/bin/dns-traefiker ]; then
      echo "Installing dns-traefiker from GHCR..."
      DOWNLOAD_ARCH="amd64"
      [[ "${arch}" == "aarch64" || "${arch}" == "arm64" ]] && DOWNLOAD_ARCH="arm64"
      GHCR_REPO="traefik-workshops/dns-traefiker-bin"
      GHCR_TAG="${dns_traefiker.version}-linux-$DOWNLOAD_ARCH"

      for i in {1..5}; do
        # Get anonymous pull token
        TOKEN=$(curl -sf "https://ghcr.io/token?scope=repository:$GHCR_REPO:pull" | \
          python3 -c "import sys,json;print(json.load(sys.stdin)['token'])" 2>/dev/null)
        if [ -z "$TOKEN" ]; then
          echo "Failed to get GHCR token (attempt $i/5)"
          sleep 5
          continue
        fi

        # Get manifest and extract binary layer digest
        DIGEST=$(curl -sf -H "Authorization: Bearer $TOKEN" \
          -H "Accept: application/vnd.oci.image.manifest.v1+json" \
          "https://ghcr.io/v2/$GHCR_REPO/manifests/$GHCR_TAG" | \
          python3 -c "import sys,json;print(json.load(sys.stdin)['layers'][0]['digest'])" 2>/dev/null)
        if [ -z "$DIGEST" ]; then
          echo "Failed to get manifest digest (attempt $i/5)"
          sleep 5
          continue
        fi

        # Download binary blob
        if curl -fL -H "Authorization: Bearer $TOKEN" \
          "https://ghcr.io/v2/$GHCR_REPO/blobs/$DIGEST" \
          -o /usr/local/bin/dns-traefiker; then
          chmod +x /usr/local/bin/dns-traefiker
          # Verify it's an actual binary
          if file /usr/local/bin/dns-traefiker | grep -q "ELF"; then
            echo "dns-traefiker binary installed successfully."
            break
          else
            echo "Downloaded file is not a valid ELF binary (attempt $i/5)"
            rm -f /usr/local/bin/dns-traefiker
          fi
        fi
        echo "Retrying dns-traefiker download ($i/5)..."
        sleep 5
      done
    fi
    if [ -f /usr/local/bin/dns-traefiker ]; then
      systemctl enable --now dns-traefiker
    else
      echo "WARNING: dns-traefiker binary not found, skipping service start"
    fi
%{ endif ~}
  - systemctl enable --now traefik-hub
  - echo "Traefik Hub provisioning complete"

%{ if otlp_address != "" ~}
  # Install OTEL Collector
  - |
    echo "Installing OTEL Collector..."
    curl -sfLO https://github.com/open-telemetry/opentelemetry-collector-releases/releases/download/v0.118.0/otelcol-contrib_0.118.0_linux_amd64.rpm || (echo "FAILED to download OTEL collector" && exit 1)
    rpm -ivh otelcol-contrib_0.118.0_linux_amd64.rpm || (echo "FAILED to install OTEL collector" && exit 1)
    systemctl enable --now otelcol-contrib
    systemctl restart otelcol-contrib
    echo "OTEL Collector status: $(systemctl is-active otelcol-contrib)"
%{ endif ~}
