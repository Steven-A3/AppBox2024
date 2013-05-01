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

@interface A3EntryElement : QEntryElement
- (id)initWithTitle:(NSString *)string Value:(NSString *)param Placeholder:(NSString *)string1;
@end

@interface A3LabelElement : QLabelElement
- (id)initWithTitle:(NSString *)string Value:(id)value;
@end

@interface A3ButtonElement : QButtonElement
- (id)initWithTitle:(NSString *)title;
@end

@interface A3NumberEntryElement : QEntryElement
- (id)initWithTitle:(NSString *)string Value:(NSString *)param Placeholder:(NSString *)string1;
@end

@interface A3CurrencyEntryElement : QEntryElement
- (id)initWithTitle:(NSString *)string Value:(NSString *)param Placeholder:(NSString *)string1;
@end

@interface A3TermEntryElement : QEntryElement
- (id)initWithTitle:(NSString *)string Value:(NSString *)param Placeholder:(NSString *)string1;
@end

@interface A3InterestEntryElement : QEntryElement
- (id)initWithTitle:(NSString *)string Value:(NSString *)param Placeholder:(NSString *)string1;
@end

@interface A3FrequencyEntryElement : QEntryElement
- (id)initWithTitle:(NSString *)string Value:(NSString *)param Placeholder:(NSString *)string1;
@end

@interface A3DateEntryElement : QEntryElement
- (id)initWithTitle:(NSString *)string Value:(NSString *)param Placeholder:(NSString *)string1;
@end

@interface A3PercentEntryElement : QEntryElement
- (id)initWithTitle:(NSString *)string Value:(NSString *)param Placeholder:(NSString *)string1;
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