#!/bin/bash -xe
source ./.env
exec ./push.rb "$@"
