//
//  A3ChooseColorView.h
//  A3TeamWork
//
//  Created by Sanghyun Yu on 2013. 11. 29..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//


@protocol A3ChooseColorDelegate <NSObject>

@required
- (void)chooseColorDidSelect:(UIColor *)aColor selectedIndex:(NSUInteger)selectedIndex;
- (void)chooseColorDidCancel;

@end

@interface A3ChooseColorView : UIView

@property (nonatomic, strong) UICollectionView *collectionView;
@property(nonatomic, weak) id<A3ChooseColorDelegate> delegate;

- (id)initWithFrame:(CGRect)frame colors:(NSArray *)colors selectedIndex:(NSUInteger)selectedIndex;
- (void)closeButtonAction;
+ (A3ChooseColorView *)chooseColorWaveInViewController:(UIViewController <A3ChooseColorDelegate> *)targetViewController inView:(UIView *)view colors:(NSArray *)colos selectedIndex:(NSUInteger)selectedIndex;

@end
