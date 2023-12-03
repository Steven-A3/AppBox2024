//
//  A3DaysCounterSetupLocationViewController.m
//  A3TeamWork
//
//  Created by coanyaa on 13. 10. 18..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3DaysCounterSetupLocationViewController.h"
#import "UIViewController+A3Addition.h"
#import "UIViewController+NumberKeyboard.h"
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
#import "A3GradientView.h"
#import "MBProgressHUD.h"
#import "DaysCounterEvent.h"
#import "DaysCounterEventLocation.h"
#import "DaysCounterEvent+extension.h"
#import "UIViewController+tableViewStandardDimension.h"
#import "NSManagedObject+extension.h"
#import "NSManagedObjectContext+extension.h"
#import "A3SyncManager.h"
#import "A3UIDevice.h"
#import "A3UserDefaults+A3Addition.h"

@interface A3DaysCounterSetupLocationViewController () <MBProgressHUDDelegate>
@property (nonatomic, strong) A3LocationPlacemarkView *placemarkView;
@property (nonatomic, strong) NSArray *nearbyVenues;
@property (nonatomic, strong) NSArray *nearbyVenuesOfSearchResults;
@property (strong, nonatomic) NSString *searchText;
@property (strong, nonatomic) UIImage *searchIcon;
@property (strong, nonatomic) UIPopoverController *popoverVC;
@property (strong, nonatomic) CLPlacemark *changedPlace;
@property (assign, nonatomic) CLLocationCoordinate2D searchCenterCoord;
@property (nonatomic) BOOL isInitializedLocation;
@property (nonatomic, strong) A3GradientView *tableViewTopBlurView;
@property (strong, nonatomic) MBProgressHUD *progressHud;
@property (assign, nonatomic) CGPoint infoTableViewOldOffset;
@property (assign, nonatomic) UIEdgeInsets infoTableViewInsetOld;
@end

@implementation A3DaysCounterSetupLocationViewController

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
    self.title = NSLocalizedString(@"Location", @"Location");
    self.navigationItem.titleView = self.searchBarBaseView;
    [self setAutomaticallyAdjustsScrollViewInsets:NO];
    [self makeBackButtonEmptyArrow];
    [self.infoTableView setTableFooterView:_tableFooterView];
    UIView *footerSeparator = [UIView new];
    footerSeparator.backgroundColor = [UIColor colorWithRed:200/255.0 green:200/255.0 blue:200/255.0 alpha:1.0];
    [_tableFooterView addSubview:footerSeparator];
    [footerSeparator makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_tableFooterView.left);
        make.right.equalTo(_tableFooterView.right);
        make.bottom.equalTo(_tableFooterView.top);
        make.height.equalTo(IS_RETINA ? @(0.5) : @(1.0));
    }];
    
    self.searchIcon = [[UIImage imageNamed:@"search"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    
    _currentLocationButton.layer.backgroundColor = [[UIColor whiteColor] CGColor];
    _currentLocationButton.layer.borderWidth = IS_RETINA ? 0.5 : 1.0;
    _currentLocationButton.layer.borderColor = [[UIColor colorWithRed:236.0/255.0 green:236.0/255.0 blue:236.0/255.0 alpha:1.0] CGColor];
    _currentLocationButton.layer.cornerRadius = 6.0;
    _currentLocationButton.layer.masksToBounds = YES;
    isLoading = YES;
    
    [SFKImage setDefaultFont:[UIFont fontWithName:@"appbox" size:18.0]];
	[SFKImage setDefaultColor:[UIColor blackColor]];
    UIImage *image = [SFKImage imageNamed:@"k"];
    [_currentLocationButton setImage:image forState:UIControlStateNormal];
    
    [Foursquare2 initialize];
    [Foursquare2 setupFoursquareWithClientId:FOURSQUARE_CLIENTID
                                      secret:FOURSQUARE_CLIENTSECRET
                                 callbackURL:FOURSQUARE_REDIRECTURI];

    self.mapView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin;
    self.mapViewHeightConst.constant = CGRectGetHeight(self.infoTableView.frame) - 88;
    self.infoTableView.contentInset = UIEdgeInsetsMake([UIWindow interfaceOrientationIsLandscape] ? (CGRectGetWidth([[UIScreen mainScreen] bounds]) - 88) : (CGRectGetHeight([[UIScreen mainScreen] bounds]) - 88), 0, 0, 0);
    self.infoTableView.separatorInset = A3UITableViewSeparatorInset;
    self.infoTableView.backgroundColor = [UIColor colorWithRed:247.0/255.0 green:247.0/255.0 blue:247.0/255.0 alpha:0.95];
    self.infoTableView.separatorColor = [UIColor colorWithRed:200/255.0 green:200/255.0 blue:200/255.0 alpha:1.0];
    self.searchResultsTableView.separatorColor = [UIColor colorWithRed:200/255.0 green:200/255.0 blue:200/255.0 alpha:1.0];

    [self.view addSubview:self.tableViewTopBlurView];
    [self.tableViewTopBlurView makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.infoTableView.left);
        make.right.equalTo(self.infoTableView.right);
        make.height.equalTo(@5);
        make.bottom.equalTo(self.mapView.bottom);
    }];
    
