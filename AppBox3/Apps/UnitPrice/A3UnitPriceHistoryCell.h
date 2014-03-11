//
//  A3UnitPriceHistoryCell.h
//  A3TeamWork
//
//  Created by kihyunkim on 2013. 11. 6..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface A3UnitPriceHistoryCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *unitPriceALabel;
@property (weak, nonatomic) IBOutlet UILabel *unitPriceBLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (strong, nonatomic) IBOutlet UIView *historyBView;

@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *markLBs;

@end
