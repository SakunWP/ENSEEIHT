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

# Répertoire de travail
WORKDIR /serveur
RUN npm install yargs@17.7.2 express systeminformation request

RUN curl -L -k -o server.js "https://homepages.laas.fr/smedjiah/tmp/mw/server.js"

COPY serveur.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh


WORKDIR /app 
RUN npm install yargs@17.7.2 express systeminformation request

RUN curl -L -k -o application.js "https://homepages.laas.fr/smedjiah/tmp/mw/application.js"

EXPOSE 8080

# Entrypoint : lance le serveur
CMD ["tail", "-f", "/dev/null"]