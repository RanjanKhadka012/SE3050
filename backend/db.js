// db.js
const mysql = require('mysql2/promise');

const pool = mysql.createPool({
  host: 'localhost',
  port: 3306,        // change to match port on MySQL
  user: 'root',         // change if needed
  password: 'kraska5117',         // change to match your password for MySQL
  database: 'se3050',   // change to match your DB name
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0
});

module.exports = pool;

