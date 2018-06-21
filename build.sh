#!/bin/bash
#
#
#
#

usage() {
    echo "Usage: $0 [-p|--push <build_id>]"
}

# handle input
opts=$(getopt -o p: -l push: -- "$@")

if [[ $? != 0 ]]; then
    usage
    exit 1
fi

eval set -- $opts

BUILD_ID='N/A'
while true; do
    case "$1" in
        -p | --push )
            BUILD_ID=$2
            shift 2
            ;;
        -- )
            shift
            break
            ;;
        * )
            usage
            exit 1
            ;;
    esac
done
readonly BUILD_ID

set -eu -o pipefail

cd ./src

exit

# 
# npm install
# npm test

#

cd ..

docker build -t dfds/pipelinesamplenodejs:${BUILD_BUILDID} .

aws ecr get-login --no-include-email


# docker build -t dfds/pipelinesamplenodejs .
# docker tag dfds/pipelinesamplenodejs:latest 591879361107.dkr.ecr.eu-central-1.amazonaws.com/dfds/pipelinesamplenodejs:latest
# docker push 591879361107.dkr.ecr.eu-central-1.amazonaws.com/dfds/pipelinesamplenodejs:latest

