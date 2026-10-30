<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Song.aspx.cs" Inherits="WebAppPoliMusicV2.Song" CodePage="65001" %>
<!DOCTYPE html>
<html lang="es">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>Canciones · PoliMusic</title>
    <link href="Content/song.css" rel="stylesheet" />
</head>
<body>
<form id="formSong" runat="server">
    <main class="page">
        <header class="welcome">
            <div>
                <span class="brand"><span class="brand-icon" aria-hidden="true">≈</span> POLIMUSIC</span>
                <h1>Bienvenido, <span><asp:Literal ID="litUser" runat="server" Mode="Encode" /></span><span class="welcome-note" aria-hidden="true">♫</span></h1>
            </div>
            <a class="logout" href="Logout.aspx">Cerrar sesión <span aria-hidden="true">↗</span></a>
        </header>
        <section class="library" aria-labelledby="libraryTitle">
            <div class="section-heading"><span class="eyebrow">TU BIBLIOTECA</span><h2 id="libraryTitle">Lista de canciones<span class="title-dot">.</span></h2></div>
            <asp:Panel ID="pnlMessage" runat="server" Visible="false" CssClass="message" role="status"><asp:Literal ID="litMessage" runat="server" Mode="Encode" /></asp:Panel>
            <div class="table-wrap">
                <asp:GridView ID="gvSongs" runat="server" AutoGenerateColumns="false" GridLines="None" CssClass="song-table" OnRowDataBound="Songs_RowDataBound" EnableViewState="false">
                    <Columns>
                        <asp:BoundField DataField="ID_SONG" HeaderText="ID canción" HtmlEncode="true" ItemStyle-CssClass="song-id" />
                        <asp:TemplateField HeaderText="Nombre"><ItemTemplate><div class="song-name"><span class="song-icon" aria-hidden="true">♪</span><strong><%# Server.HtmlEncode(Convert.ToString(Eval("SONG_NAME"))) %></strong></div></ItemTemplate></asp:TemplateField>
                        <asp:BoundField DataField="SONG_PATH" HeaderText="Ruta" HtmlEncode="true" ItemStyle-CssClass="song-path" />
                        <asp:TemplateField HeaderText="Reproducciones"><ItemTemplate><span class="plays"><%# Eval("PLAYS") == DBNull.Value ? "0" : Eval("PLAYS") %></span></ItemTemplate></asp:TemplateField>
                        <asp:TemplateField HeaderText="Reproducir"><ItemTemplate><asp:Literal ID="litAudio" runat="server" /></ItemTemplate></asp:TemplateField>
                    </Columns>
                    <EmptyDataTemplate><div class="empty-state">Todavía no hay canciones registradas.</div></EmptyDataTemplate>
                </asp:GridView>
            </div>
        </section>
        <footer>PoliMusic <span>Tu música, a tu ritmo.</span></footer>
    </main>
</form>
</body>
</html>
