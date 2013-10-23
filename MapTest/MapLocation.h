//
//  MapLocation.h
//  MapTest
//
//  Created by owen on 13-10-22.
//  Copyright (c) 2013年 owen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface MapLocation : NSObject <MKAnnotation> {
    NSString *streetAddress;
    NSString *city;
    NSString *state;
    NSString *zip;
    
    CLLocationCoordinate2D coordinate;
}
@property (nonatomic, copy) NSString *streetAddress;
@property (nonatomic, copy) NSString *city;
@property (nonatomic, copy) NSString *state;
@property (nonatomic, copy) NSString *zip;
@property (nonatomic, readwrite) CLLocationCoordinate2D coordinate;

-(id) initWithCoordinate:(CLLocationCoordinate2D) coords;
@end
