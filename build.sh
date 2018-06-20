#!/bin/bash

set -eu -o pipefail

for manifest in ./k8s/*.yml; do
    # echo "##vso[artifact.upload containerfolder=testresult;artifactname=uploadedresult;]c:\testresult.trx"
    echo "##vso[artifact.associate type=container;artifactname=manifests]#${manifest}"
done

