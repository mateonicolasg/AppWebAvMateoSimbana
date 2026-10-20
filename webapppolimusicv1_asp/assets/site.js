document.querySelectorAll('form[data-confirm]').forEach(form => form.addEventListener('submit', event => { if (!confirm(form.dataset.confirm)) event.preventDefault(); }));
(() => {
  const audio = document.getElementById('audio');
  if (!audio) return;
  const tracks = [...document.querySelectorAll('.song-play:not([disabled])')];
  const toggle = document.getElementById('togglePlay');
  const seek = document.getElementById('seek');
  const status = document.getElementById('playerStatus');
  let current = -1;
  let counted = false;
  const time = seconds => Number.isFinite(seconds) ? `${Math.floor(seconds / 60)}:${String(Math.floor(seconds % 60)).padStart(2, '0')}` : '0:00';
  async function play(index) {
    if (!tracks.length) { status.textContent = 'No hay archivos MP3 disponibles en esta lista.'; return; }
    current = (index + tracks.length) % tracks.length;
    const track = tracks[current];
    tracks.forEach(item => item.closest('.song-row').classList.toggle('playing', item === track));
    document.getElementById('playerCover').src = track.dataset.cover;
    document.getElementById('playerTitle').textContent = track.dataset.title;
    document.getElementById('playerArtist').textContent = track.dataset.artist;
    audio.src = track.dataset.src;
    counted = false;
    try { await audio.play(); } catch { status.textContent = 'No se pudo reproducir. Vuelve a pulsar reproducir.'; }
  }
  tracks.forEach((track, index) => track.addEventListener('click', () => play(index)));
  document.getElementById('playAll')?.addEventListener('click', () => play(0));
  toggle.addEventListener('click', async () => {
    if (current < 0) return play(0);
    if (audio.paused) { try { await audio.play(); } catch { status.textContent = 'El archivo no está disponible.'; } }
    else audio.pause();
  });
  document.getElementById('next').addEventListener('click', () => play(current + 1));
  document.getElementById('previous').addEventListener('click', () => play(current - 1));
  audio.addEventListener('play', () => { toggle.textContent = 'Ⅱ'; });
  audio.addEventListener('playing', () => {
    if (counted || current < 0) return;
    counted = true;
    const track = tracks[current];
    fetch('play.asp', { method: 'POST', body: new URLSearchParams({ id: track.dataset.id, csrf: track.dataset.csrf }) }).then(response => {
      if (response.ok) { const cell = track.closest('.song-row').querySelector('.plays-cell'); cell.textContent = (Number(cell.textContent) || 0) + 1; }
    }).catch(() => { status.textContent = 'No se pudo actualizar el contador de escuchas.'; });
  });
  audio.addEventListener('pause', () => { toggle.textContent = '▶'; });
  audio.addEventListener('ended', () => { if (current + 1 < tracks.length) play(current + 1); else toggle.textContent = '▶'; });
  audio.addEventListener('error', () => { status.textContent = 'No se pudo abrir el MP3 seleccionado.'; toggle.textContent = '▶'; });
  audio.addEventListener('timeupdate', () => { document.getElementById('elapsed').textContent = time(audio.currentTime); document.getElementById('duration').textContent = time(audio.duration); seek.value = Number.isFinite(audio.duration) && audio.duration > 0 ? audio.currentTime / audio.duration * 100 : 0; });
  seek.addEventListener('input', () => { if (Number.isFinite(audio.duration)) audio.currentTime = seek.value / 100 * audio.duration; });
  audio.volume = 0.8;
  document.getElementById('volume').addEventListener('input', event => { audio.volume = Number(event.target.value); });
})();
