FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV NONINTERACTIVE=1
ENV HOMEBREW_NO_ANALYTICS=1
ENV PATH="/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin:${PATH}"

RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates curl file git procps build-essential \
    && rm -rf /var/lib/apt/lists/*

RUN useradd -m -s /bin/bash linuxbrew \
    && mkdir -p /home/linuxbrew/.linuxbrew \
    && chown -R linuxbrew:linuxbrew /home/linuxbrew

USER linuxbrew
RUN /bin/bash -lc "curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh | /bin/bash"
RUN /bin/bash -lc "brew --version"

USER root
CMD ["bash"]
