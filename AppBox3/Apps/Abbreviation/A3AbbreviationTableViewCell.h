//
//  A3AbbreviationTableViewCell.h
//  AppBox3
//
//  Created by Byeong-Kwon Kwak on 12/13/16.
//  Copyright © 2016 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "A3GradientView.h"
#import "A3TrapezoidView.h"

@interface A3AbbreviationTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet A3GradientView *headBGForFirstRow;
@property (nonatomic, weak) IBOutlet A3GradientView *headBGForOtherRow;
@property (nonatomic, weak) IBOutlet A3GradientView *bodyBGForFirstRow;
@property (nonatomic, weak) IBOutlet A3GradientView *bodyBGForOtherRow;
@property (nonatomic, weak) IBOutlet A3TrapezoidView *alphabetTopView;
@property (nonatomic, weak) IBOutlet A3GradientView *alphabetBottomView;
@property (nonatomic, weak) IBOutlet UILabel *alphabetLabel;
@property (nonatomic, weak) IBOutlet UILabel *abbreviationLabel;
@property (nonatomic, weak) IBOutlet UILabel *meaningLabel;
@property (nonatomic, assign) IBInspectable BOOL clipToTrapezoid;
@property (nonatomic, weak) IBOutlet UIView *customAccessoryView;

+ (NSString *)reuseIdentifier;

@end
