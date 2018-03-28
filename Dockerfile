FROM docker:18.03
ARG HELM_VERSION=2.8.2
RUN apk add dos2unix --update-cache --repository http://dl-3.alpinelinux.org/alpine/edge/community/ --allow-untrusted && \
    apk add --no-cache bash dos2unix && \
    wget https://kubernetes-helm.storage.googleapis.com/helm-v$HELM_VERSION-linux-amd64.tar.gz && \
    tar zxvf helm-v$HELM_VERSION-linux-amd64.tar.gz && \
    rm helm-v$HELM_VERSION-linux-amd64.tar.gz && \
    chmod +x linux-amd64/helm && \
    mv linux-amd64/helm /usr/local/bin/helm && \
    mkdir /app
VOLUME /app

ADD ./run.sh /
RUN dos2unix /run.sh && chmod +x /run.sh && \
    helm init --client-only

ENTRYPOINT ["/run.sh"]
CMD ["/run.sh"]
