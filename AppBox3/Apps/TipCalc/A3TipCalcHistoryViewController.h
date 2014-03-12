//
//  A3TipCalcHistoryViewController.h
//  A3TeamWork
//
//  Created by Sanghyun Yu on 2013. 11. 5..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TipCalcHistory;
@protocol A3TipCalcHistorySelectDelegate <NSObject>
-(void)didSelectHistoryData:(TipCalcHistory *)aHistory;
-(void)clearSelectHistoryData;
-(void)dismissHistoryViewController;
@end

@interface A3TipCalcHistoryViewController : UITableViewController

@property (nonatomic, assign) id<A3TipCalcHistorySelectDelegate> delegate;

@end
