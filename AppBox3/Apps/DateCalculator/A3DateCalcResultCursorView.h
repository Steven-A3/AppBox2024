//
//  A3DateCalcResultCursorView.h
//  A3TeamWork
//
//  Created by jeonghwan kim on 13. 10. 15..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, ArrowDirection) {
    ArrowDirection_From = 0,
    ArrowDirection_To
};

@interface A3DateCalcResultCursorView : UIView

@property (nonatomic, strong) UILabel *contentLabel;
@property (nonatomic, assign) ArrowDirection arrowDirection;
@property (nonatomic, assign) BOOL isPositive;

- (id)initWithFrame:(CGRect)frame ArrowDirection:(ArrowDirection)arrowDirection;
- (void)setResultText:(NSString *)resultText;
- (CGSize)sizeOfResultText;
@end
