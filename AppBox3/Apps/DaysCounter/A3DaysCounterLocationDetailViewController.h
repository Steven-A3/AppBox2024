//
//  A3DaysCounterLocationDetailViewController.h
//  A3TeamWork
//
//  Created by coanyaa on 13. 10. 23..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "FSVenue.h"

@interface A3DaysCounterLocationDetailViewController : UIViewController<MKMapViewDelegate,UITableViewDataSource,UITableViewDelegate,UIPopoverControllerDelegate>

@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *tableViewHeightConst;

@property (strong, nonatomic) NSMutableDictionary *eventModel;
@property (assign, nonatomic) BOOL isEditMode;
@property (strong, nonatomic) FSVenue *locationItem;


- (IBAction)deleteLocationAction:(id)sender;
@end
