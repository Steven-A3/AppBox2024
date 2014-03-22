//
//  A3DaysCounterSlideshowViewController.m
//  A3TeamWork
//
//  Created by coanyaa on 2013. 11. 11..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3DaysCounterSlideshowViewController.h"
#import "UIViewController+A3Addition.h"
#import "UIViewController+A3AppCategory.h"
#import "A3DaysCounterDefine.h"
#import "A3DaysCounterModelManager.h"
#import "A3UserDefaults.h"
#import "DaysCounterEvent.h"
#import "MPFoldTransition.h"

@interface A3DaysCounterSlideshowViewController ()
@property (strong, nonatomic) NSArray *itemArray;

@property (strong, nonatomic) UIView *currentView;
@property (strong, nonatomic) UIView *nextView;

- (void)slideTimerAction:(NSTimer*)theTimer;
- (void)startTimer;
- (void)stopTimer;
- (void)addView:(UIView*)addView;
- (void)endSlideshow;

- (void)cubeTransition;
- (void)origamiTransition;
- (void)rippleTransition;
- (void)wipeTransition;
- (void)dissolveTransition;

@end

@implementation A3DaysCounterSlideshowViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Slide Show";
    currentIndex = 0;
    
    if( self.optionDict == nil )
        self.optionDict = [[NSUserDefaults standardUserDefaults] objectForKey:A3DaysCounterSlideshowOption];
    self.itemArray = [[A3DaysCounterModelManager sharedManager] allEventsListContainedImage];
    
    if( [[_optionDict objectForKey:OptionKey_Shuffle] boolValue] ){
        self.itemArray = [self shuffleArray:self.itemArray];
    }
    
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
    [self.view addGestureRecognizer:gesture];
    
    self.currentView = [[[NSBundle mainBundle] loadNibNamed:@"A3DaysCounterSlideshowEventSummaryView" owner:nil options:nil] objectAtIndex:0];
    
    [[A3DaysCounterModelManager sharedManager] setupEventSummaryInfo:[_itemArray objectAtIndex:currentIndex] toView:self.currentView];
    
    self.currentView.userInteractionEnabled = NO;
    [self addView:self.currentView];
    
    if( self.navigationController )
       [self.navigationController setToolbarHidden:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self startTimer];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    if( slideTimer == nil )
        [[A3DaysCounterModelManager sharedManager] setupEventSummaryInfo:[_itemArray objectAtIndex:currentIndex] toView:self.currentView];
//    else if( self.nextView )
//        [[A3DaysCounterModelManager sharedManager] setupEventSummaryInfo:[_itemArray objectAtIndex:currentIndex] toView:self.nextView];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)usesFullScreenInLandscape
{
    return (IS_IPAD && UIInterfaceOrientationIsLandscape(self.interfaceOrientation));
}

- (void)dealloc
{
    self.itemArray = nil;
    self.optionDict = nil;
    self.currentView = nil;
    self.nextView = nil;
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if( buttonIndex == alertView.firstOtherButtonIndex ){
        [self endSlideshow];
    }
}

#pragma mark
- (NSArray*) shuffleArray:(NSArray*) array {
    NSMutableArray* temp = [NSMutableArray arrayWithArray:array];
    
    NSUInteger count = [temp count] * 5;
    for (NSUInteger i = 0; i < count; i++) {
        NSUInteger index1 = i % [temp count];
        NSUInteger index2 = arc4random() % [temp count];
        
        if (index1 != index2) {
            [temp exchangeObjectAtIndex:index1 withObjectAtIndex:index2];
        }
    }
    return temp;
}

- (void)cubeTransition
{
    CATransition *t = [CATransition animation];
	t.type = @"cube";
	t.subtype = kCATransitionFromRight;
	
    t.duration = 0.7;
    t.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    t.delegate = self;
    
	[self.currentView removeFromSuperview];
    [self addView:self.nextView];
    [self.view.layer addAnimation:t forKey:@"Transition"];
    
}

- (void)origamiTransition
{
    CGSize size = self.view.frame.size;
    if( UIInterfaceOrientationIsLandscape(self.interfaceOrientation) )
        size = CGSizeMake(self.view.frame.size.height, self.view.frame.size.width);
    //    self.currentView.bounds = CGRectMake(0, 0, size.width, size.height);
    //    self.nextView.bounds = self.currentView.bounds;
    self.currentView.frame = CGRectMake(0, 0, size.width, size.height);
    self.nextView.frame = self.currentView.frame;
    
    [self addView:self.nextView];
    [self.nextView removeFromSuperview];
    
    
    //    MPFoldTransition *foldTransition = [[MPFoldTransition alloc] initWithSourceView:self.currentView destinationView:self.nextView duration:0.7 style:MPFoldStyleDefault completionAction:MPTransitionActionNone];
    //    foldTransition.rect = self.nextView.frame;
    //    [foldTransition perform:^(BOOL finished) {
    //        if( finished ){
    //            [self.currentView removeFromSuperview];
    //            [self addView:self.nextView];
    //            self.currentView = self.nextView;
    //            [self startTimer];
    //        }
    //    }];
    
    
    [MPFoldTransition transitionFromView:self.currentView toView:self.nextView duration:0.7 style:MPFoldStyleDefault transitionAction:MPTransitionActionNone completion:^(BOOL finished) {
        if( finished ){
            [self.currentView removeFromSuperview];
            [self addView:self.nextView];
            self.currentView = self.nextView;
            [self startTimer];
        }
    }];
}

