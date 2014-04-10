//
//  A3TextViewElement.m
//  A3TeamWork
//
//  Created by jeonghwan kim on 12/30/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3TextViewElement.h"
#import "A3TextViewCell.h"
//#import "UIScrollView+removeAutoScroll.h"
#import "A3DefaultColorDefines.h"

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
        _minHeight = 44.0;
    }
    return self;
}

- (UITableViewCell *)cellForTableView:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath {
 	static NSString *reuseIdentifier = @"A3TextViewElement";
	A3TextViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
	if (!cell) {
		cell = [[A3TextViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textView.font = [UIFont systemFontOfSize:17];
        cell.textView.textColor = COLOR_TABLE_DETAIL_TEXTLABEL;    //[UIColor colorWithRed:199.0/255.0 green:199.0/255.0 blue:205.0/255.0 alpha:1.0];
        cell.textView.scrollEnabled = NO;
	}

    
    if ( !self.value || (self.value && ((NSString *)self.value).length==0) ) {
        cell.textView.text = self.placeHolder;
        cell.textView.textColor = [UIColor colorWithRed:199.0/255.0 green:199.0/255.0 blue:205.0/255.0 alpha:1.0];
    } else {
        cell.textView.text = self.value;
        cell.textView.textColor = COLOR_TABLE_DETAIL_TEXTLABEL;
    }
    
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

-(CGFloat)currentHeight
{
    if (_currentHeight==0) {
        CGFloat width = IS_IPHONE ? 320.0 - 30 : (IS_LANDSCAPE ? 704 - 43 : 768 - 43);
        UITextView * textView = [UITextView new];
        textView.font = [UIFont systemFontOfSize:17];
        textView.text = [NSString stringWithFormat:@"%@", self.value];
        CGSize newSize = [textView sizeThatFits:CGSizeMake(width, MAXFLOAT)];
        _currentHeight = newSize.height;
        textView = nil;
    }
    
    
    if (_currentHeight > _minHeight) {
        return _currentHeight;
    }
    
    return _minHeight;
}

#pragma mark - UITextView Delegate

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    if ( [self.value length] < 1 ) {
        textView.text = @"";
    }
    
    textView.textColor = COLOR_TABLE_DETAIL_TEXTLABEL;
    
    if (_onEditingBegin) {
        _onEditingBegin(self, textView);
    }
    
    return YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    NSString * result = [textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (result.length == 0) {
        self.value = result;
    }
    
    if ( [self.value length] < 1 ) {
        textView.text = @"Notes";
        textView.textColor = [UIColor colorWithRed:199.0/255.0 green:199.0/255.0 blue:205.0/255.0 alpha:1.0];
        
    }
    else {
        textView.textColor = COLOR_TABLE_DETAIL_TEXTLABEL;
        UITableViewCell *currentCell = (UITableViewCell *)[[textView superview] superview];
        NSIndexPath *currentIndexPath = [_rootTableView indexPathForCell:currentCell];
		if (currentIndexPath) {
			[_rootTableView reloadRowsAtIndexPaths:@[currentIndexPath] withRowAnimation:UITableViewRowAnimationNone];
		}
    }
	if (_onEditingDidEnd) {
		_onEditingDidEnd(self, textView);
	}
}

- (void)textViewDidChange:(UITextView *)textView
{
    self.value = textView.text;
    
    CGSize newSize = [textView sizeThatFits:CGSizeMake(textView.frame.size.width, MAXFLOAT)];
    NSLog(@"contentSize: %@", NSStringFromCGSize(textView.contentSize));
    NSLog(@"newSize: %@", NSStringFromCGSize(newSize));

    if (_onEditingChange) {
        _onEditingChange(self, textView);
    }
    
    if (newSize.height < _minHeight) {
        return;
    }

    UITableViewCell *currentCell = (UITableViewCell *)[[textView superview] superview];
    CGFloat diffHeight = newSize.height - currentCell.frame.size.height;
    
    currentCell.frame = CGRectMake(currentCell.frame.origin.x,
                                   currentCell.frame.origin.y,
                                   currentCell.frame.size.width,
                                   newSize.height);

    _rootTableView.contentSize = CGSizeMake(_rootTableView.contentSize.width,
                                            _rootTableView.contentSize.height + diffHeight);
    
    _currentHeight = newSize.height;
    
    [UIView beginAnimations:@"cellExpand" context:nil];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationCurve:7];
    [UIView setAnimationDuration:0.25];
    _rootTableView.contentOffset = CGPointMake(0.0, _rootTableView.contentOffset.y + diffHeight);
    [UIView commitAnimations];
}


@end
