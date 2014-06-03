//
//  A3LaunchSceneViewController.h
//  AppBox3
//
//  Created by A3 on 3/17/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

@protocol A3LaunchSceneViewControllerDelegate;

@interface A3LaunchSceneViewController : UIViewController

@property (weak, nonatomic) id<A3LaunchSceneViewControllerDelegate> delegate;
@property (assign, nonatomic) NSUInteger sceneNumber;

@property (weak, nonatomic) IBOutlet UIButton *singleButton;
@property (weak, nonatomic) IBOutlet UIButton *leftButton;
@property (weak, nonatomic) IBOutlet UIButton *rightButton;
@property (assign, nonatomic) BOOL showAsWhatsNew;

- (void)hideButtons;

- (void)showButtons;
@end
