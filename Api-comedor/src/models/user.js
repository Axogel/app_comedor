import { pool } from '../config/db.js';

export const User = {
    create: async ({ cedula, email, password, role_id, is_active }) => {
        console.log({ cedula, email, password, role_id, is_active }, 'pruebas')
        const [result] = await pool.query(
            'INSERT INTO users (cedula, email, password, role_id, is_active) VALUES (?, ?, ?, ?, ?)',
            [cedula, email, password, role_id, is_active]
        );
        return result.insertId;
    },

    findAll: async () => {
        const [rows] = await pool.query('SELECT id, cedula, email, role_id, is_active FROM users');
        return rows;
    },

    findById: async (id) => {
        const [rows] = await pool.query('SELECT * FROM users WHERE id = ?', [id]);
        return rows[0];
    },

    findByEmail: async (email) => {
        const [rows] = await pool.query('SELECT * FROM users WHERE email = ?', [email]);
        return rows[0];
    }
};