import { Global, Module } from '@nestjs/common';
import { ModelsController } from './models.controller';
import { ModelsService } from './models.service';
import { TypeOrmModule } from '@nestjs/typeorm';
import { ModelsEntity } from './models.entity';
import { ConfigEntity } from '../globalConfig/config.entity';
// import { ModelsTypeEntity } from './modelType.entity';

@Global()
@Module({
  imports: [TypeOrmModule.forFeature([ModelsEntity, ConfigEntity])],
  controllers: [ModelsController],
  providers: [ModelsService],
  exports: [ModelsService],
})
export class ModelsModule {}
