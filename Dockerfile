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

RUN while IFS= read -r script; do \
        if [ -n "$script" ]; then \
            install -m 0755 "/src/$script" "/usr/local/bin/$script"; \
        fi; \
    done < /src/ci/packaged-scripts.txt && \
    rm -rf /src

CMD ["bash"]
