//
//  A3HomeStyleMenuViewController.h
//  HexagonMenu
//
//  Created by Byeong Kwon Kwak on 2/26/16.
//  Copyright © 2016 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface A3HomeStyleMenuViewController : UIViewController

@property (nonatomic, strong) UIColor *utilityColor, *calculatorColor, *referenceColor;
@property (nonatomic, strong) UIColor *converterColor, *productivityColor;
@property (nonatomic, strong) NSDictionary *groupColors;

- (UIView *)backgroundView;

@end
