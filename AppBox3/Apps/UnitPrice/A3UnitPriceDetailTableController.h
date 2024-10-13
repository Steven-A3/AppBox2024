//
//  A3UnitPriceDetailTableController.h
//  A3TeamWork
//
//  Created by kihyunkim on 2014. 1. 23..
//  Copyright (c) 2014년 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol A3UnitPriceModifyDelegate <NSObject>

- (void)unitPriceInfoChanged:(UnitPriceInfo_ *)price;

@end

@interface A3UnitPriceDetailTableController : UITableViewController <UITextFieldDelegate>

@property (nonatomic, assign) id<A3UnitPriceModifyDelegate> delegate;
@property (nonatomic, assign) BOOL isPriceA;
@property (nonatomic, strong) UnitPriceInfo_ *price;

@end
