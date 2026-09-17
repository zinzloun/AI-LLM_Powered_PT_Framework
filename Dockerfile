FROM kalilinux/kali-rolling

ENV DEBIAN_FRONTEND=noninteractive

# 1. Fix SSL temporaneo per APT e installazione certificati
RUN echo 'Acquire::https::Verify-Peer "false";' > /etc/apt/apt.conf.d/99ssl-fix && \
    apt-get update && apt-get install -y ca-certificates && \
    rm /etc/apt/apt.conf.d/99ssl-fix

# 2. Installa i tool di pentesting
RUN apt-get update && apt-get install -y \
    nmap whatweb ffuf gobuster \
    curl wget iputils-ping \
    && rm -rf /var/lib/apt/lists/*

# 3. Installa 'uv'
ADD https://astral.sh/uv/install.sh /install.sh
RUN chmod +x /install.sh && /install.sh && rm /install.sh
ENV PATH="/root/.local/bin:$PATH"

# 4. Crea l'ambiente virtuale Python 3.12
RUN uv venv /opt/venv --python 3.12
ENV PATH="/opt/venv/bin:$PATH"

# 5. Installa setuptools (versione compatibile) e open-interpreter
RUN uv pip install "setuptools<70" open-interpreter

WORKDIR /pentest

CMD ["/bin/bash"]
