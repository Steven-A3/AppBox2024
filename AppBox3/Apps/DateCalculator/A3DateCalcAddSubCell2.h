//
//  A3DateCalcAddSubCell2.h
//  A3TeamWork
//
//  Created by jeonghwan kim on 13. 11. 13..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface A3DateCalcAddSubCell2 : UITableViewCell

@property (weak, nonatomic) IBOutlet UITextField *yearTextField;
@property (weak, nonatomic) IBOutlet UITextField *monthTextField;
@property (weak, nonatomic) IBOutlet UITextField *dayTextField;

@property (weak, nonatomic) IBOutlet UILabel *yearLabel;
@property (weak, nonatomic) IBOutlet UILabel *monthLabel;
@property (weak, nonatomic) IBOutlet UILabel *dayLabel;

@property (weak, nonatomic) IBOutlet UIView *topLineView;
@property (weak, nonatomic) IBOutlet UIView *sep1LineView;
@property (weak, nonatomic) IBOutlet UIView *sep2LineView;
@property (weak, nonatomic) IBOutlet UIView *bottomLineView;

-(void)setOffsetDateComp:(NSDateComponents *)aDateComp;
-(void)saveInputedTextField:(UITextField *)textField;
-(BOOL)hasEqualTextField:(UITextField *)textField;
+(NSDateComponents *)dateComponentBySavedText;

@end
