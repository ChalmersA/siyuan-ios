//
//  DatabaseTests.m
//  Charging
//
//  Created by xpg on 15/1/5.
//  Copyright (c) 2015年 xpg. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "DCDatabase.h"
#import "DCDatabaseUser.h"
#import "DCDatabasePole.h"
#import "DCDatabaseKey.h"
#import "DCDatabaseCharge.h"
#import "DCDatabaseFavorites.h"

@interface DatabaseTests : XCTestCase

@end

@implementation DatabaseTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    NSLog(@"database path %@", [DCDatabase db].path);
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    [DCDatabasePole deleteWithPoleNo:@"P0000001"];
}

- (void)testAsyncExecute {
    XCTestExpectation *expectation = [self expectationWithDescription:@"testAsyncExecute"];
    
    [[DCDatabase db] asyncExecute:^(FMDatabase *db, BOOL *rollback) {
        FMResultSet *rs = [db executeQuery:@"SELECT * FROM sqlite_master WHERE type = 'table'"];
        while ([rs next]) {
            NSLog(@"%@", [rs stringForColumn:@"name"]);
        }
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)testDebug {
    DCDatabasePole *pole = [[DCDatabasePole alloc] init];
    pole.pole_no = @"123";
    pole.nick_name = @"poleName";
    [pole saveToDatabase];
    
    DCDatabaseKey *key = [[DCDatabaseKey alloc] init];
    key.user_id = 2;
    key.pole_no = @"123";
    //    key.add_time = [[NSDate date] timeIntervalSince1970];
    //    key.key = @"keykeykeykey";
    key.key_type = 1;
    [key insertKeyToDatabase];
}

- (void)testUserTable {
    DCDatabaseUser *user = [[DCDatabaseUser alloc] init];
    user.user_id = 1024;
    user.user_name = @"test";
    user.phone_no = @"13888888888";
    user.idcard_no = @"440111";     //"idcard_no CHAR DEFAULT NULL,"
    user.real_name = @"realname";
    user.gender = 1;
    [user saveToDatabase];
    
    DCDatabaseUser *testUser = [DCDatabaseUser userWithId:user.user_id];
    XCTAssertNotNil(testUser);
    XCTAssert([testUser isSameAs:user]);
    
    user.user_name = @"tester";
    [user saveToDatabase];
    testUser = [DCDatabaseUser userWithId:user.user_id];
    XCTAssertNotNil(testUser);
    XCTAssert([testUser isSameAs:user]);
}

- (void)testPoleTable {
    DCDatabasePole *pole = [[DCDatabasePole alloc] init];
    pole.pole_no = @"8888";
    pole.nick_name = @"pole";
    pole.pole_type = 1;
    pole.location = @"address";
    pole.longitude = 130.556443;
    pole.latitude = 30.667932;
    pole.altitude = 102.97;
    pole.rated_cur = 10.56;
    pole.rated_volt = 210.38;
    [pole saveToDatabase];
    
    DCDatabasePole *testPole = [DCDatabasePole poleWithPoleNo:pole.pole_no];
    XCTAssertNotNil(testPole);
    XCTAssert([testPole isSameAs:pole]);
    
    pole.nick_name = @"test&pole";
    [pole saveToDatabase];
    testPole = [DCDatabasePole poleWithPoleNo:pole.pole_no];
    XCTAssertNotNil(testPole);
    XCTAssert([testPole isSameAs:pole]);
}

- (void)testOwnershipTable {
    DCDatabaseKey *key = [[DCDatabaseKey alloc] init];
    key.user_id = 1024;
    key.user_role = 2;
    key.pole_no = @"8888";
    key.add_time = [[NSDate date] timeIntervalSince1970];
    key.key = @"keykeykeykey";
    key.key_type = 2;
    [key insertKeyToDatabase];
    
    NSArray *keys = [DCDatabaseKey keysWithUserId:key.user_id poleNo:key.pole_no keyType:key.key_type];
    XCTAssert([keys count] == 1);
    DCDatabaseKey *testKey = [keys firstObject];
    XCTAssert([testKey isSameAs:key]);
    
    key.user_role = 1;
    key.key_type = 1;
    key.add_time = [[NSDate date] timeIntervalSince1970];
    [key insertKeyToDatabase];
    
    keys = [DCDatabaseKey keysWithUserId:1024 poleNo:key.pole_no keyType:1];
    XCTAssert([keys count] == 1);
    
    key.add_time = [[NSDate date] timeIntervalSince1970];
    [key insertKeyToDatabase];
    
    keys = [DCDatabaseKey keysWithUserId:1024 poleNo:key.pole_no keyType:1];
    XCTAssert([keys count] == 1);
    
    keys = [DCDatabaseKey keysWithUserId:1024 poleNo:key.pole_no];
    XCTAssert([keys count] >= 2);
    testKey = [keys objectAtIndex:0];
    XCTAssert(testKey.key_type == 1);
    testKey = [keys objectAtIndex:1];
    XCTAssert(testKey.key_type == 2);
}

- (void)testChargeTable {
    DCDatabaseCharge *charge = [[DCDatabaseCharge alloc] init];
    charge.sn = 12345678;
    charge.order_id = 44444444;
    charge.user_id = 1024;
    charge.pole_no = @"8888";
    charge.start_time = [[NSDate date] timeIntervalSince1970];
    charge.end_time = [[NSDate date] timeIntervalSince1970];
    charge.quantity = 1000000;
    charge.data = @"charge";
    charge.response_data = @"chargecharge";
    [charge insertToDatabase];

//    [HSSYDatabaseCharge markRecordHasPost:charge.order_id responseData:@"test"];
    
    NSArray *charges = [DCDatabaseCharge chargesWithPoleNo:charge.pole_no];
    XCTAssert([charges count] > 0);
    DCDatabaseCharge *testCharge = [charges firstObject];
    XCTAssert([testCharge isSameAs:charge]);
    
    NSArray *chargesNeedPost = [DCDatabaseCharge chargesNeedPost];
    NSLog(@"chargesNeedPost.poleNum = %@",((DCChargeRecord *)[chargesNeedPost firstObject]).poleNum);
    XCTAssert([chargesNeedPost count] > 0);
}

- (void)testCollectionTable {
    [DCDatabaseFavorites favor:YES withPoleNo:@"1" userId:1024];
    BOOL favor = [DCDatabaseFavorites isPole:@"1" favorByUserId:1024];
    XCTAssert(favor);
    [DCDatabaseFavorites favor:NO withPoleNo:@"1" userId:1024];
    favor = [DCDatabaseFavorites isPole:@"1" favorByUserId:1024];
    XCTAssert(!favor);
}

@end
