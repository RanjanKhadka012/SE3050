// server.js
const express = require('express');
const cors = require('cors');
const path = require('path');
const pool = require('./db');

const app = express();
const PORT = 3000;          // <-- web server port (keep this 3000)
const CURRENT_USER_ID = 1;  // pretend user 1 is logged in

app.use(cors());
app.use(express.json());

// serve static files from ../frontend
app.use(express.static(path.join(__dirname, '..', 'frontend')));

app.get('/', (req, res) => {
  res.sendFile(path.join(__dirname, '..', 'frontend', 'index.html'));
});

app.get('/search', (req, res) => {
  res.sendFile(path.join(__dirname, '..', 'frontend', 'search.html'));
});

app.get('/orders', (req, res) => {
  res.sendFile(path.join(__dirname, '..', 'frontend', 'orders.html'));
});

// --- test DB on startup ---
(async () => {
  try {
    const [rows] = await pool.query('SELECT DATABASE() AS db, NOW() AS now');
    console.log('✅ MySQL connected:', rows[0]);
  } catch (err) {
    console.error('❌ MySQL connection FAILED:', err.message);
  }
})();

// ---------------------------
// Health check
// ---------------------------
app.get('/api/health', (req, res) => {
  res.json({ status: 'ok' });
});

// ---------------------------
// GET /api/markets
// Browse all markets
// ---------------------------
app.get('/api/markets', async (req, res) => {
  try {
    const sql = `
      SELECT
        m.MarketID,
        m.Name AS MarketName,
        l.City,
        l.Region,
        l.Zip,
        MIN(CASE WHEN me.EventDate >= CURDATE() THEN me.EventDate END) AS NextEventDate,
        m.OpenTime,
        m.CloseTime
      FROM market m
      LEFT JOIN location l   ON l.LocationID = m.LocationID
      LEFT JOIN marketevent me ON me.MarketID  = m.MarketID
      GROUP BY
        m.MarketID, m.Name, l.City, l.Region, l.Zip, m.OpenTime, m.CloseTime
      ORDER BY l.City, m.Name;
    `;
    const [rows] = await pool.query(sql);
    res.json(rows);
  } catch (err) {
    console.error('Error fetching markets:', err);
    res.status(500).json({ error: 'Failed to fetch markets' });
  }
});

// ---------------------------
// GET /api/markets/:id
// Market details + vendors + upcoming events
// ---------------------------
app.get('/api/markets/:id', async (req, res) => {
  const marketId = parseInt(req.params.id, 10);
  if (Number.isNaN(marketId)) {
    return res.status(400).json({ error: 'Invalid market id' });
  }

  const conn = await pool.getConnection();
  try {
    const [markets] = await conn.query(
      `
      SELECT m.*, l.City, l.Region, l.Zip
      FROM market m
      LEFT JOIN location l ON l.LocationID = m.LocationID
      WHERE m.MarketID = ?
      `,
      [marketId]
    );

    if (markets.length === 0) {
      conn.release();
      return res.status(404).json({ error: 'Market not found' });
    }
    const market = markets[0];

    const [events] = await conn.query(
      `
      SELECT me.EventID, me.EventDate, me.StartTime, me.Address
      FROM marketevent me
      WHERE me.MarketID = ? AND me.EventDate >= CURDATE()
      ORDER BY me.EventDate
      `,
      [marketId]
    );

    const [vendors] = await conn.query(
      `
      SELECT DISTINCT v.VendorID, v.Name, v.Description, v.VendorCategory
      FROM marketvendor mv
      JOIN vendor v ON v.VendorID = mv.VendorID
      WHERE mv.MarketID = ?
      ORDER BY v.Name
      `,
      [marketId]
    );

    conn.release();
    res.json({ market, events, vendors });
  } catch (err) {
    conn.release();
    console.error('Error fetching market details:', err);
    res.status(500).json({ error: 'Failed to fetch market details' });
  }
});

// ---------------------------
// GET /api/searchProducts?q=...
// Search products across all markets
// ---------------------------
app.get('/api/searchProducts', async (req, res) => {
  const term = (req.query.q || '').trim();
  if (!term) return res.json([]);

  try {
    const sql = `
      SELECT
        p.ProductID,
        p.Name AS ProductName,
        pc.Name AS Category,
        v.Name AS VendorName,
        i.EventID,
        me.EventDate,
        m.Name AS MarketName,
        (i.AvailableQuantity - i.ReservedQuantity) AS QtyAvailable
      FROM inventory i
      JOIN product p         ON p.ProductID   = i.ProductID
      JOIN vendor v          ON v.VendorID    = i.VendorID
      JOIN marketevent me    ON me.EventID    = i.EventID
      JOIN market m          ON m.MarketID    = me.MarketID
      LEFT JOIN productcategory pc ON pc.CategoryID = p.CategoryID
      WHERE (i.AvailableQuantity - i.ReservedQuantity) > 0
        AND p.Name LIKE CONCAT('%', ?, '%')
      ORDER BY p.Name, me.EventDate;
    `;
    const [rows] = await pool.query(sql, [term]);
    res.json(rows);
  } catch (err) {
    console.error('Error searching products:', err);
    res.status(500).json({ error: 'Failed to search products' });
  }
});

