//
//  ApiTests.m
//  Charging
//
//  Created by Ben on 15/1/7.
//  Copyright (c) 2015年 xpg. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "DCCommon.h"
#import "DCSiteApi.h"
#import "DCHTTPSessionManager.h"
#import "DCUser.h"
#import "DCPole.h"
#import "DCApp.h"
#import "DCChargeRecord.h"
#import "DCChargeRecord.h"

const NSInteger RequestTimeout = 10;

@interface ApiTests : XCTestCase {
}
@end

@implementation ApiTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

#pragma mark - chargecontroller : 费用相关操作
//POST /pile/chargerecord 根据电桩查询该桩所有的充电记录
//- (void)testFetchChargeRecord {
//    [DCApp sharedApp].user = [DCDefault loadLoginedUser];//需要登录
//    
//    XCTestExpectation *expectation = [self expectationWithDescription:@"testAsyncExecute"];
//    
//    //pileId
//    NSString *pileId = @"P0000003";
//    
//    //startTime
//    NSDateComponents *components = [[NSDateComponents alloc] init];
//    components.year = 2015; components.month = 1; components.day = 1;
//    NSDate *startTime = [[NSCalendar currentCalendar] dateFromComponents:components];
//    
//    //endTime
//    components.year = 2015; components.month = 2; components.day = 1;
//    NSDate *endTime = [[NSCalendar currentCalendar] dateFromComponents:components];
//    
//    [DCSiteApi postChargeRecord:pileId startTime:startTime endTime:endTime type:@"1" start:@0 count:@10 completion:^(NSURLSessionDataTask *task, BOOL success, DCWebResponse *webResponse, NSError *error) {
//        [self logRequestTask:task error:error webResponse:webResponse];
//        XCTAssert([webResponse isSuccess]);
//        NSArray *result = webResponse.result;
//        for (NSDictionary *dict in result) {
//            DCChargeRecord *record = [[DCChargeRecord alloc] initWithDict:dict];
//            
//            [self checkStringClass:record.phoneNo];
//            [self checkStringClass:record.recordId];
//            [self checkStringClass:record.userId];
//            [self checkStringClass:record.quantity];
//            [self checkStringClass:record.userName];
//            [self checkStringClass:record.pileId];
//            [self checkStringClass:record.orderId];
//            [self checkStringClass:record.chargePrice];
//            [self checkStringClass:record.sequence];
//            
//            [self checkDateClass:record.startTime];
//            [self checkDateClass:record.createTime];
//            [self checkDateClass:record.endTime];
//        }
//        
//        [expectation fulfill];
//    }];
//    [self waitForExpectationsWithTimeout:RequestTimeout handler:nil];
//}

//POST /pile/member 根据桩的编号获取该桩的家人列表
//POST /pile/pricerate/{piletype} 根据充电类型查询费率
//POST /pile/record/setrecord 上传充电记录

#pragma mark - evaluationcontroller : 评价相关操作
//POST /evaluate/add 新增评价
//POST /evaluate/list 获取评价列表

#pragma mark - get-key : 获取Key相关操作
//POST /key 授权key

#pragma mark - news : News 相关操作
//POST /news/add 增加News
//GET /news/del delNews

#pragma mark - ordercontroller : 订单相关操作
//POST /order 下订单
- (void)testOrder {
    XCTestExpectation *expectation = [self expectationWithDescription:@"testAsyncExecute"];
    
    [DCSiteApi postOrder:@"P0000001"
                 startTime:[NSDate date]
                   endTime:[NSDate dateWithTimeIntervalSinceNow:3600]
                    userId:@"3"
                completion:^(NSURLSessionDataTask *task, BOOL success, DCWebResponse *webResponse, NSError *error) {
                    [self logRequestTask:task error:error webResponse:webResponse];
                    XCTAssert(success);
                    [expectation fulfill];
                }];
    
    [self waitForExpectationsWithTimeout:RequestTimeout handler:nil];
}

