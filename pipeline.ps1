param(
    [switch] $pushImage = $false,
    $buildNumber = $null,
    $containerImageName = "samples-pipeline-nodejs"
)

# exit if push image is requested but a build number has not been specified at the command line
if ($pushImage -eq $true -AND $buildNumber -eq $null) {
        throw "Cannot push container image without a build number. Specify one at the command line."
    }

$cwd = resolve-path .

try {
    if ( !(Get-Command "aws" -ErrorAction SilentlyContinue)) 
    { 
        Write-Host 'Installing AWS'
        wget https://bootstrap.pypa.io/get-pip.py
        python3 get-pip.py
        pip -q install awscli --upgrade
        aws --version
    }
    else
    {
        Write-Host "Yay, AWS already installed :-)"
    }

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
        docker tag "${containerImageName}:latest" "${awsAccountId}.dkr.ecr.${awsRegion}.amazonaws.com/ded/${containerImageName}:${buildNumber}"
        if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
    
        write-host "Pushing container image to ECR..." -foregroundcolor green
        docker push "${awsAccountId}.dkr.ecr.${awsRegion}.amazonaws.com/ded/${containerImageName}:${buildNumber}"
        if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
    }
}
finally {
    cd $cwd
}