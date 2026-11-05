<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Login.aspx.cs" Inherits="WebAppPoliMusicV3.Login" %>
<!DOCTYPE html>
<html lang="es">
<head runat="server"><meta charset="utf-8" /><meta name="viewport" content="width=device-width, initial-scale=1" /><title>Iniciar sesión · PoliMusic</title><link href="Content/Site.css" rel="stylesheet" /></head>
<body class="auth-page">
<form id="formLogin" runat="server" class="auth-card">
    <a class="navbar-brand" href="Login"><span class="brand-mark" aria-hidden="true">&#9835;</span><span>PoliMusic<small>Tu música, a tu ritmo.</small></span></a>
    <h1>Qué bueno verte.</h1><p>Inicia sesión para escuchar tus canciones.</p>
    <div class="auth-field"><asp:Label runat="server" AssociatedControlID="txtLogin" Text="Usuario" /><asp:TextBox ID="txtLogin" runat="server" placeholder="nombre.apellido" autocomplete="username" /></div>
    <div class="auth-field"><asp:Label runat="server" AssociatedControlID="txtPassword" Text="Contraseña" /><asp:TextBox ID="txtPassword" runat="server" TextMode="Password" autocomplete="current-password" /></div>
    <asp:Button ID="btnLogin" runat="server" Text="Iniciar sesión" OnClick="BtnLogin_Click" CssClass="music-button" />
    <asp:LinkButton ID="LinkButtonNewUser" runat="server" OnClick="LinkButtonNewUser_Click" CssClass="auth-back">Crear una cuenta</asp:LinkButton>
    <asp:Label ID="lblMessage" runat="server" CssClass="auth-message" role="status" />
</form>
</body>
</html>
