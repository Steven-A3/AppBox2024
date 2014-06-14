//
//  A3SlideshowActivity.m
//  A3TeamWork
//
//  Created by coanyaa on 13. 10. 19..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3SlideshowActivity.h"
#import "A3DaysCounterSlideshowOptionViewController.h"
#import "A3DaysCounterModelManager.h"
#import "A3DaysCounterSlideshowViewController.h"

@interface A3SlideshowActivity ()
@property (strong, nonatomic) UIImage *playImage;

@end

@implementation A3SlideshowActivity

- (id)init
{
    self = [super init];
    if ( self ) {
        self.playImage = [UIImage imageNamed:IS_IPHONE ? @"share_slideshow" : @"share_slideshow_iPad"];
    }
    
    return self;
}

- (void)dealloc
{
    self.playImage = nil;
}

- (UIImage*)activityImage
{
    return self.playImage;
}

- (NSString*)activityTitle
{
    return NSLocalizedString(@"Slideshow", @"Slideshow");
}

- (NSString *)activityType
{
    return @"Slideshow";
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems
{
    FNLOG();
    return YES;
}

- (void)prepareWithActivityItems:(NSArray *)activityItems
{
    FNLOG();
}

- (void)performActivity
{
    FNLOG();
}

- (void)activityDidFinish:(BOOL)completed
{
    [super activityDidFinish:completed];
	FNLOG();
}

- (UIViewController*)activityViewController
{
    FNLOG();

    if( IS_IPHONE ){
        A3DaysCounterSlideshowOptionViewController *viewCtrl = [[A3DaysCounterSlideshowOptionViewController alloc] initWithNibName:nil bundle:nil];
        viewCtrl.activity = self;
        viewCtrl.sharedManager = _sharedManager;
        viewCtrl.completionBlock = _completionBlock;

        UINavigationController *navCtrl = [[UINavigationController alloc] initWithRootViewController:viewCtrl];
        
        return navCtrl;
    }
    else{
        [self activityDidFinish:YES];
    }
    
    return nil;
}

@end
