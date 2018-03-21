//
//  DCAddSuccessViewController.m
//  Charging
//
//  Created by xpg on 15/9/30.
//  Copyright (c) 2015年 xpg. All rights reserved.
//

#import "DCAddSuccessViewController.h"
#import "BaiduMapKits.h"

@interface DCAddSuccessViewController ()<BMKMapViewDelegate>
@property (nonatomic, retain) UIBarButtonItem* backItem;
@property (weak, nonatomic) IBOutlet BMKMapView *mapView;

@end

@implementation DCAddSuccessViewController

- (void)viewDidLoad {
    [super viewDidLoad];

//    self.backItem = [UIBarButtonItem favorBarItemWithTarget:self action:];
    
    self.backItem = [UIBarButtonItem backBarItemWithTarget:self action:@selector(backPopToVC:)];
    self.navigationItem.leftBarButtonItem = self.backItem;
    
    //地图
    [self initMapView];
}

- (void)initMapView {
    self.mapView.centerCoordinate = self.LocationCoordinate;
    self.mapView.zoomLevel = 15;
    self.mapView.ChangeWithTouchPointCenterEnabled = NO;
    self.mapView.userInteractionEnabled = NO;
    self.mapView.delegate = self;
//    [self.mapView setCenterCoordinate:self.LocationCoordinate];
    
    BMKPointAnnotation *annotation = [[BMKPointAnnotation alloc] init];
    annotation.coordinate = self.LocationCoordinate;
    [self.mapView addAnnotation:annotation];
}

#pragma mark - BMKMapViewDelegate
- (BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id<BMKAnnotation>)annotation {
    BMKAnnotationView *view = [[BMKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:nil];
    view.image = [UIImage imageNamed:@"map_annotation_pin"];
    view.centerOffset = CGPointMake(0, -(view.bounds.size.height / 2));
    return view;
}

-(void)backPopToVC:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
