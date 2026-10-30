using System;
using System.Data;
namespace WebAppPoliMusicV2.BLL
{
    public class Song
    {
        private readonly DAL.Song songs;
        public Song(string connectionString) { songs = new DAL.Song(connectionString); }
        public DataTable Read() { return songs.Read(); }
        public Entities.Song Read(int id) { ValidateID(id); return songs.Read(id); }
        public int Save(Entities.Song song) { Validate(song); return songs.Save(song); }
        public int Update(Entities.Song song) { Validate(song); ValidateID(song.ID); return songs.Update(song); }
        public int Delete(int id) { ValidateID(id); return songs.Delete(id); }
        private static void ValidateID(int id)
        {
            if (id <= 0) throw new ArgumentException("Selecciona una canción válida.");
        }
        private static void Validate(Entities.Song song)
        {
            if (song == null) throw new ArgumentException("La canción es obligatoria.");
            song.Name = (song.Name ?? string.Empty).Trim();
            if (song.Name.Length == 0 || song.Name.Length > 50)
                throw new ArgumentException("El nombre debe tener entre 1 y 50 caracteres.");
            if (string.IsNullOrEmpty(song.Path) || song.Path.Length > 255 ||
                !song.Path.StartsWith("~/SongFiles/", StringComparison.OrdinalIgnoreCase) ||
                song.Path.IndexOf("..", StringComparison.Ordinal) >= 0 || song.Path.IndexOf('\\') >= 0 ||
                !song.Path.EndsWith(".mp3", StringComparison.OrdinalIgnoreCase))
                throw new ArgumentException("El archivo debe ser un MP3 dentro de SongFiles.");
            if (song.Plays.HasValue && song.Plays.Value < 0)
                throw new ArgumentException("Las reproducciones no pueden ser negativas.");
        }
    }
}
