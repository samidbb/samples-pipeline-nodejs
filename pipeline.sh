#!/bin/bash
#
# build.sh(1)
#

[[ -n $DEBUG ]] && set -x
set -eu -o pipefail

# build parameters
readonly REGION=${AWS_DEFAULT_REGION:-"eu-central-1"}
readonly IMAGE_NAME='samples-pipeline-nodejs'
readonly BUILD_NUMBER=${1:-"N/A"}

run_tests() {
    echo "Running tests .."
    npm install
    npm run test -- -R mocha-trx-reporter --reporter-options output=testresult.trx
}

build_container_image() {
    echo "Building container image .."
    
    docker build -t ${IMAGE_NAME} .
}

push_container_image() {
    echo "Login to docker..."
    $(aws ecr get-login --no-include-email)

    account_id=$(aws sts get-caller-identity --output text --query 'Account')
    image_name="${account_id}.dkr.ecr.${REGION}.amazonaws.com/ded/${IMAGE_NAME}:${BUILD_NUMBER}"

    echo "Tagging container image..."
    docker tag ${IMAGE_NAME}:latest ${image_name}

    echo "Pushing container image to ECR..."
    docker push ${image_name}
}

if ! which aws >/dev/null ; then
    echo 'Installing AWS'
    curl -fsSO https://bootstrap.pypa.io/get-pip.py
    python3 get-pip.py
    pip -q install awscli --upgrade
    aws --version
else
    echo "Yay, AWS already installed :-)";
fi

cd ./src

run_tests

cd ..

build_container_image

if [[ "${BUILD_NUMBER}" != "N/A" ]]; then
    push_container_image
fi
