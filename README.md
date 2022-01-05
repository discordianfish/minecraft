# Minecraft
![<CI Status>](https://circleci.com/gh/discordianfish/minecraft.svg?style=svg)
Dockerfile and jsonnet to run Minecraft on Kubernetes.


## Server setup
- Small 4GB server, so kubelet only with cri-o

## TLS
```
cfssl gencert -initca ca.json | cfssljson -bare ca
cfssl gencert -ca ca.pem -ca-key ca-key.pem --config ca.json -profile www kubelet.json | cfssljson -bare kubelet
cfssl gencert -ca ca.pem -ca-key ca-key.pem --config ca.json -profile client client.json | cfssljson -bare client
```
