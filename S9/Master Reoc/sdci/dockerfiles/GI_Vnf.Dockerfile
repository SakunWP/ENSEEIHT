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

RUN curl -L -k -o gateway.js "https://homepages.laas.fr/smedjiah/tmp/mw/gateway.js"

COPY gateway.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh


ENV VIM_EMU_CMD "node /gateway/gateway.js --local_ip 0.0.0.0 --local_port 8181 --local_name gi_vnf --remote_ip 10.0.0.5 --remote_port 8080 --remote_name srv"
ENV VIM_EMU_CMD_STOP "echo 'Stopping the VNF container...'"


EXPOSE 8181
EXPOSE 8080

# Entrypoint : lance la gateway
CMD ["tail", "-f", "/dev/null"]