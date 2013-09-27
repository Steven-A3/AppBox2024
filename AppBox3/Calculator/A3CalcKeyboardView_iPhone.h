//
//  A3CalcKeyboardView_iPhone.h
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 9/22/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol A3CalcKeyboardViewDelegate <NSObject>
- (void)keyboardButtonPressed:(NSUInteger)key;
@end

@interface A3CalcKeyboardView_iPhone : UIView
@property (nonatomic, weak) id<A3CalcKeyboardViewDelegate> delegate;
@end
