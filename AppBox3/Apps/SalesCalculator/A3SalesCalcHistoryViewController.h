//
//  A3SalesCalcHistoryViewController.h
//  A3TeamWork
//
//  Created by jeonghwan kim on 13. 11. 17..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>
@class A3SalesCalcData;
@protocol A3SalesCalcHistorySelectDelegate <NSObject>
-(void)didSelectHistoryData:(A3SalesCalcData *)aData;
-(void)clearSelectHistoryData;
-(void)dismissHistoryViewController;
@end

@interface A3SalesCalcHistoryViewController : UITableViewController

@property (nonatomic, assign) id<A3SalesCalcHistorySelectDelegate> delegate;

@end
