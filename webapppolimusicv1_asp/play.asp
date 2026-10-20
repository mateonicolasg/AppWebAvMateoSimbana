<!--#include file="includes/core.asp"-->
<% Auth False
CheckPost
Dim id,r,path
id=N(Request.Form("id"))
Set r=Q("SELECT SONG_PATH FROM TBL_SONG WHERE ID_SONG=?",Array(id))
If r.EOF Then
 Response.Status="404 Not Found"
Else
 path=Asset(r(0),"")
 If Len(path)>0 Then Run "UPDATE TBL_SONG SET PLAYS=ISNULL(PLAYS,0)+1 WHERE ID_SONG=?",Array(id)
End If
Response.ContentType="application/json"
Response.Write "{""ok"":true}"
%>
