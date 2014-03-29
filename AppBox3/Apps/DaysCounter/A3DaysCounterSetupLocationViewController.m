//
//  A3DaysCounterSetupLocationViewController.m
//  A3TeamWork
//
//  Created by coanyaa on 13. 10. 18..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3DaysCounterSetupLocationViewController.h"
#import "UIViewController+A3Addition.h"
#import "UIViewController+A3AppCategory.h"
#import "A3DaysCounterDefine.h"
#import "A3DaysCounterModelManager.h"
#import "A3LocationPlacemarkView.h"
#import "FSVenue.h"
#import "common.h"
#import "A3PlacemarkBackgroundView.h"
#import "Foursquare2.h"
#import "FSConverter.h"
#import "NSString+conversion.h"
#import "SFKImage.h"
#import "A3DaysCounterLocationDetailViewController.h"
#import "A3DaysCounterLocationPopupViewController.h"
#import <AddressBookUI/AddressBookUI.h>


@interface A3DaysCounterSetupLocationViewController ()
@property (nonatomic, strong) A3LocationPlacemarkView *placemarkView;
@property (nonatomic, strong) NSArray *nearbyVenues;
@property (strong, nonatomic) NSString *searchText;
@property (strong, nonatomic) UIImage *searchIcon;
@property (strong, nonatomic) UIPopoverController *popoverVC;
@property (strong, nonatomic) CLPlacemark *changedPlace;
@property (assign, nonatomic) CLLocationCoordinate2D searchCenterCoord;


- (A3LocationPlacemarkView *)placemarkView;
- (void)removeAllAnnotationExceptOfCurrentUser;
- (void)proccessAnnotations;
- (void)updatePlacemarkViewWithVenue:(FSVenue *)venue;
- (void)showSearchResultView;
- (void)hideSearchResultView;
- (BOOL)isSearchResultShow;
@end

