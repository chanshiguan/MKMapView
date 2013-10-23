//
//  ViewController.h
//  MapTest
//
//  Created by owen on 13-10-22.
//  Copyright (c) 2013年 owen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "MapLocation.h"


@interface ViewController : UIViewController<MKMapViewDelegate,CLLocationManagerDelegate,MKReverseGeocoderDelegate>
{
    //位置管理器
    CLLocationManager *locationManager;
    //选择位置的坐标
    MapLocation *selectMap;
}
@property (nonatomic, strong) IBOutlet MKMapView *myMap;

-(IBAction)loadUserLocation:(id)sender;

@end
