//
//  ChargingTests.m
//  ChargingTests
//
//  Created by xpg on 14/12/8.
//  Copyright (c) 2014年 xpg. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "DCTime.h"
#import "NSDateFormatter+HSSYCategory.h"

@interface ChargingTests : XCTestCase

@end

@implementation ChargingTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    XCTAssert(YES, @"Pass");
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

#pragma mark -
- (void)testShareTime { // 7200000 == 10:00, 57600000 == 24:00
    HSSYTime *time = [[HSSYTime alloc] initWithStartTime:clockTimeMake(10, 0) endTime:clockTimeMake(24, 0) weekday:nil];
    XCTAssertEqual(time.startTimestamp, 7200000);
    XCTAssertEqual(time.endTimestamp, 57600000);
}

@end
