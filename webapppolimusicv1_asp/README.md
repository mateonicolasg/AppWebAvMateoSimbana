# PoliMusic · Classic ASP

Sitio musical en Classic ASP + VBScript, HTML, CSS y JavaScript. Todas las páginas y los includes tienen extensión `.asp`. No utiliza ASP.NET ni modifica la estructura de SQL Server.

## Ejecutar

1. La base `BDD_PoliMusic` debe existir en SQL Server local. **No vuelvas a ejecutar el script original sobre una base con datos: contiene DROP DATABASE.** La aplicación no ejecuta ese script.
2. Habilita IIS y la característica **ASP** (World Wide Web Services → Application Development Features → ASP), junto con contenido estático y documento predeterminado. Usa un application pool con **No Managed Code** y crea una aplicación IIS apuntando a esta carpeta. Concede lectura a la identidad del pool; el sitio no necesita escribir archivos.
3. Instala Microsoft OLE DB Driver for SQL Server (MSOLEDBSQL) con la arquitectura del application pool. `includes/core.asp` usa este proveedor y tiene un fallback al proveedor integrado SQLOLEDB. La cadena utiliza localhost, BDD_PoliMusic y las credenciales del script. Adapta servidor/proveedor en ese archivo si tu instancia cambia.
4. Abre `http://localhost/<alias>/login.asp`. Abrir el archivo directamente, Live Server y los servidores estáticos no ejecutan VBScript.
5. Los estilos y funcionalidades trabajan sin dependencias JavaScript. Las fuentes Google Fonts son opcionales; hay fuentes de sistema de respaldo.

Si tienes IIS Express instalado, ejecuta `powershell -NoProfile -ExecutionPolicy Bypass -File tools/start-local.ps1` desde esta carpeta y abre [PoliMusic local](http://localhost:8088/login.asp). El script genera una configuración local en `tools/.runtime`, usa un pool sin runtime administrado y no altera la configuración global de IIS. Mantén esa consola abierta mientras uses el sitio. Puedes elegir otro puerto mediante `-Port 8090`.

Usuarios del script: `userNormal` / `12345678` y `userAdmin` / `12345678`. También se admite el formato SHA1 hexadecimal del tercer usuario existente, mediante HASHBYTES en SQL Server. La aplicación no cambia contraseñas existentes.

## Estructura analizada antes de implementar

| Tabla | Campos existentes | Relaciones y uso |
|---|---|---|
| TBL_USER | ID_USER, USERNAME, PASSWORD, EMAIL, BIRTHDAY, USER_PHOTO, USER_TYPE | Usuario; 0 normal, 1 administrador |
| TBL_SONG | ID_SONG, SONG_NAME, SONG_PATH, PLAYS | Catálogo y contador de escuchas |
| TBL_ARTIST | ID_ARTIST, ARTIST_NAME, ARTIST_LASTNAME, ARTIST_IMAGE | Artistas |
| TBL_ALBUM | ID_ALBUM, TITLE_ALBUM, RELEASE_YEAR, ALBUM_IMAGE_PATH | Álbumes |
| TBL_PLAYER | ID_SONG, ID_ARTIST | Canciones ↔ artistas, clave compuesta |
| TBL_TRACKLIST | ID_ALBUM, ID_SONG | Álbumes ↔ canciones, clave compuesta |
| TBL_PLAYLIST | ID_PLAYLIST, ID_USER, TITLE, CREATION_DATE, TYPE, PHOTO | Usuario → playlists; TYPE 0 pública, 1 privada |
| TBL_PLAYLIST_SONG | ID_PLAYLIST, ID_SONG | Playlists ↔ canciones, clave compuesta |
| TBL_CATALOG | ID_CATALOG, COD_CATALOG_PARENT, COD_CATALOG, VALUE | Describe tipos de usuario y playlist |

Favoritos usa una playlist privada llamada `Favoritos` de cada usuario. Se crea solo al agregar la primera canción; no se reutilizan ni alteran otras playlists del script. La propiedad se obtiene de Session, nunca de un ID de usuario enviado por el navegador.

## Assets revisados

Solo existe `SongFilesAndImages_resources/SongFiles/bensound-adventure.mp3`. Dreams, Energy, Scifi y Tomorrow están en SQL pero sus MP3 no fueron entregados: aparecen como no disponibles. No se reproduce Adventure bajo el nombre de otra canción. Copia los archivos faltantes a SongFiles para habilitarlos. Las rutas `~/songFiles/...` del script se resuelven a la carpeta real sin alterar SQL.

Hay seis imágenes de playlists y dos de usuarios. Las carpetas AlbumImages y ArtistImages referidas por SQL no existen. Las tarjetas utilizan imágenes reales de PlaylistImages como respaldo visual. No se inventan columnas de portada para canciones. Al editar una imagen ausente, selecciona una imagen existente o deja la ruta vacía.

## Navegación y comportamiento

- `login.asp`: autentica los usuarios reales y guarda UserId, Username, Role y Photo en Session.
- `index.asp`: biblioteca Song List, buscador, álbumes y reproductor con volumen, progreso, anterior y siguiente.
- `favorites.asp` / `favorite.asp`: consulta, agregar y quitar favoritos persistentes del usuario actual.
- `play.asp`: incrementa PLAYS al comenzar a reproducir un MP3 disponible.
- `admin.asp?entity=songs|artists|albums`: CRUD protegido por rol; en canciones se pueden seleccionar múltiples artistas y álbumes mediante las relaciones existentes.
- `logout.asp`: POST protegido y cierre de sesión.
- `includes/*.asp`: conexión, consultas parametrizadas, protección, encabezado y pie compartidos.

Las operaciones de escritura requieren POST y un token de sesión. El SQL usa parámetros; los nombres de tablas y campos provienen exclusivamente de una lista fija del servidor. Los borrados eliminan asociaciones dentro de una transacción, conservando las demás entidades y los archivos MP3/imágenes. Hay confirmación de borrado en el navegador. Las rutas de assets se restringen al sitio y se comprueba la existencia de archivos. Los mensajes de error de conexión no exponen credenciales.

## Verificación

Comprobado con IIS Express y SQL Server local: login real con ambos roles; biblioteca y buscador; MP3 existente y cuatro ausentes; acceso 403 al administrador para usuario normal; POST sin token rechazado; cierre de sesión; creación, edición y eliminación de canciones, artistas y álbumes; persistencia de ambas relaciones; agregar/quitar favoritos y actualización de PLAYS. Los registros temporales de QA se eliminaron al terminar. También se revisó visualmente la biblioteca en el navegador.

`tools/check-local.ps1` repite las verificaciones de lectura, autenticación y autorización. `tools/check-writes.ps1` crea registros temporales de QA, prueba las escrituras y los elimina en finally; ejecútalo únicamente contra una base local de desarrollo. Ambos requieren PowerShell 7 y un sitio iniciado. Los scripts están bloqueados por HTTP mediante web.config.
