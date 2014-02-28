//
//  A3BatterStatusBatteryPanelView.h
//  A3TeamWork
//
//  Created by jeonghwan kim on 12/4/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface A3BatterStatusBatteryPanelView : UIView

@property (nonatomic, strong) UIColor * batteryColor;

-(void)setBatteryRemainingPercent:(NSInteger)percent state:(UIDeviceBatteryState)batteryState;

@end
