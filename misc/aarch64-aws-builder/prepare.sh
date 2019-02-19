#!/bin/bash -xe
cd "$(dirname $0)"
source ./.env

packer build --var "subnet_id=$SUBNET_ID" builder.json
