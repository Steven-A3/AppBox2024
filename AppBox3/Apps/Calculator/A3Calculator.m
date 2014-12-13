//
//  A3Calculator.m
//  A3TeamWork
//
//  Created by Soon Gyu Kim on 12/26/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3Calculator.h"
#import "A3ExpressionComponent.h"
#import "MathParser.h"
#import "A3CalculatorUtil.h"
#import "NSAttributedString+Append.h"
#import "A3AppDelegate.h"
#import "A3SyncManager.h"
#import "A3SyncManager+NSUbiquitousKeyValueStore.h"

@interface A3Calculator ()

@property (nonatomic, weak) HTCopyableLabel *expressionLabel;
@property (nonatomic, weak) HTCopyableLabel *evaluatedResultLabel;

@end

typedef CMathParser<char, double> MathParser;

@implementation A3Calculator {
    NSString            *mathexpression;
    BOOL                radian;
    BOOL                numberMode;
    BOOL                EEMode;
    BOOL                LOGYMode;
    A3CalculatorUtil    *calutil;
}

- (NSString *) getMathExpression {
    return mathexpression;
}

- (NSAttributedString *) getMathAttributedExpression {
    return [self getExpressionWith:mathexpression];
}

- (id) initWithLabel:(HTCopyableLabel *) expression result:(HTCopyableLabel *) result {
    self = [super init];
    if (self) {
        _expressionLabel = expression;
        _evaluatedResultLabel = result;
        radian = YES;
        numberMode = NO;
        EEMode = NO;
        LOGYMode = NO;
        calutil = [A3CalculatorUtil new];
    }
    
    return self;
}

- (void) setRadian:(BOOL)bRadian {
    radian = bRadian;
}

- (void) setLabel:(HTCopyableLabel *) expression result:(HTCopyableLabel *) result;
{
    _expressionLabel = expression;
    _evaluatedResultLabel = result;
}

- (NSString *) replaceSpecialCharactersExpression:(NSString *) expression {
	expression = [expression stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"+-/x"]];
    expression = [expression stringByReplacingOccurrencesOfString:@"x" withString:@"*"];
    expression = [expression stringByReplacingOccurrencesOfString:@"sin-1" withString:@"asin"];
    expression = [expression stringByReplacingOccurrencesOfString:@"cos-1" withString:@"acos"];
    expression = [expression stringByReplacingOccurrencesOfString:@"tan-1" withString:@"atan"];
    expression = [expression stringByReplacingOccurrencesOfString:@"sinh-1" withString:@"asinh"];
    expression = [expression stringByReplacingOccurrencesOfString:@"cosh-1" withString:@"acosh"];
    expression = [expression stringByReplacingOccurrencesOfString:@"tanh-1" withString:@"atanh"];
    expression = [expression stringByReplacingOccurrencesOfString:@"cot-1" withString:@"acotan"];
    
    return expression;
}
- (double)evaluate:(BOOL *)err {
	double resultValue;
	try {
		MathParser p;
		NSString *myExpression = [mathexpression stringByReplacingOccurrencesOfString:@"=" withString:@""];
		myExpression = [self replaceSpecialCharactersExpression:myExpression];
		p.SetExpression([myExpression cStringUsingEncoding:NSASCIIStringEncoding], radian);
		resultValue = p.GetValue();
		*err = NO;
	}
	catch (MathParser::ParserException &ex ) {
#ifdef DEBUG
		NSString *error = [NSString stringWithCString:ex.GetMessage().c_str() encoding:NSASCIIStringEncoding];
		FNLOG(@"%@", error);
#endif
		*err = YES;
	}
	return resultValue;
}

- (NSString *)getResultValueString:(double)value shortFormat:(BOOL)isShort{

    NSUInteger maxFractionDigt = 15;
    NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
    NSUInteger maxDigitLen = 16, maxSignificantDigits = 16;
//    FNLOG("value   = %.15f %ld", value, (long)nf.roundingMode);
    NSUInteger numLen = [[NSString stringWithFormat:@"%f", value] length];
    NSString *resultString = nil;
    
   // if (1 > value) maxSignificantDigits = 15; // why app's default calculator like this??
    
    if (isShort  == YES) {
        maxFractionDigt = 9;
        maxDigitLen = 9;
        maxSignificantDigits = 8;
    }
//    FNLOG(@"%@", [[NSLocale currentLocale] objectForKey:NSLocaleCountryCode]);
    [nf setLocale:[NSLocale currentLocale]];
    [nf setMaximumFractionDigits:maxFractionDigt];
    //[nf setUsesSignificantDigits:YES];
    //[nf setMaximumSignificantDigits:maxSignificantDigits];
    if(numLen <= maxDigitLen + 7) {
        [nf setNumberStyle:NSNumberFormatterDecimalStyle];

        resultString = [nf stringFromNumber:[NSNumber numberWithDouble:value]];
//        FNLOG(@"Normal : %@",resultString);
    }else {
        [nf setNumberStyle:NSNumberFormatterScientificStyle];
        [nf setExponentSymbol:@"e"];
        if(isShort == YES) {
            [nf setPositiveFormat:@"0.######E+0"];
        } else {
            [nf setPositiveFormat:@"0.#############E+0"];
        }
        
        resultString = [nf stringFromNumber:[NSNumber numberWithDouble:value]];
//                FNLOG(@"Faction : %@",resultString);
    }
    
    return resultString;
}

- (NSString *) getResultString {
    if ([self checkIfexpressionisnull] == NO) {
        	BOOL	isError;
        double result = [self evaluate:&isError];
        
        if (isError == NO) {
            return [self getResultValueString:result shortFormat:NO];
        }
    }
    return nil;
}
- (void)evaluateAndSet{
	BOOL	isError;
	
    if ([self checkIfexpressionisnull] == NO) {
        double result = [self evaluate:&isError];

        if (isError) {
			result = 0.0;
        }
		_evaluatedResultLabel.text = [self getResultValueString:result shortFormat: (IS_IPHONE && _isLandScape == NO ? YES:NO)];
    }
}

- (void) changeEEExpression {
    NSRange range = [mathexpression rangeOfString:@"EE"];
    if ( range.location != NSNotFound) {
        NSUInteger numLen = [self getNumberLengthFromMathExpression:mathexpression with:range.location + range.length];
        
        if (numLen > 0) {
            NSRange numRange;
            numRange.location = range.location + range.length;
            numRange.length = numLen;
            NSString* num = [mathexpression substringWithRange:numRange];
            if (num.length > 0) {
                int nNum = [num intValue];
                mathexpression = [mathexpression substringToIndex:range.location];
                for(int i=0;i<nNum;i++) {
                    mathexpression = [mathexpression stringByAppendingString:@"0"];
                }
            }
        }
    }
}

-(void)checkLastCharacterRemoveNeeded:(NSUInteger) key {
    if ([self checkIfexpressionisnull] == NO) {
        if (key != A3E_CALCULATE) {
			if (![mathexpression length]) return;

            NSString* lastChar = [mathexpression substringFromIndex:[mathexpression length] -1];
            NSRange range = [lastChar rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"="]];
            if(range.location != NSNotFound) {
                if(key != A3E_BACKSPACE) {
                    [self clearCalculation];
                }
            }
        }
    }
}

#pragma mark KeyboardButton handler

