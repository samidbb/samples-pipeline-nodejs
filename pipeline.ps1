param(
    [switch] $pushImage = $false,
    $buildNumber = $null,
    $containerImageName = "pipelinesamplenodejs",
    $awsAccessKeyOverride = $null,
    $awsSecretAccessKeyOverride = $null
)

$cwd = resolve-path .
$currentAccessKey = $env:AWS_ACCESS_KEY_ID
$currentSecretAccessKey = $env:AWS_SECRET_ACCESS_KEY


if ($pushImage -eq $true) {
    # exit if push images is requested but a build number has not been specified at the command line
    if ($buildNumber -eq $null) {
        throw "Cannot push container image without a build number. Specify one at the command line."
    }

    if ($awsAccessKeyOverride -ne $null) { $env:AWS_ACCESS_KEY_ID = $awsAccessKeyOverride }
    if ($awsSecretAccessKeyOverride -ne $null) { $env:AWS_SECRET_ACCESS_KEY = $awsSecretAccessKeyOverride }
}


try {
    cd src

    write-host "NPM install..." -foregroundcolor green
    npm install
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

    write-host "NPM run tests..." -foregroundcolor green
    npm run test --  -R mocha-trx-reporter --reporter-options output=testresult.trx
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

    cd ..
    write-host "docker build..." -foregroundcolor green
    docker build -t $containerImageName .
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

    if ($pushImage -eq $true) {
        write-host "Getting AWS login command for docker..." -foregroundcolor green
        $dockerlogincmd = aws ecr get-login --no-include-email
        if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
    
        write-host "Login to docker..." -foregroundcolor green
        invoke-expression -command $dockerlogincmd
        if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
    
        $awsAccountId = aws sts get-caller-identity --output text --query 'Account'
        $awsRegion = $env:AWS_DEFAULT_REGION
    
        write-host "Tagging container image..." -foregroundcolor green
        docker tag "${containerImageName}:latest" "${awsAccountId}.dkr.ecr.${awsRegion}.amazonaws.com/dfds/${containerImageName}:${buildNumber}"
        if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
    
        write-host "Pushing container image to ECR..." -foregroundcolor green
        docker push "${awsAccountId}.dkr.ecr.${awsRegion}.amazonaws.com/dfds/${containerImageName}:${buildNumber}"
        if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
    }
}
finally {
    cd $cwd
    $env:AWS_ACCESS_KEY_ID = $currentAccessKey
    $env:AWS_SECRET_ACCESS_KEY = $currentSecretAccessKey
}