SHELL := /bin/bash
.ONESHELL:
.SHELLFLAGS := -euo pipefail -c
.RECIPEPREFIX := >

CLUSTER ?= lab
IMAGE   ?= custom-nginx:1.0
PORT    ?= 8081

.PHONY: cluster build import deploy up url status clean reset

cluster:
> if k3d cluster list | awk 'NR>1 {print $$1}' | grep -qx "$(CLUSTER)"; then
>   echo "✅ Cluster $(CLUSTER) déjà existant"
> else
>   echo "🚀 Création du cluster $(CLUSTER)"
>   k3d cluster create $(CLUSTER) --servers 1 --agents 2
> fi
> k3d kubeconfig merge $(CLUSTER) --kubeconfig-switch-context
> kubectl get nodes

build:
> packer init packer/
> packer build packer/nginx.pkr.hcl

import:
> k3d image import $(IMAGE) -c $(CLUSTER)

deploy:
> ansible-playbook -i ansible/inventory.ini ansible/deploy.yml

up: cluster build import deploy
> echo "✅ OK. Lance 'make url' pour exposer l'app."

url:
> # stop old port-forward
> if [ -f /tmp/nginx_pf.pid ]; then kill $$(cat /tmp/nginx_pf.pid) >/dev/null 2>&1 || true; rm -f /tmp/nginx_pf.pid; fi
> > pkill -f 'kubectl port-forward svc/nginx-cus[t]om' || true
> nohup kubectl port-forward svc/nginx-custom $(PORT):80 >/tmp/nginx.log 2>&1 & echo $$! > /tmp/nginx_pf.pid
> echo "➡️ Onglet PORTS : mets le port $(PORT) en Public, puis ouvre l’URL."

status:
> kubectl get deploy,po,svc -o wide

clean:
> if [ -f /tmp/nginx_pf.pid ]; then kill $$(cat /tmp/nginx_pf.pid) >/dev/null 2>&1 || true; rm -f /tmp/nginx_pf.pid; fi
> kubectl delete -f k8s/service.yml --ignore-not-found
> kubectl delete -f k8s/deployment.yml --ignore-not-found

reset: clean
> k3d cluster delete $(CLUSTER) || true
