//
//  A3DateCalcExcludeViewController.h
//  A3TeamWork
//
//  Created by jeonghwan kim on 13. 10. 14..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol A3DateCalcExcludeDelegate <NSObject>
@required
- (void)excludeSettingDelegate;
- (void)dismissExcludeSettingViewController;
@end

@interface A3DateCalcExcludeViewController : UITableViewController
@property (nonatomic, weak) id<A3DateCalcExcludeDelegate> delegate;
@end