@implementation A3DaysCounterSetupLocationViewController
{
    BOOL _initializedLocale;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"Location";
    self.navigationItem.titleView = self.searchBarBaseView;
    [self setAutomaticallyAdjustsScrollViewInsets:NO];
    [self makeBackButtonEmptyArrow];
    [self.infoTableView setTableFooterView:_tableFooterView];
    self.searchIcon = [[UIImage imageNamed:@"search"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    
    _currentLocationButton.layer.backgroundColor = [[UIColor whiteColor] CGColor];
    _currentLocationButton.layer.borderWidth = 1.0;
    _currentLocationButton.layer.borderColor = [[UIColor colorWithRed:236.0/255.0 green:236.0/255.0 blue:236.0/255.0 alpha:1.0] CGColor];
    _currentLocationButton.layer.cornerRadius = 6.0;
    _currentLocationButton.layer.masksToBounds = YES;
    
    [SFKImage setDefaultFont:[UIFont fontWithName:@"appbox" size:18.0]];
	[SFKImage setDefaultColor:[UIColor blackColor]];
    UIImage *image = [SFKImage imageNamed:@"k"];
    [_currentLocationButton setImage:image forState:UIControlStateNormal];
    
    [Foursquare2 initialize];
    [Foursquare2 setupFoursquareWithClientId:FOURSQUARE_CLIENTID
                                      secret:FOURSQUARE_CLIENTSECRET
                                 callbackURL:FOURSQUARE_REDIRECTURI];
    //    [self.searchDisplayController setActive:NO];
    
//    [self.infoTableView addSubview:self.mapView];
    self.mapView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin;
    self.infoTableView.contentInset = UIEdgeInsetsMake(IS_IPHONE ? 318 : 477, 0, 0, 0);
    self.mapViewHeightConst.constant = IS_IPHONE ? 318 : 477;
}

//-(void)viewWillLayoutSubviews {
//    [super viewWillLayoutSubviews];
//
//    self.infoTableView.contentInset = UIEdgeInsetsMake(300, 0, 0, 0);
////    self.infoTableView.contentOffset = CGPointMake(0, -300);
////    self.mapView.frame = CGRectMake(0, CGRectGetHeight(self.navigationController.navigationBar.frame), CGRectGetWidth(self.infoTableView.frame), 300);
//}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self hideCurrentLocationTableView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    self.searchIcon = nil;
}

#pragma makr - Methods

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

- (void)removeAllAnnotationExceptOfCurrentUser
{
	NSMutableArray *annForRemove = [[NSMutableArray alloc] initWithArray:self.mapView.annotations];
	if ([self.mapView.annotations.lastObject isKindOfClass:[MKUserLocation class]]) {
		[annForRemove removeObject:self.mapView.annotations.lastObject];
	} else {
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

- (void)proccessAnnotations
{
	[self removeAllAnnotationExceptOfCurrentUser];
	[self.mapView addAnnotations:self.nearbyVenues];
}

- (void)updatePlacemarkViewWithVenue:(FSVenue *)venue
{
	self.placemarkView.hidden = NO;
	self.placemarkView.nameLabel.text = venue.name;
	self.placemarkView.addressLabel1.text = venue.location.address1;
	self.placemarkView.addressLabel2.text = venue.location.address2;
	self.placemarkView.addressLabel3.text = venue.location.address3;
	self.placemarkView.contactLabel.text = venue.contact;
	[self.placemarkView setNeedsLayout];
}

- (void)showSearchResultView
{
    if ( ![_searchResultBaseView isDescendantOfView:self.view] ) {
        [self hideCurrentLocationTableView];
        
        //CGFloat contentHeight = _mapView.frame.size.height - 64.0;
        CGFloat contentHeight = CGRectGetHeight(self.view.frame) - 64.0;
        _searchResultBaseView.frame = CGRectMake(_infoTableView.frame.origin.x,-(contentHeight+64.0), _mapView.frame.size.width, contentHeight);
        [self.view addSubview:_searchResultBaseView];
        [UIView animateWithDuration:0.35 animations:^{
            _searchResultBaseView.frame = CGRectMake(_searchResultBaseView.frame.origin.x, 64.0, _searchResultBaseView.frame.size.width, contentHeight);
        } completion:^(BOOL finished) {
            [_searchResultsTableView reloadData];
        }];
    }
}

- (void)hideSearchResultView
{
    if ( [_searchResultBaseView isDescendantOfView:self.view] ) {
        [_searchBar resignFirstResponder];
        [UIView animateWithDuration:0.35 animations:^{
            _searchResultBaseView.frame = CGRectMake(_searchResultBaseView.frame.origin.x, -_searchResultBaseView.frame.size.height, _searchResultBaseView.frame.size.width, _searchResultBaseView.frame.size.height);
        } completion:^(BOOL finished) {
            [_searchResultBaseView removeFromSuperview];
        }];
    }
}

- (BOOL)isSearchResultShow
{
    return [_searchResultBaseView isDescendantOfView:self.view];
}

- (void)forsqareSearchCoordinate:(CLLocationCoordinate2D)coord radius:(CGFloat)radius searchString:(NSString*)searchString completion:(void (^)(void))completionBlock
{
    [Foursquare2 venueSearchNearByLatitude:@(coord.latitude)
                                 longitude:@(coord.longitude)
                                     query:searchString
                                     limit:nil
                                    intent:intentCheckin
                                    radius:@(radius)
                                categoryId:nil
                                  callback:^(BOOL success, id result) {
                                      if (success) {
                                          isLoading = NO;
                                          NSDictionary *dic = result;
                                          NSArray *venues = [dic valueForKeyPath:@"response.venues"];
                                          FSConverter *converter = [[FSConverter alloc] init];
                                          self.nearbyVenues = [converter convertToObjects:venues];
                                          [self proccessAnnotations];
                                          [_infoTableView reloadData];
                                          //            [self.searchDisplayController.searchResultsTableView reloadData];
                                          
                                          if ( [self.nearbyVenues count] > 2 ) {
                                              _tableViewHeightConstraint.constant = 229.0;
                                          }
                                          else {
                                              _tableViewHeightConstraint.constant = 88.0;
                                          }
                                          
                                          if (completionBlock) {
                                              completionBlock();
                                          }
                                          
                                          [UIView animateWithDuration:0.3 animations:^{
                                              [self.view layoutIfNeeded];
                                          }];
                                      }
                                      else {
                                          NSLog(@"장소 검색 실패.");
                                      }
                                  }];
}

- (void)moveToLocationDetailWithItem:(FSVenue *)item
{
    A3DaysCounterLocationDetailViewController *viewCtrl = [[A3DaysCounterLocationDetailViewController alloc] initWithNibName:@"A3DaysCounterLocationDetailViewController" bundle:nil];
    viewCtrl.eventModel = self.eventModel;
    viewCtrl.locationItem = item;
    viewCtrl.isEditMode = NO;
    [self.navigationController pushViewController:viewCtrl animated:YES];
}


#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ( tableView == _currentLocationTableView )
        return 1;
    
    //    if ( [self.searchDisplayController isActive] && isInputing )
    //        return 0;
    
    //return ([self.nearbyVenues count] > 0) ? [self.nearbyVenues count] + (tableView != _infoTableView ? 1 : 0) : (tableView == _infoTableView ? 1 : 1) ;
    if ([self.nearbyVenues count] > 0) {
        if (tableView != _infoTableView) {
            return [self.nearbyVenues count] + 1;
        }
        else {
            return [self.nearbyVenues count];
        }
    }
    else {
        if (tableView == _infoTableView) {
            return 1;
        }
        else {
            return 1;
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.01;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    
    if ( tableView == _currentLocationTableView ) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"currentLocationCell"];
        if ( cell == nil ) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"currentLocationCell"];
            cell.indentationWidth = (IS_IPHONE ? 15.0 : 28.0) - tableView.separatorInset.left;
            cell.textLabel.textColor = [UIColor colorWithRed:0.0 green:105.0/255.0 blue:1.0 alpha:1.0];
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        
        if (self.changedPlace) {
            cell.textLabel.text = [[[A3DaysCounterModelManager sharedManager] addressFromPlacemark:self.changedPlace] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            
            //            NSString *locationText = [[[A3DaysCounterModelManager sharedManager] addressFromPlacemark:self.changedPlace] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            //            NSRange matchRange = [locationText rangeOfString:self.searchText options:NSCaseInsensitiveSearch];
            //            NSMutableAttributedString *attrText = [[NSMutableAttributedString alloc] initWithString:locationText];
            //            [attrText addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:17] range:matchRange];
            //            cell.textLabel.attributedText = attrText;
        }
        else {
            cell.textLabel.text = @"Current Location";
        }
        
        return cell;
    }
    
    static NSString *cellID = @"infoCell";
    cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    
    if ( cell == nil ) {
        if ( IS_IPHONE ) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellID];
        }
        else {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellID];
        }
        cell.textLabel.font = [UIFont systemFontOfSize:17.0];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:14.0];
        cell.indentationWidth = (IS_IPHONE ? 15.0 : 28.0)-tableView.separatorInset.left;
    }
    
    
    if ( tableView != _infoTableView && (indexPath.row >= [_nearbyVenues count]) ) {
        cell.textLabel.font = [UIFont boldSystemFontOfSize:17.0];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:14.0];
        
        cell.textLabel.text = @"Add this place?";
        cell.detailTextLabel.text = @"We Couldn't find that";
        cell.textLabel.textColor = [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0];
        cell.detailTextLabel.textColor = [UIColor colorWithRed:142.0/255.0 green:142.0/255.0 blue:147.0/255.0 alpha:1.0];
    }
    else if ( [self.nearbyVenues count] < 1 ) {
        cell.textLabel.text = (isLoading ? @"Loading locations...." : @"");
        cell.detailTextLabel.text = @"";
        cell.textLabel.textColor = [UIColor blackColor];
    }
    else {
        FSVenue *item = [self.nearbyVenues objectAtIndex:indexPath.row];
        
        cell.textLabel.text = item.name;
        cell.detailTextLabel.text = [[A3DaysCounterModelManager sharedManager] addressFromVenue:item isDetail:NO];
        cell.textLabel.textColor = [UIColor blackColor];
        cell.detailTextLabel.textColor = [UIColor colorWithRed:123.0/255.0 green:123.0/255.0 blue:123.0/255.0 alpha:1.0];
        
        if (self.searchText && [self.searchText length] > 0) {
            NSRange matchRange = [cell.textLabel.text rangeOfString:self.searchText options:NSCaseInsensitiveSearch];
            if (matchRange.location != NSNotFound) {
                NSMutableAttributedString *attrText = [[NSMutableAttributedString alloc] initWithAttributedString:cell.textLabel.attributedText];
                [attrText addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:17] range:matchRange];
                cell.textLabel.attributedText = attrText;
            }
        }
    }
    //    if ( [self.nearbyVenues count] > 0 )
    //        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    //    else
    //        cell.accessoryType = UITableViewCellAccessoryNone;
    
    if ( tableView != _infoTableView ) {
        cell.imageView.image = self.searchIcon;
        cell.imageView.tintColor = [UIColor lightGrayColor];
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ( tableView == _infoTableView )
        cell.backgroundColor = [UIColor colorWithRed:247.0/255.0 green:247.0/255.0 blue:247.0/255.0 alpha:0.95];
    else if ( tableView == _currentLocationTableView )
        cell.backgroundColor = [UIColor colorWithRed:243.0/255.0 green:242.0/255.0 blue:238.0/255.0 alpha:1.0];
    else
        cell.backgroundColor = [UIColor whiteColor];
}

