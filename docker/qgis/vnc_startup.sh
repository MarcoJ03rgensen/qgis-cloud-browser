#!/bin/bash
set -e

echo "Starting QGIS Cloud Browser VNC server..."

# Set VNC password from environment variable
if [ -n "$VNC_PASSWORD" ]; then
    echo "$VNC_PASSWORD" | tigervncpasswd -f > /root/.vnc/passwd
    chmod 600 /root/.vnc/passwd
    echo "VNC password updated from environment variable"
fi

# Set resolution
VNC_RESOLUTION=${VNC_RESOLUTION:-1920x1080}
VNC_COLOR_DEPTH=${VNC_COLOR_DEPTH:-24}

echo "Starting Xvfb on $DISPLAY with resolution $VNC_RESOLUTION and color depth $VNC_COLOR_DEPTH"

# Start Xvfb
Xvfb $DISPLAY -screen 0 ${VNC_RESOLUTION}x${VNC_COLOR_DEPTH} -ac +extension GLX +render -noreset &
XVFB_PID=$!

# Wait for X server to start
sleep 2

# Start window manager
echo "Starting Openbox window manager"
openbox &
OPENBOX_PID=$!

# Configure dbus
eval $(dbus-launch --sh-syntax)
export DBUS_SESSION_BUS_ADDRESS
export DBUS_SESSION_BUS_PID

# Start VNC server
echo "Starting TigerVNC server on port $VNC_PORT"
x11vnc -display $DISPLAY \
       -forever \
       -shared \
       -rfbport $VNC_PORT \
       -rfbauth /root/.vnc/passwd \
       -bg \
       -xkb \
       -nopw \
       -wait 5 &
       
VNC_PID=$!

# Wait for VNC to start
sleep 3

# Start QGIS
echo "Starting QGIS Desktop"
export QT_X11_NO_MITSHM=1
export XDG_RUNTIME_DIR=/tmp/runtime-root
mkdir -p $XDG_RUNTIME_DIR
chmod 700 $XDG_RUNTIME_DIR

qgis &
QGIS_PID=$!

echo "QGIS Cloud Browser started successfully!"
echo "Xvfb PID: $XVFB_PID"
echo "Openbox PID: $OPENBOX_PID"
echo "VNC PID: $VNC_PID"
echo "QGIS PID: $QGIS_PID"

# Keep container running and monitor processes
while kill -0 $XVFB_PID 2>/dev/null && kill -0 $VNC_PID 2>/dev/null; do
    sleep 5
done

echo "One or more critical processes died, exiting..."
exit 1