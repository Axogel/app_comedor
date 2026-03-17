import cluster from 'node:cluster';
import os from 'node:os';
import http from 'node:http';
import app from "./app.js";
import { initDB } from "./config/db.js";
import { initSocket } from "./config/socket.js";
const PORT = process.env.NODE_LOCAL_PORT || 3000;
const numCPUs = os.cpus().length; // Detecta núcleos del procesador

if (cluster.isPrimary) {
  console.log(`🤖 Maestro (Master) PID: ${process.pid} iniciado`);
  
  console.log("🔄 Inicializando Base de Datos...");
  await initDB();

  console.log(`🔥 Levantando ${numCPUs} trabajadores (workers)...`);

  for (let i = 0; i < numCPUs; i++) {
    cluster.fork();
  }

  cluster.on('exit', (worker, code, signal) => {
    console.log(`💀 Trabajador ${worker.process.pid} murió. Creando reemplazo...`);
    cluster.fork();
  });

} else {

  
  const server = http.createServer(app);
  initSocket(server);
  server.listen(PORT, () => {
    console.log(`🚀 Worker ${process.pid} listo en puerto ${PORT}`);
  });
}