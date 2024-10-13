//
//  A3DaysCounterSetupLocationViewController.h
//  A3TeamWork
//
//  Created by coanyaa on 13. 10. 18..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "A3DaysCounterChangeLocationViewController.h"

@class DaysCounterEvent_;
@class A3DaysCounterModelManager;
@interface A3DaysCounterSetupLocationViewController : UIViewController<MKMapViewDelegate,UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate,UIActionSheetDelegate,UIPopoverControllerDelegate,A3DaysCounterChangeLocationViewControllerDelegate>{
    BOOL isLoading;
    BOOL isInputing;
    BOOL isSearchActive;
}
@property (weak, nonatomic) A3DaysCounterModelManager *sharedManager;
@property (strong, nonatomic) DaysCounterEvent_ *eventModel;

@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) IBOutlet UITableView *infoTableView;
@property (strong, nonatomic) IBOutlet UIView *tableFooterView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *tableViewHeightConstraint;
@property (strong, nonatomic) IBOutlet UIButton *currentLocationButton;
@property (strong, nonatomic) IBOutlet UITableView *currentLocationTableView;
@property (strong, nonatomic) IBOutlet UIView *currentLocationView;
@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) IBOutlet UIView *searchBarBaseView;
@property (strong, nonatomic) IBOutlet UITableView *searchResultsTableView;
@property (strong, nonatomic) IBOutlet UIView *searchResultBaseView;
@property (weak, nonatomic) IBOutlet UIView *noResultsView;
@property (strong, nonatomic) IBOutlet UISearchBar *testSearchBar;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mapViewHeightConst;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *currentLocationButtonTopConst;


- (IBAction)moveCurrentLocationAction:(id)sender;
@end