#ifdef __IPHONE_8_0
    if ([self.currentLocationTableView respondsToSelector:@selector(separatorInset)])
    {
        self.currentLocationTableView.separatorInset = UIEdgeInsetsZero;
    }
#endif

}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];

	if ([self isMovingToParentViewController]) {
        if (![CLLocationManager locationServicesEnabled] || ([CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorizedWhenInUse && [CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorizedAlways)) {
            [self alertLocationDisabled];
        }
	}
	if ([self.navigationController.navigationBar isHidden]) {
		[self.navigationController setNavigationBarHidden:NO animated:NO];
	}
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (self.isMovingFromParentViewController) {
        isSearchActive = NO;
    }
    
    [_searchBar resignFirstResponder];
    [self hideCurrentLocationTableView];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
#ifdef __IPHONE_8_0
	// Ensure self.tableView.separatorInset = UIEdgeInsetsZero is applied correctly in iOS 8
	if ([self.currentLocationTableView respondsToSelector:@selector(layoutMargins)])
	{
		UIEdgeInsets layoutMargins = self.currentLocationTableView.layoutMargins;
		layoutMargins.left = 0;
		self.currentLocationTableView.layoutMargins = layoutMargins;
	}
#endif
}

#ifdef __IPHONE_8_0
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    
    self.infoTableView.contentInset = UIEdgeInsetsMake(size.height - 88, 0, 0, 0);
}
#endif

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    
    self.infoTableView.contentInset = UIEdgeInsetsMake(CGRectGetHeight(self.view.frame) - 88, 0, 0, 0);
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

