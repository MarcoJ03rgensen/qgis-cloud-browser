# Multi-stage build for optimized QGIS cloud deployment
FROM ubuntu:22.04 as base

# Prevent interactive prompts
ENV DEBIAN_FRONTEND=noninteractive

# Install base dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    gnupg \
    lsb-release \
    wget \
    software-properties-common \
    && rm -rf /var/lib/apt/lists/*

# Add QGIS repository
ARG QGIS_VERSION=ltr
RUN wget -qO - https://qgis.org/downloads/qgis-2022.gpg.key | gpg --no-default-keyring --keyring gnupg-ring:/etc/apt/trusted.gpg.d/qgis-archive.gpg --import && \
    chmod a+r /etc/apt/trusted.gpg.d/qgis-archive.gpg && \
    add-apt-repository "deb https://qgis.org/ubuntu-${QGIS_VERSION} $(lsb_release -c -s) main"

# Install QGIS, X11, VNC, and utilities
RUN apt-get update && apt-get install -y --no-install-recommends \
    qgis \
    qgis-plugin-grass \
    python3-qgis \
    # X11 and desktop environment
    xvfb \
    x11vnc \
    openbox \
    tigervnc-standalone-server \
    tigervnc-common \
    # Fonts and rendering
    fonts-liberation \
    fonts-dejavu \
    fontconfig \
    # Utilities
    curl \
    unzip \
    supervisor \
    dbus-x11 \
    # Python packages for QGIS plugins
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

# Install common QGIS plugin dependencies
RUN pip3 install --no-cache-dir \
    numpy \
    pandas \
    scipy \
    matplotlib \
    requests

# Create necessary directories
RUN mkdir -p \
    /data \
    /root/.vnc \
    /root/.local/share/QGIS/QGIS3/profiles/default/python/plugins \
    /root/QGIS/projects \
    /var/log/supervisor

# Configure VNC
COPY vnc_startup.sh /usr/local/bin/vnc_startup.sh
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
RUN chmod +x /usr/local/bin/vnc_startup.sh

# Set default VNC password (will be overridden by env var)
RUN echo "qgis2024" | tigervncpasswd -f > /root/.vnc/passwd && \
    chmod 600 /root/.vnc/passwd

# Configure Xvfb and VNC
ENV DISPLAY=:1 \
    VNC_PORT=5900 \
    VNC_RESOLUTION=1920x1080 \
    VNC_COLOR_DEPTH=24

# Expose VNC port
EXPOSE 5900

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD x11vnc -display :1 -passwd $(cat /root/.vnc/passwd) -bg -nopw -once -rfbport 5900 2>&1 | grep -q "PORT=5900" || exit 1

# Start supervisor
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]