## Dev Workstation Configuration Script
Param (
	[string]$repoUri
)

## Clone Repo
mkdir 'c:\Source'
cd 'c:\Source'
git clone $repoUri

## Build and Package App
$vs_path = "C:\Program Files (x86)\Microsoft Visual Studio\2017\Enterprise"
if (!(Test-Path $vs_path)) {
	$vs_path = "C:\Program Files (x86)\Microsoft Visual Studio\2017\Community"
}

#Set Path Variables for build
$env:Path += ";$vs_path\VC\Tools\MSVC\14.12.25827\bin\HostX86\x86"
$env:Path += ";$vs_path\Common7\IDE\VC\VCPackages"
$env:Path += ";C:\Program Files (x86)\Microsoft SDKs\TypeScript\2.5"
$env:Path += ";$vs_path\Common7\IDE\CommonExtensions\Microsoft\TestWindow"
$env:Path += ";$vs_path\Common7\IDE\CommonExtensions\Microsoft\TeamFoundation\Team Explorer"
$env:Path += ";$vs_path\MSBuild\15.0\bin\Roslyn"
$env:Path += ";$vs_path\Team Tools\Performance Tools"
$env:Path += ";C:\Program Files (x86)\Microsoft Visual Studio\Shared\Common\VSPerfCollectionTools\"
$env:Path += ";C:\Program Files (x86)\Microsoft SDKs\Windows\v10.0A\bin\NETFX 4.6.1 Tools\"
$env:Path += ";C:\Program Files (x86)\Microsoft SDKs\F#\4.1\Framework\v4.0\"
$env:Path += ";C:\Program Files (x86)\Windows Kits\10\bin\x86"
$env:Path += ";C:\Program Files (x86)\Windows Kits\10\bin\10.0.16299.0\x86"
$env:Path += ";$vs_path\\MSBuild\15.0\bin"
$env:Path += ";C:\Windows\Microsoft.NET\Framework\v4.0.30319"
$env:Path += ";$vs_path\Common7\IDE\"
$env:Path += ";$vs_path\Common7\Tools\"
$env:Path += ";C:\Program Files\Microsoft MPI\Bin\;C:\Windows\system32;C:\Windows"
$env:Path += ";C:\Windows\System32\Wbem;C:\Windows\System32\WindowsPowerShell\v1.0\"
$env:Path += ";C:\Program Files\dotnet\"
$env:Path += ";C:\Program Files\Microsoft SQL Server\130\Tools\Binn\"
$env:Path += ";C:\Program Files\Git\cmd"

## Install Chocolatey and packages
Invoke-Expression ((New-Object Net.WebClient).DownloadString('https://chocolatey.org/install.ps1')) 
## Add startup bat to install additional packages on sign in
$choco_exe = "C:\ProgramData\chocolatey\bin\choco.exe"
$install_packages_bat = "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\StartUp\install_packages.bat"
if (!(Test-Path $install_packages_bat)) {
	Set-Content -Path $install_packages_bat -Value "$choco_exe install postman googlechrome -y"
}

# Install Hyper-V
Install-Module DockerMsftProvider -Force
Install-Package Docker -ProviderName DockerMsftProvider -Force

cd $env:TEMP
Invoke-WebRequest -UseBasicParsing -OutFile docker-18.09.1.zip https://download.docker.com/components/engine/windows-server/18.09/docker-18.09.1.zip

# Extract the archive.
Expand-Archive docker-18.09.2.zip -DestinationPath $Env:ProgramFiles -Force

# Clean up the zip file.
Remove-Item -Force docker-18.09.2.zip

# Install Docker. This requires rebooting.
$null = Install-WindowsFeature containers

# Add Docker to the path for the current session.
$env:path += ";$env:ProgramFiles\docker"

# Optionally, modify PATH to persist across sessions.
$newPath = "$env:ProgramFiles\docker;" +
[Environment]::GetEnvironmentVariable("PATH",
[EnvironmentVariableTarget]::Machine)

[Environment]::SetEnvironmentVariable("PATH", $newPath,
[EnvironmentVariableTarget]::Machine)

# Register the Docker daemon as a service.
dockerd --register-service

# Start the Docker service.
Start-Service docker