- (A3GradientView *)tableViewTopBlurView {
    if (!_tableViewTopBlurView) {
        _tableViewTopBlurView = [A3GradientView new];
        _tableViewTopBlurView.gradientColors = @[
                                                 (id) [UIColor colorWithWhite:0.0 alpha:0.0].CGColor,
                                                 (id) [UIColor colorWithWhite:0.0 alpha:0.09].CGColor
                                                 ];
    }
    
    return _tableViewTopBlurView;
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

- (void)reloadMapAnnotations:(NSArray *)annotations
{
	[self removeAllAnnotationExceptOfCurrentUser];
	[self.mapView addAnnotations:annotations];
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

- (void)moveToLocationDetailWithItem:(FSVenue *)item
{
    A3DaysCounterLocationDetailViewController *viewCtrl = [[A3DaysCounterLocationDetailViewController alloc] initWithNibName:@"A3DaysCounterLocationDetailViewController" bundle:nil];
    viewCtrl.eventModel = self.eventModel;
    viewCtrl.sharedManager = _sharedManager;
    viewCtrl.locationItem = item;
    viewCtrl.isEditMode = NO;
    [self.navigationController pushViewController:viewCtrl animated:YES];
}

#pragma mark Search
- (void)initializeSelectedLocation
{
    DaysCounterEventLocation *locationInfo  = [_eventModel location];
    if (!locationInfo) {
        return;
    }
    
    NSNumber *longitude = locationInfo.longitude;
    NSNumber *latitude = locationInfo.latitude;
    NSString *locationName = locationInfo.locationName;
    _searchCenterCoord = CLLocationCoordinate2DMake([latitude doubleValue], [longitude doubleValue]);
    [self.mapView setCenterCoordinate:_searchCenterCoord animated:YES];
    [self.mapView setRegion:MKCoordinateRegionMakeWithDistance(_searchCenterCoord, 500.0, 500.0) animated:YES];
    
    [_infoTableView reloadData];

	self.progressHud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
	self.progressHud.label.text = NSLocalizedString(@"Searching", @"Searching");
	self.progressHud.minShowTime = 2;
	self.progressHud.removeFromSuperViewOnHide = YES;
	__typeof(self) __weak weakSelf = self;
	self.progressHud.completionBlock = ^{
		weakSelf.progressHud = nil;
	};
    
    [self forsqareSearchCoordinate:_searchCenterCoord radius:20000.0 searchString:locationName atTableView:_infoTableView completion:nil];
    
    self.isInitializedLocation = YES;
}

- (void)forsqareSearchCoordinate:(CLLocationCoordinate2D)coord radius:(CGFloat)radius searchString:(NSString*)searchString atTableView:(UITableView *)tableView completion:(void (^)(void))completionBlock
{
    [Foursquare2 venueSearchNearByLatitude:@(coord.latitude)
                                 longitude:@(coord.longitude)
                                     query:searchString
                                     limit:nil
                                    intent:intentCheckin
                                    radius:@(radius)
                                categoryId:nil
                                  callback:^(BOOL success, id result) {
                                      [self.progressHud hideAnimated:YES];
                                      
                                      if (success) {
                                          isLoading = NO;
                                          NSDictionary *dic = result;
                                          NSArray *venues = [dic valueForKeyPath:@"response.venues"];
                                          FSConverter *converter = [[FSConverter alloc] init];
                                          
                                          // 맵 annotation 추가.
                                          if (tableView == _infoTableView) {
                                              self.nearbyVenues = [converter convertToObjects:venues];
                                              [self reloadMapAnnotations:self.nearbyVenues];
                                              [_infoTableView setContentOffset:CGPointMake(0, -(CGRectGetHeight(self.view.frame) - 229)) animated:YES];
                                          }
                                          else if (tableView == _searchResultsTableView) {
                                              self.nearbyVenuesOfSearchResults = [converter convertToObjects:venues];
                                          }
                                          

                                          // 결과 목록 갱신.
                                          [tableView reloadData];
                                          if (tableView == _infoTableView) {
                                              if ( [self.nearbyVenues count] > 2 ) {
                                                  _tableViewHeightConstraint.constant = 229.0;
                                              }
                                              else {
                                                  _tableViewHeightConstraint.constant = 88.0;
                                              }
                                          }
                                          
                                          if (completionBlock) {
                                              completionBlock();
                                          }
                                          
                                          [UIView animateWithDuration:0.3 animations:^{
                                              [self.view layoutIfNeeded];
                                          }];
                                      }
                                      else {
                                          UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Info", @"Info")
																						  message:NSLocalizedString(@"Places are not available.", nil)
																						 delegate:nil
																				cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
																				otherButtonTitles:nil];
                                          [alert show];
                                          FNLOG(@"장소 검색 실패.");
                                      }
                                  }];
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
        }];
    }
}

#pragma mark - UISearchBarDelegate
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    isSearchActive = YES;

    _infoTableViewOldOffset = _infoTableView.contentOffset;
    _infoTableViewInsetOld = _infoTableView.contentInset;
    
    _infoTableView.contentInset = UIEdgeInsetsMake(CGRectGetHeight(self.view.frame), 0, 0, 0);
    [_infoTableView setContentOffset:CGPointMake(0, -CGRectGetHeight(self.view.frame)) animated:YES];

