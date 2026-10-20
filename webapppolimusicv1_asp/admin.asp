<!--#include file="includes/core.asp"-->
<%
Auth True
Dim pageTitle, entity, tableName, keyName, fields, labels, limits, kind, id, action, r, rows, i, values, errorMessage, sql, assignments, placeholders, v, relation, selected, opts, chosen, parts, part, relationIds, relationTable, relationKey, otherTable, otherLabel, selectedId, transactionError
entity=Request.QueryString("entity")
Select Case entity
 Case "artists"
  tableName="TBL_ARTIST":keyName="ID_ARTIST":fields=Array("ARTIST_NAME","ARTIST_LASTNAME","ARTIST_IMAGE"):labels=Array("Nombre","Apellido","Imagen (ruta local)"):limits=Array(100,100,255):kind="artistas"
 Case "albums"
  tableName="TBL_ALBUM":keyName="ID_ALBUM":fields=Array("TITLE_ALBUM","RELEASE_YEAR","ALBUM_IMAGE_PATH"):labels=Array("Título","Año de lanzamiento","Imagen (ruta local)"):limits=Array(50,4,255):kind="álbumes"
 Case Else
  entity="songs":tableName="TBL_SONG":keyName="ID_SONG":fields=Array("SONG_NAME","SONG_PATH"):labels=Array("Nombre de la canción","Archivo MP3 (ruta local)"):limits=Array(50,255):kind="canciones"
End Select
pageTitle="Administrar " & kind
id=N(Request.QueryString("id"))
errorMessage=""
ReDim values(UBound(fields))
For i=0 To UBound(fields):values(i)="":Next
If Request.ServerVariables("REQUEST_METHOD")="POST" Then
 CheckPost
 id=N(Request.Form("id"))
 action=Request.Form("action")
 If action<>"save" And action<>"delete" Then errorMessage="Acción inválida."
 If action="delete" And id=0 Then errorMessage="Selecciona un registro válido."
 If action="save" Then
  For i=0 To UBound(fields)
   values(i)=Trim(Request.Form(fields(i)))
   If Len(values(i))>limits(i) Then errorMessage="Uno de los campos supera la longitud permitida."
  Next
  If Len(values(0))=0 Then errorMessage="El nombre o título es obligatorio."
  If entity="songs" Then
   If Len(values(1))=0 Then errorMessage="Selecciona un archivo MP3."
   If LCase(Right(values(1),4))<>".mp3" Or Len(Asset(values(1),""))=0 Then errorMessage="La canción necesita un MP3 existente en los assets."
  End If
  If entity="albums" And Len(values(1))>0 Then
   If Not IsNumeric(values(1)) Then
    errorMessage="Escribe un año válido."
   ElseIf CDbl(values(1))<1 Or CDbl(values(1))>9999 Or CDbl(values(1))<>Fix(CDbl(values(1))) Then
    errorMessage="Escribe un año entre 1 y 9999."
   End If
  End If
  If entity<>"songs" Then
   If Len(values(2))>0 Then
    If Len(Asset(values(2),""))=0 Then errorMessage="La imagen debe ser un archivo local existente."
   End If
  End If
 End If
 If Len(errorMessage)=0 Then
  On Error Resume Next
  db.BeginTrans
  If id>0 Then
   Set r=Q("SELECT " & keyName & " FROM " & tableName & " WHERE " & keyName & "=?",Array(id))
   If r.EOF Then Err.Raise 513,,"Registro no encontrado"
   r.Close
  End If
  If action="delete" Then
   Select Case entity
    Case "songs"
     Run "DELETE FROM TBL_PLAYLIST_SONG WHERE ID_SONG=?",Array(id)
     Run "DELETE FROM TBL_PLAYER WHERE ID_SONG=?",Array(id)
     Run "DELETE FROM TBL_TRACKLIST WHERE ID_SONG=?",Array(id)
    Case "artists":Run "DELETE FROM TBL_PLAYER WHERE ID_ARTIST=?",Array(id)
    Case "albums":Run "DELETE FROM TBL_TRACKLIST WHERE ID_ALBUM=?",Array(id)
   End Select
   Run "DELETE FROM " & tableName & " WHERE " & keyName & "=?",Array(id)
  Else
   assignments="":placeholders=""
   For i=0 To UBound(fields)
    If i>0 Then assignments=assignments & ",":placeholders=placeholders & ","
    assignments=assignments & fields(i) & "=?"
    placeholders=placeholders & "?"
   Next
   If entity="albums" Then
    If Len(values(1))=0 Then values(1)="0"
    values(1)=CLng(values(1))
   End If
   If id=0 Then
    sql="INSERT INTO " & tableName & "(" & Join(fields,",") & ") OUTPUT INSERTED." & keyName & " VALUES(" & placeholders & ")"
    Set r=Q(sql,values)
    id=CLng(r(0))
    r.Close
   Else
    Run "UPDATE " & tableName & " SET " & assignments & " WHERE " & keyName & "=" & id,values
   End If
   If entity="albums" Then
    If values(1)=0 Then Run "UPDATE TBL_ALBUM SET RELEASE_YEAR=NULL WHERE ID_ALBUM=?",Array(id)
   End If
   If entity="songs" Then
    Run "UPDATE TBL_SONG SET PLAYS=ISNULL(PLAYS,0) WHERE ID_SONG=?",Array(id)
    Run "DELETE FROM TBL_PLAYER WHERE ID_SONG=?",Array(id)
    Run "DELETE FROM TBL_TRACKLIST WHERE ID_SONG=?",Array(id)
    Set opts=Q("SELECT ID_ARTIST FROM TBL_ARTIST",Array())
    Do Until opts.EOF
     selectedId=CLng(opts(0))
     If Request.Form("artist_" & selectedId)="1" Then Run "INSERT INTO TBL_PLAYER(ID_SONG,ID_ARTIST) VALUES(?,?)",Array(id,selectedId)
     opts.MoveNext
    Loop
    Set opts=Q("SELECT ID_ALBUM FROM TBL_ALBUM",Array())
    Do Until opts.EOF
     selectedId=CLng(opts(0))
     If Request.Form("album_" & selectedId)="1" Then Run "INSERT INTO TBL_TRACKLIST(ID_SONG,ID_ALBUM) VALUES(?,?)",Array(id,selectedId)
     opts.MoveNext
    Loop
   End If
  End If
  transactionError=Err.Number
  If transactionError<>0 Then
   Err.Clear
   db.RollbackTrans
   errorMessage="No se pudo guardar el cambio. Revisa los datos e inténtalo de nuevo."
  Else
   db.CommitTrans
   If Err.Number<>0 Then errorMessage="No se pudo confirmar el cambio."
  End If
  Err.Clear
  On Error GoTo 0
  If Len(errorMessage)=0 Then Response.Redirect "admin.asp?entity=" & entity & "&saved=1"
 End If
