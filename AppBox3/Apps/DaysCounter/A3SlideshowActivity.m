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
    return @"Slideshow";
}

- (NSString *)activityType
{
    return @"Slideshow";
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems
{
    NSLog(@"%s",__FUNCTION__);
    return YES;
}

- (void)prepareWithActivityItems:(NSArray *)activityItems
{
    NSLog(@"%s",__FUNCTION__);
}

- (void)performActivity
{
    NSLog(@"%s ",__FUNCTION__);
}

- (void)activityDidFinish:(BOOL)completed
{
    NSLog(@"%s",__FUNCTION__);
    [super activityDidFinish:completed];
}

- (UIViewController*)activityViewController
{
    NSLog(@"%s",__FUNCTION__);
    if( IS_IPHONE ){
        A3DaysCounterSlideshowOptionViewController *viewCtrl = [[A3DaysCounterSlideshowOptionViewController alloc] initWithNibName:@"A3DaysCounterSlideshowOptionViewController" bundle:nil];
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
