<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="SignUp.aspx.cs" Inherits="WebAppPoliMusicV3.SignUp" %>
<!DOCTYPE html>
<html lang="es">
<head runat="server"><meta charset="utf-8" /><meta name="viewport" content="width=device-width, initial-scale=1" /><title>Crear cuenta · PoliMusic</title><link href="Content/Site.css" rel="stylesheet" /></head>
<body class="auth-page">
<form id="formLogin" runat="server" class="auth-card">
    <a class="navbar-brand" href="Login"><span class="brand-mark" aria-hidden="true">&#9835;</span><span>PoliMusic<small>Tu música, a tu ritmo.</small></span></a>
    <h1>Tu primer compás.</h1><p>Crea tu cuenta. Los campos con * son obligatorios.</p>
    <div class="auth-field"><asp:Label runat="server" AssociatedControlID="txtUserName" Text="Usuario *" /><asp:TextBox ID="txtUserName" runat="server" autocomplete="username" /></div>
    <div class="auth-field"><asp:Label runat="server" AssociatedControlID="txtEmail" Text="Correo electrónico *" /><asp:TextBox ID="txtEmail" runat="server" autocomplete="email" /></div>
    <div class="auth-field"><asp:Label runat="server" AssociatedControlID="txtPassword" Text="Contraseña *" /><asp:TextBox ID="txtPassword" runat="server" TextMode="Password" autocomplete="new-password" /></div>
    <div class="auth-field"><asp:Label runat="server" AssociatedControlID="txtConfirmPassword" Text="Confirmar contraseña *" /><asp:TextBox ID="txtConfirmPassword" runat="server" TextMode="Password" autocomplete="new-password" /></div>
    <div class="auth-field"><asp:Label runat="server" AssociatedControlID="txtBirthDate" Text="Fecha de nacimiento (opcional)" /><asp:TextBox ID="txtBirthDate" runat="server" placeholder="dd/MM/yyyy" /></div>
    <div class="auth-field"><asp:Label runat="server" AssociatedControlID="fupPhoto" Text="Foto de perfil (opcional)" /><asp:FileUpload ID="fupPhoto" runat="server" /></div>
    <asp:Button ID="btnSumbit" runat="server" Text="Crear cuenta" OnClick="btnSumbit_Click" CssClass="music-button" />
    <asp:HyperLink ID="HyperLink1" NavigateUrl="~/Login" runat="server" CssClass="auth-back">Volver a iniciar sesión</asp:HyperLink>
    <asp:Panel ID="frmConfirmation" Visible="true" runat="server"><asp:Label ID="lblMessage" runat="server" CssClass="auth-message" role="status" /></asp:Panel>
</form>
</body>
</html>
