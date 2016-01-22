#!/bin/bash
set -e

python3 /docker_configurator/docker_configurator.py

exec /sbin/entrypoint.sh