#ifdef __IPHONE_8_0
	if ([_infoTableView respondsToSelector:@selector(layoutMargins)])
	{
		UIEdgeInsets layoutMargins = _infoTableView.layoutMargins;
		layoutMargins.left = 0;
		_infoTableView.layoutMargins = layoutMargins;
	}
#endif
    
    return YES;
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    if ( ![self isSearchResultShow] ) {
        [self showCurrentLocationTableView];
    }
    
    [searchBar setShowsCancelButton:YES animated:YES];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    
}

-(void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
	[self adjustInfoTableViewInset];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    isInputing = NO;
    self.searchText = searchBar.text;
    [searchBar resignFirstResponder];
    
	self.progressHud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
	self.progressHud.label.text = NSLocalizedString(@"Searching", @"Searching");
	self.progressHud.minShowTime = 2;
	self.progressHud.removeFromSuperViewOnHide = YES;
	__typeof(self) __weak weakSelf = self;
	self.progressHud.completionBlock = ^{
		weakSelf.progressHud = nil;
	};
    
    [self forsqareSearchCoordinate:_searchCenterCoord radius:20000.0 searchString:searchBar.text atTableView:_searchResultsTableView completion:^{
        [self showSearchResultView];
    }];
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
    
    if (tableView == _infoTableView) {
        if ([self.nearbyVenues count] > 0) {
            return [self.nearbyVenues count];
        }
        else {
            return 1;
        }
    }
    else {
        if ([self.nearbyVenuesOfSearchResults count] > 0) {
            return [self.nearbyVenuesOfSearchResults count] + 1;
        }
        else {
            return 1;
        }
    }
}

#pragma mark Cell Related
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    
    if ( tableView == _currentLocationTableView ) {
        cell = [self tableView:tableView cellOfChangeLocationAtIndexPath:indexPath];
        
        if ([cell respondsToSelector:@selector(layoutMargins)])
        {
			UIEdgeInsets layoutMargins = cell.layoutMargins;
			layoutMargins.left = 0;
			cell.layoutMargins = layoutMargins;
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
        cell.indentationWidth = 0;
    }
    
    
    if (tableView == _infoTableView) {
        cell = [self cellOfInfoTableView:cell AtIndexPath:indexPath];
    }
    else {
        cell = [self cellOfSearchResultTableView:cell AtIndexPath:indexPath];
    }
    
    if ( tableView != _infoTableView ) {
        cell.imageView.image = self.searchIcon;
        cell.imageView.tintColor = [UIColor lightGrayColor];
    }
    
    return cell;
}

