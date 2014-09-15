<powershell>
# userdata.ps1
# Userdata script to bootstrap webapp demo servers.  Requires 2012R2 base OS instance

# Set Execution Policy
Set-ExecutionPolicy Remotesigned -Force

# Join computer to domain
$password = "@345Wert" | ConvertTo-SecureString -asPlainText -Force
$username = "aws-autoscale-join"
$credential = New-Object System.Management.Automation.PSCredential($username,$password)
Add-Type -Path 'C:\Program Files (x86)\AWS SDK for .NET\bin\Net45\AWSSDK.dll'
$computername = [Amazon.EC2.Util.EC2Metadata]::InstanceId
Add-Computer -domainname tapoc.local -OUPath "OU=AWS-AutoScale,OU=Servers,DC=tapoc,DC=local" -Credential $credential -NewName $computername -passthru

# Install IIS
Install-WindowsFeature as-web-support -IncludeManagementTools

# Download webapp demo code from S3
Import-Module AWSPowerShell
New-Item -Type Directory 'c:\tmp'
New-Item -Type Directory 'c:\ImageGallery'
Read-S3Object -BucketName jalwebapp -Key 'code/jal-webapp-master.zip' -File 'c:\tmp\jal-webapp-master.zip'

# Cleanup IIS of existing default and webapp web sites
Import-Module WebAdministration
$WebSiteName = 'ImageGallery'
if(Get-Website 'Default Web Site'){Remove-Website 'Default Web Site'}
if(Test-Path ("IIS:\AppPools\" + "DefaultAppPool")){Remove-WebAppPool DefaultAppPool}
if(Get-Website $WebSiteName){Remove-Website $WebSiteName}
if(("IIS:\AppPools\" + "$WebSiteName")){Remove-WebAppPool $WebSiteName}

# Unzip downloaded webapp code and move to c:\ImageGallery
$shell_app=new-object -com shell.application
$zip_file = $shell_app.namespace("c:\tmp\jal-webapp-master.zip")
$destination = $shell_app.namespace("c:\tmp\")
$destination.Copyhere($zip_file.items())
if(Test-Path c:\ImageGallery){Remove-Item C:\ImageGallery\* -Recurse -Force}
Move-Item C:\tmp\jal-webapp-master\* C:\ImageGallery\
Remove-Item c:\tmp\*

# Set RDS Endpoint based on EC2MetaData
$EC2InstancIdDocument = (curl http://169.254.169.254/latest/dynamic/instance-identity/document/).content | ConvertFrom-Json
$EC2InstanceId = $EC2InstancIdDocument.instanceId
$EC2InstanceRegion = $EC2InstancIdDocument.region
Get-EC2Tag -Region $EC2InstanceRegion -Filter @(
    @{name="resource-id";value=$EC2InstanceId},
    @{name="key";value="Name"}
)

if($EC2InstanceRegion -eq "us-east-1"){
    $rdsendpoint = "jal-webapp-mysql.c48rqdxv8f9j.us-east-1.rds.amazonaws.com"
}

if($EC2InstanceRegion -eq "us-west-2"){
    $rdsendpoint = "jal-webapp-mysql.c2d1kjikplih.us-west-2.rds.amazonaws.com"
}

$PathToFile = "C:\ImageGallery\Default.aspx.cs"
$SearchFor = "private string dbinstance.+"
$ReplaceWith = "private string dbinstance = `"" + $rdsendpoint + "`";"
(get-content $PathtoFile) | % { $_ -replace $SearchFor, $ReplaceWith } | set-content $PathToFile

# Create new web site using C:\ImageGallery as the root
New-Website -Name $WebSiteName -ApplicationPool (New-WebAppPool $WebSiteName).Name -PhysicalPath C:\ImageGallery

# Restart Computer
Restart-Computer -Force
</powershell>
