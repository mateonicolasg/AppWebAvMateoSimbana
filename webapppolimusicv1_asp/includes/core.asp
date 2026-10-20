<%@ Language=VBScript CodePage=65001 %>
<% Option Explicit
Response.Charset = "utf-8"
Response.Buffer = True
Response.AddHeader "Cache-Control", "no-store"
Response.AddHeader "X-Content-Type-Options", "nosniff"
Response.AddHeader "X-Frame-Options", "DENY"
Dim db, dbError
dbError = False
Set db = Server.CreateObject("ADODB.Connection")
On Error Resume Next
db.Open "Provider=MSOLEDBSQL;Server=localhost;Database=BDD_PoliMusic;UID=usr_polimusic;PWD=Politecnica1;TrustServerCertificate=yes;"
If Err.Number <> 0 Then
 Err.Clear
 db.Open "Provider=SQLOLEDB;Data Source=localhost;Initial Catalog=BDD_PoliMusic;User ID=usr_polimusic;Password=Politecnica1;"
End If
If Err.Number <> 0 Then dbError = True
Err.Clear
On Error GoTo 0
Function H(v)
 If IsNull(v) Then v = ""
 H = Server.HTMLEncode(CStr(v))
End Function
Function N(v)
 N = 0
 If IsNumeric(v) Then
  If CDbl(v)>0 And CDbl(v)<=2147483647 Then N=CLng(v)
 End If
End Function
Function Q(sql, args)
 Dim cmd, i, p
 Set cmd = Server.CreateObject("ADODB.Command")
 Set cmd.ActiveConnection = db
 cmd.CommandText = sql
 cmd.CommandType = 1
 For i=0 To UBound(args)
  If VarType(args(i))=2 Or VarType(args(i))=3 Then
   Set p=cmd.CreateParameter("p" & i,3,1,,args(i))
  Else
   Set p=cmd.CreateParameter("p" & i,200,1,8000,CStr(args(i)))
  End If
  cmd.Parameters.Append p
 Next
 Set Q=cmd.Execute
End Function
Sub Run(sql,args)
 Dim r
 Set r=Q(sql,args)
End Sub
Sub NeedDB()
 If dbError Then
  Response.Status="503 Service Unavailable"
  Response.Write "<!doctype html><html lang='es'><meta charset='utf-8'><title>Conexión pendiente · PoliMusic</title><link rel='stylesheet' href='assets/site.css'><main class='connection'><span class='brand'>◉ PoliMusic</span><h1>No pudimos conectar con la biblioteca.</h1><p>Comprueba SQL Server en localhost, la base BDD_PoliMusic y el proveedor OLE DB. Consulta README.md para configurar IIS.</p><a class='button' href='login.asp'>Reintentar</a></main></html>"
  Response.End
 End If
End Sub
Sub Auth(admin)
 If Len(Session("UserId") & "")=0 Then Response.Redirect "login.asp"
 If admin And Session("Role")<>1 Then
  Response.Status="403 Forbidden"
  Response.Write "Acceso reservado al administrador. <a href='index.asp'>Volver a la biblioteca</a>"
  Response.End
 End If
 NeedDB
End Sub
Function Token()
 Dim g
 If Len(Session("CSRF") & "")=0 Then
  Randomize
  Session("CSRF")=CStr(Timer) & CStr(Rnd) & CStr(Rnd) & CStr(Rnd)
 End If
 Token=Session("CSRF")
End Function
Sub CheckPost()
 If Request.ServerVariables("REQUEST_METHOD")<>"POST" Or Len(Request.Form("csrf"))=0 Or Request.Form("csrf")<>Token() Then
  Response.Status="403 Forbidden"
  Response.Write "Solicitud inválida. Vuelve a la página e inténtalo de nuevo."
  Response.End
 End If
End Sub
Function Asset(path, fallback)
 Dim s, fso
 s=Replace(Trim(path & ""),"\","/")
 If Left(s,2)="~/" Then s=Mid(s,3)
 If InStr(s,":")>0 Or InStr(s,"..")>0 Or Left(s,1)="/" Then s=""
 If Len(s)>0 And LCase(Left(s,29))<>"songfilesandimages_resources/" Then s="SongFilesAndImages_resources/" & s
 Set fso=Server.CreateObject("Scripting.FileSystemObject")
 If Len(s)>0 Then
  If Not fso.FileExists(Server.MapPath(s)) Then s=""
 End If
 If Len(s)=0 Then s=fallback
 Asset=s
End Function
Function Cover(id)
 Cover="SongFilesAndImages_resources/PlaylistImages/playlist" & ((N(id) Mod 5)+1) & ".png"
End Function
Function FavoriteId(createIt)
 Dim r, id
 Set r=Q("SELECT TOP 1 ID_PLAYLIST FROM TBL_PLAYLIST WHERE ID_USER=? AND TITLE='Favoritos' AND TYPE=1 ORDER BY ID_PLAYLIST",Array(CLng(Session("UserId"))))
 id=0
 If Not r.EOF Then id=CLng(r(0))
 r.Close
 If id=0 And createIt Then
  Set r=Q("INSERT INTO TBL_PLAYLIST(ID_USER,TITLE,CREATION_DATE,TYPE,PHOTO) OUTPUT INSERTED.ID_PLAYLIST VALUES(?,'Favoritos',GETDATE(),1,NULL)",Array(CLng(Session("UserId"))))
  id=CLng(r(0))
  r.Close
 End If
 FavoriteId=id
End Function
%>
