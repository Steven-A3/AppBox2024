//
//  A3DaysCounterRepeatCustomCell.h
//  AppBox3
//
//  Created by dotnetguy83 on 3/27/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface A3DaysCounterRepeatCustomCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *checkImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *checkImageTrailingConst;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *daysLabelTrailingConst;
@end
