# AI-LLM_Powered_PT_Framework


A modular, privacy-focused, **human-in-the-loop** security testing lab running completely locally on Apple Silicon. Powered by Ollama, Qwen2.5-Coder, Open Interpreter, and a containerized Kali Linux environment targeting OWASP Juice Shop.

---

## Key Features

* **100% Local & Private:** Runs without cloud dependencies using Ollama (`qwen2.5-coder:32b`).
* **Human-in-the-Loop Control:** Open Interpreter interface asks for explicit confirmation before executing any CLI command.
* **Isolated Environment:** Pentesting CLI tools (`nmap`, `ffuf`, `gobuster`, `whatweb`) run inside an isolated Kali Linux Docker container.
* **Context-Optimized:** Custom `Modelfile` with expanded context limits (`num_ctx 8192`) to prevent log truncations.
* **Benchmarking Target:** Integrated OWASP Juice Shop container for measuring LLM accuracy and false-positive rates.

---

## Architecture Overview

```text
+-----------------------------------------------------------------------+
| macOS Host (Apple Silicon)                                            |
|  └── Ollama Server (http://localhost:11434)                           |
|        └── Custom Model: pentest-coder (Qwen2.5-Coder 32B, Q4/Q8)     |
+-----------------------------------------------------------------------+
                                │
                        API Inter-communication
                        (host.docker.internal)
                                │
                                ▼
+-----------------------------------------------------------------------+
| Docker Network (pt-ai-llm-lab)                                        |
|                                                                       |
|  ├── Container: kali_agent                                            |
|  │     ├── Open Interpreter (Python 3.12 via uv)                      |
|  │     └── Tools: nmap, ffuf, gobuster, whatweb, etc.                 |
|  │                                                                    |
|  └── Container: juice_shop                                            |
|        └── OWASP Juice Shop Target (Port 3000)                        |
+-----------------------------------------------------------------------+
```

---

## Prerequisites

* **Hardware:** Apple Silicon Mac (Recommended: 32GB+ Unified Memory - 16 GPU)
* **Software:**
  * [Ollama](https://ollama.com/)
  * [Docker Desktop](https://www.docker.com/products/docker-desktop/)

---

## Setup & Installation

### 1. Configure Ollama & Build Custom Model

Allow Ollama to accept connections from Docker containers and create the context-extended model:

```bash
# Allow external network bindings for Ollama
launchctl setenv OLLAMA_HOST "0.0.0.0"
# (Restart the Ollama macOS application after running the command above)

# get the model (+/- 20 GB)
ollama pull qwen2.5-coder:32b

# Create the custom model
ollama create pentest-coder -f Modelfile
```

### 2. Launch Docker Environment

Clone this repository and spin up the Kali agent and Juice Shop containers:

```bash
git clone https://github.com/your-username/local-ai-pentest-lab.git
cd local-ai-pentest-lab

# Build and start containers
docker compose build --no-cache
docker compose up -d
```

---

## Usage

### 1. Access the Kali Agent

Attach to the running Kali Linux container:

```bash
docker exec -it kali_agent bash
```

### 2. Start Open Interpreter

Run Open Interpreter pointing to your local Ollama instance on the host Mac:

```bash
interpreter --api_base http://host.docker.internal:11434/v1 --model openai/pentest-coder --context_window 8192
```

### 3. Example Prompt (Recon Phase)

```text
> We are starting the Recon phase. Target host is 'juice_shop' on port 3000. 
  Run an nmap scan for open ports and use whatweb to identify technologies. 
  Save all outputs in /pentest/reports/recon.txt and summarize the results.
```

---

## Project Structure

```text
.
├── Dockerfile           # Kali Rolling image with pentest tools & Open Interpreter
├── docker-compose.yml   # Multi-container orchestrator (Kali + Juice Shop)
├── Modelfile            # Ollama parameters (num_ctx 8192, temperature 0.3)
└── reports/             # Local volume directory for saved scan logs and reports
```

---

## Disclaimer

This framework is developed strictly for **educational, research, and authorized penetration testing purposes**. All tests should only be performed against environments you own or have explicit permission to audit (such as the included OWASP Juice Shop target).

