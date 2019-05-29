#!/bin/bash
cd metrics-server/deploy/1.8+/
patch < metrics.patch
kubectl apply -f .
