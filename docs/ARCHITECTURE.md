# System Architecture

## Overview

QGIS Cloud Browser is a containerized web-based GIS platform that runs full QGIS Desktop in the browser using Docker, VNC, and noVNC technologies.

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                         Browser                             │
│  ┌──────────────────────────────────────────────────────┐  │
│  │           Dashboard (HTML/CSS/JS)                     │  │
│  │  - Server controls                                    │  │
│  │  - Resource monitoring                                │  │
│  │  - File management                                    │  │
│  └──────────────────────────────────────────────────────┘  │
│                           │                                 │
│                           ▼                                 │
│  ┌──────────────────────────────────────────────────────┐  │
│  │         noVNC Client (WebSocket)                      │  │
│  │  - Canvas rendering                                   │  │
│  │  - Mouse/keyboard events                              │  │
│  └──────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
                            │
                            │ HTTP/WebSocket
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                      nginx (Port 80/443)                    │
│  ┌──────────────────────────────────────────────────────┐  │
│  │  - Reverse proxy                                      │  │
│  │  - SSL termination                                    │  │
│  │  │  - Static file serving                             │  │
│  │  - WebSocket upgrade                                  │  │
│  └──────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
            │                              │
            │                              │
            ▼                              ▼
┌─────────────────────┐        ┌─────────────────────────────┐
│   noVNC Server      │        │      File Storage           │
│   (Port 6080)       │        │   - /data (shared volume)   │
│                     │        │   - /projects (persistent)  │
│ WebSocket Proxy     │        │   - /plugins (persistent)   │
└─────────────────────┘        └─────────────────────────────┘
            │
            │ WebSocket
            ▼
┌─────────────────────────────────────────────────────────────┐
│              QGIS Desktop Container                         │
│  ┌──────────────────────────────────────────────────────┐  │
│  │                  Xvfb (Virtual Display)               │  │
│  │  ┌────────────────────────────────────────────────┐  │  │
│  │  │          VNC Server (Port 5900)                │  │  │
│  │  │  ┌──────────────────────────────────────────┐  │  │  │
│  │  │  │         QGIS Desktop 3.34 LTR           │  │  │  │
│  │  │  │  - Full desktop environment (XFCE)      │  │  │  │
│  │  │  │  - QGIS with all features               │  │  │  │
│  │  │  │  - GDAL, GRASS, SAGA                    │  │  │  │
│  │  │  │  - Python console & plugins             │  │  │  │
│  │  │  └──────────────────────────────────────────┘  │  │  │
│  │  └────────────────────────────────────────────────┘  │  │
│  └──────────────────────────────────────────────────────┘  │
│                                                             │
│  Mounted Volumes:                                           │
│  - /data → Host ./data                                      │
│  - /projects → Host ./qgis-projects                         │
│  - /plugins → Host ./qgis-plugins                           │
│  - /config → Docker volume (qgis-config)                    │
└─────────────────────────────────────────────────────────────┘
```

## Component Details

### 1. Browser Layer

#### Dashboard (Static HTML)
- **Technology**: Vanilla JavaScript, CSS3
- **Features**:
  - Real-time resource monitoring
  - Server start/stop controls
  - File upload/download
  - Session management
  - Responsive design
- **Communication**: Fetch API to nginx endpoints

#### noVNC Client
- **Technology**: JavaScript WebSocket client
- **Function**: Renders VNC stream to HTML5 Canvas
- **Features**:
  - Mouse position tracking
  - Keyboard event forwarding
  - Clipboard sync
  - Auto-reconnect

### 2. Web Server Layer (nginx)

#### Configuration
```nginx
upstream novnc {
    server novnc:6080;
}

