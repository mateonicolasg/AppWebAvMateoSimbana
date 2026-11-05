using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace WebAppPoliMusicV3
{
    public partial class Song : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            var user = Session[EntityLayer.PoliMusicV3.Util.Constants.USER] as EntityLayer.PoliMusicV3.User;
            if (!Request.IsAuthenticated || user == null)
            {
                FormsAuthentication.SignOut();
                Response.Redirect("~/Login", false);
                Context.ApplicationInstance.CompleteRequest();
                return;
            }
            Response.Cache.SetCacheability(HttpCacheability.NoCache);
            Response.Cache.SetNoStore();
            litUser.Text = user.UserName;
            if (!IsPostBack) LoadSongs();
        }

        private void LoadSongs()
        {
            try
            {
                string connection = ConfigurationManager.ConnectionStrings["BDD_PoliMusicConnectionString"].ConnectionString;
                gvSongs.DataSource = new BLL.PoliMusicV3.Song(connection).Read();
                gvSongs.DataBind();
                if (gvSongs.HeaderRow != null)
                    gvSongs.HeaderRow.TableSection = TableRowSection.TableHeader;
            }
            catch (SqlException ex)
            {
                Trace.Warn("Song", "No se pudo consultar TBL_SONG.", ex);
                pnlMessage.Visible = true;
            }
        }

        protected void Songs_RowDataBound(object sender, GridViewRowEventArgs e)
        {
            if (e.Row.RowType != DataControlRowType.DataRow) return;
            DataRowView song = (DataRowView)e.Row.DataItem;
            Literal audio = (Literal)e.Row.FindControl("litAudio");
            string path = Convert.ToString(song["SONG_PATH"]);
            // El laboratorio usa tanto ~/songFiles/ como ../songFiles/.
            if (path.StartsWith("../SongFiles/", StringComparison.OrdinalIgnoreCase))
                path = "~/SongFiles/" + path.Substring("../SongFiles/".Length);
            else if (path.StartsWith("SongFiles/", StringComparison.OrdinalIgnoreCase))
                path = "~/" + path;

            if (!path.StartsWith("~/SongFiles/", StringComparison.OrdinalIgnoreCase)
                || path.Contains("..") || path.Contains("\\")
                || !path.EndsWith(".mp3", StringComparison.OrdinalIgnoreCase))
            {
                audio.Text = "<span class=\"song-unavailable\">Ruta de audio no válida</span>";
                return;
            }
            if (!File.Exists(Server.MapPath(path)))
            {
                audio.Text = "<span class=\"song-unavailable\">Audio no disponible</span>";
                return;
            }
            audio.Text = "<audio controls preload=\"none\" aria-label=\"Reproducir "
                + HttpUtility.HtmlAttributeEncode(Convert.ToString(song["SONG_NAME"]))
                + "\" src=\"" + HttpUtility.HtmlAttributeEncode(ResolveUrl(path))
                + "\">Tu navegador no admite audio.</audio>";
        }
    }
}
