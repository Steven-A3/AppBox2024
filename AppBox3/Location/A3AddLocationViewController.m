//
//  A3AddLocationViewController.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 05/14/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreGraphics/CoreGraphics.h>
#import "A3AddLocationViewController.h"
#import "FSVenue.h"
#import "A3LocationPlacemarkView.h"
#import "common.h"
#import "CommonUIDefinitions.h"
#import "UIViewController+A3AppCategory.h"
#import "FSVenue.h"
#import "A3PlacemarkBackgroundView.h"
#import "Foursquare2.h"
#import "FSConverter.h"
#import "NIKFontAwesomeIconFactory.h"
#import "NIKFontAwesomeIconFactory+iOS.h"
#import "NSString+conversion.h"

@interface A3AddLocationViewController () <MKMapViewDelegate, CLLocationManagerDelegate, UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) MKMapView *mapView;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLGeocoder *geoCoder;
@property (nonatomic, strong) MKPlacemark *placemark;
@property (nonatomic, strong) A3LocationPlacemarkView *placemarkView;
@property (nonatomic, strong) UITextField *searchField;
@property (nonatomic, strong) NSArray *nearbyVenues;
@property (nonatomic, strong) CLLocation *lastKnownLocation;
@property (nonatomic, strong) UIView *tableViewBackgroundView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIView *searchView;
@property (nonatomic, strong) FSVenue *selectedVenue;
@end

@implementation A3AddLocationViewController {
	CGFloat keyboardHeight;
	BOOL	tableViewVisible;
	BOOL	hideTableView;
	BOOL	firstUpdate;
}

- (id)initWithVenue:(FSVenue *)venue {
	self = [super init];
	if (self) {
		_selectedVenue = venue;
	}

	return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];

	self.title = @"Current Location";
	[self.view addSubview:self.mapView];
	[self.view addSubview:self.placemarkView];

	[self barButtonBackEdit];
}

- (void)barButtonBackEdit {
	self.navigationItem.leftBarButtonItem = [self backbutton];
	self.navigationItem.rightBarButtonItem = [self barButtonItemWithTitle:@"Edit" action:@selector(editButtonAction)];
}

- (void)barButtonDone {
	self.navigationItem.leftBarButtonItem = nil;
	self.navigationItem.rightBarButtonItem = [self blackBarButtonItemWithTitle:@"Done" action:@selector(doneButtonAction)];
}

- (void)barButtonCancelSave {
	self.navigationItem.leftBarButtonItem = [self barButtonItemWithTitle:@"Cancel" action:@selector(cancelButtonAction)];
	self.navigationItem.rightBarButtonItem = [self blackBarButtonItemWithTitle:@"Save" action:@selector(saveButtonAction)];
}

- (void)editButtonAction {
	[self.view addSubview:self.searchView];
	[self getVenuesForLocation:_lastKnownLocation query:_searchField.text ];

	[self barButtonDone];
}

- (void)cancelButtonAction {
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)saveButtonAction {
	[_delegate locationSelectedWithVenue:_selectedVenue];
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)doneButtonAction {
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)backButtonAction {
	[self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -- Oerride UIViewController

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];

	[self.view addSubview:self.mapView];
	[self.view addSubview:self.placemarkView];

	firstUpdate = YES;

	if (_selectedVenue) {
		self.nearbyVenues = @[_selectedVenue];
		[self proccessAnnotations];
		[self updatePlacemarkViewWithVenue:_selectedVenue];

		CLLocation *newLocation = [[CLLocation alloc] initWithLatitude:_selectedVenue.coordinate.latitude longitude:_selectedVenue.coordinate.longitude];
		_lastKnownLocation = newLocation;
		[self setupMapForLocation:newLocation animated:NO ];
	} else {
		[self.locationManager startUpdatingLocation];

		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(keyboardWillShow:)
													 name:UIKeyboardWillShowNotification
												   object:nil];

		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(keyboardWillHide:)
													 name:UIKeyboardWillHideNotification
												   object:nil];
	}
}

