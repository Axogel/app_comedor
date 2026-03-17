import IORedis from 'ioredis';
import dotenv from 'dotenv';

dotenv.config();

const redisConfig = {
  host: process.env.REDIS_HOST || 'localhost',
  port: process.env.REDIS_PORT || 6379,
  maxRetriesPerRequest: null
};

export const redisConnection = new IORedis(redisConfig);

console.log(`🔌 Intentando conectar a Redis en: ${redisConfig.host}:${redisConfig.port}`);

redisConnection.on('connect', () => console.log('✅ Conectado a Redis exitosamente'));
redisConnection.on('error', (err) => console.error('❌ Error de Redis:', err));