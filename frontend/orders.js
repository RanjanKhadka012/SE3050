// orders.js

const API_BASE = '';

document.getElementById('year').textContent = new Date().getFullYear();

async function loadOrders() {
  const container = document.getElementById('orders-list');
  container.textContent = 'Loading orders…';
  try {
    const res = await fetch(`${API_BASE}/api/orders`);
    if (!res.ok) throw new Error('Network error');
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

function escapeHtml(str) {
  if (str === null || str === undefined) return '';
  return String(str)
    .replace(/&/g, '&amp;').replace(/</g, '&lt;')
    .replace(/>/g, '&gt;').replace(/</g, '&lt;')
    .replace(/>/g, '&gt;').replace(/"/g, '&quot;')
    .replace(/'/g, '&#39;');
}

// load on page open
loadOrders();