server {
    listen 80;
    
    # Serve dashboard
    location / {
        root /usr/share/nginx/html;
        try_files $uri $uri/ /index.html;
    }
    
    # Proxy to noVNC
    location /vnc/ {
        proxy_pass http://novnc/;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
    }
}
```

#### Responsibilities
- Static file serving (dashboard)
- Reverse proxy to noVNC
- WebSocket protocol upgrade
- SSL/TLS termination (production)
- Request logging

### 3. noVNC Server Layer

#### Technology Stack
- **Base**: Python websockify
- **Protocol**: WebSocket to TCP bridge
- **Port Mapping**: 6080 (HTTP) → 5900 (VNC)

#### Function
1. Receives WebSocket connections from browser
2. Translates to VNC protocol
3. Forwards to VNC server in QGIS container
4. Bidirectional stream relay

### 4. QGIS Desktop Container

#### Base Image
```dockerfile
FROM ubuntu:22.04
```

#### Software Stack

**Display Server:**
- Xvfb (X Virtual Frame Buffer)
- X11VNC (VNC server)
- Resolution: Configurable (default 1920x1080)

**Desktop Environment:**
- XFCE4 (lightweight)
- Custom theme
- Minimal resource usage

**QGIS Installation:**
```bash
# From official QGIS repository
QGIS 3.34 LTR (Long Term Release)
- Core application
- Python bindings (3.10)
- Processing framework
```

**Dependencies:**
- GDAL 3.6+
- PROJ 9.0+
- SQLite with SpatiaLite
- PostgreSQL client (PostGIS support)
- GRASS GIS 8.2
- SAGA GIS 7.8

**Python Environment:**
```python
# Pre-installed packages
pip3 install:
  - numpy
  - pandas
  - matplotlib
  - geopandas
  - rasterio
  - shapely
  - pyproj
```

#### File System Structure
```
/
├── root/
│   └── .config/QGIS/  → /config (persistent)
├── data/              → ./data (host mount)
├── projects/          → ./qgis-projects (host mount)
├── plugins/           → ./qgis-plugins (host mount)
├── usr/
│   └── share/qgis/
│       └── python/plugins/
└── tmp/               → /dev/shm (memory)
```

## Data Flow

### Session Initialization

```
1. User opens http://localhost:8080
   ↓
2. nginx serves dashboard HTML
   ↓
3. User clicks "Launch QGIS"
   ↓
4. Browser redirects to /vnc/vnc.html
   ↓
5. noVNC client loads
   ↓
6. WebSocket connects to nginx:80/vnc/websockify
   ↓
7. nginx proxies to novnc:6080/websockify
   ↓
8. noVNC server connects to qgis-desktop:5900 (VNC)
   ↓
9. X11VNC sends desktop framebuffer
   ↓
10. noVNC renders to browser canvas
```

### User Interaction

```
User Input (mouse/keyboard)
   ↓
JavaScript captures event
   ↓
noVNC client encodes as VNC protocol
   ↓
WebSocket sends to server
   ↓
noVNC server decodes
   ↓
X11VNC injects to X server
   ↓
QGIS receives input
   ↓
QGIS updates display
   ↓
X11VNC captures framebuffer
   ↓
noVNC server encodes
   ↓
WebSocket sends to client
   ↓
noVNC renders update
   ↓
User sees result
```

### File Upload

```
1. User drags file to dashboard
   ↓
2. JavaScript reads file as ArrayBuffer
   ↓
3. POST request to nginx
   ↓
4. nginx writes to /data volume
   ↓
5. Docker bind mount syncs to container
   ↓
6. File appears in QGIS /data directory
```

## Resource Management

### CPU Allocation

```yaml
# docker-compose.yml
services:
  qgis-desktop:
    deploy:
      resources:
        limits:
          cpus: '2'      # 2 cores max
        reservations:
          cpus: '0.5'    # 0.5 cores guaranteed
```

### Memory Management

```yaml
memory: 4G           # 4GB limit
memory-reservation: 2G  # 2GB guaranteed
shm_size: 2G         # Shared memory for X server
```

### Storage Strategy

**Docker Volumes** (Persistent):
- `qgis-config`: QGIS settings, plugins
- Size: ~500MB
- Survives container recreation

**Bind Mounts** (Host-accessible):
- `./data`: GIS data files
- `./qgis-projects`: Project files (.qgs/.qgz)
- `./qgis-plugins`: Custom plugins
- Direct host access for backup/transfer

**Shared Memory** (`/dev/shm`):
- Temporary files
- X server buffers
- Fast, in-memory
- Cleared on restart

## Network Architecture

### Port Mapping

```
Host        Container       Service
────        ─────────       ───────
8080   →    80              nginx (HTTP)
─      →    6080            noVNC (internal)
─      →    5900            VNC (internal)
```

### Internal Network

```yaml
networks:
  qgis-network:
    driver: bridge
    ipam:
      config:
        - subnet: 172.25.0.0/16
