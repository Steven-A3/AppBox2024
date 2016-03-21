//
//  A3HomeStyleHelpViewController.h
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 3/20/16.
//  Copyright © 2016 ALLABOUTAPPS. All rights reserved.
//

#import "A3InstructionViewController.h"

@interface A3HomeStyleHelpViewController : A3InstructionViewController

@property (nonatomic, weak) IBOutlet NSLayoutConstraint *fingerUpCenterXConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *fingerUpCenterYConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *helpTextHeightConstraint;
@property (nonatomic, weak) IBOutlet UILabel *helpLabel;
@property (nonatomic, weak) IBOutlet UIImageView *homeStyleListImageView;
@property (nonatomic, weak) IBOutlet UIImageView *homeStyleHexagonImageView;
@property (nonatomic, weak) IBOutlet UIImageView *homeStyleGridImageView;

@end
