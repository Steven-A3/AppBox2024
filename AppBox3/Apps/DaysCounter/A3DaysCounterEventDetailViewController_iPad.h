//
//  A3DaysCounterEventDetailViewController_iPad.h
//  A3TeamWork
//
//  Created by coanyaa on 2013. 11. 12..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "A3DaysCounterEventDetailViewController.h"

@class DaysCounterEvent;

@interface A3DaysCounterEventDetailViewController_iPad : UIViewController<MKMapViewDelegate,UIPopoverControllerDelegate,A3DaysCounterEventDetailViewControllerDelegate>{
    BOOL isFullDetailVC;
}

@property (strong, nonatomic) DaysCounterEvent *eventItem;

@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) IBOutlet UIView *titleView;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UIImageView *favoriteMark;
@property (strong, nonatomic) IBOutlet UIImageView *bgImageView;

@property (assign, nonatomic) BOOL landscapeFullScreen;
@end
