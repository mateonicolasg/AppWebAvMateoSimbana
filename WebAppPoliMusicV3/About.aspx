<%@ Page Title="Acerca de" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="About.aspx.cs" Inherits="WebAppPoliMusicV3.About" %>
<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
    <main class="info-page">
        <span class="song-eyebrow">ACERCA DEL PROYECTO</span>
        <h1>Así suena PoliMusic.</h1>
        <p>Una biblioteca musical para consultar canciones y reproducir el audio disponible desde el navegador.</p>
        <p>Proyecto de Mateo Simbaña para Aplicaciones Web Avanzadas de la Escuela Politécnica Nacional, desarrollado con ASP.NET Web Forms y arquitectura en capas.</p>
        <a class="music-button" runat="server" href="~/Song">Ir a la biblioteca &rarr;</a>
    </main>
</asp:Content>
