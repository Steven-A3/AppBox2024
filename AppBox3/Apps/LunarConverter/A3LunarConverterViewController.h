//
//  A3LunarConverterViewController.h
//  A3TeamWork
//
//  Created by coanyaa on 13. 10. 14..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "A3DateKeyboardViewController.h"
#import "SQLiteWrapper.h"

@interface A3LunarConverterViewController : UIViewController<UIScrollViewDelegate,A3DateKeyboardDelegate,UITextFieldDelegate,UIPopoverControllerDelegate>{

    BOOL _isLunarInput;
    SQLiteWrapper *_dbManager;
}

@property (weak, nonatomic) IBOutlet UIScrollView *mainScrollView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;

@property (strong, nonatomic) IBOutlet UIView *firstPageView;
@property (strong, nonatomic) IBOutlet UIView *secondPageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mainScrollViewHeightConst;

- (IBAction)swapAction:(id)sender;
- (IBAction)pageChangedAction:(id)sender;
- (IBAction)handleTapgesture:(id)sender;
@end
