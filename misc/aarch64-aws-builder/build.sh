#!/bin/bash -xe
if [ ! -e $1/PKGBUILD ]; then
  echo "no pkgbuild found"
  exit 1
fi
srcdir="$(realpath $1)"

cd "$(dirname $0)"
source ./.env

mkdir -p out
packer build --var "subnet_id=$SUBNET_ID" --var "pkgbuild_path=$srcdir/"  build.json
