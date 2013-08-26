//
//  A3ImageView.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 8/23/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3ImageView.h"
#import "UIImage+Resizing.h"
#import "common.h"

@implementation A3ImageView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)setImage:(UIImage *)image {
	CGRect bounds = CGRectInset(self.bounds, -50, -50);
	UIImage *scaledImage = [image scaleToCoverSize:bounds.size];
	UIImage *croppedImage = [scaledImage cropToSize:bounds.size usingMode:NYXCropModeCenter];
	FNLOG(@"%f, %f >> %f, %f", image.size.width, image.size.height, croppedImage.size.width, croppedImage.size.height);
	[super setImage:croppedImage ];
}

@end
