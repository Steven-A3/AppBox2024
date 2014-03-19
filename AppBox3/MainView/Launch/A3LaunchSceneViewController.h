//
//  A3LaunchSceneViewController.h
//  AppBox3
//
//  Created by A3 on 3/17/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol A3LaunchSceneViewControllerDelegate;

@interface A3LaunchSceneViewController : UIViewController

@property (nonatomic, weak) id<A3LaunchSceneViewControllerDelegate> delegate;
@property (nonatomic, assign) NSUInteger sceneNumber;

@property (weak, nonatomic) IBOutlet UIButton *rightButton;
@end
