using System.Data;
using System.Data.SqlClient;

namespace DAL.PoliMusicV3
{
    public class Song
    {
        private readonly string strConnectionString;

        public Song(string strConnString)
        {
            strConnectionString = strConnString;
        }

        public DataTable Read()
        {
            DataTable dtSong = new DataTable();
            using (SqlConnection con = new SqlConnection(strConnectionString))
            using (SqlCommand cmd = new SqlCommand(
                "SELECT [ID_SONG], [SONG_NAME], [SONG_PATH], ISNULL([PLAYS], 0) AS [PLAYS] " +
                "FROM [dbo].[TBL_SONG] ORDER BY [ID_SONG]", con))
            using (SqlDataAdapter adapter = new SqlDataAdapter(cmd))
            {
                adapter.Fill(dtSong);
            }
            return dtSong;
        }
    }
}
