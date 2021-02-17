ROOT     := $(dir $(lastword $(MAKEFILE_LIST)))
TARGETS  := generated/Dockerfile generated/kubernetes.yaml

all: $(TARGETS)

generated/%: %.jsonnet
	mkdir -p generated/
	jsonnet -J $(ROOT)/vendor -J $(ROOT)/lib -S $< -o $@
