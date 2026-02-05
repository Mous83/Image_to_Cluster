CLUSTER=lab
IMAGE=custom-nginx:1.0

.PHONY: cluster build import deploy up url

cluster:
	curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash
	k3d cluster create $(CLUSTER) --servers 1 --agents 2
	kubectl get nodes

build:
	packer init packer/
	packer build packer/nginx.pkr.hcl

import:
	k3d image import $(IMAGE) -c $(CLUSTER)

deploy:
	ansible-playbook ansible/deploy.yml

up: build import deploy

url:
	kubectl port-forward svc/nginx-custom 8081:80 >/tmp/nginx.log 2>&1 & echo "Open PORT 8081 in Codespaces"