- (void)preHandlerForCalculation:(NSUInteger) key {
    if(numberMode == YES) {
        if(!(A3E_0 <= key && key < A3E_NUMBERS_END) &&
           key != A3E_BACKSPACE)  {
			[self ShowMessage:NSLocalizedString(@"Enter The Number!", @"Enter The Number!")];
            return;
        } else {
            numberMode = NO;
        }
    }
    
    if(EEMode == YES) {
        if(!(A3E_0 <= key && key < A3E_NUMBERS_END) &&
           key != A3E_BACKSPACE)  {
            [self changeEEExpression];
            EEMode = NO;
        } else if (key == A3E_BACKSPACE) {
            EEMode = NO;
        }
    }

	[self checkLastCharacterRemoveNeeded:key];
}

- (void)keyboardButtonPressed:(NSUInteger)key {
    [self preHandlerForCalculation:key];
    
    if (key == A3E_E_Number) {
        [self eehandler];
    }
    else if(A3E_0 <= key && key < A3E_NUMBERS_END) {
        [self numberHandler:key];
    }
    else if(A3E_PLUS <= key && key < A3E_OPERATOR_END) {
        [self operatorHandler:key];
    }
    else if (A3E_2ND < key && key < A3E_SPECIAL_KEYS_END) {
        [self specialkeyHandler:key];
    }
    else if (A3E_SIN <= key && key < A3E_TRIGONOMETRIC_END) {
        [self trigonometricFunctionHandler:key];
    }
    else if (A3E_SQUARE <= key && key < A3E_SINGLE_ARG_END) {
        [self singleargHandler:key];
    }
    else if (A3E_NTHROOT <= key && key < A3E_DOUBLE_ARG_END) {
        [self doubleargHandler:key];
    }
    else if (A3E_PI <= key && key < A3E_CONSTANT_END) {
        [self constantHandler:key];
    }
	[self saveExpression];
}

- (void)saveExpression {
	[[A3SyncManager sharedSyncManager] setObject:mathexpression forKey:A3CalculatorUserDefaultsSavedLastExpression state:A3DataObjectStateModified];
}

- (void)eehandler {
    if(([self checkIfexpressionisnull])) return;
    
    NSString* lastChar = [mathexpression substringFromIndex:[mathexpression length] -1];
    NSRange range = [lastChar rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"1234567890"]];
    if(range.location != NSNotFound) {
        mathexpression = [mathexpression stringByAppendingString:@"EE"];
        EEMode = YES;
        [self convertMathExpressionToAttributedString];
    }
}

- (void)constantHandler:(NSUInteger)key {
    NSString *constant;
    switch (key) {
        case A3E_PI:
            constant = @"PI";
            break;
        case A3E_BASE_E:
            constant = @"e";
            break;
        default:
            break;
    }
    
    if ([mathexpression length] == 0)
    {
        mathexpression = constant;
    }
    else
    {
        NSString *lastChar = [mathexpression substringFromIndex:[mathexpression length] - 1];
        
        NSRange range = [lastChar rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"1234567890."]];
        if (range.location != NSNotFound) {
            mathexpression = [[mathexpression stringByAppendingString:@"x"] stringByAppendingString:constant];
            [self evaluateAndSet];
        } else {
            range = [lastChar rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"x/+-("]];
            if (range.location != NSNotFound) {
                mathexpression = [mathexpression stringByAppendingString:constant];
            }
        }
    }
    [self convertMathExpressionToAttributedString];
    [self evaluateAndSet];
}

- (void)doubleargHandler:(NSUInteger) key {
    
    [self changethelastnumberwithoperator:key];
    [self evaluateAndSet];
    return;
}

- (NSUInteger)getNumberLengthFromMathExpression:(NSString *)mExpression with:(NSUInteger)index {
    NSUInteger numberLength = 0, numParenthesis = 0;
    NSRange range;
    NSUInteger length = [mExpression length];
    NSString *currentString;
    do {
        range.location = index + numberLength++;
        range.length = 1;
        currentString = [mExpression substringWithRange:range];
        if([currentString isEqualToString:@"("]) {
            numParenthesis++;
        }
        
        if(numParenthesis > 0 && [currentString isEqualToString:@")"]) {
            numParenthesis--;
            numberLength++;
        }
        
        if (numParenthesis == 0) {
            range = [currentString rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"1234567890."]];
        }
    } while (range.location != NSNotFound &&
             index + numberLength < length);
    
    if(range.location == NSNotFound) {
        numberLength--;
    }
    return numberLength;
}

- (void)convertMathExpressionToAttributedString {
    _expressionLabel.attributedText = [self getExpressionWith:mathexpression isDefault:YES];
}

- (void)setMathExpression:(NSString *) mathExpr {
    mathexpression = mathExpr;
    _expressionLabel.attributedText = [self getExpressionWith:mathexpression isDefault:YES];
    [self evaluateAndSet];
}

- (NSAttributedString *)getExpressionWith:(NSString *) mExpression {
    return [self getExpressionWith:mExpression isDefault:NO];
}


