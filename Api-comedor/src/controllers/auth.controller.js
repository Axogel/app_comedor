import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import { pool } from '../config/db.js';
import { User } from '../models/user.js';

export const register = async (req, res) => {
    console.log(req.body);
    const { cedula,email,password, role_id, is_active } = req.body;
    const hashedPassword = await bcrypt.hash(password, 10);

    const result = await User.create({cedula,email,password: hashedPassword, role_id, is_active})
    if (!result.success) return res.status(429).json(result);
    res.status(201).json(result);
};

export const login = async (req, res) => {
    const { email, password } = req.body;
    // Cambias "username = ?" por "email = ?"
    const [rows] = await pool.query('SELECT * FROM users WHERE email = ?', [email]);    const user = rows[0];

    if (user && await bcrypt.compare(password, user.password)) {
        const token = jwt.sign(
            { id: user.id, role: user.role },
            process.env.JWT_SECRET,
            { expiresIn: '1d' }
        );
        res.json({ token });
    } else {
        res.status(401).json({ message: "Invalid credentials" });
    }
};