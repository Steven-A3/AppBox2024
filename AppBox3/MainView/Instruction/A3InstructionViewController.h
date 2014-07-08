//
//  A3InstructionViewController.h
//  AppBox3
//
//  Created by kimjeonghwan on 6/5/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString *const A3StoryboardInstruction_iPhone;
extern NSString *const A3StoryboardInstruction_iPad;
extern NSString *const StoryBoardID_BatteryStatus;
extern NSString *const StoryBoardID_Calculator;

@protocol A3InstructionViewControllerDelegate <NSObject>
@required
- (void)dismissInstructionViewController:(UIView *)view;

@end

@interface A3InstructionViewController : UIViewController
@property (weak, nonatomic) id<A3InstructionViewControllerDelegate> delegate;
@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *childImageViews;
@property (assign, nonatomic) BOOL isFirstInstruction;
@property (assign, nonatomic) BOOL disableAnimation;
- (IBAction)viewTapped:(UITapGestureRecognizer *)sender;

#pragma mark - Clock1 Constraints
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *clock1_finger2RightConst;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *clock1_finger3RightConst;

#pragma mark - Wallet_3 Constraints
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *wallet3_finger2BottomConst;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *wallet3_finger3BottomConst;


@end
