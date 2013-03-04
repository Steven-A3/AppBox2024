//
//  A3KeyboardButton.h
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 12/21/12.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface A3KeyboardButton : UIButton

@property (nonatomic)	BOOL blueColorOnHighlighted;
@property (nonatomic, strong)	UILabel *mainTitle;
@property (nonatomic, strong)	UILabel *subTitle;

- (void)removeExtraLabels;
@end
