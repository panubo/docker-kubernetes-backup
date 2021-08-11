FROM alpine:3.14

# Install system packages, installing a few packages to replace the busybox defaults
RUN set -x \
  && apk --no-cache add python3 ca-certificates wget bash curl coreutils gzip bzip2 lz4 tar \
  && ln -s /usr/bin/python3 /usr/bin/python \
  ;

# Install Gcloud SDK (required for gsutil workload identity authentication)
ENV \
  GCLOUD_VERSION=331.0.0 \
  GCLOUD_CHECKSUM=f90c2df5bd0b3498d7e33112f17439eead8c94ae7d60a1cab0091de0eee62c16

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
  AWS_CLI_VERSION=1.16.286 \
  AWS_CLI_CHECKSUM=7e99ea733b3d97b1fa178fab08b5d7802d0647ad514c14221513c03ce920ce83

RUN set -x \
  && cd /tmp \
  && wget -nv https://s3.amazonaws.com/aws-cli/awscli-bundle-${AWS_CLI_VERSION}.zip -O /tmp/awscli-bundle-${AWS_CLI_VERSION}.zip \
  && echo "${AWS_CLI_CHECKSUM}  awscli-bundle-${AWS_CLI_VERSION}.zip" > /tmp/SHA256SUM \
  && sha256sum -c SHA256SUM \
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
