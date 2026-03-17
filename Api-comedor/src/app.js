import express from "express";
import cors from "cors";
import userRoutes from "./routes/user.route.js";
import { pool } from "./config/db.js"; 
import path from "path"; // Asegúrate de importar esto arriba
const app = express();

app.use(express.json());

app.use(cors({
  origin: '*', 
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH'],
  allowedHeaders: ['Content-Type', 'Authorization'],
}));

app.use("/api", userRoutes);

app.get("/api/health", (req, res) => {
  return res.status(200).json({
    status: "success",
    message: "¡El servidor está funcionando correctamente! 🚀",
    timestamp: new Date().toISOString()
  });
});

app.get('/test', (req, res) => {
  // path.resolve() busca tu archivo 'index.html' en la carpeta raíz de tu proyecto
  // y crea la ruta absoluta que Express necesita.
  const htmlPath = path.resolve('index.html'); 
  
  // Enviamos el archivo al navegador
  res.sendFile(htmlPath);
});
export default app;