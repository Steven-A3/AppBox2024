//
//  A3DateCalcHeaderView.h
//  A3TeamWork
//
//  Created by jeonghwan kim on 13. 10. 11..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, CALC_TYPE) {
    CALC_TYPE_BETWEEN = 0,
    CALC_TYPE_ADD,
    CALC_TYPE_SUB
};

@protocol A3DateCalcHeaderViewDelegate <NSObject>
@required
- (void)dateCalcHeaderChangedFromDate:(NSDate *)fDate toDate:(NSDate *)tDate;
- (void)dateCalcHeaderAddSubResult:(NSDateComponents *)compResult;
- (void)dateCalcHeaderFromThumbTapped;
- (void)dateCalcHeaderToThumbTapped;
@end


@interface A3DateCalcHeaderView : UIView

- (void)setFromDate:(NSDate *)fromDate toDate:(NSDate *)toDate;
//- (void)setFromDate:(NSDate *)fromDate;
//- (void)setToDate:(NSDate *)toDate;
- (void)setCalcType:(CALC_TYPE)aType;

- (void)setResultBetweenDate:(NSDateComponents *)resultDate withAnimation:(BOOL)animation;
- (void)setResultAddDate:(NSDate *)resultDate withAnimation:(BOOL)animation;
- (void)setResultSubDate:(NSDate *)resultDate withAnimation:(BOOL)animation;

@property (nonatomic, weak) id<A3DateCalcHeaderViewDelegate> delegate;

@end