```

**Service IPs** (auto-assigned):
- nginx: 172.25.0.2
- novnc: 172.25.0.3
- qgis-desktop: 172.25.0.4

### DNS Resolution

Docker Compose creates internal DNS:
- `nginx` → nginx container
- `novnc` → noVNC container
- `qgis-desktop` → QGIS container

## Security Model

### Authentication

1. **VNC Password**: Required for desktop access
   - Stored encrypted in container
   - Configurable via `VNC_PASSWORD` env var

2. **No Web Auth**: Dashboard has no authentication
   - Suitable for localhost
   - Add nginx auth for production

### Network Isolation

- Containers on private bridge network
- Only nginx exposed to host
- Internal services not accessible externally

### File System

- QGIS runs as non-root user
- Mounted volumes have restricted permissions
- No container write access to host

## Performance Optimization

### Image Compression

```dockerfile
# Multi-stage build
FROM ubuntu:22.04 AS builder
# ... build steps ...

FROM ubuntu:22.04
COPY --from=builder /artifacts /
# Reduced final image size
```

### Layer Caching

```dockerfile
# Order: least → most frequently changing
RUN apt-get update && apt-get install ...
COPY requirements.txt .
RUN pip install -r requirements.txt
COPY . .
```

### noVNC Compression

```javascript
// noVNC config
RFB.compressionLevel = 2;  // Balance quality/bandwidth
RFB.qualityLevel = 6;       // JPEG quality
```

### VNC Framebuffer

```bash
# Reduce updates for better performance
x11vnc -wait 10        # 10ms wait between polls
       -defer 10       # Defer updates by 10ms
       -threads        # Multi-threaded encoding
```

## Scalability

### Horizontal Scaling

```yaml
# docker-compose.scale.yml
services:
  qgis-desktop:
    deploy:
      replicas: 3
```

**Load Balancer** (nginx):
```nginx
upstream qgis_cluster {
    least_conn;
    server qgis-desktop-1:5900;
    server qgis-desktop-2:5900;
    server qgis-desktop-3:5900;
}
```

### Vertical Scaling

```bash
# Increase container resources
docker compose up -d --scale qgis-desktop=1 \
  --memory=8G \
  --cpus=4
```

## Monitoring

### Health Checks

```yaml
services:
  qgis-desktop:
    healthcheck:
      test: ["CMD", "nc", "-z", "localhost", "5900"]
      interval: 30s
      timeout: 10s
      retries: 3
```

### Resource Metrics

```bash
# Built-in Docker stats
docker stats qgis-desktop

# Output:
CONTAINER       CPU %    MEM USAGE / LIMIT     NET I/O
qgis-desktop    15.3%    1.2GiB / 4GiB         1.2MB / 850KB
```

### Log Aggregation

```bash
# Centralized logging
docker compose logs -f | tee logs/qgis-$(date +%Y%m%d).log
```

## Backup & Recovery

### Backup Strategy

**Critical Data**:
1. `./data/` - User GIS data
2. `./qgis-projects/` - Project files
3. `qgis-config` volume - Settings

**Backup Script**:
```bash
#!/bin/bash
tar -czf backup-$(date +%Y%m%d).tar.gz \
    data/ \
    qgis-projects/ \
    qgis-plugins/

docker run --rm -v qgis-config:/data \
    -v $(pwd):/backup \
    alpine tar -czf /backup/config-backup.tar.gz /data
```

### Disaster Recovery

1. **Reinstall containers**: `docker compose up -d`
2. **Restore volumes**: `docker volume create qgis-config`
3. **Extract backup**: `tar -xzf backup.tar.gz`
4. **Restart services**: `docker compose restart`

## Future Enhancements

### Planned Features

1. **Multi-user support**
   - Session management
   - User authentication
   - Isolated workspaces

2. **WebGL rendering**
   - Direct GPU access
   - Hardware acceleration
   - Better 3D performance

3. **Cloud storage integration**
   - S3/GCS mounts
   - Real-time sync
   - Versioning

4. **Kubernetes deployment**
   - Auto-scaling
   - High availability
   - Service mesh

### Experimental

- **QGIS Server integration**: WMS/WFS publishing
- **Jupyter notebook**: Python GIS scripting
- **Real-time collaboration**: Shared editing sessions

## References

- [QGIS Documentation](https://docs.qgis.org/)
- [noVNC Project](https://github.com/novnc/noVNC)
- [Docker Documentation](https://docs.docker.com/)
- [nginx Documentation](https://nginx.org/en/docs/)