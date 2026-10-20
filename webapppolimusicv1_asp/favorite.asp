<!--#include file="includes/core.asp"-->
<% Auth False
CheckPost
Dim id,fid,r
id=N(Request.Form("id"))
Set r=Q("SELECT ID_SONG FROM TBL_SONG WHERE ID_SONG=?",Array(id))
If Not r.EOF Then
 fid=FavoriteId(True)
 Set r=Q("SELECT ID_SONG FROM TBL_PLAYLIST_SONG WHERE ID_PLAYLIST=? AND ID_SONG=?",Array(fid,id))
 If r.EOF Then
  Run "INSERT INTO TBL_PLAYLIST_SONG(ID_PLAYLIST,ID_SONG) VALUES(?,?)",Array(fid,id)
 Else
  Run "DELETE FROM TBL_PLAYLIST_SONG WHERE ID_PLAYLIST=? AND ID_SONG=?",Array(fid,id)
 End If
End If
If Request.Form("from")="favorites" Then Response.Redirect "favorites.asp?saved=1"
Response.Redirect "index.asp?saved=1"
%>
