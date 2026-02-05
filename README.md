# Image to Cluster — Packer → K3d → Ansible

## Objectif
Industrialiser un mini cycle de vie applicatif :

1. **Build** d’une image Docker Nginx personnalisée (avec `index.html`) via **Packer**
2. **Import** de cette image dans un cluster **Kubernetes local K3d** (1 server / 2 agents)
3. **Déploiement** sur le cluster via **Ansible** (kubectl apply + rollout status)

Résultat : une page web servie par Nginx depuis Kubernetes.

---

## Pré-requias
- Docker
- Packer
- k3d (k3s)
- kubectl
- Ansible

> Les versions utilisées (atelier) : Docker 28.x, k3d v5.8.x, k3s v1.31.x, kubectl v1.34.x, ansible-core 2.16.x, Packer 1.10.x.

---

## Structure du repository
- `index.html` : page web embarquée dans l’image Nginx
- `packer/nginx.pkr.hcl` : build de l’image `custom-nginx:1.0`
- `k8s/deployment.yml` : déploiement Kubernetes (1 replica)
- `k8s/service.yml` : service ClusterIP (port 80)
- `ansible/deploy.yml` : déploiement automatisé (apply + rollout status)
- `ansible/inventory.ini` : inventaire local Ansible
- `Makefile` : orchestration (cluster/build/import/deploy + url/status/clean/reset)

---

## Quickstart (recommandé)
Depuis la racine du repo :

### 1) Déployer
```bash
make up

## Demo

### Lancer (build + import + deploy)
make up

### Exposer le service (local)
kubectl port-forward svc/nginx-custom 8081:80

### Tester
curl -s http://127.0.0.1:8081 | head -n 5
