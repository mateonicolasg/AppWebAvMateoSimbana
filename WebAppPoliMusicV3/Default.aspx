<%@ Page Title="Inicio" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Default.aspx.cs" Inherits="WebAppPoliMusicV3._Default" %>
<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
    <main class="info-page">
        <span class="song-eyebrow">BIENVENIDO A POLIMUSIC</span>
        <h1>Tu música.<br />Tu momento.</h1>
        <p>Un espacio para descubrir tus canciones y escucharlas a tu ritmo. Abre la biblioteca y elige con qué empezar.</p>
        <a class="music-button" runat="server" href="~/Song">Explorar canciones &rarr;</a>
    </main>
</asp:Content>
