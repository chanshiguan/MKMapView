//
//  ViewController.m
//  MapTest
//
//  Created by owen on 13-10-22.
//  Copyright (c) 2013年 owen. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

#define SYSTEM_VERSION_LESS_THAN(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.myMap.delegate = self;
    //支持手势
    self.myMap.zoomEnabled = YES;
    //地图的类型：MKMapTypeStandard 显示街道和道路 MKMapTypeSatellite 显示卫星 MKMapTypeHybrid 显示混合地图
    self.myMap.mapType = MKMapTypeStandard;
    //是否可以左右滑动
    self.myMap.scrollEnabled = YES;
    //显示用户位置
    self.myMap.showsUserLocation = YES;
    
//-----------------------------添加长按手势添加标注------------------------------------------------
    UILongPressGestureRecognizer *lpress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
    lpress.minimumPressDuration = 0.5;//按0.5秒响应longPress方法
    lpress.allowableMovement = 10.0;
    [self.myMap addGestureRecognizer:lpress];//m_mapView是MKMapView的实例

    [self setPinOnMyMap];
}

-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    //该if 可以实现，其他标注为自定义样式，自身定位为原生样式
    if ([annotation isKindOfClass:[MKUserLocation class]]) {
        return nil;
    }
    //MKPinAnnotationView 为系统默认标注样式，可以继承MKAnnotationView 后，自定义该标注
    static NSString *defaultPinID = @"com.invasivecode.pin";
    MKPinAnnotationView *pinView = (MKPinAnnotationView*)[self.myMap dequeueReusableAnnotationViewWithIdentifier:defaultPinID];
    if (pinView == nil) {
        pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:defaultPinID];
    }
    //是否显示标注信息
    pinView.canShowCallout = YES;
    //标注颜色
    pinView.pinColor = MKPinAnnotationColorRed;
    //是否有落下效果
    pinView.animatesDrop = YES;
    //创建标注信息右侧按钮，左侧按钮为：leftCalloutAccessoryView
    UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    [rightBtn addTarget:self action:@selector(daohang:) forControlEvents:UIControlEventTouchUpInside];
    pinView.rightCalloutAccessoryView = rightBtn;
    return pinView;
}
//选中标注视图
- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    selectMap = (MapLocation *)view;
}

//你移动时，更新当前位置调用
-(void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    
}
//地图显示区域改变 调用
-(void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    
}
-(IBAction)loadUserLocation:(id)sender
{
    //创建位置管理器
    locationManager = [[CLLocationManager alloc] init];
    //设置代理
    locationManager.delegate=self;
    //指定需要的精度级别
    locationManager.desiredAccuracy=kCLLocationAccuracyBest;
    //设置距离筛选器,当移动1000米的时候，更新地图上用户的位置
    locationManager.distanceFilter=1000.0f;
    //启动位置管理器，该操作为异步操作，而且很费电，再不用的时候一定要关闭 方法为[locationManager stopUpdatingLocation];
    [locationManager startUpdatingLocation];
}

#pragma mark ------CLLocationManagerDelegate--
//该方法为CLLocationManagerDelegate 方法，当定位成功后，回调该方法～
//IOS6.0以前
- (void)locationManager:(CLLocationManager *)manager
	didUpdateToLocation:(CLLocation *)newLocation
		   fromLocation:(CLLocation *)oldLocation
{
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance (newLocation.coordinate, 2000, 2000);
    MKCoordinateRegion adjustedRegion = [self.myMap regionThatFits:viewRegion]; [self.myMap setRegion:adjustedRegion animated:YES];
    manager.delegate = nil; [manager stopUpdatingLocation];
    MKReverseGeocoder *geocoder = [[MKReverseGeocoder alloc] initWithCoordinate:newLocation.coordinate];
    geocoder.delegate = self;
    [geocoder start];
}
//IOS6.0以后
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    if (locations.count)
    {
        CLLocation * location = (CLLocation *)[locations objectAtIndex:0];
        CLLocationCoordinate2D coord;
        //得到经度
        coord.latitude = location.coordinate.latitude;
        //得到纬度
        coord.longitude = location.coordinate.longitude;
        //设置地图显示的中心和范围
        MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance (coord, 2000, 2000);
        MKCoordinateRegion adjustedRegion = [self.myMap regionThatFits:viewRegion];
        //根据设置的信息进行显示
        [self.myMap setRegion:adjustedRegion animated:YES];
        locationManager.delegate = nil;
        //关闭位置管理器
        [locationManager stopUpdatingLocation];
        
//-------------------------------------反向地理编码---------------------------------------------
        //5.0以后出现的方法，之前用CLGeocoderCLGeocoder
        CLGeocoder *geocoder = [[CLGeocoder alloc] init];
        [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *array, NSError *error) {
            if (array.count > 0) {

                CLPlacemark *placemark = [array objectAtIndex:0];
                MapLocation *annotation = [[MapLocation alloc] init];
                annotation.streetAddress = placemark.thoroughfare;
                annotation.city = placemark.locality;
                annotation.state = placemark.administrativeArea;
                annotation.zip = placemark.postalCode;
                annotation.coordinate = coord;
                //将定位的点添加到地图
                [self.myMap addAnnotation:annotation];
            }
        }];

    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"error =%@",error);
}


