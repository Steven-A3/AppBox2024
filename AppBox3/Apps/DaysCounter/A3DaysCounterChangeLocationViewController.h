//
//  A3DaysCounterChangeLocationViewController.h
//  A3TeamWork
//
//  Created by coanyaa on 2014. 1. 11..
//  Copyright (c) 2014년 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@protocol A3DaysCounterChangeLocationViewControllerDelegate;

@interface A3DaysCounterChangeLocationViewController : UIViewController<UISearchBarDelegate,UITableViewDataSource,UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) id<A3DaysCounterChangeLocationViewControllerDelegate> delegate;

@end

@protocol A3DaysCounterChangeLocationViewControllerDelegate <NSObject>
@optional
- (void)changeLocationViewController:(A3DaysCounterChangeLocationViewController*)ctrl didSelectLocation:(CLPlacemark*)placemark;

@end
