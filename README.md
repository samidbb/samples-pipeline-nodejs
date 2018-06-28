# Introduction 
- two flavours
- targets node.js
- declarative setup in VSTS

# Prerequisites
A couple of components are required to be installed before executing the script. Here is a list of them, with a small explenation:

| Tool    | Comment |
|---------|---------|
| AWS CLI | A command line tool that the script heavily relies on for interacting with AWS ECR |
| AWS access | The AWS CLI should be authenticated either by environment variables or a config file within you user folder. |


# Usage
The following will show how to use both the linux shell script and the powershell core editions of the pipeline.

## Linux Shell Script

### Arguments
...

### Local usage
````bash
$ ./pipeline.sh
````
### Build server usage (on VSTS)
````bash
$ ./pipeline.sh
````

## Powershell Core
The general usage is as followed:
````
Usage: pipeline.ps1 [-containerImageName <name>] [-pushImage -buildNumber <buildnumber>]

Options:

- containerImageName    Specifies name of the container image when built.
- pushImage             Flag for indicating that image should be pushed to registry.
                        Please note that if set a build number is also required.
- buildNumber           String indicating the build number that the container image 
                        will be tagged with.
````

### Local usage
For local usage you can execute the pipeline up until the container image is actually pushed to a registry. Run the following:

````powershell
PS> ./pipeline.ps1
````

Run `docker images` afterwards to verify that the container image has been built.

### Build server usage (on VSTS)
On VSTS a recommended execution could be:

````powershell
PS> ./pipeline.ps1 -pushImage -buildNumber $(Build.BuildId)
````
The example above injects the VSTS build number into the pipeline script, so that it can be used to tagging the container image.