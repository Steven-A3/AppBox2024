//
//  A3SalesCalcHeaderView.h
//  A3TeamWork
//
//  Created by jeonghwan kim on 13. 11. 17..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>

@class A3SalesCalcData;
@interface A3SalesCalcHeaderView : UIView

@property (nonatomic, strong) UIButton *detailInfoButton;
@property (nonatomic, weak) NSNumberFormatter *currencyFormatter;

//@property (nonatomic, setter = setResultDictionary:) NSDictionary *result;

//-(void)setResultWithAnimation:(NSDictionary *)resultDic;
//- (void)setResultDataWithAnimation:(A3SalesCalcData *)resultData;
- (void)setResultData:(A3SalesCalcData *)resultData withAnimation:(BOOL)animate;

@end
