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
#import "A3GradientView.h"
#import "A3AppDelegate+appearance.h"
#import "MBProgressHUD.h"

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
    self.title = @"Location";
    self.navigationItem.titleView = self.searchBarBaseView;
    [self setAutomaticallyAdjustsScrollViewInsets:NO];
    [self makeBackButtonEmptyArrow];
    [self.infoTableView setTableFooterView:_tableFooterView];
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
    [self initializeSelectedLocation];
    
    self.mapViewHeightConst.constant = CGRectGetHeight(self.infoTableView.frame) - 88;
    self.infoTableView.contentInset = UIEdgeInsetsMake(CGRectGetHeight([[UIScreen mainScreen] bounds]) - 88, 0, 0, 0);
    self.infoTableView.separatorInset = UIEdgeInsetsMake(0, IS_IPHONE ? 15 : 28, 0, 0);
    self.infoTableView.backgroundColor = [UIColor colorWithRed:247.0/255.0 green:247.0/255.0 blue:247.0/255.0 alpha:0.95];
    self.infoTableView.separatorColor = [UIColor colorWithRed:200/255.0 green:200/255.0 blue:200/255.0 alpha:1.0];
    self.searchResultsTableView.separatorColor = [UIColor colorWithRed:200/255.0 green:200/255.0 blue:200/255.0 alpha:1.0];

    [self.view addSubview:self.tableViewTopBlurView];
    [self.tableViewTopBlurView makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.infoTableView.left);
        make.trailing.equalTo(self.infoTableView.right);
        make.height.equalTo(@5);
        make.bottom.equalTo(self.mapView.bottom);
    }];
}

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
//    [annotations enumerateObjectsUsingBlock:^(id <MKAnnotation> annotation, NSUInteger idx, BOOL *stop) {
//        if ([annotation coordinate].longitude == _searchCenterCoord.longitude && [annotation coordinate].latitude == _searchCenterCoord.latitude) {
//            [self.mapView selectAnnotation:annotation animated:YES];
//            *stop = YES;
//            return;
//        }
//    }];
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
    viewCtrl.locationItem = item;
    viewCtrl.isEditMode = NO;
    [self.navigationController pushViewController:viewCtrl animated:YES];
}

