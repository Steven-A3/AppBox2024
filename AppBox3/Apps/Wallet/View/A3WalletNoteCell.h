//
//  A3WalletNoteCell.h
//  A3TeamWork
//
//  Created by kihyunkim on 2013. 12. 26..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GCPlaceholderTextView.h"

@interface A3WalletNoteCell : UITableViewCell

@property (strong, nonatomic) IBOutlet GCPlaceholderTextView *textView;

- (void)setNoteText:(NSString *)text;

- (CGFloat)calculatedHeight;
@end