- (NSAttributedString *)getExpressionWith:(NSString *) mExpression isDefault:(BOOL)bDefault{
//    FNLOG(@"mExpression = %@",mExpression);
    //NSAttributedString *temp = [[NSAttributedString alloc] initWithAttributedString:[calutil invisibleString]];
    NSAttributedString *temp = [NSAttributedString new];
    NSUInteger i, length = [mExpression length];
    NSString *currentString;
    NSRange range;
    char c;
    
    for(i = 0;i < length;)
    {
        c = [mExpression characterAtIndex:i];
        switch (c) {
            case '0':
            case '1': // 1, 10^
            case '2': // 2, 2^
            case '3':
            case '4':
            case '5':
            case '6':
            case '7':
            case '8':
            case '9':
            case '.':{
                range.location = i;
                range.length = [self getNumberLengthFromMathExpression:mExpression with:range.location];
                
                currentString = [mExpression substringWithRange:range];
                double dv = [currentString doubleValue];
                if (dv != 0) {
                    temp = [temp appendWithString:[self getResultValueString:dv shortFormat:(IS_IPHONE && _isLandScape == NO ? YES:NO)]];
                } else {
                    // to reserve 0.
                    temp = [temp appendWithString:currentString];
                }
                
                i+= range.length;
            }
                break;
            case 'E':   //EE
            case 'e':
            case '+':
            case '-':
            case 'x':
            case '/':
            case '(':
            case ')':
            case '=':{
                range.location = i;
                range.length = 1;
                currentString = [mExpression substringWithRange:range];
                temp=[temp appendWithString:currentString];
                i++;
            }
                break;
            case 's': //sin, sin-1, sinh,sinh-1
            {
                range.location = i;
                if(length >= i + 6) {
                    range.length = 6;
                    currentString = [mExpression substringWithRange:range];
                }
                if((length >= (i + 6)) > 0 &&
                   [currentString isEqualToString:@"sinh-1"]) {
                    temp = [temp appendWith:bDefault == YES ?[calutil stringArcSinh] : [calutil stringArcSinh_h]];
                } else {
                    if(length >= (i+5)) {
                        range.length = 5;
                        currentString = [mExpression substringWithRange:range];
                    }
                    if((length >= (i+5)) &&
                       [currentString isEqualToString:@"sin-1"]){
                        temp = [temp appendWith:bDefault == YES ?[calutil stringArcSin]:[calutil stringArcSin_h]];
                    } else {
                        if(length >= (i+4)) {
                            range.length = 4;
                            currentString = [mExpression substringWithRange:range];
                        }
                        if((length >= (i+4)) &&
                           [currentString isEqualToString:@"sinh"]){
                            temp = [temp appendWithString:currentString];
                        } else {
                            if(length >= (i + 3)){
                                range.length = 3;
                                currentString = [mExpression substringWithRange:range];
                            }
                            if((length >= (i+3)) &&
                               [currentString isEqualToString:@"sin"]) {
                                temp = [temp appendWithString:currentString];
                            } else {
                                FNLOG("Error:%@ is undefined in MathExpression", currentString);
                                i+=length;// exit for loop
                                break;
                            }
                        }
                    }
                    
                }
                
                i+= range.length;
            }
                break;
            case 'c': { //cos, cos-1, cosh, cosh-1,cot,cot-1
                range.location = i;
                if(length >= i + 6) {
                    range.length = 6;
                    currentString = [mExpression substringWithRange:range];
                }
                if((length >= (i + 6)) > 0 &&
                   [currentString isEqualToString:@"cosh-1"]) {
                    temp = [temp appendWith:bDefault == YES ?[calutil stringArcCosh]:[calutil stringArcCosh_h]];
                } else {
                    if(length >= (i+5)) {
                        range.length = 5;
                        currentString = [mExpression substringWithRange:range];
                    }
                    if((length >= (i+5)) &&
                       [currentString isEqualToString:@"cos-1"]){
                        temp = [temp appendWith:bDefault == YES ?[calutil stringArcCos]:[calutil stringArcCos_h]];
                    } else if((length >= (i+5)) &&
                              [currentString isEqualToString:@"cot-1"]){
                        temp = [temp appendWith:bDefault == YES ?[calutil stringArcCot]:[calutil stringArcCot_h]];
                    } else {
                        if(length >= (i+4)) {
                            range.length = 4;
                            currentString = [mExpression substringWithRange:range];
                        }
                        if((length >= (i+4)) &&
                           [currentString isEqualToString:@"cosh"]){
                            temp = [temp appendWithString:currentString];
                        } else {
                            if(length >= (i + 3)){
                                range.length = 3;
                                currentString = [mExpression substringWithRange:range];
                            }
                            if((length >= (i+3)) &&
                               [currentString isEqualToString:@"cos"]) {
                                temp = [temp appendWithString:currentString];
                            } else if((length >= (i+3)) &&
                                      [currentString isEqualToString:@"cot"]) {
                                temp = [temp appendWithString:currentString];
                            } else {
                                FNLOG("Error:%@ is undefined in MathExpression", currentString);
                                i+=length;// exit for loop
                                break;
                            }
                        }
                    }
                    
                }
                
                i+= range.length;
            }
                break;
            case 't': {// tan, tan-1, tanh, tanh-1
                range.location = i;
                if(length >= i + 6) {
                    range.length = 6;
                    currentString = [mExpression substringWithRange:range];
                }
                if((length >= (i + 6)) > 0 &&
                   [currentString isEqualToString:@"tanh-1"]) {
                    temp = [temp appendWith:bDefault == YES ?[calutil stringArcTanh]:[calutil stringArcTanh_h]];
                } else {
                    if(length >= (i+5)) {
                        range.length = 5;
                        currentString = [mExpression substringWithRange:range];
                    }
                    if((length >= (i+5)) &&
                       [currentString isEqualToString:@"tan-1"]){
                        temp = [temp appendWith:bDefault == YES ?[calutil stringArcTan]:[calutil stringArcTan_h]];
                    } else {
                        if(length >= (i+4)) {
                            range.length = 4;
                            currentString = [mExpression substringWithRange:range];
                        }
                        if((length >= (i+4)) &&
                           [currentString isEqualToString:@"tanh"]){
                            temp = [temp appendWithString:currentString];
                        } else {
                            if(length >= (i + 3)){
                                range.length = 3;
                                currentString = [mExpression substringWithRange:range];
                            }
                            if((length >= (i+3)) &&
                               [currentString isEqualToString:@"tan"]) {
                                temp = [temp appendWithString:currentString];
                            } else {
                                FNLOG("Error:%@ is undefined in MathExpression", currentString);
                                i+=length;// exit for loop
                            }
                        }
                    }
                    
                }
                
                i+= range.length;
            }
                break;
            case 'F': { // FACT()
                range.location = i;
                if( length >= i + 5) {
                    range.length = 5;
                    currentString = [mExpression substringWithRange:range];
                    if([currentString isEqualToString:@"FACT("]) {
                        range.location = i + 5;
                        range.length = [self getNumberLengthFromMathExpression:mExpression with:range.location];//numberLength - range.location-1;
                        currentString = [mExpression substringWithRange:range];
                        temp = [temp appendWithString:[currentString stringByAppendingString:@"!"]];
                        i = range.location + range.length + 1; // 1 is for ')'
                    } else {
                        FNLOG("Error:%@ is undefined in MathExpression", currentString);
                        i+=length;// exit for loop
                    }
                } else {
                    range.length = length - i;
                    currentString = [mExpression substringWithRange:range];
                    FNLOG("Error:%@ is undefined in MathExpression", currentString);
                    i+=length;// exit for loop
                }
            }
                break;
            case 'L':{ // LOGN(, LN(, LOG(, LOG2(
                range.location = i;
                if(length >= i + 5) {
                    range.length = 5;
                    currentString = [mExpression substringWithRange:range];
                    if([currentString isEqualToString:@"LOGN("]) {
                        range.location = i + 5;
                        range.length = [self getNumberLengthFromMathExpression:mExpression with:range.location];
                        NSString *subscriptNum = [mExpression substringWithRange:range];
                        range.location = i + 5 + range.length + 1; // 1: skip ','
                        if(length > range.location) {
                            range.length = [self getNumberLengthFromMathExpression:mExpression with:range.location];
                            NSString *num = [mExpression substringWithRange:range];
                            temp = [temp appendWith:[bDefault == YES ? [calutil stringWithSuperscriptMiddleFont:[@"log" stringByAppendingString:subscriptNum] location:3 length:[subscriptNum length] value:@-1] :
                                                     [calutil stringWithSuperscriptSystemFont:[@"log" stringByAppendingString:subscriptNum] location:3 length:[subscriptNum length] value:@-1] appendWithString:@"("]];
                            temp = [temp appendWithString:num];
                            i = range.location + range.length;
                        } else {
                            temp = [temp appendWith:[bDefault == YES ? [calutil stringWithSuperscriptMiddleFont:[@"log" stringByAppendingString:subscriptNum] location:3 length:[subscriptNum length] value:@-1] :
                                                     [calutil stringWithSuperscriptSystemFont:[@"log" stringByAppendingString:subscriptNum] location:3 length:[subscriptNum length] value:@-1] appendWithString:@"("]];
                            i = range.location;
                        }
                        break;
                    } else if([currentString isEqualToString:@"LOG2("]) {
                        temp = [temp appendWith:[bDefault == YES ? [calutil stringWithSuperscriptMiddleFont:[@"log" stringByAppendingString:@"2"] location:3 length:1 value:@-1] :
                                                 [calutil stringWithSuperscriptSystemFont:[@"log" stringByAppendingString:@"2"] location:3 length:1 value:@-1] appendWithString:@"("]];
                        i+= 5;
                        if(length > i) {
                            range.location = i;
                            range.length = [self getNumberLengthFromMathExpression:mExpression with:range.location];
                            if(range.length > 0 ) {
                                currentString = [mExpression substringWithRange:range];
                                temp = [temp appendWithString:currentString];
                                i+=range.length;
                            }
                        }
                        break;
                    }
                }
                
                if(length >= i + 4) {
                    range.length = 4;
                    currentString = [mExpression substringWithRange:range];
                    if([currentString isEqualToString:@"LOG("]) {
                        temp = [[temp appendWith:bDefault == YES? [calutil stringLog10] :[calutil stringLog10_h]] appendWithString:@"("];
                        i+=4;
                        if(length > i) {
                            range.location = i;
                            range.length = [self getNumberLengthFromMathExpression:mExpression with:range.location];
                            if(range.length > 0 ) {
                                currentString = [mExpression substringWithRange:range];
                                temp = [temp appendWithString:currentString];
                                i+=range.length;
                            }
                        }
                        break;
                    }
                }
                
                if(length >= i + 3) {
                    range.length = 3;
                    currentString = [mExpression substringWithRange:range];
                    if([currentString isEqualToString:@"LN("]) {
                        temp = [temp appendWithString:@"ln("];
                        i+=3;
                        if(length > i) {
                            range.location = i;
                            range.length = [self getNumberLengthFromMathExpression:mExpression with:range.location];
                            if(range.length > 0 ) {
                                currentString = [mExpression substringWithRange:range];
                                temp = [temp appendWithString:currentString];
                                i+=range.length;
                            }
                        }
                        break;
                    }
                }
                
            }
                break;
            case 'N':{ // NTHRT(
                range.location = i;
                if(length >= i + 6) {
                    range.length = 6;
                    currentString = [mExpression substringWithRange:range];
                    if([currentString isEqualToString:@"NTHRT("]) {
                        range.location = i + 6;
                        range.length = [self getNumberLengthFromMathExpression:mExpression with:range.location];
                        NSString *superscriptNum = [mExpression substringWithRange:range];
                        range.location = i + 6 + range.length + 1; // 1: skip ','
                        if(length > range.location) {
                            range.length = [self getNumberLengthFromMathExpression:mExpression with:range.location];
                            NSString *num = [mExpression substringWithRange:range];
                            temp = [temp appendWith:[bDefault == YES ? [calutil stringWithSuperscriptMiddleFont:[superscriptNum stringByAppendingString:@"√"] location:0 length:[superscriptNum length] value:@1] :
                                                     [calutil stringWithSuperscriptSystemFont:[superscriptNum stringByAppendingString:@"√"] location:0 length:[superscriptNum length] value:@1]  appendWithString:@"("]];
                            temp = [temp appendWithString:num];
                            i = range.location + range.length;
                        } else {
                            temp = [temp appendWith:[bDefault == YES ? [calutil stringWithSuperscriptMiddleFont:[superscriptNum stringByAppendingString:@"√"] location:0 length:[superscriptNum length] value:@1] :
                                                     [calutil stringWithSuperscriptSystemFont:[superscriptNum stringByAppendingString:@"√"] location:0 length:[superscriptNum length] value:@1] appendWithString:@"("]];
                            i = range.location;
                        }
                        break;
                    }
                }
            }
                break;
            case '^':{ //^number
                range.location = i;
                if(length > i + 1) {
                    range.location++;i++; // skip '^'
                    range.length = [self getNumberLengthFromMathExpression:mExpression with:range.location];
                    if(range.length > 0 ){
                        currentString = [mExpression substringWithRange:range];
                        temp = bDefault == YES ? [temp appendWith:[calutil stringWithSuperscriptMiddleFont:currentString location:0 length:[currentString length] value:@(1)]] :
                                                [temp appendWith:[calutil stringWithSuperscriptSystemFont:currentString location:0 length:[currentString length] value:@(1)]];
                        i+=[currentString length];
                    }
                } else {
                    temp = [temp appendWithString:@"^"];
                    i++;
                }
            }
                break;
            case 'S':{ // SQRT(
                if(length >= i + 5) {
                    range.location =  i;
                    range.length = 5;
                    currentString = [mExpression substringWithRange:range];
                    if([currentString isEqualToString:@"SQRT("]) {
                        temp = [temp appendWith:bDefault == YES ? [calutil stringSquareroot] :[calutil stringSquareroot_h]];
                        i+=5;
                        if(length > i) {
                            range.location = i;
                            range.length = [self getNumberLengthFromMathExpression:mExpression with:range.location];
                            if(range.length > 0 ) {
                                currentString = [mExpression substringWithRange:range];
                                temp = [temp appendWithString:currentString];
                                i+=range.length;
                            }
                        }
                        break;
                    }
                }
            }
                break;
            case 'C':{ // CBRT(
                if(length >= i + 5) {
                    range.location = i;
                    range.length = 5;
                    currentString = [mExpression substringWithRange:range];
                    if([currentString isEqualToString:@"CBRT("]) {
                        temp = [temp appendWith:bDefault == YES ? [calutil stringCuberoot] : [calutil stringCuberoot_h]];
                        i+=5;
                        if(length > i) {
                            range.location = i;
                            range.length = [self getNumberLengthFromMathExpression:mExpression with:range.location];
                            if(range.length > 0 ) {
                                currentString = [mExpression substringWithRange:range];
                                temp = [temp appendWithString:currentString];
                                i+=range.length;
                            }
                        }
                        break;
                    }
                }
            }
                break;
            case 'R':{ // RANDOM(
                if(length >= i + 7) {
                    range.location = i;
                    range.length = 7;
                    currentString = [mExpression substringWithRange:range];
                    if([currentString isEqualToString:@"RANDOM("]) {
                        temp = [temp appendWithString:currentString];
                        i+=7;
                        break;
                    }
                }
            }
                break;
            case 'P': { // PI
                if (length >= i + 2) {
                    range.location = i;
                    range.length = 2;
                    currentString = [mExpression substringWithRange:range];
                    if([currentString isEqualToString:@"PI"]) {
                        CGFloat fontsize;
                        if(IS_IPHONE) {
                            fontsize = 18.0;
                        }
                        else {
                            fontsize = 22.0;
                        }
                        NSAttributedString *pi = [[NSAttributedString alloc] initWithString:@"π" attributes:@{NSFontAttributeName:[UIFont fontWithName:@"HelveticaNeue-MediumItalic" size:fontsize]}];

                        temp = [temp appendWith:pi];
                        i+=2;
                    }
                }
            }
                break;
            default:
                FNLOG("Error:undefined char %c in MathExpression", c);
                i+=length;//exit for loop
                break;
        }
    }
    
    temp = [temp appendWith:[calutil invisibleString]];
    return [temp copy];
}

