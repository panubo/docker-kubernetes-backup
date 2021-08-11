# Kubernetes Backup Docker Image

This image contains the following tools indented to enable easy backup of a kubernetes cluster to object storage.

* [katafygio](https://github.com/bpineau/katafygio/)
* [awscli](https://aws.amazon.com/cli/)
* [gcloud](https://cloud.google.com/sdk/)

## Example

```
#!/usr/bin/env bash

set -e

katafygio \
  --dump-only \
  --local-dir ./${CLUSTER_NAME}/ \
  --no-git \
  --exclude-having-owner-ref \
  --exclude-kind events,nodes,endpoints
```
