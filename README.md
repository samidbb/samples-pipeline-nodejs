# Introduction 
- two flavours
- targets node.js
- declarative setup in VSTS

# Prerequisites
- aws cli (and python)
- aws authentication (environment variables or config file)

# Usage
...

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
````powershell
PS> ./pipeline.ps1
````
