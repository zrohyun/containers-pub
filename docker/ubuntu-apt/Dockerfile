FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

COPY docker/packages/apt-common.txt /tmp/apt-common.txt

RUN apt-get update \
    && xargs -r apt-get install -y --no-install-recommends < /tmp/apt-common.txt \
    && rm -rf /var/lib/apt/lists/* /tmp/apt-common.txt

CMD ["bash"]
