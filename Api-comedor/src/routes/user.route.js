import express from 'express';
import { register, login } from '../controllers/auth.controller.js';

// IMPORTANTE: Usar llaves { } porque es un "named export"
import { userController } from '../controllers/userController.js'; 

const router = express.Router();

// Auth
router.post('/register', register);
router.post('/login', login);

// Orders / Users
// Ahora accedemos a las funciones con punto (.)
router.post('/order', userController.createOrder); // Crear turno

// Rutas de administración de turnos (Ejemplos)
router.patch('/order/:orderId/call', userController.callOrder);     // Llamar turno
router.patch('/order/:orderId/attend', userController.attendOrder); // Atender
router.patch('/order/:orderId/finish', userController.finishOrder); // Finalizar

export default router;