// ---------------------------
// GET /api/orders
// Orders for current user
// ---------------------------
app.get('/api/orders', async (req, res) => {
  const userId = CURRENT_USER_ID;
  try {
    const sql = `
      SELECT
        o.OrderID,
        o.OrderDate,
        o.PickupDate,
        o.TotalAmount,
        o.PaymentStatus,
        o.PickupStatus,
        me.EventDate,
        m.Name AS MarketName
      FROM \`order\` o
      LEFT JOIN marketevent me ON me.EventID = o.EventID
      LEFT JOIN market m ON m.MarketID = me.MarketID
      WHERE o.UserID = ?
      ORDER BY o.OrderDate DESC
    `;
    const [rows] = await pool.query(sql, [userId]);
    res.json(rows);
  } catch (err) {
    console.error('Error fetching orders:', err);
    res.status(500).json({ error: 'Failed to fetch orders' });
  }
});

// ---------------------------
// POST /api/preorders
// body: { eventId, productId, quantity }
// Uses a DB transaction
// ---------------------------
app.post('/api/preorders', async (req, res) => {
  let { eventId, productId, quantity } = req.body;
  eventId = parseInt(eventId, 10);
  productId = parseInt(productId, 10);
  quantity = parseInt(quantity, 10);

  if (!eventId || !productId || !quantity || quantity <= 0) {
    return res.status(400).json({ error: 'Invalid eventId/productId/quantity' });
  }

  const userId = CURRENT_USER_ID;
  const conn = await pool.getConnection();

  try {
    await conn.beginTransaction();

    const [invRows] = await conn.query(
      `SELECT * FROM inventory WHERE EventID = ? AND ProductID = ? FOR UPDATE`,
      [eventId, productId]
    );
    if (invRows.length === 0) throw new Error('Inventory not found');

    const inv = invRows[0];
    const available = inv.AvailableQuantity - inv.ReservedQuantity;
    if (available < quantity) {
      throw new Error(`Not enough stock available. Only ${available} left.`);
    }

    const [priceRows] = await conn.query(
      `
      SELECT oi.UnitPrice
      FROM OrderItem oi
      JOIN \`order\` o ON o.OrderID = oi.OrderID
      WHERE oi.ProductID = ?
      ORDER BY o.OrderDate DESC
      LIMIT 1
      `,
      [productId]
    );
    const unitPrice = priceRows.length ? parseFloat(priceRows[0].UnitPrice) : 5.00;
    const total = unitPrice * quantity;

    const [orderResult] = await conn.query(
      `
      INSERT INTO \`order\`
        (UserID, EventID, OrderDate, PickupDate, TotalAmount, PaymentStatus, PickupStatus)
      VALUES
        (?, ?, NOW(), NULL, ?, 'Unpaid', 'Pending')
      `,
      [userId, eventId, total]
    );
    const orderId = orderResult.insertId;

    await conn.query(
      `INSERT INTO OrderItem (OrderID, ProductID, Quantity, UnitPrice)
       VALUES (?, ?, ?, ?)`,
      [orderId, productId, quantity, unitPrice]
    );

    await conn.query(
      `UPDATE inventory
       SET ReservedQuantity = ReservedQuantity + ?
       WHERE InventoryID = ?`,
      [quantity, inv.InventoryID]
    );

    await conn.commit();

    res.json({ success: true, orderId, total, unitPrice });
  } catch (err) {
    console.error('Error in pre-order transaction:', err);
    try { await conn.rollback(); } catch {}
    res.status(400).json({ success: false, error: err.message });
  } finally {
    conn.release();
  }
});

// ---------------------------
// Static files (front-end)
// ---------------------------
app.use(express.static(path.join(__dirname, 'public')));

// Root -> index.html
app.get('/', (req, res) => {
  res.sendFile(path.join(__dirname, 'public', 'index.html'));
});

// 404 fallback for unknown API routes
app.use('/api', (req, res) => {
  res.status(404).json({ error: 'API route not found' });
});

app.listen(PORT, () => {
  console.log(`Server listening on http://localhost:${PORT}`);
});