- (void) changethelastnumberwithoperator:(NSUInteger) key{
    if ([mathexpression length] != 0) {
        
        // Get the last number for the operator
        NSUInteger numParenthesis = 0;
        NSString *lastChar = [mathexpression substringFromIndex:[mathexpression length] - 1];
        
        NSRange range = [lastChar rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"1234567890.)"]];
        if ([lastChar isEqualToString:@")"]) {
            numParenthesis++;
        }
        if(range.location != NSNotFound) {
            range = [mathexpression rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"1234567890.)"] options:NSBackwardsSearch];
            NSUInteger startLocation = range.location;
            
            while ( (range.location != NSNotFound) &&
                   (range.location != 0)) {
                range.location = range.location > 0  ? (range.location - 1) : 0;
                if (numParenthesis == 0) {
                    range = [mathexpression rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"1234567890."] options:0 range:range];
                } else {
                    //range = [mathexpression rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"1234567890.+()"] options:0 range:range];
                    range.location--;
                    lastChar = [mathexpression substringWithRange:range];
                    
                    if ([lastChar isEqualToString:@")"]) {
                        numParenthesis++;
                    }
                    if ([lastChar isEqualToString:@"("]) {
                        numParenthesis--;
                    }
                }
                if(range.location != NSNotFound) {
                    startLocation  = range.location;
                }
            } // end - while
            
            NSString *lastnumber = [mathexpression substringFromIndex:startLocation];
            
            // count the character which exists ONLY in expression.text
            // NSCharacterSet *charset = [NSCharacterSet characterSetWithCharactersInString:@"^"];
            // int numberOfcharacter = [self getCharacterCountInExpression:mathexpression withCharacterSet:charset];
            
            range.location = startLocation;// - numberOfcharacter; // for _expressLabel.attributedtext
            range.length = [lastnumber length];
            
            switch (key) {
                case A3E_POWER_2: {
                    range = [mathexpression rangeOfString:lastnumber options:NSBackwardsSearch];
                    if (range.location != NSNotFound) {
                        NSString *newString = [@"2^" stringByAppendingString:lastnumber];
                        mathexpression = [mathexpression stringByReplacingOccurrencesOfString:lastnumber withString:newString options:NSBackwardsSearch range:range];
                    } else {
                        FNLOG("%@ is not found in mathexpression",lastnumber);
                    }
                }
                    break;
                case A3E_POWER_10: {
                    range = [mathexpression rangeOfString:lastnumber options:NSBackwardsSearch];
                    if (range.location != NSNotFound) {
                        NSString *newString = [@"10^" stringByAppendingString:lastnumber];
                        mathexpression = [mathexpression stringByReplacingOccurrencesOfString:lastnumber withString:newString options:NSBackwardsSearch range:range];
                    } else {
                        FNLOG("%@ is not found in mathexpression",lastnumber);
                    }
                    
                }
                    break;
                case A3E_FACTORIAL: {
                    range = [mathexpression rangeOfString:lastnumber options:NSBackwardsSearch];
                    if (range.location != NSNotFound) {
                        NSString *newString = [[@"FACT(" stringByAppendingString:lastnumber] stringByAppendingString:@")"];
                        mathexpression = [mathexpression stringByReplacingOccurrencesOfString:lastnumber withString:newString options:NSBackwardsSearch range:range];
                    } else {
                        FNLOG("%@ is not found in mathexpression",lastnumber);
                    }
                }
                    break;
                case A3E_LOG_Y : {
                    range = [mathexpression rangeOfString:lastnumber options:NSBackwardsSearch];
                    if (range.location != NSNotFound) {
                        NSString *newString = [[@"LOGN(" stringByAppendingString:lastnumber] stringByAppendingString:@","];
                        mathexpression = [mathexpression stringByReplacingOccurrencesOfString:lastnumber withString:newString options:NSBackwardsSearch range:range];
                    } else {
                        FNLOG("%@ is not found in mathexpression",lastnumber);
                    }
                }
                    break;
                case  A3E_NTHROOT: {
                    range = [mathexpression rangeOfString:lastnumber options:NSBackwardsSearch];
                    if (range.location != NSNotFound) {
                        NSString *newString = [[@"NTHRT(" stringByAppendingString:lastnumber] stringByAppendingString:@","];
                        mathexpression = [mathexpression stringByReplacingOccurrencesOfString:lastnumber withString:newString options:NSBackwardsSearch range:range];
                        numberMode = YES;
                    } else {
                        FNLOG("%@ is not found in mathexpression",lastnumber);
                    }
                }
                    break;
                case  A3E_POWER_XY: {
                    range = [mathexpression rangeOfString:lastnumber options:NSBackwardsSearch];
                    if (range.location != NSNotFound) {
                        NSString *newString = [lastnumber stringByAppendingString:@"^"];
                        mathexpression = [mathexpression stringByReplacingOccurrencesOfString:lastnumber withString:newString options:NSBackwardsSearch range:range];
                    } else {
                        FNLOG("%@ is not found in mathexpression",lastnumber);
                    }
                }
                    break;
                case A3E_DIVIDE_X : {
                    range = [mathexpression rangeOfString:lastnumber options:NSBackwardsSearch];
                    if (range.location != NSNotFound) {
                        NSString *newString = [[@"1/(" stringByAppendingString:lastnumber] stringByAppendingString:@")"];
                        mathexpression = [mathexpression stringByReplacingOccurrencesOfString:lastnumber withString:newString options:NSBackwardsSearch range:range];
                    } else {
                        FNLOG("%@ is not found in mathexpression",lastnumber);
                    }
                    
                    
                }
                    break;
                default:
                    break;
                    
                    
            }
            [self convertMathExpressionToAttributedString];
            FNLOG("mathexpression = %@", mathexpression);
            return;
        }
    }
    
    if (key == A3E_POWER_2 ||
        key == A3E_POWER_10 ||
        key == A3E_LOG_Y) {
        if (!mathexpression) {
            mathexpression = [NSString new];
        }
        if (key == A3E_POWER_10) {
            mathexpression = [mathexpression stringByAppendingString:@"10^"];
        } else  if (key == A3E_POWER_2){
            mathexpression = [mathexpression stringByAppendingString:@"2^"];
        } else if (key == A3E_LOG_Y) {
            LOGYMode = YES;
        }
        [self convertMathExpressionToAttributedString];
    }
}

