//
//  BMKPoiInfo+HSSY.m
//  Charging
//
//  Created by  Blade on 4/2/15.
//  Copyright (c) 2015 xpg. All rights reserved.
//

#import "BMKPoiInfo+HSSY.h"

@implementation BMKPoiInfo (HSSY)
/***
 NSString* _name;			///<POI名称
 NSString* _uid;
	NSString* _address;		///<POI地址
	NSString* _city;			///<POI所在城市
	NSString* _phone;		///<POI电话号码
	NSString* _postcode;		///<POI邮编
	int		  _epoitype;		///<POI类型，0:普通点 1:公交站 2:公交线路 3:地铁站 4:地铁线路
	CLLocationCoordinate2D _pt;	///<POI坐标
 */
-(void)encodeWithCoder:(NSCoder *)encoder{
    [encoder encodeObject:self.name forKey:@"name"];
    [encoder encodeObject:self.uid forKey:@"uid"];
    [encoder encodeObject:self.address forKey:@"address"];
    [encoder encodeObject:self.city forKey:@"city"];
    [encoder encodeObject:self.phone forKey:@"phone"];
    [encoder encodeObject:self.postcode forKey:@"postcode"];
    [encoder encodeObject:[NSNumber numberWithInt:self.epoitype] forKey:@"epoitype"];
    
    [encoder encodeObject:[NSNumber numberWithDouble:self.pt.longitude] forKey:@"ptLongitude"];
    [encoder encodeObject:[NSNumber numberWithDouble:self.pt.latitude] forKey:@"ptLatitude"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if (self = [super init]) {
        self.name = [decoder decodeObjectForKey:@"name"];
        self.uid = [decoder decodeObjectForKey:@"uid"];
        self.address = [decoder decodeObjectForKey:@"address"];
        self.city = [decoder decodeObjectForKey:@"city"];
        self.phone = [decoder decodeObjectForKey:@"phone"];
        self.postcode = [decoder decodeObjectForKey:@"postcode"];
        self.epoitype = [(NSNumber*)[decoder decodeObjectForKey:@"epoitype"] intValue];
        [decoder decodeObjectForKey:@"ptLongitude"];
        CLLocationCoordinate2D pt;
        pt.longitude = [(NSNumber*)[decoder decodeObjectForKey:@"ptLongitude"] doubleValue];
        pt.latitude = [(NSNumber*)[decoder decodeObjectForKey:@"ptLatitude"] doubleValue];
        self.pt = pt;
    }
    return self;
}
@end
