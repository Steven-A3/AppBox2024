//
//  A3UnitPriceUnitTabBarController.h
//  A3TeamWork
//
//  Created by kihyunkim on 2013. 11. 3..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "A3UnitPriceSelectViewController.h"

@class UnitPriceInfo;

extern NSString *const A3UnitPriceSegmentIndex;

@interface A3UnitPriceUnitTabBarController : UITabBarController

@property (nonatomic, strong) UnitPriceInfo *price;

- (id)initWithDelegate:(id<A3UnitSelectViewControllerDelegate>)delegate withPrice:(UnitPriceInfo *) price;

@end