- (void) singleargHandler:(NSUInteger) key {
    NSString    *stringFuncName;
    BOOL      bHasParameter = NO;
    
    switch (key) {
        case A3E_SQUARE:
            stringFuncName =@"^2";
            break;
        case A3E_CUBE:
            stringFuncName = @"^3";
            break;
            
        case A3E_SQUAREROOT:
            stringFuncName = @"SQRT(";
            bHasParameter = YES;
            break;
            
        case A3E_CUBEROOT:
            stringFuncName = @"CBRT(";
            bHasParameter = YES;
            break;
        case A3E_LN:
            stringFuncName = @"LN(";
            bHasParameter = YES;
            break;
        case A3E_LOG_10:
            stringFuncName = @"LOG(";
            bHasParameter = YES;
            break;
        case A3E_LOG_2:
            stringFuncName = @"LOG2(";
            bHasParameter = YES;
            break;
        case A3E_PERCENT:
            stringFuncName = @"x1/100";
            break;
        case A3E_RANDOM:
            stringFuncName = @"RANDOM(";
            bHasParameter = YES;
            break;
        case A3E_POWER_2:
        case A3E_FACTORIAL:
        case A3E_POWER_10:
        case A3E_LOG_Y:
            [self changethelastnumberwithoperator:key];
            [self evaluateAndSet];
            return;
            
    }
    
    if (![mathexpression length] ||
         [mathexpression isEqualToString:@"0"]) {
        if(bHasParameter) {
            mathexpression = stringFuncName;
        } else {
            return;
        }
    } else {
        NSString *lastChar = [mathexpression substringFromIndex:[mathexpression length] - 1];
        if(bHasParameter) {
            NSRange range = [lastChar rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"x/+-("]];
            if (range.location != NSNotFound) {
                mathexpression = [mathexpression stringByAppendingString:stringFuncName];
            } else {
                range = [lastChar rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"01234567890.)"]];
                // in case of number, add multiply simbol automatically
                if( range.location != NSNotFound) {
                    [self addMultiplyInExpressWith:stringFuncName];
                }
            }
        } else {
            NSRange range = [lastChar rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"01234567890.)"]];
            if(range.location != NSNotFound) {
                mathexpression = [mathexpression stringByAppendingString:stringFuncName];
                [self evaluateAndSet];
            }
        }
    }
    
    [self convertMathExpressionToAttributedString];
    
}

