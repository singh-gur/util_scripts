FROM debian:trixie-slim

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
    pipx \
    postgresql-client \
    procps \
    python3 \
    skopeo \
    tmux \
    unzip \
    wget \
    xz-utils \
    zip \
    && rm -rf /var/lib/apt/lists/*

ENV PATH="/root/.local/bin:${PATH}"

RUN pipx install faraday-cli

RUN curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh \
    | sh -s -- -b /usr/local/bin

WORKDIR /workspace

COPY . /src

RUN for script in /src/*; do \
        if [ -f "$script" ] && [ -x "$script" ]; then \
            install -m 0755 "$script" "/usr/local/bin/$(basename "$script")"; \
        fi; \
    done && \
    rm -rf /src

CMD ["bash"]
