SERVER_IP=$(ifconfig | grep "inet " | grep -v 127.0.0.1 | cut -d\  -f2);

exec socat TCP-LISTEN:6000,reuseaddr,fork UNIX-CLIENT:\"$DISPLAY\" &

sudo docker run -tdi \
    -u root \
    --net="host" \
    --privileged=true \
    -e DISPLAY=${SERVER_IP}:0 \
    -v /tmp/.X11-unix:/tmp/.X11-unix:ro \
    -v ${HOME}/.Xauthority:/home/developer/.Xauthority:ro \
    --net=host \
    900260da0173;