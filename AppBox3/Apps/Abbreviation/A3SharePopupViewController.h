//
//  A3SharePopupViewController.h
//  AppBox3
//
//  Created by Byeong-Kwon Kwak on 1/7/17.
//  Copyright © 2017 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol A3SharePopupViewDataSource;
@protocol A3SharePopupViewControllerDelegate;

@interface A3SharePopupViewController : UIViewController

@property (nonatomic, assign) BOOL shouldInsertBlurView;
@property (nonatomic, assign) BOOL presentationIsInteractive;
@property (nonatomic, assign) CGFloat interactiveTransitionProgress;
@property (nonatomic, weak) id<A3SharePopupViewDataSource> dataSource;
@property (nonatomic, weak) id<A3SharePopupViewControllerDelegate> delegate;

@property (nonatomic, copy) NSString *titleString;

+ (A3SharePopupViewController *)storyboardInstanceWithBlurBackground:(BOOL)insertBlurView;

- (void)completeCurrentInteractiveTransition;
- (void)cancelCurrentInteractiveTransition;

@end

@protocol A3SharePopupViewDataSource <NSObject>

- (BOOL)isMemberOfFavorites:(NSString *)titleString;
- (void)addToFavorites:(NSString *)titleString;
- (void)removeFromFavorites:(NSString *)titleString;

- (NSString *)stringForShare:(NSString *)titleString;
- (NSString *)subjectForActivityType:(NSString *)activityType;
- (NSString *)placeholderForShare:(NSString *)titleString;

@end

@protocol A3SharePopupViewControllerDelegate <NSObject>
@optional

- (void)sharePopupViewControllerWillDismiss:(A3SharePopupViewController *)viewController;

@end
