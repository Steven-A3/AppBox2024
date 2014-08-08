//
//  A3UnitPriceInputView.h
//  A3TeamWork
//
//  Created by kihyunkim on 2013. 11. 1..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>

@class A3UnitPriceInputView;

@protocol UnitPriceInputDelegate <NSObject>

- (void)inputViewTapped:(A3UnitPriceInputView *) inputView;

@end

@interface A3UnitPriceInputView : UIView

@property (nonatomic, weak) id<UnitPriceInputDelegate> delegate;
@property (weak, nonatomic) IBOutlet UILabel *markLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UILabel *unitLabel;
@property (weak, nonatomic) IBOutlet UILabel *sizeLabel;
@property (weak, nonatomic) IBOutlet UILabel *quantityLabel;
@property (weak, nonatomic) IBOutlet UILabel *discountLabel;
@property (strong, nonatomic) IBOutlet UIButton *unitPriceBtn;
@property (strong, nonatomic) IBOutletCollection(UIView) NSArray *lineViews;
@property (strong, nonatomic) IBOutletCollection(UIView) NSArray *labels;

- (void)loadFontSettings;

@end