- (NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ( tableView == _currentLocationTableView ) {
        [self hideCurrentLocationTableView];
        A3DaysCounterChangeLocationViewController *viewCtrl = [[A3DaysCounterChangeLocationViewController alloc] initWithNibName:@"A3DaysCounterChangeLocationViewController" bundle:nil];
        viewCtrl.delegate = self;
        [self.navigationController pushViewController:viewCtrl animated:YES];
        return;
    }
    
    if ( tableView == _infoTableView && [self.nearbyVenues count] < 1 ) {
        return;
    }
    else if ( tableView != _infoTableView && (indexPath.row >= [_nearbyVenues count]) ) {
        // 이 위치를 추가하는 화면으로 이동
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:[NSString stringWithFormat:@"Create %@",self.searchText], nil];
        [actionSheet showInView:self.view];
    }
    else {
        //        if ( [self.searchDisplayController isActive] ) {
        //            [self.searchDisplayController setActive:NO animated:YES];
        //        }
        FSVenue *item = [self.nearbyVenues objectAtIndex:indexPath.row];
        //        [self moveToLocationDetailWithItem:item];
        NSMutableDictionary *locItem = [[A3DaysCounterModelManager sharedManager] emptyEventLocationModel];
        [locItem setObject:[_eventModel objectForKey:EventItem_ID] forKey:EventItem_ID];
        [locItem setObject:@(item.location.coordinate.latitude) forKey:EventItem_Latitude];
        [locItem setObject:@(item.location.coordinate.longitude) forKey:EventItem_Longitude];
        [locItem setObject:item.name forKey:EventItem_LocationName];
        [locItem setObject:([item.location.country length] > 0 ? item.location.country : @"") forKey:EventItem_Country];
        [locItem setObject:([item.location.state length] > 0 ? item.location.state : @"") forKey:EventItem_State];
        [locItem setObject:([item.location.city length] > 0 ? item.location.city : @"") forKey:EventItem_City];
        [locItem setObject:([item.location.address length] > 0 ? item.location.address : @"") forKey:EventItem_Address];
        [locItem setObject:([item.contact length] > 0 ? item.contact : @"") forKey:EventItem_Contact];
        [_eventModel setObject:locItem forKey:EventItem_Location];
        [tableView reloadData];
        //        [self.navigationController popViewControllerAnimated:YES];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    //    [_mapView showAnnotations:@[item] animated:YES];
    //    [_mapView selectAnnotation:item animated:YES];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == _infoTableView) {
        if (scrollView.contentOffset.y > 0) {
            self.mapViewHeightConst.constant = 0;
            self.currentLocationButtonTopConst.constant = -CGRectGetHeight(self.currentLocationButton.frame);
        }
        else {
            CGFloat heightOffset = fabs(scrollView.contentOffset.y);
            self.mapViewHeightConst.constant = heightOffset < 0 ? 0 : heightOffset;
            self.currentLocationButtonTopConst.constant = heightOffset - CGRectGetHeight(self.currentLocationButton.frame);
        }
    }
}

