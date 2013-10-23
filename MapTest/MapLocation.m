//
//  MapLocation.m
//  MapTest
//
//  Created by owen on 13-10-22.
//  Copyright (c) 2013年 owen. All rights reserved.
//

#import "MapLocation.h"
#import <MapKit/MapKit.h>

@implementation MapLocation
@synthesize streetAddress;
@synthesize city;
@synthesize state;
@synthesize zip;
@synthesize coordinate;
#pragma mark -
- (NSString *)title {
    return @"您的位置!";
}
- (NSString *)subtitle {
    
    NSMutableString *ret = [NSMutableString string];
    if (streetAddress)
        [ret appendString:streetAddress]; 
    if (streetAddress && (city || state || zip)) 
        [ret appendString:@" • "];
    if (city)
        [ret appendString:city];
    if (city && state)
        [ret appendString:@", "];
    if (state)
        [ret appendString:state];
    if (zip)
        [ret appendFormat:@", %@", zip];
    
    return ret;
}

-(id) initWithCoordinate:(CLLocationCoordinate2D) coords
{
	if (self = [super init]) {
		coordinate = coords;
	}
	return self;
}
@end
