//
//  A3TipCalcHeaderView.h
//  A3TeamWork
//
//  Created by Sanghyun Yu on 2013. 11. 5..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "A3TipCalcCircle.h"

@class A3RoundedSideButton;
@class TipCalcRecently;


@interface A3TipCalcHeaderView : UIView

@property (nonatomic, strong) A3RoundedSideButton *beforeSplitButton;
@property (nonatomic, strong) A3RoundedSideButton *perPersonButton;
@property (nonatomic, strong) UIButton *detailInfoButton;

- (void)showDetailInfoButton;
- (void)setResult:(TipCalcRecently *)result;
- (void)setResult:(TipCalcRecently *)result withAnimation:(BOOL)animate;

@property (strong, nonatomic) IBOutlet UIView *viewBackBar;
@property (strong, nonatomic) IBOutlet UIView *viewValueBar;
@property (strong, nonatomic) IBOutlet A3TipCalcCircle *viewCercle;


@property (strong, nonatomic) IBOutlet UILabel *lbTip;
@property (strong, nonatomic) IBOutlet UILabel *lbTipCaption;

@property (strong, nonatomic) IBOutlet UILabel *lbTotal;
@property (strong, nonatomic) IBOutlet UILabel *lbTotalCaption;

@property (strong, nonatomic) IBOutlet UIButton *btnDetail;


@end
