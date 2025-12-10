// search.js

const API_BASE = '';

document.getElementById('year').textContent = new Date().getFullYear();

const searchForm = document.getElementById('search-form');
const searchInput = document.getElementById('search-input');
const searchResults = document.getElementById('search-results');

searchForm.addEventListener('submit', async (e) => {
  e.preventDefault();
  const term = searchInput.value.trim();
  if (!term) {
    searchResults.textContent = 'Enter a search term.';
    return;
  }
  searchResults.textContent = 'Searching…';
  try {
    const res = await fetch(`${API_BASE}/api/searchProducts?q=` + encodeURIComponent(term));
    if (!res.ok) throw new Error('Network error');
    const items = await res.json();
    if (!Array.isArray(items) || items.length === 0) {
      searchResults.textContent = 'No matching products found.';
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
    searchResults.innerHTML = '';
    searchResults.appendChild(table);

    tbody.querySelectorAll('button[data-preorder-event]').forEach(btn => {
      btn.addEventListener('click', () => openPreorderPanel(btn.dataset));
    });
  } catch (err) {
    console.error(err);
    searchResults.textContent = 'Error searching products.';
  }
});

// Pre-order panel logic

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
  preorderMessage.className = '';

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
  preorderMessage.className = '';

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

function escapeHtml(str) {
  if (str === null || str === undefined) return '';
  return String(str)
    .replace(/&/g, '&amp;').replace(/</g, '&lt;')
    .replace(/>/g, '&gt;').replace(/"/g, '&quot;')
    .replace(/'/g, '&#39;');
}
