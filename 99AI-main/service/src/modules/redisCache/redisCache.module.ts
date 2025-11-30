import { Global, Logger, Module } from '@nestjs/common';
import { createClient } from 'redis';
import { RedisCacheService } from './redisCache.service';

@Global()
@Module({
  imports: [],
  providers: [
    {
      provide: 'REDIS_CLIENT',
      useFactory: async () => {
        const host = process.env.REDIS_HOST;
        const port = parseInt(process.env.REDIS_PORT, 10);
        const password = process.env.REDIS_PASSWORD;
        const username = process.env.REDIS_USER;
        const database = parseInt(process.env.REDIS_DB, 10) || 0;

        if (!host || !port) {
          Logger.error(
            `Please configure Redis config | 未配置 Redis 配置信息，请确认配置 Redis 服务以获得更好的体验`,
            'RedisCacheModule',
          );
          return;
        }

        const client = createClient({
          socket: {
            host: host || 'localhost',
            port: port || 6379,
            reconnectStrategy: (retries) => {
              if (retries > 10) {
                Logger.error('Redis 重连次数超过限制，停止重连', 'RedisCacheModule');
                return new Error('Redis 重连失败');
              }
              const delay = Math.min(retries * 50, 2000);
              Logger.warn(`Redis 重连，第 ${retries} 次，延迟 ${delay}ms`, 'RedisCacheModule');
              return delay;
            },
          },
          username: username || undefined,
          password: password || undefined,
          database: database || 0,
        });

        client.on('ready', () => {
          Logger.log(`Redis connection successful`, 'RedisCacheModule');
        });

        client.on('error', err => {
          Logger.error(`Redis connection failed: ${err.message}`, 'RedisCacheModule');
        });

        client.on('connect', () => {
          Logger.log('Redis connecting...', 'RedisCacheModule');
        });

        client.on('reconnecting', () => {
          Logger.warn('Redis reconnecting...', 'RedisCacheModule');
        });

        try {
          await client.connect();
          return client;
        } catch (error) {
          Logger.error(`Redis 连接失败: ${error.message}`, 'RedisCacheModule');
          // 返回 null 而不是抛出错误，让应用可以继续运行
          return null;
        }
      },
    },
    RedisCacheService,
  ],
  exports: ['REDIS_CLIENT', RedisCacheService],
})
export class RedisCacheModule { }