#pragma mark Search
- (void)initializeSelectedLocation
{
    NSDictionary *locationInfo = [self.eventModel objectForKey:EventItem_Location];
    if (!locationInfo) {
        return;
    }
    
    NSNumber *longitude = [locationInfo objectForKey:EventItem_Longitude];
    NSNumber *latitude = [locationInfo objectForKey:EventItem_Latitude];
    NSString *locationName = [locationInfo objectForKey:EventItem_LocationName];
    _searchCenterCoord = CLLocationCoordinate2DMake([latitude doubleValue], [longitude doubleValue]);
    [self.mapView setCenterCoordinate:_searchCenterCoord animated:YES];
    [self.mapView setRegion:MKCoordinateRegionMakeWithDistance(_searchCenterCoord, 500.0, 500.0) animated:YES];
    
    [_infoTableView reloadData];

	self.progressHud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
	self.progressHud.labelText = @"Searching";
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
                                      [self.progressHud hide:YES];
                                      
                                      if (success) {
                                          isLoading = NO;
                                          NSDictionary *dic = result;
                                          NSArray *venues = [dic valueForKeyPath:@"response.venues"];
                                          FSConverter *converter = [[FSConverter alloc] init];
                                          
                                          // 맵 annotation 추가.
                                          if (tableView == _infoTableView) {
                                              self.nearbyVenues = [converter convertToObjects:venues];
                                              [self reloadMapAnnotations:self.nearbyVenues];
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
                                          UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"장소 검색 실패" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
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
    //_infoTableView.contentOffset = CGPointMake(0, CGRectGetHeight(self.view.frame));
    _infoTableView.contentInset = UIEdgeInsetsMake(CGRectGetHeight(self.view.frame), 0, 0, 0);
    [_infoTableView setContentOffset:CGPointMake(0, -CGRectGetHeight(self.view.frame)) animated:YES];
    
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
    _infoTableView.contentInset = _infoTableViewInsetOld;
    [_infoTableView setContentOffset:_infoTableViewOldOffset animated:YES];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    isInputing = NO;
    self.searchText = searchBar.text;
    [searchBar resignFirstResponder];
    
	self.progressHud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
	self.progressHud.labelText = @"Searching";
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

//- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
//{
//    return 0.01;
//}
//
//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
//{
//    return 0.01;
//}

#pragma mark Cell Related
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    
    if ( tableView == _currentLocationTableView ) {
        cell = [self tableView:tableView cellOfChangeLocationAtIndexPath:indexPath];
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
        cell.textLabel.text = (isLoading ? @"Loading locations...." : @"");
        cell.detailTextLabel.text = @"";
        cell.textLabel.textColor = [UIColor blackColor];
        cell.separatorInset = UIEdgeInsetsMake(0, IS_IPHONE ? 15 : 28, 0, 0);
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
    
    return cell;
}

- (UITableViewCell *)cellOfSearchResultTableView:(UITableViewCell *)cell AtIndexPath:(NSIndexPath *)indexPath
{
    if ( [self.nearbyVenuesOfSearchResults count] < 1 ) {
        cell.textLabel.text = (isLoading ? @"Loading locations...." : @"");
        cell.detailTextLabel.text = @"";
        cell.textLabel.textColor = [UIColor blackColor];
    }
    else if (indexPath.row >= [self.nearbyVenuesOfSearchResults count]) {
        cell.textLabel.font = [UIFont boldSystemFontOfSize:17.0];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:14.0];
        cell.textLabel.text = @"Add this place?";
        cell.detailTextLabel.text = @"We Couldn't find that";
        cell.textLabel.textColor = [A3AppDelegate instance].themeColor;
        cell.detailTextLabel.textColor = [UIColor colorWithRed:142.0/255.0 green:142.0/255.0 blue:147.0/255.0 alpha:1.0];
    }
    else {
        FSVenue *item = [self.nearbyVenuesOfSearchResults objectAtIndex:indexPath.row];
        
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

    return cell;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellOfChangeLocationAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"currentLocationCell"];
    
    if ( cell == nil ) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"currentLocationCell"];
        cell.textLabel.font = [UIFont systemFontOfSize:17]; 
        cell.textLabel.textColor = [A3AppDelegate instance].themeColor;
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    if (self.changedPlace) {
        cell.textLabel.text = [[[A3DaysCounterModelManager sharedManager] addressFromPlacemark:self.changedPlace] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    }
    else {
        cell.textLabel.text = @"Current Location";
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
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        return;
    }
    else if ( tableView != _infoTableView && (indexPath.row >= [_nearbyVenues count]) ) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
        // 이 위치를 추가하는 화면으로 이동
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:[NSString stringWithFormat:@"Create %@",self.searchText], nil];
        [actionSheet showInView:self.view];
    }
    else {
        FSVenue *item = [self.nearbyVenues objectAtIndex:indexPath.row];
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

#pragma mark - ScrollView Delegatge

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == _infoTableView) {
        if (scrollView.contentOffset.y > 0) {
            self.mapViewHeightConst.constant = 0;
            self.currentLocationButtonTopConst.constant = -CGRectGetHeight(self.currentLocationButton.frame);
        }
        else {
            CGFloat heightOffset = fabs(scrollView.contentOffset.y);
            self.mapViewHeightConst.constant = heightOffset < 0 ? 0 : heightOffset;
            self.currentLocationButtonTopConst.constant = heightOffset - CGRectGetHeight(self.currentLocationButton.frame) - 17;
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
	self.progressHud.labelText = @"Searching";
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
            NSMutableDictionary *locItem = [[A3DaysCounterModelManager sharedManager] emptyEventLocationModel];
            [locItem setObject:[_eventModel objectForKey:EventItem_ID] forKey:EventItem_ID];
            [locItem setObject:@(locationItem.location.coordinate.latitude) forKey:EventItem_Latitude];
            [locItem setObject:@(locationItem.location.coordinate.longitude) forKey:EventItem_Longitude];
            [locItem setObject:locationItem.name forKey:EventItem_LocationName];
            [locItem setObject:([locationItem.location.country length] > 0 ? locationItem.location.country : @"") forKey:EventItem_Country];
            [locItem setObject:([locationItem.location.state length] > 0 ? locationItem.location.state : @"") forKey:EventItem_State];
            [locItem setObject:([locationItem.location.city length] > 0 ? locationItem.location.city : @"") forKey:EventItem_City];
            [locItem setObject:([locationItem.location.address length] > 0 ? locationItem.location.address : @"") forKey:EventItem_Address];
            [locItem setObject:([locationItem.contact length] > 0 ? locationItem.contact : @"") forKey:EventItem_Contact];
            [_eventModel setObject:locItem forKey:EventItem_Location];
            [self.navigationController popViewControllerAnimated:YES];
        };
        
        UINavigationController *navCtrl = [[UINavigationController alloc] initWithRootViewController:viewCtrl];
        CGSize size = viewCtrl.view.frame.size;
        
        self.popoverVC = [[UIPopoverController alloc] initWithContentViewController:navCtrl];
        self.popoverVC.delegate = self;
        viewCtrl.popoverVC = self.popoverVC;
        
        viewCtrl.shrinkPopoverViewBlock = ^(CGSize size) {
            [self.popoverVC setPopoverContentSize:CGSizeMake(size.width, 44) animated:NO];
        };

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
        [self.progressHud hide:YES];
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
