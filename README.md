This project is being used to deploy a test webapp on AWS.

#### Windows Instance Setup

install application-server

```posh
Install-WindowsFeature as-web-support -IncludeManagementTools
```

create `c:\ImageGallery`
```posh
New-Item -Type Directory c:\ImageGallery
```