- (void)rippleTransition
{
    CATransition *t = [CATransition animation];
	t.type = @"rippleEffect";
	t.subtype = kCATransitionFromRight;
	
    t.duration = 1.5;
    t.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    t.delegate = self;
    
	[self.currentView removeFromSuperview];
    [self addView:self.nextView];
    [self.view.layer addAnimation:t forKey:@"Transition"];
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    [self.currentView removeFromSuperview];
    self.currentView = self.nextView;
    [self startTimer];
}

- (void)wipeTransition
{
    self.currentView.clipsToBounds = YES;
    self.nextView.frame = self.view.bounds;
    
    NSLog(@"%s %@ / %@ / %@",__FUNCTION__,NSStringFromCGRect(self.view.bounds),NSStringFromCGRect(_nextView.frame),NSStringFromCGRect(_currentView.frame));
    
    [self insertView:self.nextView belowView:self.currentView];
    
    CAShapeLayer *clipLayer = [[CAShapeLayer alloc] init];
    CGPathRef path = CGPathCreateWithRect(_currentView.bounds, nil);
    clipLayer.path = path;
    self.currentView.layer.mask = clipLayer;
    
    CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:@"path"];
    pathAnimation.duration = 0.7;
    pathAnimation.fromValue = (__bridge id)(path);
    pathAnimation.toValue = (__bridge id)(CGPathCreateWithRect(CGRectMake(0, 0, 0, _currentView.frame.size.height), nil));
    pathAnimation.repeatCount = 1;
    pathAnimation.autoreverses = NO;
    pathAnimation.delegate = self;
    [clipLayer addAnimation:pathAnimation forKey:@"path"];
    
}

- (void)dissolveTransition
{
    [UIView transitionWithView:self.view duration:0.7 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        [self.currentView removeFromSuperview];
        [self.view addSubview:self.nextView];
    } completion:^(BOOL finished) {
        self.currentView = self.nextView;
        [self startTimer];
    }];
}

- (void)slideTimerAction:(NSTimer*)theTimer
{
    if( currentIndex + 1 >= [_itemArray count]){
        if(![[_optionDict objectForKey:OptionKey_Repeat] boolValue] ){
            [self endSlideshow];
            return;
        }
        else{
            self.itemArray = [self shuffleArray:self.itemArray];
        }
    }
    
    currentIndex = (currentIndex+1) % [_itemArray count];
    self.nextView = [[[NSBundle mainBundle] loadNibNamed:@"A3DaysCounterSlideshowEventSummaryView" owner:nil options:nil] objectAtIndex:0];
    CGSize size = ( UIInterfaceOrientationIsLandscape(self.interfaceOrientation) ? CGSizeMake(self.view.frame.size.height, self.view.frame.size.width) : self.view.frame.size );
    _nextView.frame = CGRectMake(0, 0, size.width, size.height);
    
    [[A3DaysCounterModelManager sharedManager] setupEventSummaryInfo:[_itemArray objectAtIndex:currentIndex] toView:self.nextView];
    self.nextView.userInteractionEnabled = NO;
    
    NSInteger transitionType = [[_optionDict objectForKey:OptionKey_Transition] integerValue];
    
    switch (transitionType) {
        case TransitionType_Cube:
            [self cubeTransition];
            break;
        case TransitionType_Origami:
            [self origamiTransition];
            break;
        case TransitionType_Ripple:
            [self rippleTransition];
            break;
        case TransitionType_Wipe:
            [self wipeTransition];
            break;
        case TransitionType_Dissolve:
        default:
            [self dissolveTransition];
            break;
    }
}

- (void)startTimer
{
    if(slideTimer)
        [slideTimer invalidate];
    slideTimer = [NSTimer scheduledTimerWithTimeInterval:[[_optionDict objectForKey:OptionKey_Showtime] doubleValue] target:self selector:@selector(slideTimerAction:) userInfo:nil repeats:NO];
}

- (void)stopTimer
{
    if( slideTimer )
        [slideTimer invalidate];
    slideTimer = nil;
}

- (void)addView:(UIView*)addView
{
    if( [addView isDescendantOfView:self.view] )
        return;
    
    addView.translatesAutoresizingMaskIntoConstraints = NO;
    addView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    //    NSLog(@"%s %@ / %@",__FUNCTION__,NSStringFromCGRect(addView.frame),NSStringFromCGRect(self.view.bounds));
    [self.view addSubview:addView];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:addView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0.0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:addView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0.0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:addView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:addView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0]];
    [self.view layoutIfNeeded];
    
}

- (void)insertView:(UIView*)addView belowView:(UIView*)targetView
{
    if( [addView isDescendantOfView:self.view] )
        return;
    
    addView.translatesAutoresizingMaskIntoConstraints = NO;
    addView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    
    NSLog(@"%s %@ / %@ / %@",__FUNCTION__,NSStringFromCGRect(addView.frame),NSStringFromCGRect(self.view.bounds),NSStringFromCGRect(self.view.frame));
    
    [self.view insertSubview:addView belowSubview:targetView];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:addView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0.0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:addView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0.0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:addView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:addView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0]];
    //    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:addView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0]];
    //    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:addView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0]];
    [self.view layoutIfNeeded];
}

- (void)endSlideshow
{
    [self stopTimer];
    
    if (IS_IPHONE) {
        [self dismissViewControllerAnimated:NO completion:^{
            if (_completionBlock) {
                _completionBlock();
            }
        }];
    }
    else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)handleTapGesture:(UITapGestureRecognizer*)gesture
{
    [self endSlideshow];
    //    UIAlertView *alertView =[[UIAlertView alloc] initWithTitle:nil message:@"Do you want to exit?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
    //    [alertView show];
}

@end
