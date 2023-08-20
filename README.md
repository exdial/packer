# Packer

Packer is a tool from Hashicorp for making machine images in a reproducible way.
It supports a large variety of cloud infrastructures.

## What is this repository for?

* No more ad hoc, manual creation of AMIs
* Intended to be run from a CI system

## Quick start

`packer init .`

## Building

`packer -var-file=(ci|prod).pkrvars.hcl 20-04-focal.pkr.hcl`
