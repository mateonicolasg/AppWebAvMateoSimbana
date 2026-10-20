param([string]$BaseUrl='http://localhost:8088')
$ErrorActionPreference='Stop'
function Assert-PoliMusic($Condition,$Message) { if (-not $Condition) { throw $Message }; Write-Host "PASS: $Message" }
function Get-PoliMusicToken($Content) { [regex]::Match($Content,'name="csrf" value="([^"]+)"').Groups[1].Value }
$login=Invoke-WebRequest "$BaseUrl/login.asp" -SessionVariable normalSession
$result=Invoke-WebRequest "$BaseUrl/login.asp" -WebSession $normalSession -Method Post -Body @{csrf=(Get-PoliMusicToken $login.Content);username='userNormal';password='12345678'}
Assert-PoliMusic ($result.Content.Contains('Bienvenido, userNormal') -and $result.Content.Contains('Song List')) 'Login normal y biblioteca'
Assert-PoliMusic ($result.Content -match 'data-src="SongFilesAndImages_resources/SongFiles/bensound-adventure.mp3"') 'MP3 local resuelto'
Assert-PoliMusic (([regex]::Matches($result.Content,'MP3 no disponible')).Count -eq 4) 'Cuatro MP3 ausentes identificados'
$favorites=Invoke-WebRequest "$BaseUrl/favorites.asp" -WebSession $normalSession
Assert-PoliMusic ($favorites.StatusCode -eq 200) 'Página de favoritos'
$denied=Invoke-WebRequest "$BaseUrl/admin.asp" -WebSession $normalSession -SkipHttpErrorCheck
Assert-PoliMusic ($denied.StatusCode -eq 403) 'Administración denegada al usuario normal'
$denied=Invoke-WebRequest "$BaseUrl/favorite.asp" -WebSession $normalSession -Method Post -Body @{id=1} -SkipHttpErrorCheck
Assert-PoliMusic ($denied.StatusCode -eq 403) 'POST sin token denegado'
$login=Invoke-WebRequest "$BaseUrl/login.asp" -SessionVariable adminSession
$result=Invoke-WebRequest "$BaseUrl/login.asp" -WebSession $adminSession -Method Post -Body @{csrf=(Get-PoliMusicToken $login.Content);username='userAdmin';password='12345678'}
Assert-PoliMusic ($result.Content.Contains('Bienvenido, userAdmin')) 'Login administrador'
foreach ($entity in @('songs','artists','albums')) {
 $result=Invoke-WebRequest "$BaseUrl/admin.asp?entity=$entity" -WebSession $adminSession
 Assert-PoliMusic ($result.StatusCode -eq 200 -and $result.Content.Contains('Guardar cambios')) "CRUD $entity renderizado"
}
$result=Invoke-WebRequest "$BaseUrl/index.asp?q=Adventure" -WebSession $adminSession
Assert-PoliMusic (([regex]::Matches($result.Content,'class="song-row"')).Count -eq 1) 'Buscador filtra canciones'
$result=Invoke-WebRequest "$BaseUrl/logout.asp" -WebSession $adminSession -Method Post -Body @{csrf=(Get-PoliMusicToken $result.Content)}
Assert-PoliMusic ($result.Content.Contains('Iniciar sesión')) 'Logout'
$result=Invoke-WebRequest "$BaseUrl/admin.asp" -WebSession $adminSession
Assert-PoliMusic ($result.Content.Contains('Iniciar sesión')) 'Protección tras cerrar sesión'
