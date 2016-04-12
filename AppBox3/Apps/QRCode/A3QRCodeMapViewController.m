//
//  A3QRCodeMapViewController.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 4/11/16.
//  Copyright © 2016 ALLABOUTAPPS. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "A3QRCodeMapViewController.h"

@interface A3QRCodeMapViewController () <MKMapViewDelegate>

@property (nonatomic, strong) MKMapView *mapView;

@end

@implementation A3QRCodeMapViewController

- (void)viewDidLoad {
    [super viewDidLoad];

	self.title = @"Location";
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];

	[self.mapView setRegion:MKCoordinateRegionMakeWithDistance(_mapView.centerCoordinate, 500.0, 500.0) animated:YES];
	[self.mapView selectAnnotation:self.annotation animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setCenterLocation:(CLLocationCoordinate2D)centerLocation {
	_centerLocation = centerLocation;
	self.mapView.centerCoordinate = centerLocation;
}

- (void)setAnnotation:(A3PlaceAnnotation *)annotation {
	_annotation = annotation;
	[self.mapView removeAnnotations:self.mapView.annotations];
	[self.mapView addAnnotation:annotation];
}

- (MKMapView *)mapView {
	if (!_mapView) {
		_mapView = [MKMapView new];
		_mapView.delegate = self;
		[self.view addSubview:_mapView];

		UIView *superview = self.view;
		[_mapView makeConstraints:^(MASConstraintMaker *make) {
			make.left.equalTo(superview.left);
			make.top.equalTo(superview.top).with.offset(64);
			make.right.equalTo(superview.right);
			make.bottom.equalTo(superview.bottom);
		}];
	}
	return _mapView;
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
	MKPinAnnotationView *annotationView = nil;
	
	if ([annotation isKindOfClass:[A3PlaceAnnotation class]]) {
		annotationView = (MKPinAnnotationView *)[self.mapView dequeueReusableAnnotationViewWithIdentifier:@"Pin"];
		
		if (annotationView == nil) {
			annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"Pin"];
			annotationView.canShowCallout = YES;
			annotationView.animatesDrop = YES;
		}
	}
	return annotationView;
}

@end