- (void)keyboardHeightFromNotification:(NSNotification *)notification {
	NSValue *keyboardFrameValue = [[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey];
	CGRect keyboardFrame = [keyboardFrameValue CGRectValue];
	keyboardHeight = keyboardFrame.size.height;
	FNLOG(@"%f", keyboardHeight);
}

- (void)keyboardWillShow:(NSNotification *) notification {
	[self keyboardHeightFromNotification:notification];

	if (tableViewVisible) {
		[UIView animateWithDuration:0.3 animations:^{
			CGRect frame = self.tableViewBackgroundView.frame;
			frame.origin.y -= keyboardHeight;
			_tableViewBackgroundView.frame = frame;
		}];
	}
}

- (void)keyboardWillHide:(NSNotification *) notification {
	if (tableViewVisible) {
		[UIView animateWithDuration:0.3 animations:^{
			CGRect frame = self.tableViewBackgroundView.frame;
			frame.origin.y += keyboardHeight;
			_tableViewBackgroundView.frame = frame;
		} completion:^(BOOL finished) {
			if (hideTableView) {
				hideTableView = NO;
				[self dismissTableView];
			}
		}];
	}
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];

	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (UIView *)searchView {
	if (nil == _searchView) {
		CGRect frame = self.view.bounds;
		frame.origin.x += 10.0;
		frame.origin.y += 10.0;
		frame.size.width -= 20.0;
		frame.size.height = 44.0;
		A3PlacemarkBackgroundView *backgroundView = [[A3PlacemarkBackgroundView alloc] initWithFrame:frame];
		frame = backgroundView.bounds;
		frame.origin.x += 10.0;
		frame.size.width -= 15.0;
		_searchField = [[UITextField alloc] initWithFrame:frame];
		_searchField.placeholder = @"Search";
		_searchField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
		NSString *path = [[NSBundle mainBundle] pathForResource:@"search" ofType:@"png"];
		UIImage *searchIcon = [UIImage imageWithContentsOfFile:path];
		UIImageView *leftView = [[UIImageView alloc] initWithImage:searchIcon];
		_searchField.leftView = leftView;
		_searchField.leftViewMode = UITextFieldViewModeAlways;
		_searchField.clearButtonMode = UITextFieldViewModeWhileEditing;
		[_searchField addTarget:self action:@selector(searchFieldValueChanged:) forControlEvents:UIControlEventEditingChanged];
		[backgroundView addSubview:_searchField];
		_searchView = backgroundView;
	}
	return _searchView;
}

- (MKMapView *)mapView {
	if (nil == _mapView) {
		_mapView = [[MKMapView alloc] initWithFrame:self.view.bounds];
		_mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
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

- (UIBarButtonItem *)backbutton {
	NIKFontAwesomeIconFactory *factory = [NIKFontAwesomeIconFactory buttonIconFactory];

	UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
	button.frame = CGRectMake(0.0, 0.0, 32.0, 32.0);
	[button setImage:[factory createImageForIcon:NIKFontAwesomeIconArrowLeft] forState:UIControlStateNormal];
	[button addTarget:self action:@selector(backButtonAction) forControlEvents:UIControlEventTouchUpInside];
	UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
	return barButtonItem;
}

#pragma mark -- CLLocation delegate

-(void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
	FNLOG(@"%@", newLocation);
	[self setupMapForLocation:newLocation animated:YES ];
	[_locationManager stopUpdatingLocation];

	_lastKnownLocation = newLocation;
	if (firstUpdate) {
		firstUpdate = NO;
		[Foursquare2 searchVenuesNearByLatitude:@(newLocation.coordinate.latitude)
									  longitude:@(newLocation.coordinate.longitude)
									 accuracyLL:nil
									   altitude:nil
									accuracyAlt:nil
										  query:nil
										  limit:@1
										 intent:intentCheckin
										 radius:@(500)
									   callback:^(BOOL success, id result) {
										   if (success) {
											   NSDictionary *dic = result;
											   NSArray *venues = [dic valueForKeyPath:@"response.venues"];
											   FSConverter *converter = [[FSConverter alloc] init];
											   self.nearbyVenues = [converter convertToObjects:venues];
											   [self proccessAnnotations];
											   [self updatePlacemarkViewWithVenue:[_nearbyVenues objectAtIndex:0]];
										   }
									   }];
	}
}

- (void)updatePlacemarkView:(MKPlacemark *)placemark {
	self.placemarkView.hidden = NO;
	self.placemarkView.nameLabel.text = placemark.name;
	self.placemarkView.addressLabel1.text = [NSString combineString:placemark.subThoroughfare withString:placemark.thoroughfare];
	self.placemarkView.addressLabel2.text = [NSString combineString:[NSString combineString:placemark.subAdministrativeArea withString:placemark.administrativeArea] withString:placemark.postalCode];
	self.placemarkView.addressLabel3.text = placemark.country;
	[self.placemarkView setNeedsLayout];
	FNLOG(@"%@", placemark);
}

- (void)updatePlacemarkViewWithVenue:(FSVenue *)venue {
	self.placemarkView.hidden = NO;
	self.placemarkView.nameLabel.text = venue.name;
	self.placemarkView.addressLabel1.text = venue.location.address1;
	self.placemarkView.addressLabel2.text = venue.location.address2;
	self.placemarkView.addressLabel3.text = venue.location.address3;
	self.placemarkView.contactLabel.text = venue.contact;
	[self.placemarkView setNeedsLayout];
}

- (void)setupMapForLocation:(CLLocation *)newLocation animated:(BOOL)animated {
	MKCoordinateRegion region;
	MKCoordinateSpan span;
	span.latitudeDelta = 0.003;
	span.longitudeDelta = 0.003;
	CLLocationCoordinate2D location;
	location.latitude = newLocation.coordinate.latitude;
	location.longitude = newLocation.coordinate.longitude;
	region.span = span;
	region.center = location;
	[self.mapView setRegion:region animated:animated];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
	if ([annotation isKindOfClass:[MKUserLocation class]])
		return nil;

	static NSString *identifier = @"A3MapViewAnnotation";

	MKPinAnnotationView *annotationView = (MKPinAnnotationView *) [mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
	if (nil == annotationView) {
		annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
		annotationView.draggable = YES;
	}
	if ([annotation respondsToSelector:@selector(title)] && [annotation title]) {
		annotationView.canShowCallout = YES;
	}
	annotationView.animatesDrop = YES;

	return annotationView;
}

- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view {
	[self barButtonBackEdit];
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
	FNLOG();

	if ([view.annotation isKindOfClass:[FSVenue class]]) {
		_selectedVenue = (FSVenue *) view.annotation;
		[self updatePlacemarkViewWithVenue:(FSVenue *) view.annotation];
		if ([_searchField isFirstResponder]) {
			[_searchField resignFirstResponder];
			hideTableView = YES;
		} else {
			[self dismissTableView];
		}
	}

	[_searchView removeFromSuperview];

	[self barButtonCancelSave];
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)annotationView didChangeDragState:(MKAnnotationViewDragState)newState
	  fromOldState:(MKAnnotationViewDragState)oldState
{
	if (newState == MKAnnotationViewDragStateEnding)
	{
		CLLocationCoordinate2D droppedAt = annotationView.annotation.coordinate;
		NSLog(@"dropped at %f,%f", droppedAt.latitude, droppedAt.longitude);

		_lastKnownLocation = [[CLLocation alloc] initWithLatitude:droppedAt.latitude longitude:droppedAt.longitude];
		[Foursquare2 searchVenuesNearByLatitude:@(droppedAt.latitude)
									  longitude:@(droppedAt.longitude)
									 accuracyLL:nil
									   altitude:nil
									accuracyAlt:nil
										  query:[_searchView superview] != nil ? _searchField.text : nil
										  limit:nil
										 intent:intentCheckin
										 radius:@(500)
									   callback:^(BOOL success, id result) {
										   if (success) {
											   NSDictionary *dic = result;
											   NSArray *venues = [dic valueForKeyPath:@"response.venues"];
											   FSConverter *converter = [[FSConverter alloc] init];
											   self.nearbyVenues = [converter convertToObjects:venues];
											   [self proccessAnnotations];
											   [self updatePlacemarkViewWithVenue:[_nearbyVenues objectAtIndex:0]];
										   }
									   }];
		[self barButtonBackEdit];
	}
}

#pragma mark -- TextField delegate for searchTextField
- (void)searchFieldValueChanged:(UITextField *)textField {
	FNLOG();
	[self getVenuesForLocation:_lastKnownLocation query:textField.text];
}

#pragma mark -- Foursquare search

- (void)getVenuesForLocation:(CLLocation *)location query:(NSString *)query {
	FNLOG(@"%@", location);
	[Foursquare2 searchVenuesNearByLatitude:@(location.coordinate.latitude)
								  longitude:@(location.coordinate.longitude)
								 accuracyLL:nil
								   altitude:nil
								accuracyAlt:nil
									  query:query
									  limit:nil
									 intent:intentCheckin
									 radius:@(500)
								   callback:^(BOOL success, id result) {
									   if (success) {
										   NSDictionary *dic = result;
										   NSArray *venues = [dic valueForKeyPath:@"response.venues"];
										   FSConverter *converter = [[FSConverter alloc] init];
										   self.nearbyVenues = [converter convertToObjects:venues];
										   [self.tableView reloadData];
										   [self proccessAnnotations];
										   if ([self.nearbyVenues count]) {
											   [self presentTableView];
											   FSVenue *venue = [_nearbyVenues objectAtIndex:0];
											   CLLocation *newLocation = [[CLLocation alloc] initWithLatitude:venue.location.coordinate.latitude longitude:venue.location.coordinate.longitude];
											   [self setupMapForLocation:newLocation animated:YES ];
										   } else {
											   [self dismissTableView];
										   }
									   }
								   }];
}

- (void)presentTableView {
	tableViewVisible = YES;
	if (nil == _tableViewBackgroundView) {
		[self.view addSubview:self.tableViewBackgroundView];
	}
	if (_tableViewBackgroundView.frame.origin.y != CGRectGetMaxY(self.view.bounds)) return;
	[UIView animateWithDuration:0.3 animations:^{
		CGRect frame = self.tableViewBackgroundView.frame;
		frame.origin.y -= frame.size.height;
		self.tableViewBackgroundView.frame = frame;
	}];
}

- (void)dismissTableView {
	tableViewVisible = NO;
	if (_tableViewBackgroundView.frame.origin.y != (CGRectGetMaxY(self.view.bounds) - _tableViewBackgroundView.frame.size.height)) return;
	[UIView animateWithDuration:0.3 animations:^{
		CGRect frame = _tableViewBackgroundView.frame;
		frame.origin.y += frame.size.height;
		_tableViewBackgroundView.frame = frame;
	}];
}

- (void)removeAllAnnotationExceptOfCurrentUser
{
	NSMutableArray *annForRemove = [[NSMutableArray alloc] initWithArray:self.mapView.annotations];
	if ([self.mapView.annotations.lastObject isKindOfClass:[MKUserLocation class]]) {
		[annForRemove removeObject:self.mapView.annotations.lastObject];
	}else{
		for (id <MKAnnotation> annot_ in self.mapView.annotations)
		{
			if ([annot_ isKindOfClass:[MKUserLocation class]] ) {
				[annForRemove removeObject:annot_];
				break;
			}
		}
	}


	[self.mapView removeAnnotations:annForRemove];
}

- (void)proccessAnnotations{
	[self removeAllAnnotationExceptOfCurrentUser];
	[self.mapView addAnnotations:self.nearbyVenues];
}

#pragma mark -- TableView

- (UITableView *)tableView {
	if (nil == _tableView) {
		CGRect frame = self.view.bounds;
		frame.origin.y = 1.0;
		frame.size.height = 44.0 * 3.0;
		_tableView = [[UITableView alloc] initWithFrame:frame style:UITableViewStylePlain];
		_tableView.dataSource = self;
		_tableView.delegate = self;
		_tableView.backgroundColor = [UIColor clearColor];
		_tableView.separatorColor = [UIColor colorWithRed:200.0 / 255.0 green:200.0 / 255.0 blue:200.0 / 255.0 alpha:1.0];
	}
	return _tableView;
}

- (UIView *)footer {
	CGRect frame = CGRectMake(0.0, 44.0 * 3.0 + 1.0, CGRectGetWidth(self.view.bounds), 44.0);
	UIView *view = [[UIView alloc] initWithFrame:frame];
	NSString *path = [[NSBundle mainBundle] pathForResource:@"poweredByFoursquare_gray" ofType:@"png"];
	UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:path]];
	frame = imageView.bounds;
	frame.origin.x = 42.0;
	frame.origin.y -= 10.0;
	imageView.frame = frame;
	[view addSubview:imageView];
	return view;
}

- (UIView *)tableViewBackgroundView {
	if (nil == _tableViewBackgroundView) {
		CGRect frame = self.view.bounds;
		frame.origin.y = CGRectGetMaxY(self.view.bounds);
		frame.size.height = 44.0 * 4.0 + 1.0;
		_tableViewBackgroundView = [[UIView alloc] initWithFrame:frame];
		_tableViewBackgroundView.layer.borderColor = [UIColor colorWithRed:200.0 / 255.0 green:200.0 / 255.0 blue:200.0 / 255.0 alpha:1.0].CGColor;
		_tableViewBackgroundView.layer.borderWidth = 1.0;
		_tableViewBackgroundView.backgroundColor = [UIColor colorWithRed:246.0 / 255.0 green:246.0 / 255.0 blue:246.0 / 255.0 alpha:1.0];
		[_tableViewBackgroundView addSubview:self.tableView];
		[_tableViewBackgroundView addSubview:self.footer];
	}
	return _tableViewBackgroundView;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return self.nearbyVenues.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
	if (self.nearbyVenues.count) {
		return 1;
	}
	return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *CellIdentifier = @"Cell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
		cell.textLabel.font = [UIFont boldSystemFontOfSize:12];
		cell.detailTextLabel.font = [UIFont systemFontOfSize:12];
		cell.detailTextLabel.textColor = [UIColor lightGrayColor];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}
	cell.textLabel.text = [self.nearbyVenues[indexPath.row] name];
	FSVenue *venue = self.nearbyVenues[indexPath.row];
	if (venue.location.address) {
		cell.detailTextLabel.text = [NSString stringWithFormat:@"%@m, %@",
															   venue.location.distance,
															   venue.location.address];
	}else{
		cell.detailTextLabel.text = [NSString stringWithFormat:@"%@m",
															   venue.location.distance];
	}

	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];

	[_searchView removeFromSuperview];

	if ([_searchField isFirstResponder]) {
		[_searchField resignFirstResponder];
		hideTableView = YES;
	} else {
		[self dismissTableView];
	}

	FSVenue *venue = [self.nearbyVenues objectAtIndex:indexPath.row];
	[self updatePlacemarkViewWithVenue:venue];
	_selectedVenue = venue;

	self.nearbyVenues = @[venue];
	[self proccessAnnotations];

	CLLocation *newLocation = [[CLLocation alloc] initWithLatitude:venue.coordinate.latitude longitude:venue.coordinate.longitude];
	[self setupMapForLocation:newLocation animated:YES ];

	[self barButtonCancelSave];
}

@end
