//
//  A3TipCalcSettingViewController.h
//  A3TeamWork
//
//  Created by dotnetguy83 on 3/7/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol A3TipCalcSettingsDelegate <NSObject>
@required
- (void)tipCalcSettingsChanged;
- (void)dismissTipCalcSettingsViewController;
@end

@interface A3TipCalcSettingViewController : UITableViewController
@property (nonatomic, assign) id<A3TipCalcSettingsDelegate> delegate;
@end
