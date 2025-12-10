// public/app.js

const API_BASE = ''; // same origin (served by Express)

// DOM refs
const views = {
  markets: document.getElementById('view-markets'),
  search: document.getElementById('view-search'),
  orders: document.getElementById('view-orders')
};

document.querySelectorAll('header nav button').forEach(btn => {
  btn.addEventListener('click', () => {
    const view = btn.dataset.view;
    switchView(view);
  });
});

function switchView(name) {
  Object.entries(views).forEach(([key, el]) => {
    if (key === name) el.classList.add('active');
    else el.classList.remove('active');
  });

  if (name === 'markets') {
    loadMarkets();
  } else if (name === 'search') {
    document.getElementById('search-results').innerHTML = '';
  } else if (name === 'orders') {
    loadOrders();
  }
}

// -------- Markets --------
async function loadMarkets() {
  const container = document.getElementById('markets-list');
  const details = document.getElementById('market-details');
  details.innerHTML = '';
  container.textContent = 'Loading markets…';
  try {
    const res = await fetch(`${API_BASE}/api/markets`);
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
      const city = m.City + (m.Region ? ', ' + m.Region : '');
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
        const id = btn.dataset.marketId;
        loadMarketDetails(id);
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
    const res = await fetch(`${API_BASE}/api/markets/${marketId}`);
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
          Season: ${escapeHtml(market.StartDate)} - ${escapeHtml(market.EndDate)}<br>
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
            <button class="small" data-preorder-event="${e.EventID}">Pre-order for this event</button>
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

    details.querySelectorAll('button[data-preorder-event]').forEach(btn => {
      btn.addEventListener('click', () => {
        switchView('search');
      });
    });

  } catch (err) {
    console.error(err);
    details.textContent = 'Error loading market details.';
  }
}

// -------- Search Products --------
document.getElementById('search-form').addEventListener('submit', async (e) => {
  e.preventDefault();
  const term = document.getElementById('search-input').value.trim();
  const container = document.getElementById('search-results');
  if (!term) {
    container.textContent = 'Enter a search term.';
    return;
  }
  container.textContent = 'Searching…';
  try {
    const res = await fetch(`${API_BASE}/api/searchProducts?q=` + encodeURIComponent(term));
    const items = await res.json();
    if (!Array.isArray(items) || items.length === 0) {
      container.textContent = 'No matching products found.';
      return;
    }
    const table = document.createElement('table');
    table.innerHTML = `
      <thead>
        <tr>
          <th>Product</th>
          <th>Category</th>
          <th>Vendor</th>
          <th>Market / Event</th>
          <th>Available</th>
          <th></th>
        </tr>
      </thead>
    `;
    const tbody = document.createElement('tbody');
    items.forEach(r => {
      const tr = document.createElement('tr');
      tr.innerHTML = `
        <td>${escapeHtml(r.ProductName)}</td>
        <td>${escapeHtml(r.Category || '')}</td>
        <td>${escapeHtml(r.VendorName)}</td>
        <td>${escapeHtml(r.MarketName)} (${escapeHtml(r.EventDate)})</td>
        <td>${escapeHtml(String(r.QtyAvailable))}</td>
        <td>
          <button class="small"
            data-preorder-event="${r.EventID}"
            data-preorder-product="${r.ProductID}"
            data-preorder-name="${escapeHtml(r.ProductName)}"
            data-preorder-market="${escapeHtml(r.MarketName)}"
            data-preorder-date="${escapeHtml(r.EventDate)}"
            data-preorder-vendor="${escapeHtml(r.VendorName)}"
            data-preorder-available="${r.QtyAvailable}">
            Pre-order
          </button>
        </td>
      `;
      tbody.appendChild(tr);
    });
    table.appendChild(tbody);
    container.innerHTML = '';
    container.appendChild(table);

    tbody.querySelectorAll('button[data-preorder-event]').forEach(btn => {
      btn.addEventListener('click', () => {
        openPreorderPanel(btn.dataset);
      });
    });
  } catch (err) {
    console.error(err);
    container.textContent = 'Error searching products.';
  }
});

