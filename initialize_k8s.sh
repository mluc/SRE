#!/bin/bash

set -e

kubectl apply -f starter-p3/apps/hello-world
kubectl apply -f starter-p3/apps/canary/index_v1_html.yml
kubectl apply -f starter-p3/apps/canary/canary-v1.yml
kubectl apply -f starter-p3/apps/blue-green