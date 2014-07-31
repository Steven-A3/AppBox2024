//
//  A3TextViewElement.m
//  A3TeamWork
//
//  Created by jeonghwan kim on 12/30/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3TextViewElement.h"
#import "UIViewController+tableViewStandardDimension.h"
#import "A3WalletNoteCell.h"
#import "NSString+conversion.h"
#import "A3JHTableViewCell.h"

@interface A3TextViewElement() <UITextViewDelegate>
@end

@implementation A3TextViewElement
{
    CGFloat _textViewCurrentHeight;
    UITableView *_rootTableView;
}

- (id)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

- (UITableViewCell *)cellForTableView:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath {
	extern NSString *const A3WalletItemFieldNoteCellID;
	A3WalletNoteCell *cell = [tableView dequeueReusableCellWithIdentifier:A3WalletItemFieldNoteCellID];
	if (!cell) {
		cell = [[A3WalletNoteCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:A3WalletItemFieldNoteCellID];
		[cell setupTextView];
	}

	cell.textView.text = self.value;
    cell.textView.delegate = self;
    
    _rootTableView = tableView;

	return cell;
}

- (void)didSelectCellInViewController:(UIViewController *)viewController tableView:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath
{
    A3JHTableViewCell *cell = (A3JHTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)currentHeight
{
	return [UIViewController noteCellHeight];
}

#pragma mark - UITextView Delegate

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
	textView.text = self.value;

    if (_onEditingBegin) {
        _onEditingBegin(self, textView);
    }
    
    return YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    NSString * result = [textView.text stringByTrimmingSpaceCharacters];
	self.value = result;

	if (_onEditingDidEnd) {
		_onEditingDidEnd(self, textView);
	}
}

@end
