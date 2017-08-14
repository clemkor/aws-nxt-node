FROM openjdk:8-jre

ENV NXT_VERSION="1.11.7"
ENV NXT_SIGNING_KEY_ID="0xc654d7fcff18fd55"

# Install prerequisites
RUN apt-get update \
    && apt-get -y install curl unzip gettext \
    && rm -rf /var/lib/apt/lists

# Install AWS CLI
RUN apt-get update \
    && apt-get -y install python \
    && cd /tmp \
    && curl -L "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip" -o "awscli-bundle.zip" \
    && unzip awscli-bundle.zip \
    && ./awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws \
    && rm awscli-bundle.zip \
    && rm -rf awscli-bundle \
    && rm -rf /var/lib/apt/lists

# Install NXT client
RUN cd /tmp \
    && curl -L "https://bitbucket.org/Jelurida/nxt/downloads/nxt-client-${NXT_VERSION}.zip" -o "nxt-client-${NXT_VERSION}.zip" \
    && curl -L "https://bitbucket.org/Jelurida/nxt/downloads/nxt-client-${NXT_VERSION}.zip.asc" -o "nxt-client-${NXT_VERSION}.zip.asc" \
    && gpg --keyserver pgpkeys.mit.edu --recv-keys ${NXT_SIGNING_KEY_ID} \
    && gpg --verify nxt-client-${NXT_VERSION}.zip.asc nxt-client-${NXT_VERSION}.zip \
    && unzip nxt-client-${NXT_VERSION}.zip \
    && mv nxt /opt/ \
    && rm nxt-client-${NXT_VERSION}.zip nxt-client-${NXT_VERSION}.zip.asc

# Add startup script and properties template
ADD nxt.sh /opt/nxt/nxt.sh
ADD nxt.properties.template /opt/nxt/conf/nxt.properties.template
ADD nxt-default.env /opt/nxt/conf/nxt-default.env

RUN ["chmod", "+x", "/opt/nxt/nxt.sh"]

# Expose default ports
EXPOSE 6876 7876 6874 7874

# Run startup script by default
CMD ["/opt/nxt/nxt.sh"]