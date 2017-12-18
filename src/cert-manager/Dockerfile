FROM openjdk:8-jdk

# Install prerequisites
RUN apt-get update \
    && apt-get -y install curl unzip gettext jq \
    && rm -rf /var/lib/apt/lists

# Install certbot
RUN echo 'deb http://deb.debian.org/debian stretch-backports main' > /etc/apt/sources.list.d/backports.list \\
    && apt-get update \
    && apt-get -y install certbot -t stretch-backports \
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
    && cd / \
    && rm -rf /var/lib/apt/lists

# Add scripts
ADD cert-manager.sh /opt/cert-manager/cert-manager.sh
ADD scripts /opt/cert-manager/scripts

RUN ["chmod", "+x", "/opt/cert-manager/cert-manager.sh"]
RUN ["chmod", "+x", "/opt/cert-manager/scripts/route53-auth-hook.sh"]
RUN ["chmod", "+x", "/opt/cert-manager/scripts/route53-cleanup-hook.sh"]
RUN ["chmod", "+x", "/opt/cert-manager/scripts/route53-verification-record-manager.sh"]

# Add templates
ADD templates /opt/cert-manager/templates

# Run startup script by default
CMD ["/opt/cert-manager/cert-manager.sh"]