- (void) ShowMessage:(NSString *)message {
    if ([self.delegate respondsToSelector:@selector(ShowMessage:)]) {
        [self.delegate ShowMessage:message];
    }
    
}
- (void) trigonometricFunctionHandler:(NSUInteger) key {
    // the logic is the same as lefparentheses
    NSString *funcName;
    switch (key) {
        case A3E_SIN:
            funcName = @"sin";
            break;
        case A3E_COS:
            funcName = @"cos";
            break;
        case A3E_TAN:
            funcName = @"tan";
            break;
        case A3E_SINH:
            funcName = @"sinh";
            break;
        case A3E_COSH:
            funcName = @"cosh";
            break;
        case A3E_TANH:
            funcName = @"tanh";
            break;
        case A3E_ASIN:
            funcName = @"sin-1";
            break;
        case A3E_ACOS:
            funcName = @"cos-1";
            break;
        case A3E_ATAN:
            funcName = @"tan-1";
            break;
        case A3E_ASINH:
            funcName = @"sinh-1";
            break;
        case A3E_ACOSH:
            funcName = @"cosh-1";
            break;
        case A3E_ATANH:
            funcName = @"tanh-1";
            break;
        case A3E_COT:
            funcName = @"cot";
            break;
        case A3E_ACOT:
            funcName = @"cot-1";
            break;
            
    }
    
    funcName = [funcName stringByAppendingString:@"("];
    
    if (![mathexpression length] ||
        [mathexpression isEqualToString:@"0"]) {
        mathexpression = funcName;
    } else {
        NSString *lastChar = [mathexpression substringFromIndex:[mathexpression length] - 1];
        NSRange range = [lastChar rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"x/+-("]];
        if (range.location != NSNotFound) {
            mathexpression = [mathexpression stringByAppendingString:funcName];
        } else {
            range = [lastChar rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"01234567890.)"]];
            // in case of number, add multiply simbol automatically
            if( range.location != NSNotFound) {
                [self addMultiplyInExpressWith:funcName];
            }
        }
    }
    [self convertMathExpressionToAttributedString];
}

- (void) deleteCharactersInExpress:(NSRange) range {
    NSMutableAttributedString *temp = [_expressionLabel.attributedText mutableCopy];
    [temp deleteCharactersInRange:range];
    _expressionLabel.attributedText = [temp copy];
}

- (void) backspaceHandler {
    if([mathexpression length] == 0) {
        return;
    }
    
    if ([mathexpression length] == 1) {
        _expressionLabel.text = @"";
        mathexpression = @"";
        _evaluatedResultLabel.text = @"0";
        return;
    }
    
    NSRange range;
    NSString *lastChar;
    
    // delete the function with two parameter
    lastChar = [mathexpression substringFromIndex:[mathexpression length] -1];
    
    if([lastChar isEqualToString:@","]) {   //NTHRT(, LOGN(
        mathexpression = [mathexpression substringToIndex:[mathexpression length] - 1];
        while([mathexpression length] > 0) {
            lastChar = [mathexpression substringFromIndex:[mathexpression length] -1];
            range = [lastChar rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"1234567890."]];
            if(range.location != NSNotFound) {
                mathexpression = [mathexpression substringToIndex:[mathexpression length] - 1];
            } else {
                break;
            }
        }
        if([mathexpression length] >= 6) {
            lastChar = [mathexpression substringFromIndex:[mathexpression length] - 6];
            if([lastChar isEqualToString:@"NTHRT("]) {
                mathexpression = [mathexpression substringToIndex:[mathexpression length] - 6];
                return;
            }
        }
        if ([mathexpression length] >= 5){
            lastChar = [mathexpression substringFromIndex:[mathexpression length] - 5];
            if([lastChar isEqualToString:@"LOGN("]) {
                mathexpression = [mathexpression substringToIndex:[mathexpression length] - 5];
                return;
            }
        }
        return;
    }
    
    // delete function with one parameter
    if([lastChar isEqualToString:@"("]) {
        if([mathexpression length] >= 7) {
            lastChar = [mathexpression substringFromIndex:[mathexpression length] - 7];
            if([lastChar isEqualToString:@"sinh-1("] ||
               [lastChar isEqualToString:@"cosh-1("] ||
               [lastChar isEqualToString:@"tanh-1("] ||
               [lastChar isEqualToString:@"RANDOM("]) {
                mathexpression = [mathexpression substringToIndex:[mathexpression length] - 7];
                return;
            }
        }
        if ([mathexpression length] >= 6) {
            lastChar = [mathexpression substringFromIndex:[mathexpression length] - 6];
            if([lastChar isEqualToString:@"sin-1("]||
               [lastChar isEqualToString:@"cos-1("]||
               [lastChar isEqualToString:@"cot-1("]||
               [lastChar isEqualToString:@"tan-1("]||
               [lastChar isEqualToString:@"NTHRT("]) {
                mathexpression = [mathexpression substringToIndex:[mathexpression length] - 6];
                return;
            }
        }
        
        if ([mathexpression length] >=5) {
            lastChar = [mathexpression substringFromIndex:[mathexpression length] - 5];
            if([lastChar isEqualToString:@"sinh("]||
               [lastChar isEqualToString:@"cosh("]||
               [lastChar isEqualToString:@"tanh("]||
               [lastChar isEqualToString:@"LOGN("]||
               [lastChar isEqualToString:@"SQRT("]||
               [lastChar isEqualToString:@"CBRT("]||
               [lastChar isEqualToString:@"LOG2("]) {
                mathexpression = [mathexpression substringToIndex:[mathexpression length] - 5];
                return;
            }
        }
        
        if ([mathexpression length] >= 4) {
            lastChar = [mathexpression substringFromIndex:[mathexpression length] - 4];
            if([lastChar isEqualToString:@"sin("]||
               [lastChar isEqualToString:@"cos("]||
               [lastChar isEqualToString:@"tan("]||
               [lastChar isEqualToString:@"cot("]||
               [lastChar isEqualToString:@"LOG("]) {
                mathexpression = [mathexpression substringToIndex:[mathexpression length] - 4];
                return;
            }
        }
        
        if ([mathexpression length] >= 3) {
            lastChar = [mathexpression substringFromIndex:[mathexpression length] - 3];
            if([lastChar isEqualToString:@"LN("]) {
                mathexpression = [mathexpression substringToIndex:[mathexpression length] - 3];
                return;
            }
        }
    }
    
    // delete the character one by one
    range = [lastChar rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"1234567890.+-x/EIe^="]]; // 1:E:EE, PI:I
    if(range.location != NSNotFound) {
        mathexpression = [mathexpression substringToIndex:[mathexpression length] - 1];
        
        // special case
        if ([lastChar isEqualToString:@"E"] ||
            [lastChar isEqualToString:@"I"]) {
            mathexpression = [mathexpression substringToIndex:[mathexpression length] - 1];
            return;
        }
        
        lastChar = [mathexpression substringFromIndex:[mathexpression length] - 1];
        if([lastChar isEqualToString:@"^"]) {
            mathexpression = [mathexpression substringToIndex:[mathexpression length] - 1];
        }
                return;
    }
    
    if([lastChar isEqualToString:@")"]) {
        mathexpression = [mathexpression substringToIndex:[mathexpression length] - 1];
        NSUInteger nLen = 0, numParenthesis = 0;
        while ([mathexpression length] - ++nLen > 0) {
            range.location = [mathexpression length] - nLen;
            range.length = 1;
            lastChar = [mathexpression substringWithRange:range];
            if ([lastChar isEqualToString:@")"]) {
                numParenthesis++;
            }
            
            if (numParenthesis> 0 && [lastChar isEqualToString:@"("]) {
                numParenthesis--;
                continue;
            }

            if (numParenthesis == 0) {
                range = [lastChar rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"1234567890."]];
                if (range.location == NSNotFound) {
                    nLen--;
                    break;
                }
            }
        }
        
        if([lastChar isEqualToString:@"("])
        {
            range.location = [mathexpression length] - nLen - 5;// 5=? FACT(
            range.length = 5;
            lastChar = [mathexpression substringWithRange:range];
            if([lastChar isEqualToString:@"FACT("]) {
                range.location = [mathexpression length] - nLen;
                range.length = nLen;
                NSString *number = [mathexpression substringWithRange:range];
                mathexpression = [mathexpression substringToIndex:[mathexpression length] - nLen -5];
                mathexpression = [mathexpression stringByAppendingString:number];
            }
        }
    }
}

