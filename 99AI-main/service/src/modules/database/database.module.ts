import { Logger, Module, OnModuleInit } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { DataSource, DataSourceOptions } from 'typeorm';
import { DatabaseService } from './database.service';

// Import all entities explicitly
import { AppEntity } from '../app/app.entity';
import { AppCatsEntity } from '../app/appCats.entity';
import { UserAppsEntity } from '../app/userApps.entity';
import { AutoReplyEntity } from '../autoReply/autoReply.entity';
import { BadWordsEntity } from '../badWords/badWords.entity';
import { ViolationLogEntity } from '../badWords/violationLog.entity';
import { ChatGroupEntity } from '../chatGroup/chatGroup.entity';
import { ChatLogEntity } from '../chatLog/chatLog.entity';
import { CramiEntity } from '../crami/crami.entity';
import { CramiPackageEntity } from '../crami/cramiPackage.entity';
import { ConfigEntity } from '../globalConfig/config.entity';
import { ModelsEntity } from '../models/models.entity';
import { OrderEntity } from '../order/order.entity';
import { PluginEntity } from '../plugin/plugin.entity';
import { Share } from '../share/share.entity';
import { SigninEntity } from '../signin/signIn.entity';
import { UserEntity } from '../user/user.entity';
import { AccountLogEntity } from '../userBalance/accountLog.entity';
import { BalanceEntity } from '../userBalance/balance.entity';
import { FingerprintLogEntity } from '../userBalance/fingerprint.entity';
import { UserBalanceEntity } from '../userBalance/userBalance.entity';
import { VerificationEntity } from '../verification/verification.entity';

@Module({
  imports: [
    TypeOrmModule.forRootAsync({
      useFactory: () =>
      ({
        type: 'mysql',
        host: process.env.DB_HOST || process.env.DB_HOSTNAME || 'localhost',
        port: parseInt(process.env.DB_PORT || '3306', 10),
        username: process.env.DB_USER || process.env.DB_USERNAME || 'root',
        password: process.env.DB_PASS || process.env.DB_PASSWORD || '',
        database: process.env.DB_DATABASE || 'chatgpt',
        // entities: [__dirname + '/../**/*.entity{.ts,.js}'], // <-- Remove glob pattern
        entities: [
          // <-- Use explicit array of imported classes
          Share,
          AutoReplyEntity,
          CramiEntity,
          CramiPackageEntity,
          BadWordsEntity,
          ChatGroupEntity,
          VerificationEntity,
          SigninEntity,
          ViolationLogEntity,
          ModelsEntity,
          UserEntity,
          AccountLogEntity,
          FingerprintLogEntity,
          BalanceEntity,
          UserBalanceEntity,
          PluginEntity,
          ConfigEntity,
          ChatLogEntity,
          UserAppsEntity,
          AppCatsEntity,
          AppEntity,
          OrderEntity,
        ],
        synchronize: false,
        logging: false,
        charset: 'utf8mb4',
        timezone: '+08:00',
        connectTimeout: 10000,
        acquireTimeout: 10000,
        extra: {
          connectionLimit: 10,
          reconnect: true,
        },
      } as DataSourceOptions),
    }),
  ],
  providers: [DatabaseService],
})
export class DatabaseModule implements OnModuleInit {
  constructor(private readonly connection: DataSource) { }
  private readonly logger = new Logger(DatabaseModule.name);

  async onModuleInit(): Promise<void> {
    const { database } = this.connection.options;
    this.logger.log(`Your MySQL database named ${database} has been connected`);
  }
}
