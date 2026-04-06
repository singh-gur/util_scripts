FROM debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    awscli \
    bash \
    ca-certificates \
    curl \
    file \
    git \
    iproute2 \
    jq \
    less \
    nfs-common \
    openssh-client \
    postgresql-client \
    procps \
    tmux \
    unzip \
    wget \
    xz-utils \
    zip \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /workspace

COPY . /src

RUN for script in /src/*; do \
        if [ -f "$script" ] && [ -x "$script" ]; then \
            install -m 0755 "$script" "/usr/local/bin/$(basename "$script")"; \
        fi; \
    done && \
    rm -rf /src

CMD ["bash"]
