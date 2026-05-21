# JupyterLab GPU Docker + Cloudflare Tunnel Setup

This guide sets up JupyterLab in Docker with NVIDIA GPU support, then exposes it to the internet safely through Cloudflare Tunnel.

Target machine:

```text
GPU: NVIDIA RTX 3060 12 GB
Use case: PyTorch / AI learning / JupyterLab
OS: Ubuntu / Debian-like Linux
```

---

## 1. Goal

Final architecture:

```text
Browser
  ↓
Cloudflare Access / Cloudflare Tunnel
  ↓
cloudflared container
  ↓
JupyterLab Docker container
  ↓
NVIDIA RTX 3060 GPU
```

You will be able to open JupyterLab from:

```text
https://jupyter.yourdomain.com
```

or locally from:

```text
http://localhost:8888
```

---

## 2. Check NVIDIA driver on host

First check whether the host can see the GPU:

```bash
nvidia-smi
```

Expected result should show something like:

```text
NVIDIA GeForce RTX 3060
CUDA Version: ...
```

If `nvidia-smi` does not work on the host, fix the NVIDIA driver before continuing.

---

## 3. Install NVIDIA Container Toolkit

Docker cannot use the GPU directly unless NVIDIA Container Toolkit is installed.

Install required packages:

```bash
sudo apt-get update
sudo apt-get install -y --no-install-recommends ca-certificates curl gnupg2
```

Add NVIDIA Container Toolkit repository:

```bash
curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey \
  | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg

curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list \
  | sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' \
  | sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list
```

Install toolkit:

```bash
sudo apt-get update
sudo apt-get install -y nvidia-container-toolkit
```

Configure Docker:

```bash
sudo nvidia-ctk runtime configure --runtime=docker
sudo systemctl restart docker
```

---

## 4. Test Docker GPU

Run:

```bash
docker run --rm --gpus all nvidia/cuda:12.4.1-base-ubuntu22.04 nvidia-smi
```

Expected result:

```text
NVIDIA GeForce RTX 3060
```

If you get this error:

```text
failed to discover GPU vendor from CDI: no known GPU vendor found
```

run:

```bash
sudo nvidia-ctk cdi generate --output=/var/run/cdi/nvidia.yaml
sudo nvidia-ctk cdi list
sudo systemctl restart docker
```

Then retry:

```bash
docker run --rm --gpus all nvidia/cuda:12.4.1-base-ubuntu22.04 nvidia-smi
```

---

## 5. Create project folder

```bash
mkdir jupyter-gpu-cloudflare
cd jupyter-gpu-cloudflare
mkdir work
```

The `work/` folder will be mounted into JupyterLab.

Files created inside Jupyter will be saved here.

---

## 6. Create `.env` file

Create `.env`:

```bash
cat > .env <<'EOF'
JUPYTER_TOKEN=my-strong-jupyter-token-123456
CLOUDFLARE_TUNNEL_TOKEN=paste-your-cloudflare-tunnel-token-here
EOF
```

Change `JUPYTER_TOKEN` to a long private token.

Example:

```env
JUPYTER_TOKEN=change-this-to-a-long-random-secret
CLOUDFLARE_TUNNEL_TOKEN=paste-your-cloudflare-tunnel-token-here
```

Never commit `.env` to GitHub.

---

## 7. Create `docker-compose.yml`

Create the compose file:

```bash
cat > docker-compose.yml <<'EOF'
services:
  jupyter:
    image: pytorch/pytorch:2.5.1-cuda12.4-cudnn9-runtime
    container_name: jupyter-gpu
    restart: unless-stopped
    gpus: all
    working_dir: /workspace
    volumes:
      - ./work:/workspace/work
    expose:
      - "8888"
    command: >
      bash -lc "pip install -q jupyterlab matplotlib pandas scikit-learn opencv-python &&
      jupyter lab --ip=0.0.0.0 --port=8888 --no-browser --allow-root
      --ServerApp.token=${JUPYTER_TOKEN}"

  cloudflared:
    image: cloudflare/cloudflared:latest
    container_name: cloudflared-jupyter
    restart: unless-stopped
    command: tunnel --no-autoupdate run --token ${CLOUDFLARE_TUNNEL_TOKEN}
    depends_on:
      - jupyter
EOF
```

This version is for Cloudflare Tunnel.

If you only want local access, replace this:

```yaml
expose:
  - "8888"
```

with:

```yaml
ports:
  - "8888:8888"
```

Then you can open:

```text
http://localhost:8888
```

---

## 8. Create Cloudflare Tunnel

Go to Cloudflare Zero Trust dashboard.

Create a Tunnel:

```text
Zero Trust → Networks → Tunnels → Create Tunnel
```

Choose:

```text
cloudflared
```

Cloudflare will give you a tunnel token.

Copy the token into `.env`:

```env
CLOUDFLARE_TUNNEL_TOKEN=your-real-token-here
```

Then create a Public Hostname:

```text
Subdomain: jupyter
Domain: yourdomain.com
Type: HTTP
URL: jupyter:8888
```

Important:

```text
URL must be jupyter:8888
```

