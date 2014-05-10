//
//  A3CalculatorButtonsInBasicViewController.m
//  A3TeamWork
//
//  Created by Soon Gyu Kim on 12/24/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3CalculatorButtonsInBasicViewController_iPad.h"

@interface A3CalculatorButtonsInBasicViewController_iPad ()

@end

@implementation A3CalculatorButtonsInBasicViewController_iPad

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
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillLayoutSubviews {
    CGFloat p_bigbuttonwidth = 120.0, p_smallbuttonwidth = 90.0, p_buttonheight = 89.0;
    CGFloat l_bigbuttonwidth = 168.0, l_smallbuttonwidth = 107.0, l_buttonheight = 74.0;
    CGFloat start_x, start_y, v_space, h_bigspace,h_smallspace;
    CGFloat current_x, current_y, bigbuttonwidth, smallbuttonwidth, buttonheight;

	if (IS_PORTRAIT) {
		[_calculatorkeypadvw setFrame:CGRectMake(0.0,  617.0, 768.0, 407.0)];
        start_x = 22.0,start_y = 10.0, v_space = 11.0, h_bigspace = 24.0, h_smallspace = 11.0;
        bigbuttonwidth = p_bigbuttonwidth, smallbuttonwidth = p_smallbuttonwidth,buttonheight = p_buttonheight;
	} else {
		[_calculatorkeypadvw setFrame:CGRectMake(0.0, 420.0, 1024.0, 348.0)];
        start_x = 33.0,start_y = 10.0, v_space = 11.0, h_bigspace = 33.0, h_smallspace = 17.0;
        bigbuttonwidth = l_bigbuttonwidth, smallbuttonwidth = l_smallbuttonwidth,buttonheight = l_buttonheight;
	}
    
    current_x = start_x, current_y = start_y;
    [self.percentbutton setFrame:CGRectMake(current_x, current_y, bigbuttonwidth, buttonheight)];
    current_x += (bigbuttonwidth + h_bigspace);
    [self.dividebutton setFrame:CGRectMake(current_x, current_y, bigbuttonwidth, buttonheight)];
    current_x += (bigbuttonwidth + h_bigspace);
    [self.number7button setFrame:CGRectMake(current_x, current_y, smallbuttonwidth, buttonheight)];
    current_x += (smallbuttonwidth + h_smallspace);
    [self.number8button setFrame:CGRectMake(current_x, current_y, smallbuttonwidth, buttonheight)];
    current_x += (smallbuttonwidth + h_smallspace);
    [self.number9button setFrame:CGRectMake(current_x, current_y, smallbuttonwidth, buttonheight)];
    current_x += (smallbuttonwidth + h_bigspace);
    [self.deletebutton setFrame:CGRectMake(current_x, current_y, bigbuttonwidth, buttonheight)];
    
    current_x = start_x, current_y = start_y + buttonheight + v_space;
    [self.signbutton setFrame:CGRectMake(current_x, current_y, bigbuttonwidth, buttonheight)];
    current_x += (bigbuttonwidth + h_bigspace);
    [self.multiplybutton setFrame:CGRectMake(current_x, current_y, bigbuttonwidth, buttonheight)];
    current_x += (bigbuttonwidth + h_bigspace);
    [self.number4button setFrame:CGRectMake(current_x, current_y, smallbuttonwidth, buttonheight)];
    current_x += (smallbuttonwidth + h_smallspace);
    [self.number5button setFrame:CGRectMake(current_x, current_y, smallbuttonwidth, buttonheight)];
    current_x += (smallbuttonwidth + h_smallspace);
    [self.number6button setFrame:CGRectMake(current_x, current_y, smallbuttonwidth, buttonheight)];
    current_x += (smallbuttonwidth + h_bigspace);
    [self.clearbutton setFrame:CGRectMake(current_x, current_y, bigbuttonwidth, buttonheight)];
    
    current_x = start_x, current_y = start_y + buttonheight*2 + v_space*2;
    [self.leftparenthesisbutton setFrame:CGRectMake(current_x, current_y, bigbuttonwidth, buttonheight)];
    current_x += (bigbuttonwidth + h_bigspace);
    [self.minusbutton setFrame:CGRectMake(current_x, current_y, bigbuttonwidth, buttonheight)];
    current_x += (bigbuttonwidth + h_bigspace);
    [self.number1button  setFrame:CGRectMake(current_x, current_y, smallbuttonwidth, buttonheight)];
    current_x += (smallbuttonwidth + h_smallspace);
    [self.number2button  setFrame:CGRectMake(current_x, current_y, smallbuttonwidth, buttonheight)];
    current_x += (smallbuttonwidth + h_smallspace);
    [self.number3button setFrame:CGRectMake(current_x, current_y, smallbuttonwidth, buttonheight)];
    current_x += (smallbuttonwidth + h_bigspace);                               
    [self.operationendbutton setFrame:CGRectMake(current_x, current_y, bigbuttonwidth, buttonheight*2+
                                                 v_space)];

    current_x = start_x, current_y = start_y + buttonheight*3 + v_space*3;
    [self.rightparenthesisbutton  setFrame:CGRectMake(current_x, current_y, bigbuttonwidth, buttonheight)];
    current_x += (bigbuttonwidth + h_bigspace);
    [self.plusbutton setFrame:CGRectMake(current_x, current_y, bigbuttonwidth, buttonheight)];
    current_x += (bigbuttonwidth + h_bigspace);
    [self.number0button  setFrame:CGRectMake(current_x, current_y, smallbuttonwidth, buttonheight)];
    current_x += (smallbuttonwidth + h_smallspace);
    [self.commabutton setFrame:CGRectMake(current_x, current_y, smallbuttonwidth, buttonheight)];
    current_x += (smallbuttonwidth + h_smallspace);
    [self.decimalpointbutton setFrame:CGRectMake(current_x, current_y, smallbuttonwidth, buttonheight)];
    
    self.dividebutton.titleLabel.font = [UIFont fontWithName:@".HelveticaNeueInterface-Thin" size:50 ];
    self.multiplybutton.titleLabel.font = [UIFont fontWithName:@".HelveticaNeueInterface-Thin" size:50 ];
    self.minusbutton.titleLabel.font = [UIFont fontWithName:@".HelveticaNeueInterface-Thin" size:50 ];
    self.plusbutton.titleLabel.font = [UIFont fontWithName:@".HelveticaNeueInterface-Thin" size:50 ];
    self.operationendbutton.titleLabel.font = [UIFont fontWithName:@".HelveticaNeueInterface-Thin" size:50 ];
}
@end
