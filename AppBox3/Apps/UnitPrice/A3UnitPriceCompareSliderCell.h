//
//  A3UnitPriceCompareSliderCell.h
//  A3TeamWork
//
//  Created by kihyunkim on 2014. 2. 22..
//  Copyright (c) 2014년 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "A3UnitPriceSliderView.h"

@interface A3UnitPriceCompareSliderCell : UITableViewCell

@property (weak, nonatomic) IBOutlet A3UnitPriceSliderView *upSliderView;
@property (weak, nonatomic) IBOutlet A3UnitPriceSliderView *downSliderView;

@end
