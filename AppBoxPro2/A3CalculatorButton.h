//
//  A3CalculatorButton.h
//  AppBoxPro2
//
//  Created by Byeong Kwon Kwak on 7/10/12.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum tagA3CalculatorButtonColors {
	A3CalculatorButtonColorBlue = 0,
	A3CalculatorButtonColorPink,
	A3CalculatorButtonColorBlack,
	A3CalculatorButtonColorGray,
	A3CalculatorButtonColorOrange
} A3CalculatorButtonColors;

@interface A3CalculatorButton : UIButton

@property (nonatomic, strong)	NSString *buttonColor;		// Blue, Pink, Black, Gray, Orange

@end
