//
//  A3InstructionViewController.h
//  AppBox3
//
//  Created by kimjeonghwan on 6/5/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString *const StoryBoardID_BatteryStatus;
extern NSString *const StoryBoardID_Calcualtor;

@protocol A3InstructionViewControllerDelegate <NSObject>
@required
- (void)dismissInstructionViewController:(UIView *)view;

@end

@interface A3InstructionViewController : UIViewController
@property (weak, nonatomic) id<A3InstructionViewControllerDelegate> delegate;
@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *childImageViews;
- (IBAction)viewTapped:(UITapGestureRecognizer *)sender;

@end