- (UITableViewCell *)cellOfInfoTableView:(UITableViewCell *)cell AtIndexPath:(NSIndexPath *)indexPath
{
    if ( [self.nearbyVenues count] < 1 ) {
        cell.textLabel.text = (isLoading ? NSLocalizedString(@"Loading locations....", @"Loading locations....") : @"");
        cell.detailTextLabel.text = @"";
        cell.textLabel.textColor = [UIColor blackColor];
        cell.separatorInset = A3UITableViewSeparatorInset;
    }
    else {
        FSVenue *item = [self.nearbyVenues objectAtIndex:indexPath.row];
        
        cell.textLabel.text = item.name;
        cell.detailTextLabel.text = [_sharedManager addressFromVenue:item isDetail:NO];
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
    
    return cell;
}

- (UITableViewCell *)cellOfSearchResultTableView:(UITableViewCell *)cell AtIndexPath:(NSIndexPath *)indexPath
{
    if ( [self.nearbyVenuesOfSearchResults count] == 0 ) {
        cell.textLabel.text = (isLoading ? NSLocalizedString(@"Loading locations....", @"Loading locations....") : NSLocalizedString(@"Add this place", @"Add this place"));
        cell.detailTextLabel.text = @"";
        cell.textLabel.textColor = isLoading ? [UIColor blackColor] : [[A3UserDefaults standardUserDefaults] themeColor];
    }
    else if (indexPath.row >= [self.nearbyVenuesOfSearchResults count]) {
        cell.textLabel.font = [UIFont boldSystemFontOfSize:17.0];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:14.0];
        cell.textLabel.text = NSLocalizedString(@"Add this place?", @"Add this place?");
        cell.detailTextLabel.text = NSLocalizedString(@"We Couldn't find that", @"We Couldn't find that");
        cell.textLabel.textColor = [[A3UserDefaults standardUserDefaults] themeColor];
        cell.detailTextLabel.textColor = [UIColor colorWithRed:142.0/255.0 green:142.0/255.0 blue:147.0/255.0 alpha:1.0];
    }
    else {
        FSVenue *item = [self.nearbyVenuesOfSearchResults objectAtIndex:indexPath.row];
        
        cell.textLabel.text = item.name;
        cell.detailTextLabel.text = [_sharedManager addressFromVenue:item isDetail:NO];
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

    return cell;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellOfChangeLocationAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"currentLocationCell"];
    
    if ( cell == nil ) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"currentLocationCell"];
        cell.textLabel.font = [UIFont systemFontOfSize:17]; 
        cell.textLabel.textColor = [[A3UserDefaults standardUserDefaults] themeColor];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    if (self.changedPlace) {
        cell.textLabel.text = [[_sharedManager addressFromPlacemark:self.changedPlace] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    }
    else {
        cell.textLabel.text = NSLocalizedString(@"Current Location", @"Current Location");
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
        viewCtrl.sharedManager = _sharedManager;
        [self.navigationController pushViewController:viewCtrl animated:YES];
        return;
    }
    
    if ( tableView == _infoTableView && [self.nearbyVenues count] < 1 ) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        return;
    }
    else if ( tableView == _searchResultsTableView && indexPath.row == [_nearbyVenuesOfSearchResults count] ) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];

        // 이 위치를 추가하는 화면으로 이동
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
																 delegate:self
														cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel")
												   destructiveButtonTitle:nil
														otherButtonTitles:[NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"Create", nil), self.searchText], nil];
        [actionSheet showInView:self.view];
    }
    else {
        FSVenue *item;
        if (tableView == _searchResultsTableView) {
            item = [self.nearbyVenuesOfSearchResults objectAtIndex:indexPath.row];
        }
        else {
            item = [self.nearbyVenues objectAtIndex:indexPath.row];
        }

        DaysCounterEventLocation *locItem = [_eventModel location];
        NSManagedObjectContext *context = A3SyncManager.sharedSyncManager.persistentContainer.viewContext;
        if (!locItem) {
            locItem = [[DaysCounterEventLocation alloc] initWithContext:context];
            locItem.uniqueID = [[NSUUID UUID] UUIDString];
        }
		
		locItem.updateDate = [NSDate date];
        locItem.eventID = _eventModel.uniqueID;
        locItem.latitude = @(item.location.coordinate.latitude);
        locItem.longitude = @(item.location.coordinate.longitude);
        locItem.locationName = item.name;
        locItem.country = ([item.location.country length] > 0 ? item.location.country : @"");
        locItem.state = ([item.location.state length] > 0 ? item.location.state : @"");
        locItem.city = ([item.location.city length] > 0 ? item.location.city : @"");
        locItem.address = ([item.location.address length] > 0 ? item.location.address : @"");
        locItem.contact = ([item.contact length] > 0 ? item.contact : @"");

        [tableView reloadData];

        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)registerVenueForPlacemark:(NSArray*)placemarks
{
    CLPlacemark *mark = [placemarks objectAtIndex:0];
    NSDictionary *addressDict = mark.addressDictionary;
    // 포스퀘어에 해당 지점을 등록하고,
    [Foursquare2 venueAddWithName:self.searchText address:[addressDict objectForKey:(NSString*)kABPersonAddressStreetKey] crossStreet:nil city:[addressDict objectForKey:(NSString*)kABPersonAddressCityKey] state:[addressDict objectForKey:(NSString*)kABPersonAddressStateKey] zip:nil phone:nil twitter:nil description:nil latitude:@(_mapView.userLocation.coordinate.latitude) longitude:@(_mapView.userLocation.coordinate.longitude) primaryCategoryId:nil callback:^(BOOL success, id result) {
        // 등록화면으로 이동
        //        FNLOG(@"%s %@",__FUNCTION__,result);
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

#pragma mark - ScrollView Delegatge

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == _infoTableView) {
        if (scrollView.contentOffset.y > 0) {
            self.mapViewHeightConst.constant = 0;
            self.currentLocationButtonTopConst.constant = -(CGRectGetHeight(self.currentLocationButton.frame) + 5);
        }
        else {
            CGFloat heightOffset = fabs(scrollView.contentOffset.y);
            self.mapViewHeightConst.constant = heightOffset < 0 ? 0 : heightOffset;
            self.currentLocationButtonTopConst.constant = heightOffset - CGRectGetHeight(self.currentLocationButton.frame) - 17 - 5;
        }
    }
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
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
																		message:NSLocalizedString(@"Location information is not available.", nil)
																	   delegate:nil
															  cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
															  otherButtonTitles:nil];
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
    if ([self isInitializedLocation]) {
        return;
    }
    
    CLLocationCoordinate2D coord = userLocation.coordinate;
    [mapView setRegion:MKCoordinateRegionMakeWithDistance(coord, 2000, 2000) animated:YES];
    isLoading = YES;
    [_infoTableView reloadData];
    self.searchCenterCoord = coord;
    FNLOG(@"location updated");

	self.progressHud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
	self.progressHud.label.text = NSLocalizedString(@"Searching", @"Searching");
	self.progressHud.minShowTime = 2;
	self.progressHud.removeFromSuperViewOnHide = YES;
	__typeof(self) __weak weakSelf = self;
	self.progressHud.completionBlock = ^{
		weakSelf.progressHud = nil;
	};
    
    [self forsqareSearchCoordinate:_searchCenterCoord radius:20000.0 searchString:nil atTableView:_infoTableView completion:nil];
    
    self.isInitializedLocation = YES;
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
    if ( IS_IPAD ) {
        [mapView deselectAnnotation:view.annotation animated:NO];
        
        A3DaysCounterLocationPopupViewController *viewCtrl = [[A3DaysCounterLocationPopupViewController alloc] initWithNibName:@"A3DaysCounterLocationPopupViewController" bundle:nil];
        viewCtrl.locationItem = view.annotation;
        viewCtrl.resizeFrameBlock = ^(CGSize size) {
            [self.popoverVC setPopoverContentSize:CGSizeMake(size.width, size.height == 0 ? 44 : 274) animated:YES];
        };
        viewCtrl.dismissCompletionBlock = ^(FSVenue *locationItem) {
            [self.eventModel deleteLocation];
            
            NSManagedObjectContext *context = A3SyncManager.sharedSyncManager.persistentContainer.viewContext;
            DaysCounterEventLocation *locItem = [[DaysCounterEventLocation alloc] initWithContext:context];
			locItem.uniqueID = [[NSUUID UUID] UUIDString];
			locItem.updateDate = [NSDate date];
            locItem.eventID = self.eventModel.uniqueID;
            locItem.latitude = @(locationItem.location.coordinate.latitude);
            locItem.longitude = @(locationItem.location.coordinate.longitude);
            locItem.locationName = locationItem.name;
            locItem.country = ([locationItem.location.country length] > 0 ? locationItem.location.country : @"");
            locItem.state = ([locationItem.location.state length] > 0 ? locationItem.location.state : @"");
            locItem.city = ([locationItem.location.city length] > 0 ? locationItem.location.city : @"");
            locItem.address = ([locationItem.location.address length] > 0 ? locationItem.location.address : @"");
            locItem.contact = ([locationItem.contact length] > 0 ? locationItem.contact : @"");

            [self.navigationController popViewControllerAnimated:YES];
        };
        
        UINavigationController *navCtrl = [[UINavigationController alloc] initWithRootViewController:viewCtrl];
        CGSize size = viewCtrl.view.frame.size;
        
        self.popoverVC = [[UIPopoverController alloc] initWithContentViewController:navCtrl];
        self.popoverVC.delegate = self;
        viewCtrl.popoverVC = self.popoverVC;
        
        viewCtrl.shrinkPopoverViewBlock = ^(CGSize size) {
            [self.popoverVC setPopoverContentSize:CGSizeMake(size.width, 44) animated:NO];
            self.popoverVC.contentViewController.view.hidden = NO;
        };

        self.popoverVC.contentViewController.view.hidden = YES;
        [self.popoverVC setPopoverContentSize:CGSizeMake(size.width, 274) animated:NO];
        [self.popoverVC presentPopoverFromRect:view.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)annotationView didChangeDragState:(MKAnnotationViewDragState)newState
   fromOldState:(MKAnnotationViewDragState)oldState
{
	if (newState == MKAnnotationViewDragStateEnding) {
		CLLocationCoordinate2D droppedAt = annotationView.annotation.coordinate;
        [self forsqareSearchCoordinate:droppedAt radius:20000.0 searchString:self.searchText atTableView:_infoTableView completion:nil];
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

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:NO animated:YES];
    if (self.progressHud) {
        [self.progressHud hideAnimated:YES];
    }

    if ( !isSearchActive ) {
        [self hideSearchResultView];
        [self hideCurrentLocationTableView];
    }
    else {
        isSearchActive = NO;
        [self hideSearchResultView];
        [self hideCurrentLocationTableView];
        self.searchText = nil;
        [searchBar resignFirstResponder];
    }
	[self adjustInfoTableViewInset];
    
    if ([_infoTableView respondsToSelector:@selector(layoutMargins)])
    {
        UIEdgeInsets layoutMargins = _infoTableView.layoutMargins;
        layoutMargins.left = 0;
        _infoTableView.layoutMargins = layoutMargins;
    }
}

- (void)adjustInfoTableViewInset {
	if (_infoTableViewInsetOld.top > CGRectGetHeight(self.view.bounds)) {
		_infoTableViewInsetOld.top = CGRectGetHeight(self.view.bounds) - 88;
		_infoTableView.contentInset = _infoTableViewInsetOld;
	}
	else {
		_infoTableView.contentInset = _infoTableViewInsetOld;
		[_infoTableView setContentOffset:_infoTableViewOldOffset animated:YES];
	}
}

#pragma mark - action method
- (IBAction)moveCurrentLocationAction:(id)sender {
    CLLocationCoordinate2D coord = _mapView.userLocation.coordinate;
    [_mapView setCenterCoordinate:coord animated:YES];
    self.isInitializedLocation = NO;
}

#pragma mark - A3DaysCounterChangeLocationViewControllerDelegate
- (void)changeLocationViewController:(A3DaysCounterChangeLocationViewController *)ctrl didSelectLocation:(CLPlacemark *)placemark searchText:(NSString *)searchText
{
    [self.searchBar resignFirstResponder];
    self.isInitializedLocation = NO;

    if ( placemark == nil ) {
        [self moveCurrentLocationAction:nil];
        self.changedPlace = nil;
        self.searchCenterCoord = _mapView.userLocation.coordinate;
        [self forsqareSearchCoordinate:_mapView.userLocation.coordinate radius:20000.0 searchString:searchText atTableView:_infoTableView completion:nil];
    }
    else {
        self.searchCenterCoord = placemark.location.coordinate;
        self.changedPlace = placemark;
        [_mapView setCenterCoordinate:_searchCenterCoord animated:YES];
        [self forsqareSearchCoordinate:_searchCenterCoord radius:20000.0 searchString:searchText atTableView:_infoTableView completion:nil];
    }
    [self.currentLocationTableView reloadData];
    [ctrl.navigationController popViewControllerAnimated:YES];
}

@end
