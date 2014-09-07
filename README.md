This project is being used to deploy a test webapp on AWS.

#### Windows Instance Setup

[Userdata Script](userdata.ps1) to include during instance launch.  Requires 2012R2 Base instance.

[Refresh-Website Script](refresh-website.ps1) which can be run to update imagegallery web site from S3.

Load sdk `$assembly = [Reflection.Assembly]::LoadFile('C:\Program Files (x86)\AWS SDK for .NET\bin\Net45\AWSSDK.dll')`
