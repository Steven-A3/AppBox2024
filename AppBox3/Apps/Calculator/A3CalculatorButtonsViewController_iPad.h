//
//  A3CalculatorButtonsViewController_iPad.h
//  A3TeamWork
//
//  Created by Soon Gyu Kim on 12/24/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol A3CalcKeyboardViewIPadDelegate <NSObject>
- (void)keyboardButtonPressed:(NSUInteger)key;
@end

@interface A3CalculatorButtonsViewController_iPad : UIViewController
@property (nonatomic, weak) id<A3CalcKeyboardViewIPadDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIButton *sinbutton;
@property (weak, nonatomic) IBOutlet UIButton *cosbutton;
@property (weak, nonatomic) IBOutlet UIButton *tanbutton;
@property (weak, nonatomic) IBOutlet UIButton *secondbutton;
@property (weak, nonatomic) IBOutlet UIButton *clearbutton;
@property (weak, nonatomic) IBOutlet UIButton *signbutton;
@property (weak, nonatomic) IBOutlet UIButton *percentbutton;
@property (weak, nonatomic) IBOutlet UIButton *dividebutton;
@property (weak, nonatomic) IBOutlet UIButton *sinhbutton;
@property (weak, nonatomic) IBOutlet UIButton *coshbutton;
@property (weak, nonatomic) IBOutlet UIButton *tanhbutton;
@property (weak, nonatomic) IBOutlet UIButton *cotbutton;
@property (weak, nonatomic) IBOutlet UIButton *deletebutton;
@property (weak, nonatomic) IBOutlet UIButton *leftparenthesisbutton;
@property (weak, nonatomic) IBOutlet UIButton *rightparenthesisbutton;
@property (weak, nonatomic) IBOutlet UIButton *multiplybutton;
@property (weak, nonatomic) IBOutlet UIButton *power2button;
@property (weak, nonatomic) IBOutlet UIButton *power3button;
@property (weak, nonatomic) IBOutlet UIButton *powerxybutton;
@property (weak, nonatomic) IBOutlet UIButton *power10xbutton;
@property (weak, nonatomic) IBOutlet UIButton *number7button;
@property (weak, nonatomic) IBOutlet UIButton *number8button;
@property (weak, nonatomic) IBOutlet UIButton *number9button;
@property (weak, nonatomic) IBOutlet UIButton *minusbutton;
@property (weak, nonatomic) IBOutlet UIButton *squarerootbutton;
@property (weak, nonatomic) IBOutlet UIButton *cuberootbutton;
@property (weak, nonatomic) IBOutlet UIButton *nthrootbutton;
@property (weak, nonatomic) IBOutlet UIButton *logbutton;
@property (weak, nonatomic) IBOutlet UIButton *number4button;
@property (weak, nonatomic) IBOutlet UIButton *number5button;
@property (weak, nonatomic) IBOutlet UIButton *number6button;
@property (weak, nonatomic) IBOutlet UIButton *plusbutton;
@property (weak, nonatomic) IBOutlet UIButton *dividexbutton;
@property (weak, nonatomic) IBOutlet UIButton *factorialbutton;
@property (weak, nonatomic) IBOutlet UIButton *pibutton;
@property (weak, nonatomic) IBOutlet UIButton *log10button;
@property (weak, nonatomic) IBOutlet UIButton *number1button;
@property (weak, nonatomic) IBOutlet UIButton *number2button;
@property (weak, nonatomic) IBOutlet UIButton *number3button;
@property (weak, nonatomic) IBOutlet UIButton *operationendbutton;
@property (weak, nonatomic) IBOutlet UIButton *enumberbutton;
@property (weak, nonatomic) IBOutlet UIButton *eenumberbutton;
@property (weak, nonatomic) IBOutlet UIButton *randbutton;
@property (weak, nonatomic) IBOutlet UIButton *radbutton;
@property (weak, nonatomic) IBOutlet UIButton *number0button;
@property (weak, nonatomic) IBOutlet UIButton *commabutton;
@property (weak, nonatomic) IBOutlet UIButton *decimalpointbutton;
- (IBAction)number1action:(id)sender;
- (IBAction)sinaction:(id)sender;
- (IBAction)cosaction:(id)sender;
- (IBAction)tanaction:(id)sender;
- (IBAction)secondaction:(id)sender;
- (IBAction)clearbutton:(id)sender;
- (IBAction)signaction:(id)sender;
- (IBAction)percentaction:(id)sender;
- (IBAction)divideaction:(id)sender;
- (IBAction)sinhaction:(id)sender;
- (IBAction)coshaction:(id)sender;
- (IBAction)tanhaction:(id)sender;
- (IBAction)cotaction:(id)sender;
- (IBAction)deleteaction:(id)sender;
- (IBAction)leftparenthesisaction:(id)sender;
- (IBAction)rightparenthesisaction:(id)sender;
- (IBAction)multiplyaction:(id)sender;
- (IBAction)power2action:(id)sender;
- (IBAction)power3action:(id)sender;
- (IBAction)powerxyaction:(id)sender;
- (IBAction)power10xaction:(id)sender;
- (IBAction)number7action:(id)sender;
- (IBAction)number8action:(id)sender;
- (IBAction)number9action:(id)sender;
- (IBAction)minusaction:(id)sender;
- (IBAction)squarerootaction:(id)sender;
- (IBAction)cuberrootaction:(id)sender;
- (IBAction)nthrootaction:(id)sender;
- (IBAction)logaction:(id)sender;
- (IBAction)number4action:(id)sender;
- (IBAction)number5action:(id)sender;
- (IBAction)number6action:(id)sender;
- (IBAction)plusaction:(id)sender;
- (IBAction)dividexaction:(id)sender;
- (IBAction)factorialaction:(id)sender;
- (IBAction)piaction:(id)sender;
- (IBAction)log10action:(id)sender;
- (IBAction)number2action:(id)sender;
- (IBAction)number3action:(id)sender;
- (IBAction)operationendaction:(id)sender;
- (IBAction)enumberaction:(id)sender;
- (IBAction)eenumberaction:(id)sender;
- (IBAction)randaction:(id)sender;
- (IBAction)radaction:(id)sender;
- (IBAction)number0action:(id)sender;
- (IBAction)commaction:(id)sender;
- (IBAction)decimalaction:(id)sender;

@end
