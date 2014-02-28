//
//  A3PercentCalcHistoryViewController.h
//  A3TeamWork
//
//  Created by jeonghwan kim on 13. 10. 26..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>

@class A3PercentCalcData;

@protocol A3PercentCalcHistoryDelegate <NSObject>

-(void)setHistoryDataFor:(A3PercentCalcData *)history;
-(void)didDeleteHistory;
-(void)dismissHistoryViewController;
@end


@interface A3PercentCalcHistoryViewController : UITableViewController

@property (nonatomic, assign) id<A3PercentCalcHistoryDelegate> delegate;

@end
