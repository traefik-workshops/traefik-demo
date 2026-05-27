FROM python:3.11-alpine

# Install system dependencies including Java, catatonit, and build tools
RUN apk add --no-cache \
    openjdk21-jre \
    unzip \
    wget \
    ca-certificates \
    bash \
    catatonit \
    gcc \
    musl-dev \
    python3-dev \
    && update-ca-certificates

# Install mcp-proxy via pip
RUN pip install --no-cache-dir mcp-proxy

# Install SQLcl
WORKDIR /opt
RUN wget -O /tmp/sqlcl.zip https://download.oracle.com/otn_software/java/sqldeveloper/sqlcl-latest.zip \
 && unzip /tmp/sqlcl.zip -d /opt \
 && chmod +x /opt/sqlcl/bin/sql \
 && ln -sf /opt/sqlcl/bin/sql /usr/local/bin/sql \
 && rm -f /tmp/sqlcl.zip

EXPOSE 8096

ENTRYPOINT ["catatonit","--","mcp-proxy","--host","0.0.0.0","--port","8096","--","/opt/sqlcl/bin/sql","-mcp"]