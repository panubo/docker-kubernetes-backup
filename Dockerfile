FROM alpine:3.17

# Install system packages, installing a few packages to replace the busybox defaults
RUN set -x \
  && apk --no-cache add python3 ca-certificates wget bash curl coreutils gzip bzip2 lz4 tar \
  ;

# Install Gcloud SDK (required for gsutil workload identity authentication)
ENV \
  GCLOUD_VERSION=437.0.1 \
  GCLOUD_CHECKSUM=ff478c6697361495b8843597563656267eaca9d407a1780717acb882a212b8ff

RUN set -x \
  && curl -o /tmp/google-cloud-sdk-${GCLOUD_VERSION}-linux-x86_64.tar.gz -L https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-${GCLOUD_VERSION}-linux-x86_64.tar.gz \
  && echo "${GCLOUD_CHECKSUM}  google-cloud-sdk-${GCLOUD_VERSION}-linux-x86_64.tar.gz" > /tmp/SHA256SUM \
  && ( cd /tmp; sha256sum -c SHA256SUM || ( echo "Expected $(sha256sum google-cloud-sdk-${GCLOUD_VERSION}-linux-x86_64.tar.gz)"; exit 1; )) \
  && tar -C / -zxvf /tmp/google-cloud-sdk-${GCLOUD_VERSION}-linux-x86_64.tar.gz \
  && /google-cloud-sdk/install.sh --quiet \
  && ln -s /google-cloud-sdk/bin/gcloud /usr/local/bin/ \
  && ln -s /google-cloud-sdk/bin/gsutil /usr/local/bin/ \
  && rm -rf /tmp/* /root/.config/gcloud \
  ;

# Install AWS CLI
ENV \
  PYTHONIOENCODING=UTF-8 \
  PYTHONUNBUFFERED=0 \
  PAGER=more \
  AWS_CLI_VERSION=1.27.165 \
  AWS_CLI_CHECKSUM=c90a9405382b7bcfca8e795252cf7e04fff56734b6c0aeef179ff8c5a4f2c336

RUN set -x \
  && cd /tmp \
  && wget -nv https://s3.amazonaws.com/aws-cli/awscli-bundle-${AWS_CLI_VERSION}.zip -O /tmp/awscli-bundle-${AWS_CLI_VERSION}.zip \
  && echo "${AWS_CLI_CHECKSUM}  awscli-bundle-${AWS_CLI_VERSION}.zip" > /tmp/SHA256SUM \
  && ( cd /tmp; sha256sum -c SHA256SUM || ( echo "Expected $(sha256sum awscli-bundle-${AWS_CLI_VERSION}.zip)"; exit 1; )) \
  && unzip awscli-bundle-${AWS_CLI_VERSION}.zip \
  && /tmp/awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws \
  && rm -rf /tmp/* \
  ;

# Install katafygio
RUN set -x \
  && KATAFYGIO_VERSION=0.8.3 \
  && KATAFYGIO_SHA256=83f1709f2f577f77616cad0a03d11a6f94be89318aa4632f511c1bbe515532c5 \
  && if [ -n "$(readlink /usr/bin/wget)" ]; then \
      fetchDeps="${fetchDeps} wget"; \
     fi \
  && cd /tmp \
  && wget -nv https://github.com/bpineau/katafygio/releases/download/v${KATAFYGIO_VERSION}/katafygio_${KATAFYGIO_VERSION}_linux_amd64 \
  && echo "${KATAFYGIO_SHA256}  katafygio_${KATAFYGIO_VERSION}_linux_amd64" > /tmp/SHA256SUM \
  && ( cd /tmp; sha256sum -c SHA256SUM || ( echo "Expected $(sha256sum katafygio_${KATAFYGIO_VERSION}_linux_amd64)"; exit 1; )) \
  && chmod +x katafygio_${KATAFYGIO_VERSION}_linux_amd64 \
  && mv katafygio_${KATAFYGIO_VERSION}_linux_amd64 /usr/local/bin/katafygio \
  && rm -rf /tmp/* \
  ;