- (void)registerVenueForPlacemark:(NSArray*)placemarks
{
    CLPlacemark *mark = [placemarks objectAtIndex:0];
    NSDictionary *addressDict = mark.addressDictionary;
    // 포스퀘어에 해당 지점을 등록하고,
    [Foursquare2 venueAddWithName:self.searchText address:[addressDict objectForKey:(NSString*)kABPersonAddressStreetKey] crossStreet:nil city:[addressDict objectForKey:(NSString*)kABPersonAddressCityKey] state:[addressDict objectForKey:(NSString*)kABPersonAddressStateKey] zip:nil phone:nil twitter:nil description:nil latitude:@(_mapView.userLocation.coordinate.latitude) longitude:@(_mapView.userLocation.coordinate.longitude) primaryCategoryId:nil callback:^(BOOL success, id result) {
        // 등록화면으로 이동
        //        NSLog(@"%s %@",__FUNCTION__,result);
        if ( success ) {
            FSVenue *venue = [[FSVenue alloc] init];
            venue.name = self.searchText;
            venue.contact = @"";
            venue.location.coordinate = _mapView.userLocation.coordinate;
            venue.location.address = [addressDict objectForKey:(NSString*)kABPersonAddressStreetKey];
            venue.location.city = [addressDict objectForKey:(NSString*)kABPersonAddressCityKey];
            venue.location.state = [addressDict objectForKey:(NSString*)kABPersonAddressStateKey];
            venue.location.country = [addressDict objectForKey:(NSString*)kABPersonAddressCountryKey];
            [self moveToLocationDetailWithItem:venue];
        }
    }];
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if ( buttonIndex == actionSheet.firstOtherButtonIndex ) {
        CLGeocoder *geoCoder = [[CLGeocoder alloc] init];
        CLLocation *location = [[CLLocation alloc] initWithLatitude:_mapView.userLocation.coordinate.latitude longitude:_mapView.userLocation.coordinate.longitude];
        [geoCoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
            if ( error == nil ) {
                if ( [placemarks count] < 1 ) {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"현재 위치에 대한 정보를 가져올 수 없습니다." delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil];
                    [alertView show];
                    return;
                    
                }
                if (![Foursquare2 isAuthorized] ) {
                    [Foursquare2 authorizeWithCallback:^(BOOL success, id result) {
                        if ( success ) {
                            [self registerVenueForPlacemark:placemarks];
                        }
                    }];
                }
                else {
                    [self registerVenueForPlacemark:placemarks];
                }
            }
        }];
        geoCoder = nil;
    }
}

