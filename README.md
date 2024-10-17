# Packer

Packer is a tool from Hashicorp for making machine images in a reproducible way.
It supports a large variety of cloud infrastructures.

## What is this repository for?

* No more ad hoc, manual creation of AMIs
* Intended to be run from a CI system

## Usage examples

### Virtualbox and Ubuntu Noble

```sh
pushd virtualbox && packer init . && popd

packer build -var-file=vars/noble.pkvars.hcl virtualbox/virtualbox.pkr.hcl
```

### VMware and Ubuntu Focal

```sh
pushd vmware && packer init . && popd

packer build -var-file=vars/focal.pkvars.hcl vmware/vmware.pkr.hcl
```

## Feedback

[Suggestions and improvements](https://github.com/exdial/packer/issues).