because `jupyter` is the Docker Compose service name.

---

## 9. Start the system

Run:

```bash
docker compose up -d
```

Check containers:

```bash
docker ps
```

Check logs:

```bash
docker compose logs -f jupyter
```

In another terminal:

```bash
docker compose logs -f cloudflared
```

Open:

```text
https://jupyter.yourdomain.com
```

Use your token from `.env`.

---

## 10. Test GPU inside Jupyter

Create a new notebook and run:

```python
import torch

print("PyTorch:", torch.__version__)
print("CUDA available:", torch.cuda.is_available())
print("GPU:", torch.cuda.get_device_name(0))

x = torch.rand(3000, 3000).cuda()
y = x @ x
print(y.shape)
```

Expected result:

```text
CUDA available: True
GPU: NVIDIA GeForce RTX 3060
torch.Size([3000, 3000])
```

If `torch.cuda.is_available()` is `False`, Docker is not passing the GPU correctly.

---

## 11. Useful commands

Stop:

```bash
docker compose down
```

Start again:

```bash
docker compose up -d
```

Restart only Jupyter:

```bash
docker compose restart jupyter
```

View logs:

```bash
docker compose logs -f jupyter
```

Enter Jupyter container shell:

```bash
docker exec -it jupyter-gpu bash
```

Check GPU from inside container:

```bash
docker exec -it jupyter-gpu nvidia-smi
```

Remove everything except saved notebooks:

```bash
docker compose down
```

Your notebooks remain in:

```text
./work
```

---

## 12. Common errors

### Error: `--ip=0.0.0.0: command not found`

Cause: Jupyter command was split incorrectly.

Correct command must be inside one quoted `bash -lc` command:

```yaml
command: >
  bash -lc "pip install -q jupyterlab matplotlib pandas scikit-learn opencv-python &&
  jupyter lab --ip=0.0.0.0 --port=8888 --no-browser --allow-root
  --ServerApp.token=${JUPYTER_TOKEN}"
```

---

### Error: `Unable to locate package nvidia-container-toolkit`

Cause: NVIDIA repository was not added.

Fix:

```bash
curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey \
  | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg

curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list \
  | sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' \
  | sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list

sudo apt-get update
sudo apt-get install -y nvidia-container-toolkit
```

---

### Error: `failed to discover GPU vendor from CDI`

Fix:

```bash
sudo nvidia-ctk cdi generate --output=/var/run/cdi/nvidia.yaml
sudo nvidia-ctk cdi list
sudo systemctl restart docker
```

Then retry:

```bash
docker run --rm --gpus all nvidia/cuda:12.4.1-base-ubuntu22.04 nvidia-smi
```

---

### Error: Jupyter asks for token

Use the value from `.env`:

```env
JUPYTER_TOKEN=my-strong-jupyter-token-123456
```

---

### Error: Cloudflare tunnel works but Jupyter does not open

Check the Public Hostname service URL.

It must be:

```text
http://jupyter:8888
```

or in Cloudflare UI:

```text
Type: HTTP
URL: jupyter:8888
```

Do not use:

```text
localhost:8888
```

from the Cloudflare container, because `localhost` means the `cloudflared` container itself, not the Jupyter container.

---

## 13. Security notes

JupyterLab should not be exposed carelessly.

Recommended:

```text
Use a strong Jupyter token
Use Cloudflare Access
Do not mount sensitive host folders
Do not expose Docker socket
Do not put secrets in notebooks
Do not commit .env to GitHub
```

Bad idea:

```yaml
volumes:
  - /:/host
```

This gives Jupyter access to the whole machine. Avoid it.

Good idea:

```yaml
volumes:
  - ./work:/workspace/work
```

This only exposes the project folder.

---

## 14. Final recommended files

Final `.env`:

```env
JUPYTER_TOKEN=my-strong-jupyter-token-123456
CLOUDFLARE_TUNNEL_TOKEN=paste-your-cloudflare-tunnel-token-here
```

Final `docker-compose.yml`:

```yaml
services:
  jupyter:
    image: pytorch/pytorch:2.5.1-cuda12.4-cudnn9-runtime
    container_name: jupyter-gpu
    restart: unless-stopped
    gpus: all
    working_dir: /workspace
    volumes:
      - ./work:/workspace/work
    expose:
      - "8888"
    command: >
      bash -lc "pip install -q jupyterlab matplotlib pandas scikit-learn opencv-python &&
      jupyter lab --ip=0.0.0.0 --port=8888 --no-browser --allow-root
      --ServerApp.token=${JUPYTER_TOKEN}"

  cloudflared:
    image: cloudflare/cloudflared:latest
    container_name: cloudflared-jupyter
    restart: unless-stopped
    command: tunnel --no-autoupdate run --token ${CLOUDFLARE_TUNNEL_TOKEN}
    depends_on:
      - jupyter
```

Start:

```bash
docker compose up -d
```

Open:

```text
https://jupyter.yourdomain.com
```

Test:

```python
import torch
print(torch.cuda.is_available())
print(torch.cuda.get_device_name(0))
```

Expected:

```text
True
NVIDIA GeForce RTX 3060
```
