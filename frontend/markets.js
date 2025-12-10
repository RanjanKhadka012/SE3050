// markets.js

const API_BASE = ''; // same origin

document.getElementById('year').textContent = new Date().getFullYear();

async function loadMarkets() {
  const container = document.getElementById('markets-list');
  const details = document.getElementById('market-details');
  details.innerHTML = '';
  container.textContent = 'Loading markets…';

  try {
    const res = await fetch(`${API_BASE}/api/markets`);
    if (!res.ok) throw new Error('Network error');
    const markets = await res.json();
    if (!Array.isArray(markets) || markets.length === 0) {
      container.textContent = 'No markets found.';
      return;
    }

    const table = document.createElement('table');
    const thead = document.createElement('thead');
    thead.innerHTML = `
      <tr>
        <th>Market</th>
        <th>City</th>
        <th>Next Event</th>
        <th>Hours</th>
        <th></th>
      </tr>`;
    table.appendChild(thead);

    const tbody = document.createElement('tbody');
    markets.forEach(m => {
      const tr = document.createElement('tr');
      const city = (m.City || '') + (m.Region ? ', ' + m.Region : '');
      const nextEvent = m.NextEventDate || 'No upcoming events';
      const hours = `${(m.OpenTime || '').slice(0,5)} - ${(m.CloseTime || '').slice(0,5)}`;
      tr.innerHTML = `
        <td>${escapeHtml(m.MarketName)}</td>
        <td>${escapeHtml(city)}</td>
        <td>${escapeHtml(nextEvent)}</td>
        <td>${escapeHtml(hours)}</td>
        <td><button class="small" data-market-id="${m.MarketID}">View Details</button></td>
      `;
      tbody.appendChild(tr);
    });
    table.appendChild(tbody);
    container.innerHTML = '';
    container.appendChild(table);

    tbody.querySelectorAll('button[data-market-id]').forEach(btn => {
      btn.addEventListener('click', () => {
        loadMarketDetails(btn.dataset.marketId);
      });
    });
  } catch (err) {
    console.error(err);
    container.textContent = 'Error loading markets.';
  }
}

async function loadMarketDetails(marketId) {
  const details = document.getElementById('market-details');
  details.textContent = 'Loading market details…';
  try {
    const res = await fetch(`/api/markets/${marketId}`);
    if (!res.ok) {
      details.textContent = 'Failed to load market details.';
      return;
    }
    const data = await res.json();
    const { market, events, vendors } = data;

    let html = `
      <div class="panel">
        <h3>${escapeHtml(market.Name)}</h3>
        <p>
          ${escapeHtml(market.Address || '')},
          ${escapeHtml(market.City || '')} ${escapeHtml(market.Zip || '')}<br>
          Season: ${escapeHtml(market.StartDate || '')} - ${escapeHtml(market.EndDate || '')}<br>
          Hours: ${(market.OpenTime || '').slice(0,5)} - ${(market.CloseTime || '').slice(0,5)}
        </p>
      </div>
    `;

    html += `<div class="panel"><h4>Upcoming Events</h4>`;
    if (!events || events.length === 0) {
      html += `<p>No upcoming events.</p>`;
    } else {
      html += '<ul>';
      for (const e of events) {
        html += `
          <li>
            <strong>${escapeHtml(e.EventDate)}</strong> at ${(e.StartTime || '').slice(0,5)}
            – ${escapeHtml(e.Address || '')}
          </li>`;
      }
      html += '</ul>';
    }
    html += '</div>';

    html += `<div class="panel"><h4>Vendors</h4>`;
    if (!vendors || vendors.length === 0) {
      html += `<p>No vendors listed.</p>`;
    } else {
      html += '<ul>';
      for (const v of vendors) {
        const cat = v.VendorCategory ? ` (${escapeHtml(v.VendorCategory)})` : '';
        html += `<li><strong>${escapeHtml(v.Name)}</strong>${cat}</li>`;
      }
      html += '</ul>';
    }
    html += '</div>';

    details.innerHTML = html;
  } catch (err) {
    console.error(err);
    details.textContent = 'Error loading market details.';
  }
}

function escapeHtml(str) {
  if (str === null || str === undefined) return '';
  return String(str)
    .replace(/&/g, '&amp;').replace(/</g, '&lt;')
    .replace(/>/g, '&gt;').replace(/"/g, '&quot;')
    .replace(/'/g, '&#39;');
}

// initial load
loadMarkets();
