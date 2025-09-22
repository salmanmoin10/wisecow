# Accuknox DevOps Trainee Practical Assessment: Wisecow Deployment

Containerized and deployed the Wisecow app (from https://github.com/nyrahul/wisecow) on Kind Kubernetes with TLS, CI/CD, PS2 scripts, and PS3 KubeArmor policy. Repo is public.

## PS1: Containerization and Deployment
- **App**: Original `wisecow.sh` (Bash HTTP server with fortune/cowsay on port 4499).
- **Docker**: `Dockerfile` builds Ubuntu image with deps and PATH fix.
- **Kubernetes**: Manifests in `k8s/` (deployment, service, ingress with TLS secret).
- **TLS**: Self-signed certs for HTTPS; ingress redirects HTTP to HTTPS.
- **CI/CD**: `.github/workflows/ci-cd.yaml` builds/pushes to Docker Hub (`moinsalman/wisecow:latest`), deploys to temp Kind on push (Actions tab shows runs).

### Local Setup and Test
1. Install Kind/kubectl (in Codespaces: curl commands from workflow).
2. `kind create cluster --config kind-config.yaml`.
3. `kubectl label node kind-control-plane ingress-ready=true`.
4. `kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.0/deploy/static/provider/kind/deploy.yaml`.
5. `kubectl rollout status deployment/ingress-nginx-controller -n ingress-nginx --timeout=120s`.
6. Generate certs: `openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout tls.key -out tls.crt -subj "/CN=localhost"`.
7. `kubectl create secret tls wisecow-tls --cert=tls.crt --key=tls.key`.
8. `kubectl apply -f k8s/`.
9. Port-forward: `kubectl port-forward svc/ingress-nginx-controller -n ingress-nginx 8080:80 8443:443`.
10. Test: `curl -k -H "Host: localhost" https://127.0.0.1:8443/` (returns random wise cow quote over TLS).

## PS2: Scripts (Objectives 1 & 4)
- **System Health Monitor** (`system_health_monitor.sh`): Checks CPU/mem/disk (>80% alert) and processes; logs to `/var/log/system_health.log`.
  - Test: `./system_health_monitor.sh` (alerts if stressed).
- **App Health Checker** (`app_health_checker.sh`): Checks HTTP status (200/301/302 = UP).
  - Test: `./app_health_checker.sh https://127.0.0.1:8443/` (UP with port-forward).

## PS3: Zero-Trust KubeArmor Policy
- Policy: `kubearmor-policy.yaml` (allows fortune/cowsay/bash/nc; audits /etc access).
- Install: Helm chart (`helm upgrade --install kubearmor kubearmor/kubearmor -n kubearmor --create-namespace`).
- Apply: `kubectl apply -f kubearmor-policy.yaml`.
- Test: Allowed `fortune | cowsay` works; `ls /etc` audited (logs detection in Kind).
- Proof: `ps3-policy-status.png` (apply/status), `violation-screenshot.png` (logs showing pod monitoring—"Detected a Pod").
- Note: Kind audits (no hard block due to AppArmor limit).

## CI/CD Verification
- Push to main: Builds image, deploys to temp Kind with TLS (Actions tab).
- Docker Hub: `moinsalman/wisecow:latest`.

All tested in Codespaces/Kind—contact for demo.