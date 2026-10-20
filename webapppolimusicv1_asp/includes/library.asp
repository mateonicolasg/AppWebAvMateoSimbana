<%
Dim songs, albums, artists, term, sql, fid, songPath, artistText, albumText, count, favorite, imagePath
fid=FavoriteId(False)
term=Left(Trim(Request.QueryString("q")),50)
sql="SELECT s.*, (SELECT STRING_AGG(a.ARTIST_NAME + ' ' + ISNULL(a.ARTIST_LASTNAME,''), ', ') FROM TBL_PLAYER p JOIN TBL_ARTIST a ON a.ID_ARTIST=p.ID_ARTIST WHERE p.ID_SONG=s.ID_SONG) AS ARTISTS, (SELECT TOP 1 a.TITLE_ALBUM FROM TBL_TRACKLIST t JOIN TBL_ALBUM a ON a.ID_ALBUM=t.ID_ALBUM WHERE t.ID_SONG=s.ID_SONG ORDER BY a.ID_ALBUM) AS ALBUM_TITLE, (SELECT COUNT(*) FROM TBL_PLAYLIST_SONG ps WHERE ps.ID_SONG=s.ID_SONG AND ps.ID_PLAYLIST=" & fid & ") AS IS_FAVORITE FROM TBL_SONG s WHERE s.SONG_NAME LIKE ?"
If favoritesOnly Then sql=sql & " AND EXISTS(SELECT 1 FROM TBL_PLAYLIST_SONG ps WHERE ps.ID_SONG=s.ID_SONG AND ps.ID_PLAYLIST=" & fid & ")"
sql=sql & " ORDER BY s.ID_SONG"
Set songs=Q(sql,Array("%" & Replace(Replace(Replace(term,"[","[[]"),"%","[%]"),"_","[_]") & "%"))
%>
<!--#include file="header.asp"-->
<section class="hero"><div class="hero-content"><span class="pill"><% If favoritesOnly Then Response.Write "HECHA POR TI" Else Response.Write "TU DOSIS DIARIA DE MÚSICA" %></span><h1><% If favoritesOnly Then Response.Write "Los sonidos<br>que se quedan." Else Response.Write "Siente el ritmo.<br>Encuentra tu ritmo." %></h1><p><% If favoritesOnly Then Response.Write "Todas tus canciones favoritas, en un solo lugar." Else Response.Write "Explora tu biblioteca y dale un nuevo sonido a tu día." %></p><button id="playAll" class="button">▶ &nbsp; Escuchar ahora</button></div><div class="hero-vinyl" aria-hidden="true"><div class="vinyl-label">PoliMusic<span>FEEL THE FREQUENCY</span></div></div><span class="hero-caption">SONIDOS QUE CONECTAN ↗</span></section>
<section class="library-section"><div class="section-heading"><div><span class="eyebrow">TU BIBLIOTECA</span><h2><% If favoritesOnly Then Response.Write "Tus favoritos" Else Response.Write "Song List" %><span class="blue-dot">.</span></h2></div><form class="search" method="get"><label class="sr-only" for="search">Buscar canciones</label><span>⌕</span><input id="search" name="q" value="<%=H(term)%>" placeholder="Buscar una canción…"><button class="icon" aria-label="Buscar">→</button></form></div><% If Len(Request.QueryString("saved"))>0 Then %><p class="notice" role="status">Tu biblioteca de favoritos se ha actualizado.</p><% End If %><div class="song-table"><div class="song-row table-head"><span>#</span><span>CANCIÓN</span><span>ÁLBUM</span><span>ESCUCHAS</span><span>FAVORITO</span></div>
<% count=0
Do Until songs.EOF
 count=count+1
 songPath=Asset(songs("SONG_PATH"),"")
 artistText=songs("ARTISTS") & ""
 If Len(artistText)=0 Then artistText="Artista sin asignar"
 albumText=songs("ALBUM_TITLE") & ""
 If Len(albumText)=0 Then albumText="Sin álbum"
 favorite=(CLng(songs("IS_FAVORITE"))>0)
 imagePath=Cover(songs("ID_SONG"))
%><div class="song-row"><span class="song-number"><%=Right("0" & count,2)%></span><div class="song-info"><button class="song-play" <% If Len(songPath)=0 Then Response.Write "disabled" %> data-id="<%=songs("ID_SONG")%>" data-src="<%=H(songPath)%>" data-title="<%=H(songs("SONG_NAME"))%>" data-artist="<%=H(artistText)%>" data-cover="<%=H(imagePath)%>" data-csrf="<%=H(Token())%>" aria-label="Reproducir <%=H(songs("SONG_NAME"))%>"><img src="<%=H(imagePath)%>" alt=""><span>▶</span></button><div><strong><%=H(songs("SONG_NAME"))%></strong><small><%=H(artistText)%></small><% If Len(songPath)=0 Then %><small class="unavailable">MP3 no disponible</small><% End If %></div></div><span class="album-cell"><%=H(albumText)%></span><span class="plays-cell"><%=H(songs("PLAYS"))%></span><form method="post" action="favorite.asp"><input type="hidden" name="csrf" value="<%=H(Token())%>"><input type="hidden" name="id" value="<%=songs("ID_SONG")%>"><input type="hidden" name="from" value="<% If favoritesOnly Then Response.Write "favorites" Else Response.Write "index" %>"><button class="favorite icon <% If favorite Then Response.Write "selected" %>" aria-label="<% If favorite Then Response.Write "Quitar de favoritos" Else Response.Write "Agregar a favoritos" %>" aria-pressed="<%=LCase(CStr(favorite))%>"><% If favorite Then Response.Write "♥" Else Response.Write "♡" %></button></form></div><% songs.MoveNext
Loop
songs.Close
%></div><% If count=0 Then %><div class="empty"><span>♫</span><h3>Aquí comienza tu próxima colección.</h3><p><% If favoritesOnly Then Response.Write "Toca el corazón de una canción para guardarla aquí." Else Response.Write "No hay canciones que coincidan con tu búsqueda." %></p><a href="index.asp">Explorar canciones →</a></div><% End If %><p class="list-caption"><%=count%> canciones · Elige el sonido de tu momento</p></section>
<% If Not favoritesOnly Then
Set albums=Q("SELECT TOP 5 * FROM TBL_ALBUM ORDER BY ID_ALBUM",Array())
%><section class="album-section"><div class="section-heading"><div><span class="eyebrow">EXPLORA OTROS SONIDOS</span><h2>Un álbum, un mundo<span class="blue-dot">.</span></h2></div><span class="muted">De tu colección</span></div><div class="album-grid"><% Do Until albums.EOF %><article class="album-card"><img src="<%=H(Asset(albums("ALBUM_IMAGE_PATH"),Cover(albums("ID_ALBUM"))))%>" alt="Portada de <%=H(albums("TITLE_ALBUM"))%>"><h3><%=H(albums("TITLE_ALBUM"))%></h3><p>Álbum · <%=H(albums("RELEASE_YEAR"))%></p></article><% albums.MoveNext
Loop
albums.Close %></div></section><% End If %>
<!--#include file="footer.asp"-->
