FROM openjdk:8-jre

# Install prerequisites
RUN apt-get update \
    && apt-get -y install curl unzip \
    && rm -rf /var/lib/apt/lists

# Install certbot
RUN apt-get update \
    && apt-get -y install certbot \
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

# Add startup script
ADD cert-manager.sh /opt/cert-manager/cert-manager.sh

RUN ["chmod", "+x", "/opt/cert-manager/cert-manager.sh"]

# Run startup script by default
CMD ["/opt/cert-manager/cert-manager.sh"]
