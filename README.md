This project is being used to deploy a test webapp on AWS.

#### Windows Instance Setup

install application-server

```posh
Install-WindowsFeature as-web-support -IncludeManagementTools
```

download code from s3
```posh
Import-Module AWSPowerShell
New-Item -Type Directory 'c:\tmp'
New-Item -Type Directory 'c:\ImageGallery'
Read-S3Object -BucketName jalwebapp -Key code/jal-webapp-master.zip -File c:\tmp\code/jal-webapp-master.zip
```
