# Troubleshooting Guide

## Common Issues

### Black Screen in noVNC

**Symptoms:**
- noVNC connects but shows black screen
- Can't see QGIS interface

**Solutions:**

1. **Check Xvfb is running**
   ```bash
   docker exec qgis-desktop ps aux | grep Xvfb
   ```

2. **Check VNC server**
   ```bash
   docker exec qgis-desktop ps aux | grep x11vnc
   ```

3. **Restart container**
   ```bash
   docker compose restart qgis-desktop
   ```

4. **Check logs**
   ```bash
   docker compose logs qgis-desktop
   ```

### QGIS Won't Start

**Symptoms:**
- QGIS crashes on startup
- Error messages in logs

**Solutions:**

1. **Check memory**
   ```bash
   docker stats qgis-desktop
   ```
   - If using 90%+ memory, increase limit

2. **Increase memory limit**
   ```bash
   # Edit docker-compose.yml
   memory: 8G  # Increase from 4G
   ```

3. **Check QGIS config**
   ```bash
   docker exec qgis-desktop ls -la /root/.local/share/QGIS
   ```

4. **Reset QGIS config**
   ```bash
   docker volume rm qgis-cloud-browser_qgis-config
   docker compose up -d
   ```

### Slow Performance

**Symptoms:**
- Laggy mouse
- Slow screen updates
- High latency

**Solutions:**

1. **Reduce color depth**
   ```bash
   # Edit .env
   VNC_COLOR_DEPTH=16  # Down from 24
   ```

2. **Lower resolution**
   ```bash
   # Edit .env
   VNC_RESOLUTION=1280x720  # Down from 1920x1080
   ```

3. **Enable compression in noVNC**
   - In noVNC interface: Settings → Quality: Low
   - Compression: High

4. **Check network**
   ```bash
   ping <server-ip>
   traceroute <server-ip>
   ```

### Can't Upload Large Files

**Symptoms:**
- Upload fails for files > 100MB
- 413 Request Entity Too Large error

**Solution:**

1. **Increase Nginx upload limit**
   ```bash
   # Edit nginx/default.conf
   client_max_body_size 2G;  # Increase from 500M
   ```

2. **Restart Nginx**
   ```bash
   docker compose restart nginx
   ```

### Permission Errors

**Symptoms:**
- Can't save projects
- Can't write to data folder

**Solution:**

1. **Fix permissions**
   ```bash
   sudo chown -R 1000:1000 data/ qgis-projects/ qgis-plugins/
   chmod -R 755 data/ qgis-projects/ qgis-plugins/
   ```

### Container Won't Start

**Symptoms:**
- `docker compose up` fails
- Container exits immediately

**Solutions:**

1. **Check Docker logs**
   ```bash
   docker compose logs
   ```

2. **Check port conflicts**
   ```bash
   sudo lsof -i :8080
   sudo lsof -i :6080
   ```

3. **Rebuild containers**
   ```bash
   docker compose down
   docker compose build --no-cache
   docker compose up -d
   ```

### SSL Certificate Errors

**Symptoms:**
- "Your connection is not private"
- Certificate warnings

**Solutions:**

1. **Check certificate files**
   ```bash
   ls -la nginx/certs/
   ```

2. **Verify certificate**
   ```bash
   openssl x509 -in nginx/certs/cert.pem -text -noout
   ```

3. **Renew Let's Encrypt**
   ```bash
   sudo certbot renew --force-renewal
   ./scripts/setup-ssl.sh yourdomain.com
   ```

## Performance Optimization

### For Low-End Hardware

```bash
# .env settings
VNC_RESOLUTION=1024x768
VNC_COLOR_DEPTH=16
CPU_LIMIT=1
MEMORY_LIMIT=2G
```

### For High-End Hardware

```bash
# .env settings
VNC_RESOLUTION=1920x1080
VNC_COLOR_DEPTH=24
CPU_LIMIT=4
MEMORY_LIMIT=8G
```

### For Oracle Cloud Free Tier

```bash
# .env settings (optimal)
VNC_RESOLUTION=1920x1080
VNC_COLOR_DEPTH=24
CPU_LIMIT=4
MEMORY_LIMIT=20G
```

## Debug Mode

 Enable debug logging:

```bash
# Edit .env
DEBUG=true
LOG_LEVEL=debug

# Restart
docker compose down
docker compose up -d

# View logs
docker compose logs -f
```

## Getting Help

If you're still stuck:

1. **Check logs**
   ```bash
   docker compose logs > logs.txt
   ```

2. **System info**
   ```bash
   docker version > sysinfo.txt
   docker compose version >> sysinfo.txt
   uname -a >> sysinfo.txt
   ```

3. **Open issue**: https://github.com/MarcoJ03rgensen/qgis-cloud-browser/issues
   - Include logs.txt and sysinfo.txt
   - Describe the problem
   - Steps to reproduce

---

**Most issues can be resolved by restarting containers and checking resource usage!**