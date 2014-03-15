//
//  A3CalculatorButtonsInScientificViewController_iPad.m
//  A3TeamWork
//
//  Created by Soon Gyu Kim on 12/24/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3CalculatorButtonsInScientificViewController_iPad.h"
#import "A3AppDelegate+appearance.h"

@interface A3CalculatorButtonsInScientificViewController_iPad ()

@end

@implementation A3CalculatorButtonsInScientificViewController_iPad

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
    CGFloat p_buttonwidth = 96.0, p_buttonheight = 96.0;
    CGFloat l_buttonwidth = 128.0, l_buttonheight = 80.0;
    CGFloat start_x = -1.0, start_y = 0.0;
    CGFloat current_x, current_y, buttonwidth, buttonheight;

	if (IS_PORTRAIT) {
		[_calculatorkeypadvw setFrame:CGRectMake(0,  448, 768, 576)];

        buttonwidth = p_buttonwidth, buttonheight = p_buttonheight;
	} else {
		[_calculatorkeypadvw setFrame:CGRectMake(0, 288, 1024, 480)];

        buttonwidth = l_buttonwidth, buttonheight = l_buttonheight;
	}
    current_x = start_x, current_y = start_y;
    [self.sinbutton setFrame:CGRectMake(current_x, current_y,buttonwidth+ 1+ 1, buttonheight+1)];
    current_x=buttonwidth;
    [self.cosbutton setFrame:CGRectMake(current_x, current_y,buttonwidth+1, buttonheight+1)];
    current_x+=buttonwidth;
    [self.tanbutton setFrame:CGRectMake(current_x, current_y,buttonwidth+1, buttonheight+1)];
    current_x+=buttonwidth;
    [self.secondbutton setFrame:CGRectMake(current_x, current_y,buttonwidth+1, buttonheight+1)];
    current_x+=buttonwidth;
    [self.clearbutton setFrame:CGRectMake(current_x, current_y,buttonwidth+1, buttonheight+1)];
    current_x+=buttonwidth;
    [self.signbutton setFrame:CGRectMake(current_x, current_y,buttonwidth+1, buttonheight+1)];
    current_x+=buttonwidth;
    [self.percentbutton setFrame:CGRectMake(current_x, current_y,buttonwidth+1, buttonheight+1)];
    current_x+=buttonwidth;
    [self.dividebutton setFrame:CGRectMake(current_x, current_y,buttonwidth+1, buttonheight+1)];
    
    current_x = start_x, current_y += buttonheight;
    [self.sinhbutton setFrame:CGRectMake(current_x, current_y,buttonwidth+1+1, buttonheight+1)];
    current_x=buttonwidth;
    [self.coshbutton setFrame:CGRectMake(current_x, current_y,buttonwidth+1, buttonheight+1)];
    current_x+=buttonwidth;
    [self.tanhbutton setFrame:CGRectMake(current_x, current_y,buttonwidth+1, buttonheight+1)];
    current_x+=buttonwidth;
    [self.cotbutton setFrame:CGRectMake(current_x, current_y,buttonwidth+1, buttonheight+1)];
    current_x+=buttonwidth;
    [self.deletebutton setFrame:CGRectMake(current_x, current_y,buttonwidth+1, buttonheight+1)];
    current_x+=buttonwidth;
    [self.leftparenthesisbutton setFrame:CGRectMake(current_x, current_y,buttonwidth+1, buttonheight+1)];
    current_x+=buttonwidth;
    [self.rightparenthesisbutton setFrame:CGRectMake(current_x, current_y,buttonwidth+1, buttonheight+1)];
    current_x+=buttonwidth;
    [self.multiplybutton setFrame:CGRectMake(current_x, current_y,buttonwidth+1, buttonheight+1)];
    
    current_x = start_x, current_y += buttonheight;
    [self.power2button setFrame:CGRectMake(current_x, current_y,buttonwidth+1+1, buttonheight+1)];
    current_x=buttonwidth;
    [self.power3button setFrame:CGRectMake(current_x, current_y,buttonwidth+1, buttonheight+1)];
    current_x+=buttonwidth;
    [self.powerxybutton setFrame:CGRectMake(current_x, current_y,buttonwidth+1, buttonheight+1)];
    current_x+=buttonwidth;
    [self.power10xbutton setFrame:CGRectMake(current_x, current_y,buttonwidth+1, buttonheight+1)];
    current_x+=buttonwidth;
    [self.number7button setFrame:CGRectMake(current_x, current_y,buttonwidth+1, buttonheight+1)];
    current_x+=buttonwidth;
    [self.number8button setFrame:CGRectMake(current_x, current_y,buttonwidth+1, buttonheight+1)];
    current_x+=buttonwidth;
    [self.number9button setFrame:CGRectMake(current_x, current_y,buttonwidth+1, buttonheight+1)];
    current_x+=buttonwidth;
    [self.minusbutton setFrame:CGRectMake(current_x, current_y,buttonwidth+1, buttonheight+1)];
    
    current_x = start_x, current_y += buttonheight;
    [self.squarerootbutton setFrame:CGRectMake(current_x, current_y,buttonwidth+1+1, buttonheight+1)];
    current_x=buttonwidth;
    [self.cuberootbutton setFrame:CGRectMake(current_x, current_y,buttonwidth+1, buttonheight+1)];
    current_x+=buttonwidth;
    [self.nthrootbutton setFrame:CGRectMake(current_x, current_y,buttonwidth+1, buttonheight+1)];
    current_x+=buttonwidth;
    [self.logbutton setFrame:CGRectMake(current_x, current_y,buttonwidth+1, buttonheight+1)];
    current_x+=buttonwidth;
    [self.number4button setFrame:CGRectMake(current_x, current_y,buttonwidth+1, buttonheight+1)];
    current_x+=buttonwidth;
    [self.number5button setFrame:CGRectMake(current_x, current_y,buttonwidth+1, buttonheight+1)];
    current_x+=buttonwidth;
    [self.number6button setFrame:CGRectMake(current_x, current_y,buttonwidth+1, buttonheight+1)];
    current_x+=buttonwidth;
    [self.plusbutton setFrame:CGRectMake(current_x, current_y,buttonwidth+1, buttonheight+1)];
    
    current_x = start_x, current_y += buttonheight;
    [self.dividexbutton setFrame:CGRectMake(current_x, current_y,buttonwidth+1+1, buttonheight+1)];
    current_x=buttonwidth;
    [self.factorialbutton setFrame:CGRectMake(current_x, current_y,buttonwidth+1, buttonheight+1)];
    current_x+=buttonwidth;
    [self.pibutton setFrame:CGRectMake(current_x, current_y,buttonwidth+1, buttonheight+1)];
    current_x+=buttonwidth;
    [self.log10button setFrame:CGRectMake(current_x, current_y,buttonwidth+1, buttonheight+1)];
    current_x+=buttonwidth;
    [self.number1button setFrame:CGRectMake(current_x, current_y,buttonwidth+1, buttonheight+1)];
    current_x+=buttonwidth;
    [self.number2button setFrame:CGRectMake(current_x, current_y,buttonwidth+1, buttonheight+1)];
    current_x+=buttonwidth;
    [self.number3button setFrame:CGRectMake(current_x, current_y,buttonwidth+1, buttonheight+1)];
    current_x+=buttonwidth;
    [self.operationendbutton setFrame:CGRectMake(current_x, current_y,buttonwidth+1, buttonheight*2)];
    
    current_x = start_x, current_y += buttonheight;
    [self.enumberbutton setFrame:CGRectMake(current_x, current_y,buttonwidth+1+1, buttonheight+1)];
    current_x=buttonwidth;
    [self.eenumberbutton setFrame:CGRectMake(current_x, current_y,buttonwidth+1, buttonheight+1)];
    current_x+=buttonwidth;
    [self.randbutton setFrame:CGRectMake(current_x, current_y,buttonwidth+1, buttonheight+1)];
    current_x+=buttonwidth;
    [self.radbutton setFrame:CGRectMake(current_x, current_y,buttonwidth+1, buttonheight+1)];
    current_x+=buttonwidth;
    [self.number0button setFrame:CGRectMake(current_x, current_y,buttonwidth+1, buttonheight+1)];
    current_x+=buttonwidth;
    [self.commabutton setFrame:CGRectMake(current_x, current_y,buttonwidth+1, buttonheight+1)];
    current_x+=buttonwidth;
    [self.decimalpointbutton setFrame:CGRectMake(current_x, current_y,buttonwidth+1, buttonheight+1)];
    
    UIColor *themeColor = [A3AppDelegate instance].themeColor;
    [self.dividebutton setBackgroundColor:themeColor];
    [self.multiplybutton setBackgroundColor:themeColor];
    [self.minusbutton setBackgroundColor:themeColor];
    [self.plusbutton setBackgroundColor:themeColor];
    [self.operationendbutton setBackgroundColor:themeColor];

}
@end
