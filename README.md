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

# Unzip code
$shell_app=new-object -com shell.application
$zip_file = $shell_app.namespace("c:\tmp\jal-webapp-master.zip")
$destination = $shell_app.namespace("c:\tmp\")
$destination.Copyhere($zip_file.items())
if(Test-Path c:\ImageGallery){Remove-Item C:\ImageGallery -Recurse -Force}
Move-Item C:\tmp\jal-webapp-master\ C:\ImageGallery\
Remove-Item c:\tmp\*

# Update default website config
Set-ItemProperty 'IIS:\Sites\Default Web Site' -Name PhysicalPath -Value C:\ImageGallery
Restart-WebItem 'IIS:\Sites\Default Web Site'
</powershell>
```