//GET /order/aliname/{userid} 订单用户信息
- (void)testGetAlipayAccount {
    XCTestExpectation *expectation = [self expectationWithDescription:@"testAsyncExecute"];
    
    [DCApp sharedApp].user = [DCDefault loadLoginedUser];//需要登录
    [DCSiteApi getUserAlipayAccount:[DCApp sharedApp].user.userId completion:^(NSURLSessionDataTask *task, BOOL success, DCWebResponse *webResponse, NSError *error) {
        [self logRequestTask:task error:error webResponse:webResponse];
        XCTAssert([webResponse isSuccess]);
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:RequestTimeout handler:nil];
}

//GET /order/evalute/{orderId} 根据订单Id获取订单评价
//POST /order/list 获取订单
//POST /order/modify 处理订单
//GET /order/{orderId} 根据订单id来获取订单

#pragma mark - paycontroller : 支付接口
//GET /pay/money 签名等信息
- (void)testGetPayInfo {
    XCTestExpectation *expectation = [self expectationWithDescription:@"testGetPayInfo"];
    
    [DCSiteApi getPayInfoWithChargeRecordIds:@[@"123"] completion:^(NSURLSessionDataTask *task, BOOL success, DCWebResponse *webResponse, NSError *error) {
        [self logRequestTask:task error:error webResponse:webResponse];
        XCTAssert([webResponse isSuccess]);
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:RequestTimeout handler:nil];
}

#pragma mark - pilecontroller : 电桩的相关操作
//POST /favorites 收藏电桩
//POST /favorites/list 获取已收藏电桩
//POST /pile 获取电桩详细信息
//POST /pile/access 获取有权限的桩
//POST /pile/authorization 授权给家人
//POST /pile/hadcollect 判断电桩是否已收藏
//POST /pile/list 获取电桩列表信息
//POST /pile/modify 修改电桩
//POST /pile/share 设置电桩分享

#pragma mark - pushcontroller : 消息推送相关操作
//POST /push/bind pushbind
//POST /push/list notieslist
//POST /push/set push
//POST /push/status status
//GET /push/unread/{userid} unread

#pragma mark - smssendcontroller : 短信相关操作
//POST /tplsendsms 获取短信验证码

#pragma mark - tokencontroller : token相关操作
//GET /refresh_token/{userid}/{refreshToken} 刷新token

#pragma mark - user : UserController 相关操作
//GET /user/exist/{phone} exit
//POST /user/info userInfo
//POST /user/login userLogin
//POST /user/logout userLoginout
//POST /user/password userPassword
//POST /user/register userRegister
//POST /user/verification userVerification

/*
- (void)testLogin {
    XCTestExpectation *expectation = [self expectationWithDescription:@"testAsyncExecute"];
    
    [DCSiteApi postLoginWithPhone:@"13988888888" password:@"123456" userType:@"1" pushId:nil completion:^(NSURLSessionDataTask *task, BOOL success, DCWebResponse *webResponse, NSError *error) {
        XCTAssert([webResponse isSuccess]);
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:RequestTimeout handler:nil];
}

- (void)testRegister {
    XCTestExpectation *expectation = [self expectationWithDescription:@"testAsyncExecute"];
    [DCSiteApi postUserRegister:@"18824140606" password:@"123456" userType:@"1" name:@"name" sex:@"1" verification:@"123456" completion:^(NSURLSessionDataTask *task, BOOL success, id object, NSError *error) {
        NSLog(@"%@", object);
        XCTAssert(success);
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:RequestTimeout handler:nil];
}

- (void)testReSetPassword {
    XCTestExpectation *expectation = [self expectationWithDescription:@"testAsyncExecute"];
    [DCSiteApi postReSetPassword:@"13660204145" password:@"123456" userType:@"1" verification:@"verify" completion:^(NSURLSessionDataTask *task, BOOL success, DCWebResponse *webResponse, NSError *error) {
        XCTAssert([webResponse isSuccess]);
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:RequestTimeout handler:nil];
}

- (void)testLogOut {
    XCTestExpectation *expectation = [self expectationWithDescription:@"testAsyncExecute"];
    [DCSiteApi postLogOut:@"18824140606" userType:@"1" completion:^(NSURLSessionDataTask *task, BOOL success, id object, NSError *error) {
        NSLog(@"%@", object);
        XCTAssert(success);
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:RequestTimeout handler:nil];
}

- (void)testUpdateUserInfo {
    DCUser *info = [[DCUser alloc]init];
    info.userId = @"10";

    XCTestExpectation *expectation = [self expectationWithDescription:@"testAsyncExecute"];
    [DCSiteApi postUpdateUserInfo:info completion:^(NSURLSessionDataTask *task, BOOL success, id object, NSError *error) {
        NSLog(@"%@", object);
        XCTAssert(success);
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:RequestTimeout handler:nil];
}

- (void)testPileList {
    
//    XCTestExpectation *expectation = [self expectationWithDescription:@"testAsyncExecute"];
//    [DCSiteApi postPileList:@"1" longitude:nil latitude:nil cityId:nil distance:nil shareStartTime:nil shareEndTime:nil start:nil count:@(1) completion:^(NSURLSessionDataTask *task, BOOL success, id object, NSError *error) {
//        NSLog(@"%@", object);
//        XCTAssert(success);
//        [expectation fulfill];
//    }];
    
//    [self waitForExpectationsWithTimeout:RequestTimeout handler:nil];
}

- (void)testPileInfo {
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"testAsyncExecute"];
    [DCSiteApi postGetPoleInfo:@"1" completion:^(NSURLSessionDataTask *task, BOOL success, id object, NSError *error) {
        NSLog(@"%@", object);
        XCTAssert(success);
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:RequestTimeout handler:nil];
}

- (void)testPileFavor {
    XCTestExpectation *expectation = [self expectationWithDescription:@"testAsyncExecute"];
    [DCSiteApi postCollectPile:@"WDSoyIqs" isCollect:YES pileId:@"1" completion:^(NSURLSessionDataTask *task, BOOL success, id object, NSError *error) {
        NSLog(@"%@", object);
        XCTAssert(success);
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:RequestTimeout handler:nil];
}

- (void)testGetFavorPiles {
    XCTestExpectation *expectation = [self expectationWithDescription:@"testAsyncExecute"];
    [DCSiteApi postGetFavorPiles:@"WDSoyIqs" start:nil count:nil completion:^(NSURLSessionDataTask *task, BOOL success, id object, NSError *error) {
        NSLog(@"%@", object);
        XCTAssert(success);
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:RequestTimeout handler:nil];
}

- (void)testGetAccessPiles {
    XCTestExpectation *expectation = [self expectationWithDescription:@"testAsyncExecute"];
    [DCSiteApi postGetAccessPiles:@"WDSoyIqs" completion:^(NSURLSessionDataTask *task, BOOL success, id object, NSError *error) {
        NSLog(@"%@", object);
        XCTAssert(success);
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:RequestTimeout handler:nil];
}

- (void)testUpdatePileInfo {
    DCPole *poleInfo = [[DCPole alloc]init];
    poleInfo.altitude = 23.117;
    poleInfo.cityId = @"cityId";
    poleInfo.pileId = @"1";
    poleInfo.userId = @"323";
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"testAsyncExecute"];
    [DCSiteApi postUpdatePileInfo:poleInfo completion:^(NSURLSessionDataTask *task, BOOL success, id object, NSError *error) {
        NSLog(@"%@", object);
        XCTAssert(success);
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:RequestTimeout handler:nil];
}

- (void)testGetMenber {
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"testAsyncExecute"];
    [DCSiteApi postGetMember:@"1" completion:^(NSURLSessionDataTask *task, BOOL success, id object, NSError *error) {
        NSLog(@"%@", object);
        XCTAssert(success);
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:RequestTimeout handler:nil];
}

- (void)testAuth {
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"testAsyncExecute"];
    [DCSiteApi postAuthorization:@"1" phone:@"323" isAuth:YES completion:^(NSURLSessionDataTask *task, BOOL success, id object, NSError *error) {
        NSLog(@"%@", object);
        XCTAssert(success);
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:RequestTimeout handler:nil];
}

- (void)testShare {
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"testAsyncExecute"];
    [DCSiteApi postShare:@"1" contactPhone:@"" pileId:@"" times:nil isShare:YES completion:^(NSURLSessionDataTask *task, BOOL success, DCWebResponse *webResponse, NSError *error) {
        XCTAssert([webResponse isSuccess]);
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:RequestTimeout handler:nil];
}

- (void)testOrderList {
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"testAsyncExecute"];
    [DCSiteApi postOrderList:@"P0000003" userid:@"2" search:nil start:nil count:nil action:@"1" completion:^(NSURLSessionDataTask *task, BOOL success, id object, NSError *error) {
        NSLog(@"%@", object);
        XCTAssert(success);
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:RequestTimeout handler:nil];
}

- (void)testOrderModify {
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"testAsyncExecute"];
    [DCSiteApi postOrderModify:@"1" action:@"1" completion:^(NSURLSessionDataTask *task, BOOL success, id object, NSError *error) {
        NSLog(@"%@", object);
        XCTAssert(success);
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:RequestTimeout handler:nil];
}

- (void)testPostChargeRecord {
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"testAsyncExecute"];
    DCChargeRecordPost *record = [[DCChargeRecordPost alloc]init];
    record.pileId = @"P0000003";
    record.chargeId = @"1";
    record.userid = @"25";
    record.orderId = @"1";
    record.quantity = @"1";
    record.startTime = 1419866682000;
    record.endTime = 1419866700000;
    [DCSiteApi postChargeRecordToServer:@[record] completion:^(NSURLSessionDataTask *task, BOOL success, DCWebResponse *webResponse, NSError *error) {
        NSLog(@"%@", webResponse);
        XCTAssert(success);
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:RequestTimeout handler:nil];
}

- (void)testReqKeyData {
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"testAsyncExecute"];
    [DCSiteApi postRequestKey:@"13888888888" idType:@"2" completion:^(NSURLSessionDataTask *task, BOOL success, id object, NSError *error) {
        NSLog(@"%@", object);
        XCTAssert(success);
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:RequestTimeout handler:nil];
}

- (void)testSendSms {
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"testAsyncExecute"];
    [DCSiteApi postSendSms:@"18824140606" completion:^(NSURLSessionDataTask *task, BOOL success, DCWebResponse *webResponse, NSError *error) {
        NSLog(@"%@", webResponse);
        XCTAssert(success);
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:RequestTimeout handler:nil];
}

- (void)testRefreshToken {
    XCTestExpectation *expectation = [self expectationWithDescription:@"testAsyncExecute"];
    
    [DCSiteApi postLoginWithPhone:@"13660204145" password:@"123456" userType:@"1" pushId:nil completion:^(NSURLSessionDataTask *task, BOOL success, DCWebResponse *webResponse, NSError *error) {
        NSLog(@"%@", task.originalRequest.URL);
        NSLog(@"%@", webResponse);
        XCTAssert([webResponse isSuccess]);
        
        DCUser *user = [[DCUser alloc] initWithLoginResponse:webResponse.result];
        [DCDefault saveLoginedUser:user];
        [DCApp sharedApp].user = user;
        [[DCHTTPSessionManager shareManager].requestSerializer setValue:user.token forHTTPHeaderField:@"token"];
        
        [DCSiteApi refreshToken:user.refreshToken userId:user.userId completion:^(NSURLSessionDataTask *task, BOOL success, DCWebResponse *webResponse, NSError *error) {
            NSLog(@"%@", task.originalRequest.URL);
            NSLog(@"%@", webResponse);
            XCTAssert([webResponse isSuccess]);
            [expectation fulfill];
        }];
    }];
    
    [self waitForExpectationsWithTimeout:RequestTimeout handler:nil];
    
}

- (void)testEvalate {
    XCTestExpectation *expectation = [self expectationWithDescription:@"testAsyncExecute"];
    [DCSiteApi postEvaluate:@"nice" pileId:@"Z0000001" userId:@"3" orderId:@"101422865417566457" level:@"5" completion:^(NSURLSessionDataTask *task, BOOL success, DCWebResponse *webResponse, NSError *error) {
        NSLog(@"%@", webResponse);
        XCTAssert(success);
        [expectation fulfill];
    }];
}

- (void)testEvalateList {
//    XCTestExpectation *expectation = [self expectationWithDescription:@"testAsyncExecute"];
//    [DCSiteApi postEvaluateList:@"Z0000001" userId:@"3" orderId:@"101422865417566457" level:@"5" start:[NSNumber numberWithInt:0] count:[NSNumber numberWithInt:10] completion:^(NSURLSessionDataTask *task, BOOL success, DCWebResponse *webResponse, NSError *error) {
//        NSLog(@"%@", webResponse);
//        XCTAssert(success);
//        [expectation fulfill];
//    }];
}
*/


#pragma mark - Extensions
- (void)logRequestTask:(NSURLSessionTask *)task error:(NSError *)error webResponse:(DCWebResponse *)webResponse {
    NSLog(@"///////");
    id json = nil;
    if (task.originalRequest.HTTPBody) {
        json = [NSJSONSerialization JSONObjectWithData:task.originalRequest.HTTPBody options:0 error:nil];
    }
    NSLog(@"%@ %@\n%@\n%@", task.originalRequest.HTTPMethod, task.originalRequest.URL, prettyPrintedstringForJSONObject(json), task.originalRequest.allHTTPHeaderFields);
    if (error) {
        NSLog(@"ERROR %@", error);
    } else {
        NSLog(@"RESPONSE %@", webResponse);
        //        NSString *responseString = prettyPrintedstringForJSONObject(webResponse.result);
        //        NSLog(@"%d %@\n%@", webResponse.code, webResponse.message, responseString);
    }
}

- (BOOL)checkStringClass:(id)obj {
    if (obj) {
        XCTAssert([obj isKindOfClass:[NSString class]], @"%@", [obj class]);
    }
}

- (BOOL)checkDateClass:(id)obj {
    if (obj) {
        XCTAssert([obj isKindOfClass:[NSDate class]], @"%@", [obj class]);
    }
}

@end
