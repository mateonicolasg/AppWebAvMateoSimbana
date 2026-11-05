<%@ Page Title="Canciones" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Song.aspx.cs" Inherits="WebAppPoliMusicV3.Song" %>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
    <main class="song-page">
        <header class="song-welcome">
            <div><span class="song-eyebrow">TU ESPACIO MUSICAL</span>
            <h1>Hola, <asp:Literal ID="litUser" runat="server" Mode="Encode" /><span class="song-note">.</span></h1>
            <p>Una pausa, una canción. Encuentra tu próximo ritmo.</p></div>
            <div class="record-art" aria-hidden="true"><span></span></div>
        </header>
        <section class="song-library" aria-labelledby="songsTitle">
            <div class="library-heading"><div><span class="song-eyebrow">EXPLORA Y ESCUCHA</span><h2 id="songsTitle">Tus canciones</h2></div><span class="library-tag">Biblioteca musical</span></div>
            <asp:Panel ID="pnlMessage" runat="server" Visible="false" CssClass="song-message" role="status">
                No se pudo cargar la lista de canciones. Comprueba la conexión con SQL Server e intenta nuevamente.
            </asp:Panel>
            <div class="song-table-wrap">
                <asp:GridView ID="gvSongs" runat="server" AutoGenerateColumns="false" GridLines="None"
                    CssClass="song-table" OnRowDataBound="Songs_RowDataBound" EnableViewState="false" ShowHeaderWhenEmpty="true">
                    <Columns>
                        <asp:BoundField DataField="ID_SONG" HeaderText="ID canción" ItemStyle-CssClass="song-id" />
                        <asp:BoundField DataField="SONG_NAME" HeaderText="Nombre" ItemStyle-CssClass="song-name" />
                        <asp:BoundField DataField="SONG_PATH" HeaderText="Ruta" ItemStyle-CssClass="song-path" />
                        <asp:BoundField DataField="PLAYS" HeaderText="Reproducciones" />
                        <asp:TemplateField HeaderText="Reproducir">
                            <ItemTemplate><asp:Literal ID="litAudio" runat="server" /></ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                    <EmptyDataTemplate>Todavía no hay canciones registradas.</EmptyDataTemplate>
                </asp:GridView>
            </div>
        </section>
    </main>
    <script>
        // Evita que suenen dos canciones al mismo tiempo.
        document.querySelectorAll('.song-table audio').forEach(function (player) {
            player.addEventListener('play', function () {
                document.querySelectorAll('.song-table audio').forEach(function (other) {
                    if (other instanceof HTMLAudioElement && other !== player) {
                        other.pause();
                    }
                });
            });
        });
    </script>
</asp:Content>
