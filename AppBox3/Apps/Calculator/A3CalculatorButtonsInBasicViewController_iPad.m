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

	CGFloat scale = [A3UIDevice scaleToOriginalDesignDimension];
    CGFloat vscale = scale;
    CGFloat p_bigbuttonwidth = 120.0 * scale, p_smallbuttonwidth = 90.0 * scale, p_buttonheight = 89.0 * scale;
    CGFloat l_bigbuttonwidth = 168.0 * scale, l_smallbuttonwidth = 107.0 * scale, l_buttonheight = 74.0 * scale;
    CGFloat start_x, start_y, v_space, h_bigspace,h_smallspace;
    CGFloat current_x, current_y, bigbuttonwidth, smallbuttonwidth, buttonheight;

    CGRect bounds = [UIScreen mainScreen].bounds;
    FNLOGRECT(self.view.bounds);
    FNLOGRECT(bounds);

    // iPad mini 6th edition : 1133 x 744
	if (IS_PORTRAIT) {
        CGFloat top, width, height;
        if (bounds.size.height == 1366.0) {
            // iPad Pro 12.9"
            top = 617.0 * scale;
            width = 768.0 * scale;
            height = 407.0 * scale;
        } else if (bounds.size.height == 1194.0) {
            // iPad Pro 11"
            top = 732.0;
            width = 834.0;
            height = 407.0 * vscale + 20;
        } else if (bounds.size.height == 1180.0) {
            // iPad Air 5th Gen
            top = 732.0;
            width = 820.0;
            height = 407.0 * vscale + 20;
        } else if (bounds.size.height == 1112.0) {
            // iPad Pro 10.5"
            top = 670.0;
            width = 834.0;
            height = 407.0 * vscale;
        } else if (bounds.size.height == 1133.0) {
            // iPad mini 6th
            width = 744.0;
            height = 407.0 * vscale + 20;
            top = 1133 - height;
        } else {
            top = 617.0 * scale;
            width = 768.0 * scale;
            height = 407.0 * scale;
        }
        
		[_calculatorkeypadvw setFrame:CGRectMake(0.0,  top, width, height)];
        start_x = 22.0 * scale; start_y = 10.0 * scale; v_space = 11.0 * scale; h_bigspace = 24.0 * scale; h_smallspace = 11.0 * scale;
        bigbuttonwidth = p_bigbuttonwidth; smallbuttonwidth = p_smallbuttonwidth; buttonheight = p_buttonheight;
	} else {
        CGFloat top, width, height;
        if (bounds.size.width == 1366.0) {
            // iPad Pro 12.9"
            top = 420.0 * scale;
            width = 1024.0 * scale;
            height = 348.0 * scale;
        } else if (bounds.size.width == 1194.0) {
            // iPad Pro 11", height = 834
            vscale = 834.0/768.0;
            top = 440.0;
            width = 1194.0;
            height = 348.0 * vscale + 20;
            
            p_buttonheight = 89.0 * vscale;
            l_buttonheight = 74.0 * vscale;
        } else if (bounds.size.width == 1180.0) {
            // iPad Air 5th Gen, 820x1180
            vscale = 820.0/768.0;
            top = 440.0;
            width = 1194.0;
            height = 348.0 * vscale + 20;
            
            p_buttonheight = 89.0 * vscale;
            l_buttonheight = 74.0 * vscale;
        } else if (bounds.size.width == 1112.0) {
            // iPad Pro 10.5", height = 834
            vscale = 834.0/768.0;
            top = 456.0;
            width = 1112.0;
            height = 348.0 * vscale;
            
            p_buttonheight = 89.0 * vscale;
            l_buttonheight = 74.0 * vscale;
        } else if (bounds.size.width == 1133.0) {
            // iPad mini 6th edition
            vscale = 744.0/768.0;
            width = 1133.0;
            height = 348.0 * vscale + 20;
            top = 744.0 - height;
            
            p_buttonheight = 89.0 * vscale;
            l_buttonheight = 74.0 * vscale;
        } else {
            top = 420.0 * scale;
            width = 1024.0 * scale;
            height = 348.0 * scale;
        }
        
		[_calculatorkeypadvw setFrame:CGRectMake(0.0, top, width, height)];
        start_x = 33.0 * scale; start_y = 10.0 * vscale; v_space = 11.0 * vscale; h_bigspace = 33.0 * scale; h_smallspace = 17.0 * scale;
        bigbuttonwidth = l_bigbuttonwidth; smallbuttonwidth = l_smallbuttonwidth; buttonheight = l_buttonheight;
	}
    
    current_x = start_x; current_y = start_y;
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
    
    current_x = start_x; current_y = start_y + buttonheight + v_space;
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
    
    current_x = start_x; current_y = start_y + buttonheight*2 + v_space*2;
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

    current_x = start_x; current_y = start_y + buttonheight*3 + v_space*3;
    [self.rightparenthesisbutton  setFrame:CGRectMake(current_x, current_y, bigbuttonwidth, buttonheight)];
    current_x += (bigbuttonwidth + h_bigspace);
    [self.plusbutton setFrame:CGRectMake(current_x, current_y, bigbuttonwidth, buttonheight)];
    current_x += (bigbuttonwidth + h_bigspace);
    [self.number0button  setFrame:CGRectMake(current_x, current_y, smallbuttonwidth, buttonheight)];
    current_x += (smallbuttonwidth + h_smallspace);
    [self.commabutton setFrame:CGRectMake(current_x, current_y, smallbuttonwidth, buttonheight)];
    current_x += (smallbuttonwidth + h_smallspace);
    [self.decimalpointbutton setFrame:CGRectMake(current_x, current_y, smallbuttonwidth, buttonheight)];
    
    self.dividebutton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:50 * scale ];
    self.multiplybutton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:50 * scale ];
    self.minusbutton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:50 * scale ];
    self.plusbutton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:50 * scale ];
    self.operationendbutton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:50 * scale ];
}

@end
