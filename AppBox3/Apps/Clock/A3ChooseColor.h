//
//  A3ChooseColor.h
//  A3TeamWork
//
//  Created by Sanghyun Yu on 2013. 11. 29..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol A3ChooseColorDelegate;

@interface A3ChooseColor : UIView

@property(nonatomic, strong) UIColor* clrSelected;
@property(nonatomic, weak) id<A3ChooseColorDelegate> delegate;

+ (A3ChooseColor *)chooseColorWaveInViewController:(UIViewController <A3ChooseColorDelegate> *)targetViewController inView:(UIView *)view colors:(NSArray *)colos selectedIndex:(NSUInteger)selectedIndex;
+ (A3ChooseColor *)chooseColorFlipInViewController:(UIViewController <A3ChooseColorDelegate> *)targetViewController colors:(NSArray *)colors;
+ (A3ChooseColor *)chooseColorLED:(UIViewController <A3ChooseColorDelegate> *)targetViewController colors:(NSArray *)colors;

- (void)colorButtonAction:(id)aSender;
- (void)closeButtonAction;

@end

@protocol A3ChooseColorDelegate <NSObject>

@required
- (void)chooseColorDidSelect:(UIColor *)aColor selectedIndex:(NSUInteger)selectedIndex;
- (void)chooseColorDidCancel;

@end
