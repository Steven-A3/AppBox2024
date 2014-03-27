//
//  A3KeyboardButton_iOS7.h
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 10/11/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

@interface A3KeyboardButton_iOS7 : UIButton

@property (nonatomic, strong)	UILabel *mainTitle;
@property (nonatomic, strong)	UILabel *subTitle;
@property (nonatomic, strong)	UIColor *backgroundColorForHighlightedState;
@property (nonatomic, strong)	UIColor *backgroundColorForDefaultState;
@property (nonatomic, strong)	UIColor *backgroundColorForSelectedState;

- (void)removeExtraLabels;

@end
