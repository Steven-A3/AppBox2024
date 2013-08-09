//
//  A3TouchableImageView.h
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 8/9/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface A3TouchableImageView : UIScrollView <UIScrollViewDelegate> {
id delegate;
SEL	singleTapSelector;
SEL doubleTapSelector;
NSTimer *tTimer;
UIImageView	*_imageView;
CGFloat	initialZoomScale;
}

@property (nonatomic, retain)	UIImageView *imageView;

- (void)addTarget:(id)target action:(SEL)action;
- (void)addTarget:(id)target action:(SEL)action doubleTapAction:(SEL)doubleTap_action;

- (void)displayImage:(UIImage *)image;
- (void)configureForImageSize:(CGSize)imageSize;
- (void)resetZoomsScale;
- (void)configureForImageSize;

@end
