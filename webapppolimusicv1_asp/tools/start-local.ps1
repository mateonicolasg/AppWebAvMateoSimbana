param([int]$Port = 8088)
$ErrorActionPreference = 'Stop'
$siteRoot = Split-Path -Parent $PSScriptRoot
$iisRoot = Join-Path $env:ProgramFiles 'IIS Express'
$templatePath = Join-Path $iisRoot 'config/templates/PersonalWebServer/applicationhost.config'
if (-not (Test-Path -LiteralPath $templatePath)) { throw 'Instala IIS Express o configura este directorio como aplicación Classic ASP en IIS.' }
$runtimeDir = Join-Path $PSScriptRoot '.runtime'
New-Item -ItemType Directory -Path $runtimeDir -Force | Out-Null
[xml]$config = Get-Content -LiteralPath $templatePath
$site = $config.configuration.'system.applicationHost'.sites.site
$site.name = 'PoliMusicClassicASP'
$site.application.SetAttribute('applicationPool', 'UnmanagedClassicAppPool')
$site.application.virtualDirectory.physicalPath = $siteRoot
$site.bindings.binding.bindingInformation = ":${Port}:localhost"
$config.configuration.'system.applicationHost'.sites.siteDefaults.logFile.directory = $runtimeDir
$config.configuration.'system.applicationHost'.sites.siteDefaults.traceFailedRequestsLogging.directory = $runtimeDir
$configPath = Join-Path $runtimeDir 'applicationhost.config'
$config.Save($configPath)
Write-Host "PoliMusic: http://localhost:$Port/login.asp"
& (Join-Path $iisRoot 'iisexpress.exe') "/config:$configPath" '/site:PoliMusicClassicASP' '/systray:false'
