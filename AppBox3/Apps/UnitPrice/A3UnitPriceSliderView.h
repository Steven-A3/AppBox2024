//
//  A3UnitPriceSliderView.h
//  A3TeamWork
//
//  Created by kihyunkim on 2013. 10. 30..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UnitItem;

typedef NS_ENUM(NSInteger, UnitPriceSliderViewLayout) {
    Slider_StandAlone = 0,
    Slider_UpperOfTwo,
    Slider_LowerOfTwo,
};

@interface A3UnitPriceSliderView : UIView

@property (nonatomic, strong) UIColor *displayColor;

@property (weak, nonatomic) IBOutlet UILabel *unitPriceNumLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceNumLabel;
@property (weak, nonatomic) IBOutlet UILabel *markLabel;
@property (weak, nonatomic) IBOutlet UILabel *unitPriceLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UIView *lineView;
@property (weak, nonatomic) IBOutlet UIView *progressLineView;

@property (nonatomic, readwrite) float maxValue;
@property (nonatomic, readwrite) float minValue;
@property (nonatomic, readwrite) float priceValue;
@property (nonatomic, readwrite) double unitPriceValue;
@property (nonatomic, strong) UnitItem *unit;
@property (readwrite) BOOL progressBarHidden;

@property (nonatomic, readwrite) UnitPriceSliderViewLayout layoutType;

- (void)setLayoutWithAnimated;
- (void)setLayoutWithNoAnimated;

- (void)labelFontSetting;

@end
