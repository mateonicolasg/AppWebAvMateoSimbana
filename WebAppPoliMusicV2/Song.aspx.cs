using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace WebAppPoliMusicV2
{
    public partial class Song : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            Entities.User user = Session[Util.Constants.USER] as Entities.User;
            if (!Request.IsAuthenticated || user == null)
            {
                FormsAuthentication.SignOut();
                Response.Redirect("Login.aspx", false);
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
                gvSongs.DataSource = new BLL.Song(connection).Read();
                gvSongs.DataBind();
                if (gvSongs.HeaderRow != null)
                {
                    gvSongs.UseAccessibleHeader = true;
                    gvSongs.HeaderRow.TableSection = TableRowSection.TableHeader;
                }
            }
            catch (SqlException ex)
            {
                Trace.Warn("Song", "No se pudo consultar la lista de canciones.", ex);
                pnlMessage.Visible = true;
                litMessage.Text = "No se pudo cargar la lista. Comprueba la conexión con SQL Server y la base BDD_PoliMusic.";
            }
        }

        protected void Songs_RowDataBound(object sender, GridViewRowEventArgs e)
        {
            if (e.Row.RowType != DataControlRowType.DataRow) return;
            DataRowView row = (DataRowView)e.Row.DataItem;
            string path = Convert.ToString(row["SONG_PATH"]);
            Literal audio = (Literal)e.Row.FindControl("litAudio");
            // Only serve local MP3 files from this application's song folder.
            if (string.IsNullOrEmpty(path) || !path.StartsWith("~/SongFiles/", StringComparison.OrdinalIgnoreCase)
                || path.IndexOf("..", StringComparison.Ordinal) >= 0 || path.IndexOf('\\') >= 0
                || !path.EndsWith(".mp3", StringComparison.OrdinalIgnoreCase))
            {
                audio.Text = "<span class=\"unavailable\">Ruta de audio no válida</span>";
                return;
            }
            audio.Text = "<audio controls preload=\"none\" aria-label=\"Reproducir "
                + HttpUtility.HtmlAttributeEncode(Convert.ToString(row["SONG_NAME"]))
                + "\" src=\"" + HttpUtility.HtmlAttributeEncode(ResolveUrl(path))
                + "\">Tu navegador no admite audio.</audio>";
            if (!File.Exists(Server.MapPath(path)))
                audio.Text += "<small class=\"unavailable\">MP3 no encontrado en SongFiles</small>";
        }
    }
}