#pragma mark - UIMapViewDelegate
- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    if (self.changedPlace) {
        return;
    }
    if (_initializedLocale) {
        return;
    }
    
    CLLocationCoordinate2D coord = userLocation.coordinate;
    [mapView setRegion:MKCoordinateRegionMakeWithDistance(coord, 2000, 2000) animated:YES];
    isLoading = YES;
    [_infoTableView reloadData];
    self.searchCenterCoord = coord;
    [self forsqareSearchCoordinate:_searchCenterCoord radius:20000.0 searchString:nil completion:nil];
    
    _initializedLocale = YES;
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
	if ([annotation isKindOfClass:[MKUserLocation class]]) {
		return nil;
    }
    
	static NSString *identifier = @"A3MapViewAnnotation";
    
	MKPinAnnotationView *annotationView = (MKPinAnnotationView *) [mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
	if (nil == annotationView) {
		annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
		annotationView.draggable = YES;
        annotationView.canShowCallout = YES;
        annotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        
	}
	if ([annotation respondsToSelector:@selector(title)] && [annotation title]) {
		annotationView.canShowCallout = YES;
	}
	annotationView.animatesDrop = YES;
    
	return annotationView;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    [self moveToLocationDetailWithItem:view.annotation];
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    NSInteger index = [self.nearbyVenues indexOfObject:view.annotation];
    if ( index != NSNotFound ) {
        [_infoTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
    
    if ( IS_IPAD ) {
        [mapView deselectAnnotation:view.annotation animated:NO];
        
        A3DaysCounterLocationPopupViewController *viewCtrl = [[A3DaysCounterLocationPopupViewController alloc] initWithNibName:@"A3DaysCounterLocationPopupViewController" bundle:nil];
        viewCtrl.locationItem = view.annotation;
        
        UINavigationController *navCtrl = [[UINavigationController alloc] initWithRootViewController:viewCtrl];
        CGSize size = viewCtrl.view.frame.size;
        
        self.popoverVC = [[UIPopoverController alloc] initWithContentViewController:navCtrl];
        self.popoverVC.delegate = self;
        viewCtrl.popoverVC = self.popoverVC;
        [self.popoverVC setPopoverContentSize:CGSizeMake(size.width, size.height + 44.0) animated:NO];
        [self.popoverVC presentPopoverFromRect:view.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionRight animated:YES];
    }
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)annotationView didChangeDragState:(MKAnnotationViewDragState)newState
   fromOldState:(MKAnnotationViewDragState)oldState
{
	if (newState == MKAnnotationViewDragStateEnding)
	{
		CLLocationCoordinate2D droppedAt = annotationView.annotation.coordinate;
        [self forsqareSearchCoordinate:droppedAt radius:20000.0 searchString:self.searchText completion:nil];
    }
}

#pragma mark - UIPopoverControllerDelegate
- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    self.popoverVC = nil;
}

- (void)showCurrentLocationTableView
{
    if ( ![_currentLocationView isDescendantOfView:self.navigationController.view]) {
        _currentLocationView.frame = CGRectMake(0, self.navigationController.navigationBar.frame.size.height + 20.0, _currentLocationView.frame.size.width, _currentLocationView.frame.size.height);
        [self.navigationController.view insertSubview:_currentLocationView belowSubview:self.navigationController.navigationBar];
        [_currentLocationTableView reloadData];
        [_currentLocationView makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.navigationController.view.left).with.offset(0.0);
            make.top.equalTo(self.navigationController.navigationBar.bottom).with.offset(0.0);
            make.right.equalTo(self.navigationController.view.right).with.offset(0.0);
            make.height.equalTo(@(_currentLocationView.frame.size.height));
        }];
    }
}

