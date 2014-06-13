//
//  A3TipCalcHeaderView.h
//  A3TeamWork
//
//  Created by Sanghyun Yu on 2013. 11. 5..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>

@class A3RoundedSideButton;
@class TipCalcRecently;
@class A3TipCalcDataManager;

@interface A3TipCalcHeaderView : UIView

@property (nonatomic, weak) A3TipCalcDataManager *dataManager;
@property (nonatomic, strong) A3RoundedSideButton *beforeSplitButton;
@property (nonatomic, strong) A3RoundedSideButton *perPersonButton;
@property (nonatomic, strong) UIButton *detailInfoButton;

- (id)initWithFrame:(CGRect)frame dataManager:(A3TipCalcDataManager *)dataManager;
- (void)showDetailInfoButton;
- (void)setResult:(TipCalcRecently *)result;
- (void)setResult:(TipCalcRecently *)result withAnimation:(BOOL)animate;

@end
