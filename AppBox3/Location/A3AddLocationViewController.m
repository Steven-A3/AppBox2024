//
//  A3AddLocationViewController.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 05/14/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "A3AddLocationViewController.h"
#import "A3LocationPlacemarkView.h"
#import "common.h"
#import "CommonUIDefinitions.h"
#import "UIViewController+A3AppCategory.h"

@interface A3AddLocationViewController () <MKMapViewDelegate, CLLocationManagerDelegate>
@property (nonatomic, strong) MKMapView *mapView;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLGeocoder *geoCoder;
@property (nonatomic, strong) MKPlacemark *placemark;
@property (nonatomic, strong) A3LocationPlacemarkView *placemarkView;
@end

@implementation A3AddLocationViewController

- (void)viewDidLoad {
	[super viewDidLoad];

	self.title = @"Current Location";
	[self.view addSubview:self.mapView];
	[self.view addSubview:self.placemarkView];

	self.navigationItem.rightBarButtonItem = [self barButtonItemWithTitle:@"Edit" action:@selector(editButtonAction)];

	[self.locationManager startUpdatingLocation];
}

- (void)editButtonAction {

}

- (MKMapView *)mapView {
	if (nil == _mapView) {
		_mapView = [[MKMapView alloc] initWithFrame:self.view.bounds];
		_mapView.delegate = self;
	}
	return _mapView;
}

- (CLLocationManager *)locationManager {
	if (nil == _locationManager) {
		_locationManager = [[CLLocationManager alloc] init];
		_locationManager.desiredAccuracy = kCLLocationAccuracyBest;
		_locationManager.delegate = self;
	}
	return _locationManager;
}

- (CLGeocoder *)geoCoder {
	if (nil == _geoCoder) {
		_geoCoder = [[CLGeocoder alloc] init];
	}
	return _geoCoder;
}

- (A3LocationPlacemarkView *)placemarkView {
	if (nil == _placemarkView) {
		_placemarkView = [[A3LocationPlacemarkView alloc] initWithFrame:CGRectZero];
		CGSize size = [_placemarkView sizeThatFits:CGSizeZero];
		FNLOGRECT(self.view.bounds);
		_placemarkView.frame = CGRectMake(self.view.bounds.origin.x, self.view.bounds.size.height - size.height, size.width, size.height);
		FNLOGRECT(_placemarkView.frame);
	}
	return _placemarkView;
}

#pragma mark -- CLLocation delegate

-(void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation{
	[_locationManager stopUpdatingLocation];
	[self setupMapForLocation:newLocation];

	[self.geoCoder reverseGeocodeLocation:self.mapView.userLocation.location completionHandler:^(NSArray *placemarks, NSError *error) {
		if (error) {
			FNLOG(@"%@", [error localizedDescription]);
		} else {
			_placemark = [placemarks objectAtIndex:0];

			self.placemarkView.nameLabel.text = _placemark.name;
			self.placemarkView.addressLabel1.text = [NSString stringWithFormat:@"%@ %@", _placemark.subThoroughfare, _placemark.thoroughfare];
			self.placemarkView.addressLabel2.text = [NSString stringWithFormat:@"%@ %@ %@", _placemark.subAdministrativeArea,
																			   _placemark.administrativeArea, _placemark.postalCode];
			self.placemarkView.addressLabel3.text = _placemark.country;
			self.placemarkView.contactLabel.text = @"010-0000-0000";
			[self.placemarkView setNeedsLayout];
			FNLOG(@"%@", _placemark);
		}
		self.placemarkView.nameLabel.text = @"Apple Inc.";
		self.placemarkView.addressLabel1.text = @"1 Infinite Loop";
		self.placemarkView.addressLabel2.text = @"Cupertino CA 95014";
		self.placemarkView.addressLabel3.text = @"United States";
		self.placemarkView.contactLabel.text = @"+1 (408) 974 1010";

		[self.placemarkView setNeedsLayout];
	}];
}

-(void)setupMapForLocation:(CLLocation*)newLocation{
	MKCoordinateRegion region;
	MKCoordinateSpan span;
	span.latitudeDelta = 0.003;
	span.longitudeDelta = 0.003;
	CLLocationCoordinate2D location;
	location.latitude = newLocation.coordinate.latitude;
	location.longitude = newLocation.coordinate.longitude;
	region.span = span;
	region.center = location;
	[self.mapView setRegion:region animated:YES];
}


@end
