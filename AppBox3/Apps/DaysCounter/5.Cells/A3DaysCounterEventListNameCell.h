//
//  A3DaysCounterEventListNameCell.h
//  AppBox3
//
//  Created by dotnetguy83 on 3/24/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface A3DaysCounterEventListNameCell : UITableViewCell

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sinceLeadingConst;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nameLeadingConst;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *photoLeadingConst;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *photoWidthConst;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *untilRoundWidthConst;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleBottomConst;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sinceBottomConst;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleRightSpaceConst;
@end