ElseIf id>0 Then
 Set r=Q("SELECT * FROM " & tableName & " WHERE " & keyName & "=?",Array(id))
 If r.EOF Then
  Response.Status="404 Not Found"
  errorMessage="El registro ya no existe.":id=0
 Else
  For i=0 To UBound(fields):values(i)=r(fields(i)) & "":Next
 End If
End If
Set rows=Q("SELECT * FROM " & tableName & " ORDER BY " & keyName & " DESC",Array())
%>
<!--#include file="includes/header.asp"-->
<section class="admin-title"><span class="eyebrow">ESTUDIO PoliMusic / ADMINISTRACIÓN</span><h1>Tu música, en orden<span class="blue-dot">.</span></h1><p>Gestiona tu biblioteca de <%=kind%>.</p></section><div class="admin-tabs"><a class="<% If entity="songs" Then Response.Write "active" %>" href="admin.asp?entity=songs">Canciones</a><a class="<% If entity="artists" Then Response.Write "active" %>" href="admin.asp?entity=artists">Artistas</a><a class="<% If entity="albums" Then Response.Write "active" %>" href="admin.asp?entity=albums">Álbumes</a></div>
<% If Len(errorMessage)>0 Then %><p class="alert" role="alert"><%=H(errorMessage)%></p><% End If %><% If Request.QueryString("saved")="1" Then %><p class="notice" role="status">Cambios guardados correctamente.</p><% End If %>
<div class="admin-grid"><section class="editor panel"><h2><% If id=0 Then Response.Write "Crear registro" Else Response.Write "Editar registro #" & id %></h2><form method="post" action="admin.asp?entity=<%=entity%>"><input type="hidden" name="csrf" value="<%=H(Token())%>"><input type="hidden" name="id" value="<%=id%>"><input type="hidden" name="action" value="save"><% For i=0 To UBound(fields) %><label for="<%=fields(i)%>"><%=labels(i)%></label><input id="<%=fields(i)%>" name="<%=fields(i)%>" maxlength="<%=limits(i)%>" value="<%=H(values(i))%>" <% If i=0 Or (entity="songs" And i=1) Then Response.Write "required" %> <% If entity="songs" And i=1 Then Response.Write "list='mp3files'" %>><% Next %>
<% If entity="songs" Then %><datalist id="mp3files"><option value="SongFilesAndImages_resources/SongFiles/bensound-adventure.mp3"></datalist><p class="help">Usa rutas locales relativas al sitio. Solo se aceptan MP3 existentes.</p><fieldset><legend>Artistas</legend><% Set opts=Q("SELECT a.ID_ARTIST,a.ARTIST_NAME+' '+ISNULL(a.ARTIST_LASTNAME,'') AS LABEL, (SELECT COUNT(*) FROM TBL_PLAYER p WHERE p.ID_ARTIST=a.ID_ARTIST AND p.ID_SONG=?) AS CHOSEN FROM TBL_ARTIST a ORDER BY a.ARTIST_NAME",Array(id))
Do Until opts.EOF %><label class="check"><input type="checkbox" name="artist_<%=opts("ID_ARTIST")%>" value="1" <% If Request.ServerVariables("REQUEST_METHOD")="POST" Then
If Request.Form("artist_" & opts("ID_ARTIST"))="1" Then Response.Write "checked"
ElseIf CLng(opts("CHOSEN"))>0 Then
Response.Write "checked"
End If %>><%=H(opts("LABEL"))%></label><% opts.MoveNext:Loop %></fieldset><fieldset><legend>Álbumes</legend><% Set opts=Q("SELECT a.ID_ALBUM,a.TITLE_ALBUM AS LABEL, (SELECT COUNT(*) FROM TBL_TRACKLIST t WHERE t.ID_ALBUM=a.ID_ALBUM AND t.ID_SONG=?) AS CHOSEN FROM TBL_ALBUM a ORDER BY a.TITLE_ALBUM",Array(id))
Do Until opts.EOF %><label class="check"><input type="checkbox" name="album_<%=opts("ID_ALBUM")%>" value="1" <% If Request.ServerVariables("REQUEST_METHOD")="POST" Then
If Request.Form("album_" & opts("ID_ALBUM"))="1" Then Response.Write "checked"
ElseIf CLng(opts("CHOSEN"))>0 Then
Response.Write "checked"
End If %>><%=H(opts("LABEL"))%></label><% opts.MoveNext:Loop %></fieldset><% End If %><div class="form-actions"><button class="button">Guardar cambios</button><a href="admin.asp?entity=<%=entity%>">Nuevo / Cancelar</a></div></form></section><section class="records panel"><h2>Biblioteca de <%=kind%></h2><% If rows.EOF Then %><p class="muted">Todavía no hay registros. Crea el primero.</p><% End If %><% Do Until rows.EOF %><article class="record-row"><div><span class="eyebrow">#<%=rows(keyName)%></span><h3><%=H(rows(fields(0)))%></h3><p><%=H(rows(fields(1)))%></p></div><div class="record-actions"><a class="edit-link" href="admin.asp?entity=<%=entity%>&amp;id=<%=rows(keyName)%>">Editar</a><form method="post" action="admin.asp?entity=<%=entity%>" data-confirm="¿Eliminar este registro y sus asociaciones? Los archivos se conservarán."><input type="hidden" name="csrf" value="<%=H(Token())%>"><input type="hidden" name="id" value="<%=rows(keyName)%>"><input type="hidden" name="action" value="delete"><button class="delete">Eliminar</button></form></div></article><% rows.MoveNext:Loop %></section></div>
<!--#include file="includes/footer.asp"-->
