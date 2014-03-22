//
//  A3DaysCounterSlideshowEventSummaryView.h
//  AppBox3
//
//  Created by dotnetguy83 on 3/22/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FXLabel;

@interface A3DaysCounterSlideshowEventSummaryView : UICollectionViewCell
@property (weak, nonatomic) IBOutlet FXLabel *dayCountLabel;
@property (weak, nonatomic) IBOutlet FXLabel *daysSinceLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *dayCountTopSpaceConst;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *daysSinceTopSpaceConst;

@end
