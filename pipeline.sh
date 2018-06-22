#!/bin/bash
#
# build.sh(1)
#

[[ -n $DEBUG ]] && set -x
set -eu -o pipefail

# build parameters
readonly REGION=${AWS_DEFAULT_REGION:-"eu-central-1"}
readonly IMAGE_NAME='pipelinesamplenodejs'
readonly BUILD_NUMBER=${1:-"N/A"}

info() {
    NORMAL=$(tput sgr0)
    GREEN=$(tput setaf 2)
    echo "${GREEN}$@${NORMAL}"
}

run_tests() {
    info "Running tests .."
    npm install
    npm run test -- -R mocha-trx-reporter --reporter-options output=testresult.trx
}

build_container_image() {
    info "Building container image .."
    
    docker build -t ${IMAGE_NAME} .
}

push_container_image() {
    info "Login to docker..."
    $(aws ecr get-login --no-include-email)

    account_id=$(aws sts get-caller-identity --output text --query 'Account')
    image_name="${account_id}.dkr.ecr.${REGION}.amazonaws.com/dfds/${IMAGE_NAME}:${BUILD_NUMBER}"

    info "Tagging container image..."
    docker tag ${IMAGE_NAME}:latest ${image_name}

    info "Pushing container image to ECR..."
    docker push ${image_name}
}

cd ./src

run_tests

cd ..

build_container_image

if [[ "${BUILD_NUMBER}" != "N/A" ]]; then
    push_container_image
fi
