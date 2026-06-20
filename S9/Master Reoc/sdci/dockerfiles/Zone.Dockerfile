# Ce Dockerfile génère une zone telles que définie dans le projet, donc avec 
# une Gateway finale, qui interconecte sur un lan 3 devices s
FROM node:alpine


RUN apk add --update --no-cache \
        bash \
        tcpdump \
        iperf \
        busybox-extras \
        iproute2 \
        iputils\
        curl\
        net-tools

WORKDIR /gateway
RUN npm install yargs@17.7.2 express systeminformation request
COPY gateway.js /gateway/gateway.js

COPY zone.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh


WORKDIR /device
RUN npm install yargs@17.7.2 express systeminformation request
RUN curl -L -k -o device.js "https://homepages.laas.fr/smedjiah/tmp/mw/device.js"

EXPOSE 8282
EXPOSE 8181

CMD ["tail", "-f", "/dev/null"]