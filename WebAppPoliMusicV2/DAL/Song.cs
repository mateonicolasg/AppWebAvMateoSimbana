using System;
using System.Data;
using System.Data.SqlClient;
namespace WebAppPoliMusicV2.DAL
{
    public class Song
    {
        private readonly string connectionString;
        public Song(string connectionString) { this.connectionString = connectionString; }
        public DataTable Read()
        {
            using (SqlConnection connection = new SqlConnection(connectionString))
            using (SqlDataAdapter adapter = new SqlDataAdapter("SELECT ID_SONG, SONG_NAME, SONG_PATH, PLAYS FROM dbo.TBL_SONG ORDER BY SONG_NAME, ID_SONG", connection))
            {
                DataTable table = new DataTable();
                adapter.Fill(table);
                return table;
            }
        }
        public Entities.Song Read(int id)
        {
            using (SqlConnection connection = new SqlConnection(connectionString))
            using (SqlCommand command = new SqlCommand("SELECT ID_SONG, SONG_NAME, SONG_PATH, PLAYS FROM dbo.TBL_SONG WHERE ID_SONG = @ID", connection))
            {
                command.Parameters.Add("@ID", SqlDbType.Int).Value = id;
                connection.Open();
                using (SqlDataReader reader = command.ExecuteReader())
                {
                    if (!reader.Read()) return null;
                    return new Entities.Song { ID = reader.GetInt32(0), Name = reader.GetString(1), Path = reader.GetString(2), Plays = reader.IsDBNull(3) ? (int?)null : reader.GetInt32(3) };
                }
            }
        }
        public int Save(Entities.Song song)
        {
            return Execute("INSERT INTO dbo.TBL_SONG (SONG_NAME, SONG_PATH, PLAYS) VALUES (@NAME, @PATH, @PLAYS)", song);
        }
        public int Update(Entities.Song song)
        {
            // Preserve playback counts when editing metadata.
            return Execute("UPDATE dbo.TBL_SONG SET SONG_NAME = @NAME, SONG_PATH = @PATH WHERE ID_SONG = @ID", song);
        }
        public int Delete(int id)
        {
            // Foreign keys protect songs referenced by albums or playlists.
            return Execute("DELETE FROM dbo.TBL_SONG WHERE ID_SONG = @ID", new Entities.Song { ID = id });
        }
        private int Execute(string sql, Entities.Song song)
        {
            using (SqlConnection connection = new SqlConnection(connectionString))
            using (SqlCommand command = new SqlCommand(sql, connection))
            {
                command.Parameters.Add("@ID", SqlDbType.Int).Value = song.ID;
                command.Parameters.Add("@NAME", SqlDbType.VarChar, 50).Value = (object)song.Name ?? DBNull.Value;
                command.Parameters.Add("@PATH", SqlDbType.VarChar, 255).Value = (object)song.Path ?? DBNull.Value;
                command.Parameters.Add("@PLAYS", SqlDbType.Int).Value = (object)song.Plays ?? DBNull.Value;
                connection.Open();
                return command.ExecuteNonQuery();
            }
        }
    }
}
