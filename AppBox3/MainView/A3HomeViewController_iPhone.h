//
//  A3HomeViewController_iPhone.h
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 10/10/12.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "A3SegmentedControl.h"
#import "PaperFoldView.h"

@interface A3HomeViewController_iPhone : UIViewController
		<A3SegmentedControlDataSource, A3SegmentedControlDelegate>

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) UIViewController *activeViewControllerForSelectedSegment;

@end
