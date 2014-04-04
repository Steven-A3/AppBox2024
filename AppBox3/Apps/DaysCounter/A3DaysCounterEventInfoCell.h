//
//  A3DaysCounterEventInfoCell.h
//  AppBox3
//
//  Created by kimjeonghwan on 3/31/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface A3DaysCounterEventInfoCell : UITableViewCell

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleLeftSpaceConst;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleBottomSpaceConst;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *untilRoundBottomConst;     // A, until since
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sinceRoundBottomConst;     // B, since
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *untilRoundWidthConst;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sinceRoundWidthConst;

@property (weak, nonatomic) IBOutlet UILabel *eventTitleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *eventPhotoImageView;
@property (weak, nonatomic) IBOutlet UIImageView *favoriteStarImageView;

@property (weak, nonatomic) IBOutlet UILabel *untilSinceRoundLabel;
@property (weak, nonatomic) IBOutlet UILabel *durationALabel;
@property (weak, nonatomic) IBOutlet UILabel *startEnd1ALabel;
@property (weak, nonatomic) IBOutlet UILabel *startEnd2ALabel;
@property (weak, nonatomic) IBOutlet UILabel *repeatALabel;
@property (weak, nonatomic) IBOutlet UIImageView *lunar1AImageView;

@property (weak, nonatomic) IBOutlet UILabel *sinceRoundLabel;
@property (weak, nonatomic) IBOutlet UILabel *durationBLabel;
@property (weak, nonatomic) IBOutlet UILabel *startEnd1BLabel;
@property (weak, nonatomic) IBOutlet UILabel *startEnd2BLabel;
@property (weak, nonatomic) IBOutlet UILabel *repeatBLabel;
@property (weak, nonatomic) IBOutlet UIImageView *lunar1BImageView;


@end
