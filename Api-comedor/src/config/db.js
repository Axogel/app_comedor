import mysql from "mysql2/promise";
import dotenv from "dotenv";

dotenv.config();

export const pool = mysql.createPool({
  host: process.env.DB_HOST || process.env.MYSQLDB_HOST ,
  user: process.env.DB_USER || process.env.MYSQLDB_USER ,
  password: process.env.DB_PASSWORD || process.env.MYSQLDB_PASSWORD || "",
  database: process.env.DB_NAME || process.env.MYSQLDB_DATABASE || "comedor_db",
  waitForConnections: true,
  connectionLimit: 10, 
  port: process.env.DB_PORT || process.env.MYSQLDB_LOCAL_PORT || 3306,
});
console.log('try')

export const initDB = async () => {
  try {

    const rolesTable = `
      CREATE TABLE IF NOT EXISTS roles (
        id INT AUTO_INCREMENT PRIMARY KEY,
        name VARCHAR(50) NOT NULL UNIQUE -- admin, teacher, employee, student
      );
    `;

    const usersTable = `
      CREATE TABLE IF NOT EXISTS users (
        id INT AUTO_INCREMENT PRIMARY KEY,
        cedula VARCHAR(20) NOT NULL UNIQUE,
        email VARCHAR(255) NOT NULL UNIQUE,
        password VARCHAR(255) NOT NULL,
        role_id INT NOT NULL,
        is_active BOOLEAN DEFAULT TRUE,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (role_id) REFERENCES roles(id)
      );
    `;

    const ordersTable = `
      CREATE TABLE IF NOT EXISTS orders (
        id INT AUTO_INCREMENT PRIMARY KEY,
        user_id INT NOT NULL,
        turn_number INT NOT NULL, 
        status ENUM('pending', 'called', 'attended', 'expired', 'completed') DEFAULT 'pending',
        assigned_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- Cuando pidió el turno
        expires_at TIMESTAMP NULL, -- assigned_at + 15 min (calculado por la app)
        completed_at TIMESTAMP NULL, -- Cuando recibió la comida
        FOREIGN KEY (user_id) REFERENCES users(id)
      );
    `;

    const orderExtraTable = `
      CREATE TABLE IF NOT EXISTS order_extra (
        id INT AUTO_INCREMENT PRIMARY KEY,
        order_id INT NOT NULL UNIQUE,
        observation TEXT,
        is_reserved BOOLEAN DEFAULT FALSE,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE
      );
    `;

    const orderLogsTable = `
      CREATE TABLE IF NOT EXISTS order_logs (
        id INT AUTO_INCREMENT PRIMARY KEY,
        order_id INT NOT NULL,
        action VARCHAR(100), -- Ej: "Turno Asignado", "Expirado por Tiempo", "Usuario llegó tarde"
        details TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE
      );
    `;

    /* ===Migraciones */
    console.log("Migraciones ");
    await pool.query(rolesTable);
    await pool.query(usersTable);
    await pool.query(ordersTable);
    await pool.query(orderExtraTable);
    await pool.query(orderLogsTable);


    /* ======Seed======= */
    
    const [existingRoles] = await pool.query("SELECT id FROM roles LIMIT 1");
    if (existingRoles.length === 0) {
      console.log("🌱 Insertando Roles base...");
      await pool.query(`
        INSERT INTO roles (name) VALUES 
        ('admin'), 
        ('teacher'), 
        ('employee'), 
        ('student');
      `);
    }

    const [existingUsers] = await pool.query("SELECT id FROM users LIMIT 1");
    if (existingUsers.length === 0) {
      console.log("Insertando Usuario Admin...");
      await pool.query(`
        INSERT INTO users (cedula, email, password, role_id) 
        VALUES ('V12345678', 'admin@comedor.com', 'admin123', 1);
      `);
    }

    console.log("✅ Base de datos arriba");

  } catch (error) {
    console.error(" Error inicializando la base de datos:", error);
  }
};