param([string]$BaseUrl='http://localhost:8088')
$ErrorActionPreference='Stop'
function Assert-PoliMusic($Condition,$Message) { if (-not $Condition) { throw $Message }; Write-Host "PASS: $Message" }
function Get-PoliMusicToken($Content) { [regex]::Match($Content,'name="csrf" value="([^"]+)"').Groups[1].Value }
$connection=New-Object System.Data.SqlClient.SqlConnection 'Server=localhost;Database=BDD_PoliMusic;User ID=usr_polimusic;Password=Politecnica1;TrustServerCertificate=True'
$connection.Open()
function Scalar($Sql) { $command=$connection.CreateCommand(); $command.CommandText=$Sql; $command.ExecuteScalar() }
$login=Invoke-WebRequest "$BaseUrl/login.asp" -SessionVariable testSession
$page=Invoke-WebRequest "$BaseUrl/login.asp" -WebSession $testSession -Method Post -Body @{csrf=(Get-PoliMusicToken $login.Content);username='userAdmin';password='12345678'}
$csrf=Get-PoliMusicToken $page.Content
function Post-PoliMusic($Entity,$Body) { $Body.csrf=$csrf; $response=Invoke-WebRequest "$BaseUrl/admin.asp?entity=$Entity" -WebSession $testSession -Method Post -Body $Body; if (-not $response.Content.Contains('Cambios guardados correctamente.')) { Write-Host ([regex]::Match($response.Content,'class="alert"[^>]*>(.*?)</p>').Groups[1].Value) }; Assert-PoliMusic ($response.Content.Contains('Cambios guardados correctamente.')) "Escritura $Entity ($($Body.action))" }
$tag='PoliMusic QA '+[DateTime]::Now.ToString('yyyyMMddHHmmss')
$artistId=0;$albumId=0;$songId=0
$initialPlaylist=[int](Scalar "SELECT ISNULL((SELECT TOP 1 ID_PLAYLIST FROM TBL_PLAYLIST WHERE ID_USER=2 AND TITLE='Favoritos' AND TYPE=1 ORDER BY ID_PLAYLIST),0)")
try {
 Post-PoliMusic 'artists' @{action='save';id=0;ARTIST_NAME=$tag;ARTIST_LASTNAME='Prueba';ARTIST_IMAGE=''}
 $artistId=[int](Scalar "SELECT ID_ARTIST FROM TBL_ARTIST WHERE ARTIST_NAME='$tag'")
 Post-PoliMusic 'albums' @{action='save';id=0;TITLE_ALBUM=$tag;RELEASE_YEAR='2026';ALBUM_IMAGE_PATH=''}
 $albumId=[int](Scalar "SELECT ID_ALBUM FROM TBL_ALBUM WHERE TITLE_ALBUM='$tag'")
 $songBody=@{action='save';id=0;SONG_NAME=$tag;SONG_PATH='SongFilesAndImages_resources/SongFiles/bensound-adventure.mp3'}
 $songBody["artist_$artistId"]='1'; $songBody["album_$albumId"]='1'
 Post-PoliMusic 'songs' $songBody
 $songId=[int](Scalar "SELECT ID_SONG FROM TBL_SONG WHERE SONG_NAME='$tag'")
 Assert-PoliMusic (([int](Scalar "SELECT COUNT(*) FROM TBL_PLAYER WHERE ID_SONG=$songId AND ID_ARTIST=$artistId")) -eq 1) 'Asociación canción/artista'
 Assert-PoliMusic (([int](Scalar "SELECT COUNT(*) FROM TBL_TRACKLIST WHERE ID_SONG=$songId AND ID_ALBUM=$albumId")) -eq 1) 'Asociación canción/álbum'
 Post-PoliMusic 'artists' @{action='save';id=$artistId;ARTIST_NAME=$tag;ARTIST_LASTNAME='Editado';ARTIST_IMAGE=''}
 Post-PoliMusic 'albums' @{action='save';id=$albumId;TITLE_ALBUM=$tag;RELEASE_YEAR='2025';ALBUM_IMAGE_PATH=''}
 $songBody.id=$songId;$songBody.SONG_NAME="$tag editado"
 Post-PoliMusic 'songs' $songBody
 Assert-PoliMusic ((Scalar "SELECT ARTIST_LASTNAME FROM TBL_ARTIST WHERE ID_ARTIST=$artistId") -eq 'Editado') 'Artista editado'
 Assert-PoliMusic (([int](Scalar "SELECT RELEASE_YEAR FROM TBL_ALBUM WHERE ID_ALBUM=$albumId")) -eq 2025) 'Álbum editado'
 Assert-PoliMusic ((Scalar "SELECT SONG_NAME FROM TBL_SONG WHERE ID_SONG=$songId") -eq "$tag editado") 'Canción editada'
 $page=Invoke-WebRequest "$BaseUrl/favorite.asp" -WebSession $testSession -Method Post -Body @{csrf=$csrf;id=$songId;from='favorites'}
 Assert-PoliMusic ($page.Content.Contains("$tag editado")) 'Favorito persistente agregado'
 $page=Invoke-WebRequest "$BaseUrl/favorite.asp" -WebSession $testSession -Method Post -Body @{csrf=$csrf;id=$songId;from='favorites'}
 Assert-PoliMusic (-not $page.Content.Contains("$tag editado")) 'Favorito quitado'
 $page=Invoke-WebRequest "$BaseUrl/play.asp" -WebSession $testSession -Method Post -Body @{csrf=$csrf;id=$songId}
 Assert-PoliMusic (([int](Scalar "SELECT PLAYS FROM TBL_SONG WHERE ID_SONG=$songId")) -eq 1) 'Contador de reproducción actualizado'
} finally {
 if ($songId -gt 0) { Post-PoliMusic 'songs' @{action='delete';id=$songId} }
 if ($artistId -gt 0) { Post-PoliMusic 'artists' @{action='delete';id=$artistId} }
 if ($albumId -gt 0) { Post-PoliMusic 'albums' @{action='delete';id=$albumId} }
 if ($initialPlaylist -eq 0) {
  $command=$connection.CreateCommand()
  $command.CommandText="DELETE FROM TBL_PLAYLIST WHERE ID_USER=2 AND TITLE='Favoritos' AND TYPE=1 AND NOT EXISTS(SELECT 1 FROM TBL_PLAYLIST_SONG ps WHERE ps.ID_PLAYLIST=TBL_PLAYLIST.ID_PLAYLIST)"
  [void]$command.ExecuteNonQuery()
 }
 $connection.Close()
}