- (void) clearCalculation {
    _expressionLabel.text = @"";
    _evaluatedResultLabel.text = @"0";
    mathexpression = @"";
}

- (void) specialkeyHandler:(NSUInteger) key {
    switch (key) {
        case A3E_CLEAR:{
            [self clearCalculation];
            break;
        }
        case A3E_SIGN: {
            if([self checkIfexpressionisnull]) {
                if (mathexpression == nil) {
                    mathexpression = [NSString new];
                }
                mathexpression = @"(-0)";
                [self convertMathExpressionToAttributedString];
                return;
            }
			NSString *lastChar = nil;
			if ([mathexpression length]) {
				lastChar = [mathexpression substringFromIndex:[mathexpression length] - 1];
			}
            if ([lastChar isEqualToString:@")"]) {
                lastChar = [mathexpression substringFromIndex:[mathexpression length] - 2];
                NSRange range = [lastChar rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"1234567890."]];
                if (range.location != NSNotFound) {
                    if ([[mathexpression substringFromIndex:[mathexpression length] -4] isEqualToString:@"(-0)"]) {
                        mathexpression = [mathexpression substringToIndex:[mathexpression length] -4];
                    }
                    else {
                        range = [mathexpression rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"-"] options:NSBackwardsSearch];
                        if (range.location != NSNotFound) {// remove '-'
                            range.location = range.location - 1;
                            range.length = [mathexpression length] - range.location;
                            mathexpression = [mathexpression stringByReplacingOccurrencesOfString:@"-" withString:@"" options:0 range:range];
                            range.length = range.length - 1;
                            mathexpression = [mathexpression stringByReplacingOccurrencesOfString:@"(" withString:@"" options:0 range:range];
                            range.length = range.length - 1;
                            mathexpression = [mathexpression stringByReplacingOccurrencesOfString:@")" withString:@"" options:0 range:range];
                            
                        }
                    }
                    [self convertMathExpressionToAttributedString];
                    [self evaluateAndSet];
                }
            }
            else
            {
                NSRange range = [lastChar rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"1234567890."]];
                if ([mathexpression length] && range.location != NSNotFound) {
                    range = [mathexpression rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"1234567890."] options:NSBackwardsSearch];
                    NSUInteger startLocation = range.location;
                    while ((range.location != NSNotFound) &&
                           (range.location != 0)) {
                        range.location = (range.location > 0) ? (range.location - 1) : 0;
                        range = [mathexpression rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"1234567890."] options:0 range:range];
                        if (range.location != NSNotFound)
                            startLocation = range.location;
                    }
                    NSString *oldNumber = [mathexpression substringFromIndex:startLocation];
                    NSString *newNumber = [[@"(-" stringByAppendingString:oldNumber] stringByAppendingString:@")"];
                    range.location = startLocation;
                    range.length = [mathexpression length] - startLocation;
                    mathexpression = [mathexpression stringByReplacingOccurrencesOfString:oldNumber withString:newNumber options:0 range:range];
                    [self convertMathExpressionToAttributedString];
                    [self evaluateAndSet];
                } else {
                    mathexpression = [mathexpression stringByAppendingString:@"(-0)"];
                    [self convertMathExpressionToAttributedString];
                }
            }
            break;
            
        }
        case A3E_BACKSPACE: {
            [self backspaceHandler];
            
            if(![mathexpression length]) {
                _expressionLabel.text = @"";
                mathexpression = @"";
                _evaluatedResultLabel.text = @"0";
            } else {
                [self convertMathExpressionToAttributedString];
                [self evaluateAndSet];
            }
            
            break;
        }
        case A3E_DIVIDE_X: {
            [self changethelastnumberwithoperator:key];
            [self evaluateAndSet];
            return;
        }
            break;
        case A3E_CALCULATE: {
            if([self checkIfexpressionisnull]) return;
            int numberOfOpen = 0, numberOfClose = 0;
            NSCharacterSet *charset = [NSCharacterSet characterSetWithCharactersInString:@"("];
            numberOfOpen = [self getCharacterCountInExpression:mathexpression withCharacterSet:charset];
            charset = [NSCharacterSet characterSetWithCharactersInString:@")"];
            numberOfClose = [self getCharacterCountInExpression:mathexpression withCharacterSet:charset];
            if (numberOfOpen > numberOfClose) {
                int ndifference = numberOfOpen - numberOfClose;
                while (ndifference-- > 0) {
                    mathexpression = [mathexpression stringByAppendingString:@")"];
                }
            }
            
            NSString *lastChar = [mathexpression substringFromIndex:[mathexpression length] - 1];
            NSRange range = [lastChar rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"(x/+-="]];
            if (range.location == NSNotFound) {
                mathexpression = [mathexpression stringByAppendingString:@"="];
            }
            [self convertMathExpressionToAttributedString];
            [self evaluateAndSet];
        }
            break;
        case A3E_00: {
            if(([self checkIfexpressionisnull])) return;
            NSString* lastChar = [mathexpression substringFromIndex:[mathexpression length] -1];
            NSRange range = [lastChar rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"1234567890."]];
            if(range.location != NSNotFound) {
                mathexpression = [mathexpression stringByAppendingString:@"00"];
                [self convertMathExpressionToAttributedString];
                [self evaluateAndSet];
            }
        }
            break;
        case A3E_DECIMAL_SEPARATOR:
        {
            if (!mathexpression || ![mathexpression length]) {
                mathexpression = @"0.";
                [self convertMathExpressionToAttributedString];
                break;
            }
            
            // . 중복 검색.
            NSRange range = [mathexpression rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"(x/+-="] options:NSBackwardsSearch];
            NSString *lastValue = [mathexpression substringFromIndex:range.location != NSNotFound? range.location + 1 : 0];
            range = [lastValue rangeOfString:@"."];
            if (range.location != NSNotFound) {
                break;  // 마지막 입력값이 이미 소수점을 갖고 있습니다.
            }
            
            mathexpression = [mathexpression stringByAppendingString:[lastValue length] == 0 ? @"0." : @"."];
            [self convertMathExpressionToAttributedString];
        }
            break;
    }
}

