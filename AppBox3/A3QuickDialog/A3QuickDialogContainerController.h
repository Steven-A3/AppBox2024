//
//  A3QuickDialogContainerController
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 4/19/13 12:56 PM.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "A3AppViewController.h"
#import "A3KeyboardProtocol.h"
#import "A3NumberKeyboardViewController.h"
#import "A3DateKeyboardViewController.h"
#import "A3FrequencyKeyboardViewController.h"

@protocol A3QuickDialogCellStyleDelegate <NSObject>

- (UIColor *)tableViewBackgroundColor;
- (UIFont *)fontForCellLabel;
- (UIFont *)fontForEntryCellLabel;
- (UIFont *)fontForEntryCellTextField;
- (UIColor *)colorForCellLabelNormal;
- (UIColor *)colorForCellLabelSelected;
- (UIColor *)colorForEntryCellTextField;
- (UIColor *)colorForCellButton;
- (CGFloat)heightForElement:(QElement *)element;

@end

@interface A3EntryElement : QEntryElement
@property (nonatomic, weak) id<A3QuickDialogCellStyleDelegate> cellStyleDelegate;

- (id)initWithTitle:(NSString *)string Value:(NSString *)param Placeholder:(NSString *)string1;
@end

@interface A3LabelElement : QLabelElement
@property (nonatomic, weak) id<A3QuickDialogCellStyleDelegate> cellStyleDelegate;

- (id)initWithTitle:(NSString *)string Value:(id)value;
@end

@interface A3ButtonElement : QButtonElement
@property (nonatomic, weak) id<A3QuickDialogCellStyleDelegate> cellStyleDelegate;

- (id)initWithTitle:(NSString *)title;
@end

@interface A3NumberEntryElement : A3EntryElement
@end

@interface A3CurrencyEntryElement : A3EntryElement
@end

@interface A3TermEntryElement : A3EntryElement
@end

@interface A3InterestEntryElement : A3EntryElement
@end

@interface A3FrequencyEntryElement : A3EntryElement
@end

@interface A3DateEntryElement : A3EntryElement
@end

@interface A3PercentEntryElement : A3EntryElement
@end

@interface A3SelectItemElement : QRootElement
@property (nonatomic, weak) id<A3QuickDialogCellStyleDelegate> cellStyleDelegate;

- (id)init;
@end

@interface A3DateTimeInlineElement : QDateTimeInlineElement
@property (nonatomic, weak) id<A3QuickDialogCellStyleDelegate> cellStyleDelegate;

- (id)initWithTitle:(NSString *)string date:(NSDate *)date;
@end

@interface A3QuickDialogContainerController : A3AppViewController <QuickDialogStyleProvider, QuickDialogEntryElementDelegate, A3KeyboardDelegate, A3DateKeyboardDelegate, A3FrequencyKeyboardDelegate>

@property (nonatomic, weak) QRootElement *root;
@property (nonatomic, weak) QEntryElement *editingElement;
@property (nonatomic, strong) NSString *defaultCurrencyCode;
@property (nonatomic, strong) QuickDialogController *quickDialogController;
@property (nonatomic, weak) QuickDialogTableView *quickDialogTableView;
@property (nonatomic) CGFloat rowHeight;

- (QRootElement *)rootElement;
- (void)registerForKeyboardNotifications;

@end