// -------- Orders --------
async function loadOrders() {
  const container = document.getElementById('orders-list');
  container.textContent = 'Loading orders…';
  try {
    const res = await fetch(`${API_BASE}/api/orders`);
    const orders = await res.json();
    if (!Array.isArray(orders) || orders.length === 0) {
      container.textContent = 'You have no orders yet.';
      return;
    }
    const table = document.createElement('table');
    table.innerHTML = `
      <thead>
        <tr>
          <th>Order #</th>
          <th>Date</th>
          <th>Market / Event</th>
          <th>Total</th>
          <th>Payment</th>
          <th>Pickup</th>
        </tr>
      </thead>
    `;
    const tbody = document.createElement('tbody');
    orders.forEach(o => {
      const tr = document.createElement('tr');
      const market = o.MarketName || 'N/A';
      const eventDate = o.EventDate ? ` (${o.EventDate})` : '';
      const total = Number(o.TotalAmount || 0).toFixed(2);
      tr.innerHTML = `
        <td>${escapeHtml(String(o.OrderID))}</td>
        <td>${escapeHtml(o.OrderDate)}</td>
        <td>${escapeHtml(market)}${escapeHtml(eventDate)}</td>
        <td>$${escapeHtml(total)}</td>
        <td>${escapeHtml(o.PaymentStatus || '')}</td>
        <td>${escapeHtml(o.PickupStatus || '')}</td>
      `;
      tbody.appendChild(tr);
    });
    table.appendChild(tbody);
    container.innerHTML = '';
    container.appendChild(table);
  } catch (err) {
    console.error(err);
    container.textContent = 'Error loading orders.';
  }
}

// -------- Pre-order panel --------
const preorderPanel = document.getElementById('preorder-panel');
const preorderTitle = document.getElementById('preorder-title');
const preorderInfo = document.getElementById('preorder-info');
const preorderEventId = document.getElementById('preorder-event-id');
const preorderProductId = document.getElementById('preorder-product-id');
const preorderQty = document.getElementById('preorder-qty');
const preorderMessage = document.getElementById('preorder-message');

function openPreorderPanel(data) {
  preorderEventId.value = data.preorderEvent;
  preorderProductId.value = data.preorderProduct;
  preorderQty.value = 1;
  preorderMessage.textContent = '';

  preorderTitle.textContent = `Pre-order: ${data.preorderName}`;
  preorderInfo.innerHTML = `
    Vendor: ${data.preorderVendor}<br>
    Market: ${data.preorderMarket}<br>
    Event Date: ${data.preorderDate}<br>
    Available: ${data.preorderAvailable}
  `;

  preorderPanel.classList.remove('hidden');
}

document.getElementById('preorder-cancel').addEventListener('click', () => {
  preorderPanel.classList.add('hidden');
});

document.getElementById('preorder-form').addEventListener('submit', async (e) => {
  e.preventDefault();
  const eventId = preorderEventId.value;
  const productId = preorderProductId.value;
  const qty = parseInt(preorderQty.value, 10) || 1;

  preorderMessage.textContent = 'Placing pre-order…';
  try {
    const res = await fetch(`${API_BASE}/api/preorders`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ eventId, productId, quantity: qty })
    });
    const data = await res.json();
    if (!res.ok || !data.success) {
      preorderMessage.textContent = 'Error: ' + (data.error || 'Failed to place order');
      preorderMessage.className = 'alert error';
      return;
    }
    preorderMessage.textContent = `Success! Order #${data.orderId}, total $${data.total.toFixed(2)}`;
    preorderMessage.className = 'alert success';
  } catch (err) {
    console.error(err);
    preorderMessage.textContent = 'Error placing pre-order.';
    preorderMessage.className = 'alert error';
  }
});

// -------- Helpers --------
function escapeHtml(str) {
  if (str === null || str === undefined) return '';
  return String(str)
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&#39;');
}

document.getElementById('year').textContent = new Date().getFullYear();

// Initial view
switchView('markets');
