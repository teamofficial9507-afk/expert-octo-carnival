// client.js - NUI handler for VehRaid leaderboard (patched)
(() => {
  const app = document.getElementById('app');
  const rowsEl = document.getElementById('rows');
  const emptyEl = document.getElementById('empty');
  const closeBtn = document.getElementById('closeBtn');

  function esc(s) {
    if (s === null || s === undefined) return '';
    return String(s).replace(/[&<>"']/g, (m) => ({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[m]));
  }

  function formatNumber(n) {
    const num = Number(n || 0);
    return num.toLocaleString();
  }

  function render(rows) {
    rowsEl.innerHTML = '';
    if (!rows || rows.length === 0) {
      emptyEl.style.display = 'block';
      return;
    }
    emptyEl.style.display = 'none';
    rows.forEach((r, i) => {
      const tr = document.createElement('tr');

      const rank = document.createElement('td');
      rank.className = 'rank';
      rank.textContent = (i + 1);
      tr.appendChild(rank);

      const player = document.createElement('td');
      player.className = 'player';
      // prefer displayName if provided, otherwise show shortened identifier
      const display = r.displayName || r.citizenid || r.steam_id || r.identifier || 'Unknown';
      const safe = esc(display);
      player.textContent = safe.length > 28 ? safe.slice(0, 25) + '...' : safe;
      tr.appendChild(player);

      const gold = document.createElement('td');
      gold.textContent = formatNumber(r.gold_bars || r.gold || r.reward_amount || 0);
      tr.appendChild(gold);

      const kills = document.createElement('td');
      kills.textContent = formatNumber(r.kills || 0);
      tr.appendChild(kills);

      rowsEl.appendChild(tr);
    });
  }

  window.addEventListener('message', (ev) => {
    const d = ev.data;
    if (!d || !d.action) return;
    if (d.action === 'openLeaderboard') {
      render(d.rows || []);
      app.classList.remove('hidden');
    } else if (d.action === 'close') {
      app.classList.add('hidden');
    } else if (d.action === 'update') {
      // update without changing focus/visibility
      render(d.rows || []);
    }
  });

  closeBtn.addEventListener('click', () => {
    app.classList.add('hidden');
    fetch(`https://${GetParentResourceName()}/close`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({})
    }).catch((err) => console.warn('NUI close failed', err));
  });

  document.addEventListener('keydown', (e) => {
    if (e.key === 'Escape') {
      app.classList.add('hidden');
      fetch(`https://${GetParentResourceName()}/close`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({})
      }).catch((err) => console.warn('NUI close failed', err));
    }
  });

  window.vehraidNui = { render };
})();
