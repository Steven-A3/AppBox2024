//
//  InclinometerSurfaceView.h
//  CalcSuite#3
//
//  Created by Byeong-Kwon Kwak on 12/22/08.
//  Copyright 2008 ALLABOUTAPPS. All rights reserved.
//

@class InclinometerViewController;

@interface InclinometerView : UIView 

@property (nonatomic, weak) InclinometerViewController *viewController;

- (instancetype)initWithFrame:(CGRect)frame mode:(NSUInteger)mode;
- (void)updateToInclinationInRadians:(float)rads radianX:(float)radX radianY:(float)radY;

@end
