//
//  A3RandomViewController.h
//  AppBox3
//
//  Created by kimjeonghwan on 9/24/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface A3RandomViewController : UIViewController

- (IBAction)randomButtonTouchUp:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *resultPrintLabel;
@property (weak, nonatomic) IBOutlet UIPickerView *limitNumberPickerView;
@property (weak, nonatomic) IBOutlet UIButton *generatorButton;

@end
