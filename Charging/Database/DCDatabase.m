//
//  DCDatabase.m
//  Charging
//
//  Created by xpg on 15/1/3.
//  Copyright (c) 2015年 xpg. All rights reserved.
//

#import "DCDatabase.h"
#import "DCApp.h"

NSString * const DatabaseVersion = @"DatabaseVersion";

@interface DCDatabase () {
    dispatch_queue_t _serialDispatchQueue;
}
//@property (strong, nonatomic) FMDatabase *fmdb;
@property (strong, nonatomic) FMDatabaseQueue *fmdbQueue;
@end

@implementation DCDatabase

+ (instancetype)db {
    static DCDatabase *db;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *path = [[DCApp appDelegate] applicationDocumentsDirectory].path;
        path = [path stringByAppendingPathComponent:@"dc.db"];
        DDLogDebug(@"[database] %@", path);
        db = [[self alloc] initWithPath:path];
    });
    return db;
}

- (instancetype)initWithPath:(NSString *)path {
    self = [super init];
    if (self) {
        _path = [path copy];
        self.fmdbQueue = [FMDatabaseQueue databaseQueueWithPath:path];
        _serialDispatchQueue = dispatch_queue_create("com.dc.database", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

#pragma mark - Queue
- (void)asyncExecute:(void(^)(FMDatabase *db, BOOL *rollback))block {
    dispatch_async(_serialDispatchQueue, ^{
        [self.fmdbQueue inTransaction:block];
    });
}

- (void)syncExecute:(void(^)(FMDatabase *db, BOOL *rollback))block {
    [self.fmdbQueue inTransaction:block];
}

- (void)executeQuery:(NSString *)sql withArgumentsInArray:(NSArray *)arguments resultBlock:(void(^)(FMResultSet *resultSet))resultBlock {
    [self.fmdbQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *rs = [db executeQuery:sql withArgumentsInArray:arguments];
        resultBlock(rs);
        [rs close];
    }];
}

#pragma mark - Setup
- (void)setupDatabase:(void(^)(NSInteger version))progress completion:(void(^)(BOOL success))completion {
    DDLogDebug(@"[database] setup");
    [self asyncExecute:^(FMDatabase *db, BOOL *rollback) {
        NSInteger currentVersion = [self databaseVersion:db];
        NSInteger targetVersion = [self bundleDatabaseVersion];
        DDLogDebug(@"[database] currentVersion %ld targetVersion %ld", (long)currentVersion, (long)targetVersion);
        BOOL success = YES;
        while (currentVersion < targetVersion) {
            switch (currentVersion) {
                case 0://创建数据库
                    success = ([self createUserTable:db]
                               && [self createStationTable:db]
                               && [self createPileTable:db]
                               && [self createChargePortTable:db]
//                               && [self createPoleTable:db]
//                               && [self createOwnershipTable:db]
//                               && [self createChargeTable:db]
//                               && [self createChargeRecordTable:db]
                               && [self createOrderTable:db]
                               && [self createFaultTable:db]
                               && [self createSharePeriodTable:db]
                               && [self createStationCollectionTable:db]);
                    break;
                    
                default:
                    DDLogError(@"no handle for version %ld", (long)currentVersion);
                    break;
            }
            
            if (success) {//继续升级
                currentVersion++;
                [self updateDatabase:db version:currentVersion];
                if (progress) {
                    progress(currentVersion);
                }
            } else {//失败
                DDLogDebug(@"database setup fail currentVersion %ld", (long)currentVersion);
                *rollback = YES;
                break;
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) {
                completion(success);
            }
        });
    }];
}

#pragma mark - Delete
- (BOOL)deleteDatabase {
    DDLogDebug(@"delete database");
    return [[NSFileManager defaultManager] removeItemAtPath:self.path error:nil];
}

#pragma mark - Version
- (BOOL)databaseIsAvailable {
    NSInteger __block currentVersion;
    [self.fmdbQueue inDatabase:^(FMDatabase *db) {
        currentVersion = [self databaseVersion:db];
    }];
    NSInteger targetVersion = [self bundleDatabaseVersion];
    if (currentVersion > targetVersion) {
        DDLogDebug(@"database version is greater than bundle expect version");
        [self deleteDatabase];
    }
    return (currentVersion == targetVersion);
}

- (NSInteger)bundleDatabaseVersion { //应用包使用的数据库版本
    return [[[NSBundle mainBundle] objectForInfoDictionaryKey:DatabaseVersion] integerValue];
}

- (NSInteger)databaseVersion:(FMDatabase *)db { //数据库记录的数据库版本
    NSInteger version = 0;
    FMResultSet *rs = [db executeQuery:@"SELECT * FROM database_version"];
    if ([rs next]) {
        version = [rs intForColumn:@"version"];
    }
    return version;
}

- (void)updateDatabase:(FMDatabase *)db version:(NSInteger)version {
    [db executeUpdate:@"CREATE TABLE IF NOT EXISTS database_version (version INTEGER)"];
    [db executeUpdate:@"DELETE FROM database_version"];
    [db executeUpdate:@"INSERT INTO database_version (version) VALUES (?)", @(version)];
    DDLogDebug(@"database upgrade to version %ld", (long)version);
//    if (version == 2) {
//        BOOL success = NO;
//        if (![db columnExists:@"price" inTableWithName:@"T_Order"])
//        {
//            success = [db executeUpdate:@"ALTER TABLE T_Order ADD COLUMN price DOUBLE"];
//            NSAssert(success, @"alter table failed: %@", [db lastErrorMessage]);
//        }
//    }
//    if (version == 3) {
//        BOOL success = NO;
//        if (![db columnExists:@"post_count" inTableWithName:@"T_Charge"])
//        {
//            success = [db executeUpdate:@"ALTER TABLE T_Charge ADD COLUMN post_count INTEGER DEFAULT 0"];
//            NSAssert(success, @"alter table failed: %@", [db lastErrorMessage]);
//        }
//    }
//    if (version == 4) {
//        BOOL success = NO;
//        if (![db columnExists:@"phone_no" inTableWithName:@"T_Charge"])
//        {
//            success = [db executeUpdate:@"ALTER TABLE T_Charge ADD COLUMN phone_no CHAR NULL  DEFAULT NULL"];
//            NSAssert(success, @"alter table failed: %@", [db lastErrorMessage]);
//        }
//        if (![db columnExists:@"user_nickName" inTableWithName:@"T_Charge"])
//        {
//            success = [db executeUpdate:@"ALTER TABLE T_Charge ADD COLUMN user_nickName CHAR NULL DEFAULT NULL"];
//            NSAssert(success, @"alter table failed: %@", [db lastErrorMessage]);
//        }
//        if (![db columnExists:@"charge_price" inTableWithName:@"T_Charge"])
//        {
//            success = [db executeUpdate:@"ALTER TABLE T_Charge ADD COLUMN charge_price DOUBLE NULL DEFAULT NULL"];
//            NSAssert(success, @"alter table failed: %@", [db lastErrorMessage]);
//        }
//        if (![db columnExists:@"creat_time" inTableWithName:@"T_Charge"])
//        {
//            success = [db executeUpdate:@"ALTER TABLE T_Charge ADD COLUMN creat_time TIMESTAMP NULL DEFAULT NULL"];
//            NSAssert(success, @"alter table failed: %@", [db lastErrorMessage]);
//        }
//    }
//    if (version == 5) {
//        BOOL success = NO;
//        if (![db columnExists:@"appointManageType" inTableWithName:@"T_Pole"]) {
//            success = [db executeUpdate:@"ALTER TABLE T_Pole ADD COLUMN appointManageType INT DEFAULT 0"];
//            NSAssert(success, @"alter table failed: %@", [db lastErrorMessage]);
//        }
//    }
}

#pragma mark - Table
//####### T_User
//CREATE TABLE IF NOT EXISTS `mydb`.`T_User` (
//                                            `user_id` INT NULL DEFAULT NULL,
//                                            `user_portrait` BINARY NULL,
//                                            `user_nickName` CHAR(16) NULL DEFAULT NULL,
//                                            `phone_no` CHAR NULL DEFAULT NULL,
//                                            `idcard_no` CHAR NULL DEFAULT NULL,
//                                            `real_name` CHAR NULL DEFAULT NULL,
//                                            `gender` INT NULL DEFAULT NULL,
//                                            PRIMARY KEY (`user_id`));
- (BOOL)createUserTable:(FMDatabase *)db {
    BOOL success = [db executeUpdate:@"CREATE TABLE IF NOT EXISTS T_User ("
                    "user_id INT NULL DEFAULT NULL,"
                    "user_portrait BINARY NULL,"
                    "user_nickName CHAR(16) NULL DEFAULT NULL,"
                    "user_thirdUuid CHAR(16) NULL DEFAULT NULL,"
                    "user_phone CHAR(16) NULL DEFAULT NULL,"
                    "user_gender INT NULL DEFAULT NULL,"
                    "user_createAt DOUBLE NULL DEFAULT NULL,"
                    "user_bindType INT NULL DEFAULT NULL,"
                    "user_pushId CHAR(16) NULL DEFAULT NULL,"
                    "user_pushTyep INT NULL DEFAULT NULL,"
                    "PRIMARY KEY (user_id));"];
    return success;
}

//####### T_Station
//CREATE TABLE IF NOT EXISTS `mydb`.`T_Station` (
//                                            `station_id` CHAR(16) NULL,
//                                            `station_stationName` CHAR(16) NULL DEFAULT NULL,
//                                            `station_stationType` INT NULL DEFAULT NULL,
//                                            `station_stationStatus` INT NULL DEFAULT NULL,
//                                            `address` VARCHAR(50) NULL DEFAULT NULL,
//                                            `longitude` DOUBLE NULL DEFAULT NULL,
//                                            `latitude` DOUBLE NULL DEFAULT NULL,
//                                            `station_directNum` INT NULL DEFAULT NULL,
//                                            `station_alterNum` INT NULL DEFAULT NULL,
//                                            `ownerId` CHAR(16) NULL,
//                                            `ownerName` VARCHAR(50) NULL,
//                                            `ownerPhone` VARCHAR(16) NULL,
//                                            `bookFee` DOUBLE NULL DEFAULT NULL,
//                                            `refundState` INT NULL DEFAULT NULL,
//                                            `allowBookNum` INT NULL DEFAULT NULL,
//                                            PRIMARY KEY (`station_id`));
- (BOOL)createStationTable:(FMDatabase *)db {
    BOOL success = [db executeUpdate:@"CREATE TABLE IF NOT EXISTS T_Station ("
                    "station_id CHAR(16) NULL,"
                    "station_stationName CHAR(16) NULL DEFAULT NULL,"
                    "station_stationType INT NULL DEFAULT NULL,"
                    "station_stationStatus INT NULL DEFAULT NULL,"
                    "address VARCHAR(50) NULL DEFAULT NULL,"
                    "longitude DOUBLE NULL DEFAULT NULL,"
                    "latitude DOUBLE NULL DEFAULT NULL,"
                    "station_directNum INT NULL DEFAULT NULL,"
                    "station_alterNum INT NULL DEFAULT NULL,"
                    "ownerId CHAR(16) NULL,"
                    "ownerName VARCHAR(50) NULL,"
                    "ownerPhone VARCHAR(16) NULL,"
                    "bookFee DOUBLE NULL DEFAULT NULL,"
                    "refundState INT NULL DEFAULT NULL,"
                    "allowBookNum INT NULL DEFAULT NULL,"
                    "PRIMARY KEY (station_id));"];
    return success;
}

//####### T_Pile
//CREATE TABLE IF NOT EXISTS `mydb`.`T_Pile` (
//                                            `pile_id` CHAR(16) NULL,
//                                            `pile_deviceId` CHAR(16) NULL DEFAULT NULL,
//                                            `pile_stationId` CHAR(16) NULL DEFAULT NULL,
//                                            `pile_pileName` VARCHAR(32) NULL DEFAULT NULL,
//                                            `pile_pileType` INT NULL DEFAULT NULL,
//                                            `ratePower` DOUBLE NULL DEFAULT NULL,
//                                            `rateVoltage` DOUBLE NULL DEFAULT NULL,
//                                            `rateCurrent` DOUBLE NULL DEFAULT NULL,
//                                            `chargerNum` INT NULL DEFAULT NULL,
//                                            PRIMARY KEY (`pile_id`));
- (BOOL)createPileTable:(FMDatabase *)db {
    BOOL success = [db executeUpdate:@"CREATE TABLE IF NOT EXISTS T_Pile ("
                    "pile_id CHAR(16) NULL,"
                    "pile_deviceId CHAR(16) NULL DEFAULT NULL,"
                    "pile_stationId CHAR(16) NULL DEFAULT NULL,"
                    "pile_pileName VARCHAR(32) NULL DEFAULT NULL,"
                    "pile_pileType INT NULL DEFAULT NULL,"
                    "ratePower DOUBLE NULL DEFAULT NULL,"
                    "rateVoltage DOUBLE NULL DEFAULT NULL,"
                    "rateCurrent DOUBLE NULL DEFAULT NULL,"
                    "chargerNum INT NULL DEFAULT NULL,"
                    "PRIMARY KEY (pile_id));"];
    return success;
}

//####### T_ChargePort
//CREATE TABLE IF NOT EXISTS `mydb`.`T_ChargePort` (
//                                            `index` CHAR(8) NULL,
//                                            `pileId` CHAR(16) NULL DEFAULT NULL,
//                                            `voltage` DOUBLE NULL DEFAULT NULL,
//                                            `current` DOUBLE NULL DEFAULT NULL,
//                                            `electricQuantity` DOUBLE NULL DEFAULT NULL,
//                                            `orderId` CHAR(16) NULL DEFAULT NULL,
//                                            `runStatus` INT NULL DEFAULT NULL,
//                                            `chargeStartType` INT NULL DEFAULT NULL,
//                                            `chargeMode` INT NULL DEFAULT NULL,
//                                            PRIMARY KEY (`index`));
- (BOOL)createChargePortTable:(FMDatabase *)db {
    BOOL success = [db executeUpdate:@"CREATE TABLE IF NOT EXISTS T_ChargePort ("
                    "cp_index CHAR(8) NULL,"
                    "pileId CHAR(16) NULL DEFAULT NULL,"
                    "voltage DOUBLE NULL DEFAULT NULL,"
                    "current DOUBLE NULL DEFAULT NULL,"
                    "electricQuantity DOUBLE NULL DEFAULT NULL,"
                    "orderId CHAR(16) NULL DEFAULT NULL,"
                    "runStatus INT NULL DEFAULT NULL,"
                    "chargeStartType INT NULL DEFAULT NULL,"
                    "chargeMode INT NULL DEFAULT NULL,"
                    "PRIMARY KEY (cp_index));"];
    return success;
}


//####### T_Pole
//CREATE TABLE IF NOT EXISTS `mydb`.`T_Pole` (
//                                            `pole_no` CHAR(8) NULL,
//                                            `nick_name` CHAR(16) NULL DEFAULT NULL,
//                                            `pole_type` INT NULL DEFAULT NULL,
//                                            `location` CHAR NULL DEFAULT NULL,
//                                            `longitude` DOUBLE NULL DEFAULT NULL,
//                                            `latitude` DOUBLE NULL DEFAULT NULL,
//                                            `altitude` DOUBLE NULL DEFAULT NULL,
//                                            `rated_cur` FLOAT NULL DEFAULT NULL,
//                                            `rated_volt` FLOAT NULL DEFAULT NULL,
//                                            `price` FLOAT NULL,
//                                            `contact_name` VARCHAR(45) NULL,
//                                            `contact_phone_no` VARCHAR(45) NULL,
//                                            PRIMARY KEY (`pole_no`));
- (BOOL)createPoleTable:(FMDatabase *)db {
    BOOL success = [db executeUpdate:@"CREATE TABLE IF NOT EXISTS T_Pole ("
                    "pole_no CHAR(8) NULL,"
                    "nick_name CHAR(16) NULL DEFAULT NULL,"
                    "pole_type INT NULL DEFAULT NULL,"
                    "location CHAR NULL DEFAULT NULL,"
                    "longitude DOUBLE NULL DEFAULT NULL,"
                    "latitude DOUBLE NULL DEFAULT NULL,"
                    "altitude DOUBLE NULL DEFAULT NULL,"
                    "rated_cur FLOAT NULL DEFAULT NULL,"
                    "rated_volt FLOAT NULL DEFAULT NULL,"
                    "price FLOAT NULL,"
                    "contact_name VARCHAR(45) NULL,"
                    "contact_phone_no VARCHAR(45) NULL,"
                    "appointManageType INT NULL DEFAULT NULL,"
                    "PRIMARY KEY (pole_no));"];
    return success;
}



//####### T_Ownership
//CREATE TABLE IF NOT EXISTS `mydb`.`T_Ownership` (
//                                                 `user_id` INT NULL DEFAULT NULL,
//                                                 `user_role` INT NULL DEFAULT NULL,
//                                                 `pole_no` CHAR(8) NULL DEFAULT NULL,
//                                                 `add_time` TIMESTAMP NULL DEFAULT NULL,
//                                                 `key` CHAR(200) NULL DEFAULT NULL,
//                                                 `key_type` INT NULL DEFAULT NULL,
//                                                 `valid_time_start` DATETIME NULL,
//                                                 `valid_time_end` DATETIME NULL,
//                                                 `order_id` INT NULL,
//- (BOOL)createOwnershipTable:(FMDatabase *)db {
//    BOOL success = [db executeUpdate:@"CREATE TABLE IF NOT EXISTS T_Ownership ("
//                    "user_id INT NULL DEFAULT NULL,"
//                    "user_role INT NULL DEFAULT NULL,"
//                    "pole_no CHAR(8) NULL DEFAULT NULL,"
//                    "add_time TIMESTAMP NULL DEFAULT NULL,"
//                    "key CHAR(200) NULL DEFAULT NULL,"
//                    "key_type INT NULL DEFAULT NULL,"
//                    "valid_time_start DATETIME NULL,"
//                    "valid_time_end DATETIME NULL,"
//                    "order_id INT NULL);"];
//    return success;
//}



//####### T_Charge
//CREATE TABLE IF NOT EXISTS `mydb`.`T_Charge` (
//                                              `sn` INT NULL DEFAULT NULL,
//                                              `order_id` INT NULL DEFAULT NULL,
//                                              `user_id` INT NULL DEFAULT NULL,
//                                              `pole_no` CHAR(8) NULL DEFAULT NULL,
//                                              `start_time` TIMESTAMP NULL DEFAULT NULL,
//                                              `end_time` TIMESTAMP NULL DEFAULT NULL,
//                                              `quantity` INT NULL DEFAULT NULL,
//                                              `data` CHAR NULL DEFAULT NULL,
//                                              `response_data` CHAR NULL DEFAULT NULL,
//- (BOOL)createChargeTable:(FMDatabase *)db {
//    BOOL success = [db executeUpdate:@"CREATE TABLE IF NOT EXISTS T_Charge ("
//                    "sn INT NULL DEFAULT NULL,"
//                    "order_id INT NULL DEFAULT NULL,"
//                    "user_id INT NULL DEFAULT NULL,"
//                    "pole_no CHAR(8) NULL DEFAULT NULL,"
//                    "start_time TIMESTAMP NULL DEFAULT NULL,"
//                    "end_time TIMESTAMP NULL DEFAULT NULL,"
//                    "quantity INT NULL DEFAULT NULL,"
//                    "data CHAR NULL DEFAULT NULL,"
//                    "response_data CHAR NULL DEFAULT NULL,"
//                    "phone_no CHAR NULL DEFAULT NULL,"
//                    "user_nickName CHAR NULL DEFAULT NULL,"
//                    "charge_price DOUBLE NULL DEFAULT NULL,"
//                    "creat_time  TIMESTAMP NULL DEFAULT NULL);"];
//    return success;
//}
//
//- (BOOL)createChargeRecordTable:(FMDatabase *)db {
//    BOOL success = [db executeUpdate:@"CREATE TABLE IF NOT EXISTS T_ChargeRecord ("
//                    "sn INT NULL DEFAULT NULL,"
//                    "order_id INT NULL DEFAULT NULL,"
//                    "user_id INT NULL DEFAULT NULL,"
//                    "pole_no CHAR(8) NULL DEFAULT NULL,"
//                    "start_time TIMESTAMP NULL DEFAULT NULL,"
//                    "end_time TIMESTAMP NULL DEFAULT NULL,"
//                    "quantity INT NULL DEFAULT NULL,"
//                    "data CHAR NULL DEFAULT NULL,"
//                    "response_data CHAR NULL DEFAULT NULL,"
//                    "phone_no CHAR(13) NULL  DEFAULT NULL,"
//                    "user_nickName CHAR(16) NULL DEFAULT NULL,"
//                    "charge_price DOUBLE NULL DEFAULT NULL,"
//                    "creat_time  TIMESTAMP NULL DEFAULT NULL);"];
//    return success;
//}

//####### T_Order
//CREATE TABLE IF NOT EXISTS `mydb`.`T_Order` (
//                                             `orderId` CHAR(16) NULL DEFAULT NULL,
//                                             `pileId` CHAR(16) NULL DEFAULT NULL,
//                                             `ownerId` CHAR(16) NULL DEFAULT NULL,
//                                             `tenantId` CHAR(16) NULL DEFAULT NULL,
//                                             `stationId` CHAR(16) NULL DEFAULT NULL,
//                                             `schedule_start_t` TIMESTAMP NULL DEFAULT NULL,
//                                             `schedule_end_t` TIMESTAMP NULL DEFAULT NULL,
//                                             `orderState` INT NULL,
//                                             `serviceFee` DOUBLE NULL,
//                                             PRIMARY KEY (`orderId`),
- (BOOL)createOrderTable:(FMDatabase *)db {
    BOOL success = [db executeUpdate:@"CREATE TABLE IF NOT EXISTS T_Order ("
                    "orderId CHAR(16) NULL DEFAULT NULL,"
                    "pileId CHAR(16) NULL DEFAULT NULL,"
                    "ownerId CHAR(16) NULL DEFAULT NULL,"
                    "tenantId CHAR(16) NULL DEFAULT NULL,"
                    "stationId CHAR(16) NULL DEFAULT NULL,"
                    "schedule_start_t TIMESTAMP NULL DEFAULT NULL,"
                    "schedule_end_t TIMESTAMP NULL DEFAULT NULL,"
                    "create_time TIMESTAMP NULL DEFAULT NULL,"
                    "orderState INT NULL,"
                    "serviceFee DOUBLE NULL,"
                    "PRIMARY KEY (orderId));"];
    return success;
}



//####### T_Fault
//CREATE TABLE IF NOT EXISTS `mydb`.`T_Fault` (
//                                             `fault_no` INT NULL DEFAULT NULL,
//                                             `pole_no` CHAR(8) NULL DEFAULT NULL,
//                                             `record_time` TIMESTAMP NULL DEFAULT NULL,
//                                             `fault_type` INT NULL DEFAULT NULL,
//                                             `data` CHAR NULL DEFAULT NULL,
//                                             `response_data` CHAR NULL,
- (BOOL)createFaultTable:(FMDatabase *)db {
    BOOL success = [db executeUpdate:@"CREATE TABLE IF NOT EXISTS T_Fault ("
                    "fault_no INT NULL DEFAULT NULL,"
                    "pole_no CHAR(8) NULL DEFAULT NULL,"
                    "record_time TIMESTAMP NULL DEFAULT NULL,"
                    "fault_type INT NULL DEFAULT NULL,"
                    "data CHAR NULL DEFAULT NULL,"
                    "response_data CHAR NULL);"];
    return success;
}



//####### T_Share_Period
//CREATE TABLE IF NOT EXISTS `mydb`.`T_Share_Period` (
//                                                    `pole_no` CHAR(8) NULL,
//                                                    `start_time` TIME NULL,
//                                                    `end_time` TIME NULL,
//                                                    `week` VARCHAR(45) NULL,
- (BOOL)createSharePeriodTable:(FMDatabase *)db {
    BOOL success = [db executeUpdate:@"CREATE TABLE IF NOT EXISTS T_Share_Period ("
                    "pole_no CHAR(8) NULL,"
                    "start_time TIME NULL,"
                    "end_time TIME NULL,"
                    "week VARCHAR(45) NULL);"];
    return success;
}



//####### T_Pole_Collection
//CREATE TABLE IF NOT EXISTS `mydb`.`T_Pole_Collection` (
//                                                       `user_id` INT NULL,
//                                                       `pole_no` CHAR(8) NULL,
//                                                       `collection_state` INT NULL,
- (BOOL)createStationCollectionTable:(FMDatabase *)db {
    BOOL success = [db executeUpdate:@"CREATE TABLE IF NOT EXISTS T_Station_Collection ("
                    "user_id INT NULL,"
                    "station_id CHAR(8) NULL,"
                    "collection_state INT NULL);"];
    return success;
}

@end


//-- -----------------------------------------------------
//-- Table `mydb`.`T_Pole`
//-- -----------------------------------------------------
//CREATE TABLE IF NOT EXISTS `mydb`.`T_Pole` (
//                                            `pole_no` CHAR(8) NULL,
//                                            `nick_name` CHAR(16) NULL DEFAULT NULL,
//                                            `pole_type` INT NULL DEFAULT NULL,
//                                            `location` CHAR NULL DEFAULT NULL,
//                                            `longitude` DOUBLE NULL DEFAULT NULL,
//                                            `latitude` DOUBLE NULL DEFAULT NULL,
//                                            `altitude` DOUBLE NULL DEFAULT NULL,
//                                            `rated_cur` FLOAT NULL DEFAULT NULL,
//                                            `rated_volt` FLOAT NULL DEFAULT NULL,
//                                            `price` FLOAT NULL,
//                                            `contact_name` VARCHAR(45) NULL,
//                                            `contact_phone_no` VARCHAR(45) NULL,
//                                            PRIMARY KEY (`pole_no`));
//
//
//-- -----------------------------------------------------
//-- Table `mydb`.`T_Fault`
//-- -----------------------------------------------------
//CREATE TABLE IF NOT EXISTS `mydb`.`T_Fault` (
//                                             `fault_no` INT NULL DEFAULT NULL,
//                                             `pole_no` CHAR(8) NULL DEFAULT NULL,
//                                             `record_time` TIMESTAMP NULL DEFAULT NULL,
//                                             `fault_type` INT NULL DEFAULT NULL,
//                                             `data` CHAR NULL DEFAULT NULL,
//                                             `response_data` CHAR NULL,
//                                             INDEX `pole_no_idx` (`pole_no` ASC),
//                                             CONSTRAINT `pole_no`
//                                             FOREIGN KEY (`pole_no`)
//                                             REFERENCES `mydb`.`T_Pole` (`pole_no`)
//                                             ON DELETE NO ACTION
//                                             ON UPDATE NO ACTION);
//
//
//-- -----------------------------------------------------
//-- Table `mydb`.`T_User`
//-- -----------------------------------------------------
//CREATE TABLE IF NOT EXISTS `mydb`.`T_User` (
//                                            `user_id` INT NULL DEFAULT NULL,
//                                            `user_portrait` BINARY NULL,
//                                            `user_nickName` CHAR(16) NULL DEFAULT NULL,
//                                            `phone_no` CHAR NULL DEFAULT NULL,
//                                            `idcard_no` CHAR NULL DEFAULT NULL,
//                                            `real_name` CHAR NULL DEFAULT NULL,
//                                            `gender` INT NULL DEFAULT NULL,
//                                            PRIMARY KEY (`user_id`));
//
//
//-- -----------------------------------------------------
//-- Table `mydb`.`T_Order`
//-- -----------------------------------------------------
//CREATE TABLE IF NOT EXISTS `mydb`.`T_Order` (
//                                             `order_id` INT NULL DEFAULT NULL,
//                                             `user_id` INT NULL DEFAULT NULL,
//                                             `pole_no` CHAR(8) NULL DEFAULT NULL,
//                                             `schedule_start_t` TIMESTAMP NULL DEFAULT NULL,
//                                             `schedule_end_t` TIMESTAMP NULL DEFAULT NULL,
//                                             `status` INT NULL,
//                                             `confirm_time` TIMESTAMP NULL,
//                                             PRIMARY KEY (`order_id`),
//                                             INDEX `user_id_idxfk_1` (`user_id` ASC),
//                                             INDEX `pole_no_fk_idx` (`pole_no` ASC),
//                                             CONSTRAINT `user_id_idxfk_1`
//                                             FOREIGN KEY (`user_id`)
//                                             REFERENCES `mydb`.`T_User` (`user_id`),
//                                             CONSTRAINT `pole_no_fk`
//                                             FOREIGN KEY (`pole_no`)
//                                             REFERENCES `mydb`.`T_Pole` (`pole_no`)
//                                             ON DELETE NO ACTION
//                                             ON UPDATE NO ACTION);
//
//
//-- -----------------------------------------------------
//-- Table `mydb`.`T_Charge`
//-- -----------------------------------------------------
//CREATE TABLE IF NOT EXISTS `mydb`.`T_Charge` (
//                                              `sn` INT NULL DEFAULT NULL,
//                                              `order_id` INT NULL DEFAULT NULL,
//                                              `user_id` INT NULL DEFAULT NULL,
//                                              `pole_no` CHAR(8) NULL DEFAULT NULL,
//                                              `start_time` TIMESTAMP NULL DEFAULT NULL,
//                                              `end_time` TIMESTAMP NULL DEFAULT NULL,
//                                              `quantity` INT NULL DEFAULT NULL,
//                                              `data` CHAR NULL DEFAULT NULL,
//                                              `response_data` CHAR NULL DEFAULT NULL,
//                                              INDEX `order_id_idxfk` (`order_id` ASC),
//                                              INDEX `user_id_idxfk` (`user_id` ASC),
//                                              INDEX `pole_no_idx` (`pole_no` ASC),
//                                              CONSTRAINT `order_id_idxfk`
//                                              FOREIGN KEY (`order_id`)
//                                              REFERENCES `mydb`.`T_Order` (`order_id`),
//                                              CONSTRAINT `user_id_idxfk`
//                                              FOREIGN KEY (`user_id`)
//                                              REFERENCES `mydb`.`T_User` (`user_id`),
//                                              CONSTRAINT `pole_no`
//                                              FOREIGN KEY (`pole_no`)
//                                              REFERENCES `mydb`.`T_Pole` (`pole_no`)
//                                              ON DELETE NO ACTION
//                                              ON UPDATE NO ACTION);
//
//
//-- -----------------------------------------------------
//-- Table `mydb`.`T_Ownership`
//-- -----------------------------------------------------
//CREATE TABLE IF NOT EXISTS `mydb`.`T_Ownership` (
//                                                 `user_id` INT NULL DEFAULT NULL,
//                                                 `user_role` INT NULL DEFAULT NULL,
//                                                 `pole_no` CHAR(8) NULL DEFAULT NULL,
//                                                 `add_time` TIMESTAMP NULL DEFAULT NULL,
//                                                 `key` CHAR(200) NULL DEFAULT NULL,
//                                                 `key_type` INT NULL DEFAULT NULL,
//                                                 `valid_time_start` DATETIME NULL,
//                                                 `valid_time_end` DATETIME NULL,
//                                                 `order_id` INT NULL,
//                                                 INDEX `user_id_idxfk_2` (`user_id` ASC),
//                                                 INDEX `pole_no_idx` (`pole_no` ASC),
//                                                 INDEX `order_id_idx` (`order_id` ASC),
//                                                 CONSTRAINT `user_id_idxfk_2`
//                                                 FOREIGN KEY (`user_id`)
//                                                 REFERENCES `mydb`.`T_User` (`user_id`),
//                                                 CONSTRAINT `pole_no`
//                                                 FOREIGN KEY (`pole_no`)
//                                                 REFERENCES `mydb`.`T_Pole` (`pole_no`)
//                                                 ON DELETE NO ACTION
//                                                 ON UPDATE NO ACTION,
//                                                 CONSTRAINT `order_id`
//                                                 FOREIGN KEY (`order_id`)
//                                                 REFERENCES `mydb`.`T_Order` (`order_id`)
//                                                 ON DELETE NO ACTION
//                                                 ON UPDATE NO ACTION);
//
//
//-- -----------------------------------------------------
//-- Table `mydb`.`T_Share_Period`
//-- -----------------------------------------------------
//CREATE TABLE IF NOT EXISTS `mydb`.`T_Share_Period` (
//                                                    `pole_no` CHAR(8) NULL,
//                                                    `start_time` TIME NULL,
//                                                    `end_time` TIME NULL,
//                                                    `week` VARCHAR(45) NULL,
//                                                    INDEX `pole_no_idx` (`pole_no` ASC),
//                                                    CONSTRAINT `pole_no`
//                                                    FOREIGN KEY (`pole_no`)
//                                                    REFERENCES `mydb`.`T_Pole` (`pole_no`)
//                                                    ON DELETE NO ACTION
//                                                    ON UPDATE NO ACTION)
//ENGINE = InnoDB;
//
//
//-- -----------------------------------------------------
//-- Table `mydb`.`T_Pole_Collection`
//-- -----------------------------------------------------
//CREATE TABLE IF NOT EXISTS `mydb`.`T_Pole_Collection` (
//                                                       `user_id` INT NULL,
//                                                       `pole_no` CHAR(8) NULL,
//                                                       `collection_state` INT NULL,
//                                                       INDEX `user_id_idx` (`user_id` ASC),
//                                                       INDEX `pole_no_idx` (`pole_no` ASC),
//                                                       CONSTRAINT `user_id`
//                                                       FOREIGN KEY (`user_id`)
//                                                       REFERENCES `mydb`.`T_User` (`user_id`)
//                                                       ON DELETE NO ACTION
//                                                       ON UPDATE NO ACTION,
//                                                       CONSTRAINT `pole_no`
//                                                       FOREIGN KEY (`pole_no`)
//                                                       REFERENCES `mydb`.`T_Pole` (`pole_no`)
//                                                       ON DELETE NO ACTION
//                                                       ON UPDATE NO ACTION)
//ENGINE = InnoDB;