- (void)numberHandler:(NSUInteger)key {
    
    NSString *num = [NSString stringWithFormat:@"%lu", (unsigned long)key - A3E_0];
    
    if (LOGYMode == YES) {
        if ([mathexpression length] == 0) {
            mathexpression =  [[@"LOGN(" stringByAppendingString:num] stringByAppendingString:@","];
        } else {
            mathexpression = [mathexpression stringByAppendingString:[[@"LOGN(" stringByAppendingString:num] stringByAppendingString:@","]];
        }
        [self convertMathExpressionToAttributedString];
        LOGYMode = NO;
        return;
    }
    
    if ([mathexpression length] == 0) {
        mathexpression = num;
        _evaluatedResultLabel.text = num;
        [self convertMathExpressionToAttributedString];
    }
    else {
        NSString *lastChar = [mathexpression substringFromIndex:[mathexpression length] - 1];
        
        if ([lastChar isEqualToString:@")"]) {
            NSUInteger i=1;
            NSRange range;
            range.length = 1;
            do {
                i++;
                range.location = [mathexpression length] - i;
                lastChar = [mathexpression substringWithRange:range];
            } while((![lastChar isEqualToString:@"-"]) &&
                    i < [mathexpression length]);
            if( [lastChar isEqualToString:@"-"]) {
                i++;
                range.location = [mathexpression length] - i;
                lastChar = [mathexpression substringWithRange:range];
                if ([lastChar isEqualToString:@"("]) {
                    mathexpression = [mathexpression substringToIndex:[mathexpression length] - 1];
                    mathexpression = [mathexpression stringByAppendingString:[NSString stringWithFormat:@"%@)",num]];
                    [self convertMathExpressionToAttributedString];
                    [self evaluateAndSet];
                    return;
                }
            } else {
                mathexpression = [mathexpression stringByAppendingString:@"+"];
            }
        } else if ([lastChar isEqualToString:@"0"] && [mathexpression length] == 1) {
            _evaluatedResultLabel.text = num;
            mathexpression = num;
        }
        
        NSUInteger i = 1, numLen = 0;
        NSRange range;
        range.length = 1;
        do {
            range.location = [mathexpression length] - i++;
            range = [mathexpression rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"0123456789"] options:0 range:range];
            if(range.location != NSNotFound) {
                numLen++;
            }
        } while (range.location != NSNotFound &&
                 i <= [mathexpression length]);
        
        if (IS_IPHONE && IS_PORTRAIT) {
            if (numLen >= 9) return;
        } else {
            if (numLen >= 15) return;
        }
        mathexpression = [mathexpression stringByAppendingString:num];
        [self convertMathExpressionToAttributedString];
        [self evaluateAndSet];
    }
}

- (NSString *) getOperator:(NSUInteger)key {
    
    switch (key) {
        case A3E_PLUS:
            return @"+";
        case A3E_MINUS:
            return @"-";
        case A3E_MULTIPLY:
            return @"x";
        case A3E_DIVIDE:
            return @"/";
        case A3E_LEFT_PARENTHESIS:
            return @"(";
        case A3E_RIGHT_PARENTHESIS:
            return @"):";
    }
    
    return @"";
}

- (int) getCharacterCountInExpression:(NSString *) string withCharacterSet:(NSCharacterSet *) charset {
    int num = 0;
    NSRange range = [string rangeOfCharacterFromSet:charset];
    while (range.location != NSNotFound) {
        num++;
        range.location++;
        range.length = [string length] - range.location;
        range = [string rangeOfCharacterFromSet:charset options:0 range:range];
    }
    
    return num;
}

- (void) addMultiplyInExpressWith:(NSString *) symbol{
    mathexpression = [[mathexpression stringByAppendingString:@"x"] stringByAppendingString:symbol];
    // _expressionLabel.attributedText = [_expressionLabel.attributedText appendWith:asymbol];
}

- (BOOL) checkIfexpressionisnull {
    if (![_expressionLabel.text length] ||
        [_expressionLabel.text isEqualToString:@"0"]) {
        return YES;
    }
    
    return NO;
}
- (void)operatorHandler:(NSUInteger)key {
    NSString *numOperator = [self getOperator:key];
    
    switch (key) {
        case A3E_PLUS:
        case A3E_MINUS:
        case A3E_MULTIPLY:
        case A3E_DIVIDE: {
            if([self checkIfexpressionisnull]) return;
            
            NSString *lastChar = [mathexpression substringFromIndex:[mathexpression length] - 1];
            NSRange range = [lastChar rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"+-x/("]];
            if (range.location == NSNotFound) {
                // _expressionLabel.attributedText = [_expressionLabel.attributedText appendWithString:numOperator];
                mathexpression  = [mathexpression stringByAppendingString:numOperator];
            } else { // TODO
                if(![lastChar isEqualToString:@"("]) {
                    mathexpression = [[mathexpression substringToIndex:[mathexpression length] -1] stringByAppendingString:numOperator];
                }
            }
            [self convertMathExpressionToAttributedString];
            [self evaluateAndSet];
            
            break;
        }
        case A3E_LEFT_PARENTHESIS: {
            
            if (![mathexpression length] ||
                [mathexpression isEqualToString:@"0"]) {
                mathexpression = numOperator;
                //_expressionLabel.attributedText = [[NSAttributedString alloc ] initWithString:numOperator];
            } else {
                NSString *lastChar = [mathexpression substringFromIndex:[mathexpression length] - 1];
                NSRange range = [lastChar rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"x/+-("]];
                if (range.location != NSNotFound) {
                    mathexpression = [mathexpression stringByAppendingString:numOperator];
                    //_expressionLabel.attributedText = [_expressionLabel.attributedText appendWithString:numOperator];
                } else {
                    range = [lastChar rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"01234567890.)"]];
                    // in case of number, add multiply simbol automatically
                    if( range.location != NSNotFound) {
                        //NSAttributedString* anumOperator = [[NSAttributedString alloc] initWithString:numOperator]; // TODO
                        [self addMultiplyInExpressWith:numOperator];
                    }
                }
            }
            [self convertMathExpressionToAttributedString];
            break;
        }
        case A3E_RIGHT_PARENTHESIS: {
            if([self checkIfexpressionisnull]) return;
            
            NSString *lastChar = [mathexpression substringFromIndex:[mathexpression length] - 1];
            NSRange range = [lastChar rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"1234567890.)"]];
            if (range.location != NSNotFound) {
                int numberOfOpen = 0, numberOfClose = 0;
                NSCharacterSet *charset = [NSCharacterSet characterSetWithCharactersInString:@"("];
                numberOfOpen = [self getCharacterCountInExpression:mathexpression withCharacterSet:charset];
                charset = [NSCharacterSet characterSetWithCharactersInString:@")"];
                numberOfClose = [self getCharacterCountInExpression:mathexpression withCharacterSet:charset];
                if (numberOfOpen <= numberOfClose) {
                    mathexpression = [@"(" stringByAppendingString:mathexpression];
                }
                mathexpression = [mathexpression stringByAppendingString:@")"];
                // _expressionLabel.attributedText = [_expressionLabel.attributedText appendWithString:@")"];
            }
            [self convertMathExpressionToAttributedString];
            [self evaluateAndSet];
            break;
        }
    }
    
}

@end
