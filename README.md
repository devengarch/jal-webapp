This project is being used to deploy a test webapp on AWS.

#### Windows Instance Setup

```posh
<powershell>
# Install IIS
Install-WindowsFeature as-web-support -IncludeManagementTools

# Download code from S3
Import-Module AWSPowerShell
New-Item -Type Directory 'c:\tmp'
New-Item -Type Directory 'c:\ImageGallery'
Read-S3Object -BucketName jalwebapp -Key 'code/jal-webapp-master.zip' -File 'c:\tmp\jal-webapp-master.zip'

# Cleanup IIS
Import-Module WebAdministration
$WebSiteName = 'ImageGallery'
if(Get-Website 'Default Web Site'){Remove-Website 'Default Web Site'}
if(Test-Path ("IIS:\AppPools\" + "DefaultAppPool")){Remove-WebAppPool DefaultAppPool}
if(Get-Website $WebSiteName){Remove-Website $WebSiteName}
if(("IIS:\AppPools\" + "$WebSiteName")){Remove-WebAppPool $WebSiteName}

# Unzip code
$shell_app=new-object -com shell.application
$zip_file = $shell_app.namespace("c:\tmp\jal-webapp-master.zip")
$destination = $shell_app.namespace("c:\tmp\")
$destination.Copyhere($zip_file.items())
if(Test-Path c:\ImageGallery){Remove-Item C:\ImageGallery -Recurse -Force}
Move-Item C:\tmp\jal-webapp-master\ C:\ImageGallery\
Remove-Item c:\tmp\*

# Update default website config
New-Website -Name $WebSiteName -ApplicationPool (New-WebAppPool $WebSiteName).Name -PhysicalPath C:\ImageGallery
</powershell>
```
