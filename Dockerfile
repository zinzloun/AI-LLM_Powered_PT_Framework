FROM kalilinux/kali-rolling

ENV DEBIAN_FRONTEND=noninteractive

# 1. Temporary SSL fix for APT and ca-certificates installation
RUN echo 'Acquire::https::Verify-Peer "false";' > /etc/apt/apt.conf.d/99ssl-fix && \
    apt-get update && apt-get install -y ca-certificates && \
    rm /etc/apt/apt.conf.d/99ssl-fix

# 2. Install pentesting tools and C compilation headers for ARM64
RUN apt-get update && apt-get install -y \
    gcc python3-dev build-essential \
    nmap whatweb ffuf gobuster \
    curl wget iputils-ping \
    && rm -rf /var/lib/apt/lists/*

# 3. Install 'uv' package manager
ADD https://astral.sh/uv/install.sh /install.sh
RUN chmod +x /install.sh && /install.sh && rm /install.sh
ENV PATH="/root/.local/bin:$PATH"

# 4. Create Python 3.12 virtual environment
RUN uv venv /opt/venv --python 3.12
ENV PATH="/opt/venv/bin:$PATH"

# 5. Install setuptools (<70) and open-interpreter
RUN uv pip install "setuptools<70" open-interpreter

WORKDIR /pentest

CMD ["/bin/bash"]