- (void)hideCurrentLocationTableView
{
    if ( [_currentLocationView isDescendantOfView:self.navigationController.view]) {
        [_currentLocationView removeFromSuperview];
    }
}

/*
 #pragma mark - UISearchDisplayDelegate
 - (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption
 {
 NSLog(@"%s",__FUNCTION__);
 return YES;
 }
 
 - (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
 {
 NSLog(@"%s",__FUNCTION__);
 return YES;
 }
 
 - (void)searchDisplayController:(UISearchDisplayController *)controller didHideSearchResultsTableView:(UITableView *)tableView
 {
 
 }
 
 - (void)searchDisplayController:(UISearchDisplayController *)controller didShowSearchResultsTableView:(UITableView *)tableView
 {
 
 }
 
 - (void)searchDisplayController:(UISearchDisplayController *)controller willHideSearchResultsTableView:(UITableView *)tableView
 {
 [self showCurrentLocationTableView];
 }
 
 - (void)searchDisplayController:(UISearchDisplayController *)controller willShowSearchResultsTableView:(UITableView *)tableView
 {
 [self hideCurrentLocationTableView];
 }
 
 - (void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller
 {
 [self hideCurrentLocationTableView];
 }
 */
#pragma mark - UISearchBarDelegate
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    isSearchActive = YES;
    return YES;
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    if ( ![self isSearchResultShow] ) {
        [self showCurrentLocationTableView];
    }
    
    //    [CATransaction begin];
    //    [CATransaction setCompletionBlock:^{
    //        UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
    //                                                                               target:self
    //                                                                               action:nil];
    //        space.width = -20.0;
    //        self.navigationItem.backBarButtonItem = space;
    //        [searchBar setShowsCancelButton:YES animated:YES];
    //        [searchBar sizeToFit];
    //    }];
    //    [self.navigationItem setHidesBackButton:YES animated:YES];
    //    [CATransaction commit];
    [self.navigationItem setHidesBackButton:YES animated:YES];
    [searchBar setShowsCancelButton:YES animated:YES];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    isInputing = NO;
    self.searchText = searchBar.text;
    [searchBar resignFirstResponder];
    [self forsqareSearchCoordinate:_searchCenterCoord radius:20000.0 searchString:searchBar.text completion:^{
        
        //        if ( isSearchActive ) {
        [self showSearchResultView];
        //                if ( [self.nearbyVenues count] < 1 ) {
        //                    _searchResultsTableView.hidden = YES;
        //                    _noResultsView.hidden = NO;
        //                }
        //                else {
        //                    _searchResultsTableView.hidden = NO;
        //                    _noResultsView.hidden = YES;
        //                }
        //        }
    }];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:NO animated:YES];
    [self.navigationItem setHidesBackButton:NO animated:YES];
    
    if ( !isSearchActive ) {
        [self hideSearchResultView];
        [self hideCurrentLocationTableView];
        //        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else {
        isSearchActive = NO;
        [self hideSearchResultView];
        [self hideCurrentLocationTableView];
        self.searchText = nil;
        //        [self forsqareSearchCoordinate:_searchCenterCoord radius:20000.0 searchString:self.searchText completion:nil];
        [searchBar resignFirstResponder];
    }
}

