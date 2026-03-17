import { requestTurn, callTurn, attendTurn, completeTurn } from '../queues/turnQueue.js';
import { User } from '../models/user.js';
export const userController = {
  

    createUser: async (req,res) => {
    const { cedula,email,password, role_id, is_active } = req.body;
    const result = await User.create({cedula,email,password, role_id, is_active})
    if (!result.success) return res.status(429).json(result);
    res.status(201).json(result);
    },
  createOrder: async (req, res) => {
    const { userId } = req.body;
    const result = await requestTurn(userId);
    if (!result.success) return res.status(429).json(result);
    res.status(201).json(result);
  },

  callOrder: async (req, res) => {
    const { orderId } = req.params; 
    const result = await callTurn(orderId);
    res.json(result);
  },

  attendOrder: async (req, res) => {
    const { orderId } = req.params;
    const result = await attendTurn(orderId);
    res.json(result);
  },

  finishOrder: async (req, res) => {
    const { orderId } = req.params;
    const result = await completeTurn(orderId);
    res.json(result);
  }

};