-(void)daohang:(id)sender
{
    
    if (SYSTEM_VERSION_LESS_THAN(@"6.0")) {//6.0以下，调用googleMap
        
        NSLog(@"6.0以下，调用googleMap");
        
        //注意经纬度不要写反了
        NSString * loadString=[NSString stringWithFormat:@"http://maps.google.com/maps?saddr=%f,%f&daddr=%@",selectMap.coordinate.latitude,selectMap.coordinate.longitude,@"中国山东济南市某某街某某号"];
        
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:loadString]];
        
    }else{

        MKMapItem *currentLocation = [MKMapItem mapItemForCurrentLocation];//调用自带地图（定位）

        //显示目的地坐标。画路线

        MKMapItem *toLocation = [[MKMapItem alloc] initWithPlacemark:[[MKPlacemark alloc] initWithCoordinate:selectMap.coordinate addressDictionary:nil]];

        toLocation.name = @"大观园";

        [MKMapItem openMapsWithItems:[NSArray arrayWithObjects:currentLocation, toLocation, nil]

        launchOptions:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:MKLaunchOptionsDirectionsModeDriving, [NSNumber numberWithBool:YES], nil]
        forKeys:[NSArray arrayWithObjects:MKLaunchOptionsDirectionsModeKey, MKLaunchOptionsShowsTrafficKey, nil]]];
    }
}


#pragma mark ------MKReverseGeocoderDelegate---------

-(void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFindPlacemark:(MKPlacemark *)placemark
{
    NSLog(@"countryCode=%@",placemark.countryCode);
    NSLog(@"country=%@",placemark.country);
    NSLog(@"administrativeArea=%@",placemark.administrativeArea);
    NSLog(@"subAdministrativeArea=%@",placemark.subAdministrativeArea);
    NSLog(@"locality=%@",placemark.locality);
    NSLog(@"subLocality=%@",placemark.subLocality);
    NSLog(@"thoroughfare=%@",placemark.thoroughfare);
    NSLog(@"subThoroughfare=%@",placemark.subThoroughfare);
    NSLog(@"postalCode=%@",placemark.postalCode);
}

-(void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFailWithError:(NSError *)error
{
    NSLog(@"逆向地理解析失败");
}

-(void)setPinOnMyMap
{
    for (int i = 0; i<10; i++) {
        CLLocationCoordinate2D coord = {38.84616875+i*i,121.50557546+i*i};
        MapLocation *map = [[MapLocation alloc] initWithCoordinate:coord];
        [self.myMap addAnnotation:map];
        //添加一组点
//        [self.myMap addAnnotations:<#(NSArray *)#>];
    }
}


#pragma mark ------UILongPressGestureRecognizer--------
- (void)longPress:(UIGestureRecognizer*)gestureRecognizer{
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded){
        return;
    }
    
    //坐标转换
    CGPoint touchPoint = [gestureRecognizer locationInView:self.myMap];
    CLLocationCoordinate2D touchMapCoordinate =
    [self.myMap convertPoint:touchPoint toCoordinateFromView:self.myMap];
    
    MapLocation *poin = [[MapLocation alloc] initWithCoordinate:touchMapCoordinate];

    [self.myMap addAnnotation:poin];

}
@end