#pragma mark - action method
- (IBAction)moveCurrentLocationAction:(id)sender {
    CLLocationCoordinate2D coord = _mapView.userLocation.coordinate;
    [_mapView setCenterCoordinate:coord animated:YES];
}

#pragma mark - A3DaysCounterChangeLocationViewControllerDelegate
- (void)changeLocationViewController:(A3DaysCounterChangeLocationViewController *)ctrl didSelectLocation:(CLPlacemark *)placemark
{
    [self.searchBar resignFirstResponder];
    _initializedLocale = NO;
    
    if ( placemark == nil ) {
        [self moveCurrentLocationAction:nil];
        self.changedPlace = nil;
        self.searchCenterCoord = _mapView.userLocation.coordinate;
        [self forsqareSearchCoordinate:_mapView.userLocation.coordinate radius:20000.0 searchString:self.searchText completion:nil];
    }
    else {
        self.searchCenterCoord = placemark.location.coordinate;
        self.changedPlace = placemark;
        [_mapView setCenterCoordinate:_searchCenterCoord animated:YES];
        [self forsqareSearchCoordinate:_searchCenterCoord radius:20000.0 searchString:self.searchText completion:nil];
    }
    [self.currentLocationTableView reloadData];
    [ctrl.navigationController popViewControllerAnimated:YES];
}

@end
