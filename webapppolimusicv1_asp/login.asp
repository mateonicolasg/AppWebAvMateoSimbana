<!--#include file="includes/core.asp"-->
<%
Dim errorMessage, r, username, password
errorMessage=""
If Len(Session("UserId") & "")>0 Then Response.Redirect "index.asp"
If Request.ServerVariables("REQUEST_METHOD")="POST" Then
 CheckPost
 NeedDB
 username=Trim(Request.Form("username"))
 password=Request.Form("password")
 If Len(username)>50 Or Len(password)>50 Or Len(username)=0 Or Len(password)=0 Then
  errorMessage="Introduce tu usuario y contraseña."
 Else
  Set r=Q("SELECT ID_USER,USERNAME,USER_TYPE,USER_PHOTO FROM TBL_USER WHERE USERNAME=? AND (PASSWORD COLLATE Latin1_General_100_BIN2 = ? COLLATE Latin1_General_100_BIN2 OR PASSWORD = CONVERT(varchar(40),HASHBYTES('SHA1',?),2)) AND USER_TYPE IN (0,1)",Array(username,password,password))
  If r.EOF Then
   errorMessage="Usuario o contraseña incorrectos."
  Else
   Session("UserId")=CLng(r("ID_USER"))
   Session("Username")=r("USERNAME")
   Session("Role")=CInt(r("USER_TYPE"))
   Session("Photo")=r("USER_PHOTO") & ""
   Session("CSRF")=""
   Session.Timeout=30
   r.Close
   Response.Redirect "index.asp"
  End If
 End If
End If
%>
<!doctype html><html lang="es"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>Iniciar sesión · PoliMusic</title><link rel="stylesheet" href="assets/site.css"></head><body class="login-body"><main class="login-shell"><section class="login-art"><a class="brand" href="login.asp">◉ PoliMusic.</a><div class="orbit orbit-one"></div><div class="orbit orbit-two"></div><div class="record"><div>PoliMusic.</div></div><div class="login-copy"><span class="eyebrow">DALE PLAY A TU MUNDO</span><h1>Todo empieza<br>con una canción.</h1><p>Descubre sonidos. Guarda momentos.<br>Encuentra tu propia frecuencia.</p></div><span class="art-footer">TU MÚSICA. TU ESPACIO. POLIMUSIC.</span></section><section class="login-form"><span class="eyebrow">QUÉ BUENO VOLVER A VERTE</span><h2>Entra a PoliMusic.</h2><p>Inicia sesión para escuchar tu biblioteca.</p><% If Len(errorMessage)>0 Then %><p class="alert" role="alert"><%=H(errorMessage)%></p><% End If %><% If dbError Then %><p class="alert">La biblioteca no está disponible. Revisa la conexión a SQL Server.</p><% End If %><form method="post" action="login.asp"><input type="hidden" name="csrf" value="<%=H(Token())%>"><label for="username">Usuario</label><input id="username" name="username" maxlength="50" autocomplete="username" placeholder="Tu nombre de usuario" required><label for="password">Contraseña</label><input id="password" name="password" type="password" maxlength="50" autocomplete="current-password" placeholder="Tu contraseña" required><button class="button full">Iniciar sesión <span>→</span></button></form><p class="login-foot">Una biblioteca de sonidos, infinitas posibilidades.</p></section></main></body></html>
