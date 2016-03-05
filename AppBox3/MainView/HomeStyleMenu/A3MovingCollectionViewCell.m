//
//  A3MovingCollectionViewCell.m
//  HexagonMenu
//
//  Created by Byeong Kwon Kwak on 2/25/16.
//  Copyright © 2016 ALLABOUTAPPS. All rights reserved.
//

#import "A3MovingCollectionViewCell.h"

@implementation A3MovingCollectionViewCell

- (instancetype)initWithCell:(UICollectionViewCell *)cell{
	self = [super initWithFrame:cell.frame];
	if (self) {
		self.cell = cell;
		
		self.layer.shadowColor = [UIColor blackColor].CGColor;
		self.layer.shadowOffset = CGSizeMake(0, 0);
		self.layer.shadowOpacity = 0;
		self.layer.shadowRadius = 5.0;
		self.layer.shouldRasterize = false;
		
		self.cellFakeImageView = [[UIImageView alloc]initWithFrame:self.bounds];
		self.cellFakeImageView.contentMode = UIViewContentModeScaleAspectFill;
		self.cellFakeImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		
		self.cellFakeHightedView = [[UIImageView alloc]initWithFrame:self.bounds];
		self.cellFakeHightedView.contentMode = UIViewContentModeScaleAspectFill;
		self.cellFakeHightedView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		
		cell.highlighted = YES;
		self.cellFakeHightedView.image = [self getCellImage];
		cell.highlighted = NO;
		self.cellFakeImageView.image = [self getCellImage];
		
		[self addSubview:self.cellFakeImageView];
		[self addSubview:self.cellFakeHightedView];
		
	}
	
	return self;
}

- (void)changeBoundsIfNeeded:(CGRect)bounds{
	if (CGRectEqualToRect(self.bounds, bounds)) {
		return;
	}
	[UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut|UIViewAnimationOptionBeginFromCurrentState animations:^{
		self.bounds = bounds;
	} completion:nil];
}

- (void)pushFowardView{
	[UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut|UIViewAnimationOptionBeginFromCurrentState animations:^{
		self.center = self.originalCenter;
		self.transform = CGAffineTransformMakeScale(1.5, 1.5);
		self.cellFakeHightedView.alpha = 0;
		
		CABasicAnimation *shadowAnimation = [CABasicAnimation animationWithKeyPath:@"shadowOpacity"];
		shadowAnimation.fromValue = @(0);
		shadowAnimation.toValue = @(0.7);
		shadowAnimation.removedOnCompletion = NO;
		shadowAnimation.fillMode = kCAFillModeForwards;
		[self.layer addAnimation:shadowAnimation forKey:@"applyShadow"];
	} completion:^(BOOL finished) {
		[self.cellFakeHightedView removeFromSuperview];
	}];
}

- (void)pushBackView:(void(^)(void))completion{
	[UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut|UIViewAnimationOptionBeginFromCurrentState animations:^{
		self.transform = CGAffineTransformIdentity;
		self.frame = self.cellFrame;
		CABasicAnimation *shadowAnimation = [CABasicAnimation animationWithKeyPath:@"shadowOpacity"];
		shadowAnimation.fromValue = @(0.7);
		shadowAnimation.toValue = @(0);
		shadowAnimation.removedOnCompletion = NO;
		shadowAnimation.fillMode = kCAFillModeForwards;
		[self.layer addAnimation:shadowAnimation forKey:@"removeShadow"];
	} completion:^(BOOL finished) {
		if (completion) {
			completion();
		}
	}];
}

- (UIImage *)getCellImage{
	UIGraphicsBeginImageContextWithOptions(_cell.bounds.size, NO, [UIScreen mainScreen].scale * 2);
	[_cell drawViewHierarchyInRect:_cell.bounds afterScreenUpdates:YES];
	UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return image;
}

@end
