//
//  A3DaysCounterEventDetailLocationViewController.h
//  A3TeamWork
//
//  Created by coanyaa on 2013. 11. 9..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@class DaysCounterEventLocation_;
@class A3DaysCounterModelManager;

@interface A3DaysCounterEventDetailLocationViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,MKMapViewDelegate>
@property (weak, nonatomic) A3DaysCounterModelManager *sharedManager;
@property (strong, nonatomic) DaysCounterEventLocation_ *location;
@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@end
