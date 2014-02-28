//
//  A3DateCalcDurationViewController.h
//  A3TeamWork
//
//  Created by jeonghwan kim on 13. 10. 14..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol A3DateCalcDurationDelegate <NSObject>

- (void)durationSettingChanged;
- (void)dismissDateCalcDurationViewController;

@end

@interface A3DateCalcDurationViewController : UITableViewController

@property (nonatomic, weak) id<A3DateCalcDurationDelegate>	delegate;

@end
