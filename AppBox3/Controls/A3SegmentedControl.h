//
//  A3WalletSegmentedControl.h
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 10/10/12.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol A3SegmentedControlDataSource, A3SegmentedControlDelegate;

@interface A3SegmentedControl : UIControl

@property (nonatomic, assign) NSUInteger numberOfSegment;
@property (nonatomic, assign) NSUInteger selectedIndex;
@property (nonatomic, strong) NSArray *segmentArray;
@property (nonatomic, weak)	  IBOutlet id <A3SegmentedControlDelegate> delegate;
@property (nonatomic, weak)   IBOutlet id <A3SegmentedControlDataSource> dataSource;

@end

@protocol A3SegmentedControlDelegate <NSObject>
@required
- (void)segmentedControl:(A3SegmentedControl *)control didChangedSelectedIndex:(NSInteger)selectedIndex fromIndex:(NSInteger)fromIndex;
@end

@protocol A3SegmentedControlDataSource <NSObject>
@required

- (NSUInteger)numberOfColumnsInSegmentedControl:(A3SegmentedControl *)control;
- (UIImage *)segmentedControl:(A3SegmentedControl *)control imageForIndex:(NSUInteger)index;
- (NSString *)segmentedControl:(A3SegmentedControl *)control titleForIndex:(NSUInteger)index;

@end
