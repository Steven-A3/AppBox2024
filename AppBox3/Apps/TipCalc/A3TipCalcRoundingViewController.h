//
//  A3TipCalcRoundingViewController.h
//  A3TeamWork
//
//  Created by Sanghyun Yu on 2013. 11. 6..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol A3TipCalcRoundingViewDelegate <NSObject>
@required
- (void)tipCalcRoundingChanged;
@end

@interface A3TipCalcRoundingViewController : UITableViewController
{
    NSArray* _arrSectionTitle;
    NSMutableDictionary* _mdicCellText;
}

@property (nonatomic, assign) id<A3TipCalcRoundingViewDelegate> delegate;


@end
