//
//  A3TouchableImageView.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 8/9/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3TouchableImageView.h"

@implementation A3TouchableImageView

#pragma mark Zoom/Scrollable image view

- (id)initWithFrame:(CGRect)frame
{
	if ((self = [super initWithFrame:frame])) {
		self.showsVerticalScrollIndicator = NO;
		self.showsHorizontalScrollIndicator = NO;
		self.bouncesZoom = YES;
		self.delegate = self;
        
		self.userInteractionEnabled = YES;
		self.clipsToBounds = YES;
		self.contentMode = UIViewContentModeCenter;
		self.decelerationRate = .85;
		self.contentSize = CGSizeMake(frame.size.width, frame.size.height);
	}
	return self;
}

#pragma mark -
#pragma mark Override layoutSubviews to center content

- (void)layoutSubviews
{
	[super layoutSubviews];
	
	// center the image as it becomes smaller than the size of the screen
	
	CGSize boundsSize = self.bounds.size;
	CGRect frameToCenter = _imageView.frame;
	
	// center horizontally
	if (frameToCenter.size.width < boundsSize.width)
		frameToCenter.origin.x = (boundsSize.width - frameToCenter.size.width) / 2;
	else
		frameToCenter.origin.x = 0;
	
	// center vertically
	if (frameToCenter.size.height < boundsSize.height)
		frameToCenter.origin.y = (boundsSize.height - frameToCenter.size.height) / 2;
	else
		frameToCenter.origin.y = 0;
	
	_imageView.frame = frameToCenter;
}

#pragma mark -
#pragma mark UIScrollView delegate methods

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
	return _imageView;
}

#pragma mark -
#pragma mark Configure scrollView to display new image (tiled or not)

- (void)displayImage:(UIImage *)image
{
	// clear the previous _imageView
	[_imageView removeFromSuperview];
	_imageView = nil;
	
	// reset our zoomScale to 1.0 before doing any further calculations
	self.zoomScale = 1.0;
	
	if (image) {
		// make a new UIImageView for the new image
		_imageView = [[UIImageView alloc] initWithImage:image];
		_imageView.contentMode = UIViewContentModeScaleAspectFit;
		[self addSubview:_imageView];
		
		[self configureForImageSize:[image size]];
	}
}

- (void)centerImageAfterZoom {
	[self setContentOffset:CGPointMake(MAX(0.0, self.contentSize.width - CGRectGetWidth(self.bounds) ) / 2.0,
									   MAX(0.0, self.contentSize.height - CGRectGetHeight(self.bounds) ) / 2.0 )];
}

- (void)configureForImageSize:(CGSize)imageSize
{
	CGSize boundsSize = [self bounds].size;
	
	// set up our content size and min/max zoomscale
	CGFloat xScale = boundsSize.width / imageSize.width;	// the scale needed to perfectly fit the image width-wise
	CGFloat yScale = boundsSize.height / imageSize.height;	// the scale needed to perfectly fit the image height-wise
    
	if (boundsSize.width < boundsSize.height) {
		if (imageSize.width < imageSize.height) {
			initialZoomScale = MAX(xScale, yScale);
		} else {
			initialZoomScale = MIN(xScale, yScale);
		}
	} else {
		if (imageSize.width < imageSize.height) {
			initialZoomScale = MIN(xScale, yScale);
		} else {
			initialZoomScale = MAX(xScale, yScale);
		}
	}
	CGFloat minScale = MIN(xScale, yScale);					// use minimum of these to allow the image to become fully visible
	
	// on high resolution screens we have double the pixel density, so we will be seeing every pixel if we limit the
	// maximum zoom scale to 0.5.
	CGFloat maxScale = 2.0;
	
	// don't let minScale exceed maxScale. (If the image is smaller than the screen, we don't want to force it to be zoomed.)
	if (minScale > maxScale) {
		minScale = maxScale;
	}
	
	self.contentSize = imageSize;
	self.maximumZoomScale = maxScale;
	self.minimumZoomScale = minScale;
    
	self.zoomScale = initialZoomScale;	// start out with the content fully visible
    
	[self centerImageAfterZoom];
}

- (void)resetZoomsScale {
	[self setZoomScale:initialZoomScale animated:YES];
	[self centerImageAfterZoom];
}

- (void)configureForImageSize {
	[self configureForImageSize:_imageView.image.size];
}

#pragma mark Touch control

- (void)addTarget:(id)target action:(SEL)touchup_action doubleTapAction:(SEL)doubleTap_action {
	delegate = target;
	singleTapSelector = touchup_action;
	doubleTapSelector = doubleTap_action;
	
	self.userInteractionEnabled = YES;
}

- (void)addTarget:(id)target action:(SEL)touchup_action {
	[self addTarget:target action:touchup_action doubleTapAction:nil];
}

- (void)stopTimer {
	[tTimer invalidate];
	tTimer = nil;
}

- (void)singleTapAction {
	if (tTimer)
		[self stopTimer];
	
	if (singleTapSelector)
		[delegate performSelector:singleTapSelector];
}

- (CGRect)zoomRectForScale:(float)scale withCenter:(CGPoint)center {
	CGRect zoomRect;
	
	// the zoom rect is in the content view's coordinates.
	//	  At a zoom scale of 1.0, it would be the size of the imageScrollView's bounds.
	//	  As the zoom scale decreases, so more content is visible, the size of the rect grows.
	zoomRect.size.height = [self frame].size.height * scale;
	zoomRect.size.width	 = [self frame].size.width * scale;
	
	// choose an origin so as to get the right center.
	zoomRect.origin.x = (center.x - (zoomRect.size.width  / 2.0));
	zoomRect.origin.y = (center.y - (zoomRect.size.height / 2.0));
	
	return zoomRect;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	[super touchesEnded:touches withEvent:event];
    
	NSUInteger numTaps = [[touches anyObject] tapCount];
	
	if (numTaps == 1) {
		if (doubleTapSelector) {
			if (tTimer == nil) {
				NSTimer *timer = [[NSTimer alloc] initWithFireDate:[NSDate dateWithTimeIntervalSinceNow:0.35]
														  interval:0.0
															target:self
														  selector:@selector(singleTapAction)
														  userInfo:nil
														   repeats:NO];
				tTimer = timer;
				NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
				[runLoop addTimer:tTimer forMode:NSDefaultRunLoopMode];
			}
			else {
				[self stopTimer];
			}
		}
		else {
			[self singleTapAction];
		}
	}
	else {
		if (tTimer)
			[self stopTimer];
	}
    
	if (numTaps == 2) {
		if (self.zoomScale == initialZoomScale) {
			CGPoint touchLocation = [[touches anyObject] locationInView:_imageView];
			CGRect zoomRect = [self zoomRectForScale:self.maximumZoomScale - self.zoomScale withCenter:touchLocation];
			[self zoomToRect:zoomRect animated:YES];
		} else {
			[self setZoomScale:initialZoomScale animated:YES];
			[self centerImageAfterZoom];
		}
	}
}

- (void)dealloc {
	[self stopTimer];
}

@end
