# Introduction

This is a simple example of a Node.JS applications build using scripts and a VSTS declarative build definition (`.vsts-ci.yml`).

The sample contains scripts for both *bash* and *Powershell Core* (pick a flavor), and means to express a VSTS build definiton in a declarative style.

## Prerequisites

A couple of components are required to be installed before executing the script. Here is a list of them, with a small explenation:

| Tool    | Comment |
|---------|---------|
| AWS CLI | A command line tool that the script heavily relies on for interacting with AWS ECR |
| AWS access | The AWS CLI should be authenticated either by environment variables or a config file within you user folder. |

## Usage

The following will show how to use both the linux shell script and the powershell core editions of the pipeline.

## Linux Shell Script

The general usage is as followed:

```text
Usage: pipeline.sh [buildnumber]

Options:

- buildnumber   Specifing a buildnumber will also push the container
                to the container registry.
```

### Local usage

```bash
./pipeline.sh
```

### Build server usage (on VSTS)

To enable automatic push of container image, please supply an argument to the `pipeline.sh` bash script. Like:

```text
./pipeline.sh $(Build.BuildId)
```

NOTE: When executing `pipeline.sh` bash script as an inline script (or through the `.vsts-ci.yml`) the script needs *execute permission*. Also be aware that VSTS secrets are **NOT** available as environment variables, but can be made available through the use of build variables:

```bash
export AWS_SECRET_ACCESS_KEY=$(AWS_SECRET_ACCESS_KEY)
chmod +x ./pipeline.sh
./pipeline.sh $(Build.BuildId)
```

## Powershell Core

The general usage is as followed:

```text
Usage: pipeline.ps1 [-containerImageName <name>] [-pushImage -buildNumber <buildnumber>]

Options:

- containerImageName    Specifies name of the container image when built.
- pushImage             Flag for indicating that image should be pushed to registry.
                        Please note that if set a build number is also required.
- buildNumber           String indicating the build number that the container
                        image will be tagged with.
```

### Local usage

For local usage you can execute the pipeline up until the container image is actually pushed to a registry. Run the following:

```powershell
PS> ./pipeline.ps1
```

Run `docker images` afterwards to verify that the container image has been built.

### Build server usage (on VSTS)

On VSTS a recommended execution could be:

```powershell
PS> ./pipeline.ps1 -pushImage -buildNumber $(Build.BuildId)
```

The example above injects the VSTS build number into the pipeline script, so that it can be used to tagging the container image.

NOTE: When executing the `pipeline.ps1` script as an inline script (or through the `.vsts-ci.yml`), be aware that VSTS secrets are **NOT** available as environment variables, but can be made available through the use of build variables:

```powershell
$env:AWS_SECRET_ACCESS_KEY = "$(AWS_SECRET_ACCESS_KEY)"
./pipeline.ps1 -pushImage -buildNumber $(Build.BuildId)
```

## Declarative Build Definition (a.k.a. `.vsts-ci.yml`)

> **IMPORTANT**: The naming and location of `.vsts-ci.yml` is fixed - otherwise the build will not have the required permission to build agents and other resources in VSTS.

The `.vsts-ci.yml` contains the steps need to execute a build in VSTS that:

1. Runs the build script (either `pipeline.sh` or `pipeline.ps1`), which final output is a container image pushed to the registry.
1. Publishes test results using the "Publish Test Results" VSTS task.
1. Publishes the Kubernetes manifests as build artifacts using the "Publish Build Artifacts" VSTS task.

> **NOTE**: For other application setups some manual modification is most likely required.
