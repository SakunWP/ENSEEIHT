# Ce Dockerfile génère une Gateway Intermediaire qui interconecte les serveur et les zones
FROM node:alpine

RUN apk add --update --no-cache \
        bash \
        tcpdump \
        iperf \
        busybox-extras \
        iproute2 \
        iputils \
        curl\
        net-tools


WORKDIR /gateway
RUN npm install yargs@17.7.2 express systeminformation request

COPY gateway.js /gateway/gateway.js
COPY gateway.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 8181
EXPOSE 8080

# Entrypoint : lance la gateway
CMD ["tail", "-f", "/dev/null"]