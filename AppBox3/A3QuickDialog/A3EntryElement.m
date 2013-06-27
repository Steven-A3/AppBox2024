//
//  A3EntryElement
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 4/27/13 6:57 PM.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import "A3QuickDialogContainerController.h"
#import "A3UIDevice.h"
#import "CommonUIDefinitions.h"
#import "common.h"
#import "A3SelectItemTableViewCell.h"

@implementation QElement (CustomStyle)

- (void)updateCellHeightWithDelegate:(id <A3QuickDialogCellStyleDelegate>)delegate {
	if ([delegate respondsToSelector:@selector(heightForElement:)]) {
		self.height = [delegate heightForElement:self];
	} else {
		self.height = IS_IPAD ? A3_TABLE_VIEW_ROW_HEIGHT_IPAD : A3_TABLE_VIEW_ROW_HEIGHT_IPHONE;
	}
}

- (void)applyEntryElementAppearanceWithDelegate:(id <A3QuickDialogCellStyleDelegate>)delegate appearance:(QAppearance *)appearance {
	// Label Attributes
	FNLOG(@"%@", self.key);
	if ([delegate respondsToSelector:@selector(fontForEntryCellLabel)]) {
		appearance.labelFont = [delegate fontForEntryCellLabel];
	}
	if ([delegate respondsToSelector:@selector(colorForCellLabelNormal)]) {
		appearance.labelColorEnabled = [delegate colorForCellLabelNormal];
	}

	// Value Attributes
	if ([delegate respondsToSelector:@selector(fontForEntryCellTextField)]) {
		appearance.valueFont = [delegate fontForEntryCellTextField];
	}
	if ([delegate respondsToSelector:@selector(colorForEntryCellTextField)]) {
		appearance.valueColorEnabled = [delegate colorForEntryCellTextField];
	}

	// Entry Attributes
	if ([delegate respondsToSelector:@selector(fontForEntryCellTextField)]) {
		appearance.entryFont = [delegate fontForEntryCellTextField];
	}
	if ([delegate respondsToSelector:@selector(colorForEntryCellTextField)]) {
		appearance.entryTextColorEnabled = [delegate colorForEntryCellTextField];
	}
}

- (void)applyLabelElementAppearanceWithDelegate:(id <A3QuickDialogCellStyleDelegate>)delegate appearance:(QAppearance *)appearance {
	FNLOG(@"%@", self.key);
	if ([delegate respondsToSelector:@selector(fontForEntryCellLabel)]) {
		appearance.labelFont = [delegate fontForEntryCellLabel];
	}
	if ([delegate respondsToSelector:@selector(colorForCellLabelNormal)]) {
		appearance.labelColorEnabled = [delegate colorForCellLabelNormal];
	}
	if ([delegate respondsToSelector:@selector(fontForEntryCellTextField)]) {
		appearance.valueFont = [delegate fontForEntryCellTextField];
	}
	if ([delegate respondsToSelector:@selector(colorForEntryCellTextField)]) {
		appearance.valueColorEnabled = [delegate colorForEntryCellTextField];
	}
}

- (void)applyButtonElementAppearanceWithDelegate:(id <A3QuickDialogCellStyleDelegate>)delegate appearance:(QAppearance *)appearance {
	FNLOG(@"%@", self.key);
	if ([delegate respondsToSelector:@selector(fontForCellLabel)]) {
		appearance.labelFont = [delegate fontForCellLabel];
	}
	if ([delegate respondsToSelector:@selector(colorForCellButton)]) {
		appearance.actionColorEnabled = [delegate colorForCellButton];
	}
}

@end

@implementation A3EntryElement

- (id)initWithTitle:(NSString *)string Value:(NSString *)param Placeholder:(NSString *)string1 {
	self = [super initWithTitle:string Value:param Placeholder:string1];
	if (self) {
	}

	return self;
}

- (UITableViewCell *)getCellForTableView:(QuickDialogTableView *)tableView controller:(QuickDialogController *)controller {
	QAppearance *newAppearance = [[self class] appearance];
	[self applyEntryElementAppearanceWithDelegate:_cellStyleDelegate appearance:newAppearance];
	self.appearance = newAppearance;

	QEntryTableViewCell *cell = (QEntryTableViewCell *) [super getCellForTableView:tableView controller:controller];
	cell.textField.adjustsFontSizeToFitWidth = YES;
	return cell;
}

- (CGFloat)getRowHeightForTableView:(QuickDialogTableView *)tableView {
	[self updateCellHeightWithDelegate:_cellStyleDelegate];
	return [super getRowHeightForTableView:tableView];
}

@end

@implementation A3LabelElement

- (id)initWithTitle:(NSString *)string Value:(id)value {
	self = [super initWithTitle:string Value:value];
	if (self) {
	}

	return self;
}

- (UITableViewCell *)getCellForTableView:(QuickDialogTableView *)tableView controller:(QuickDialogController *)controller {
	FNLOG(@"%@", self.key);
	QAppearance *newAppearance = [[self class] appearance];
	[self applyLabelElementAppearanceWithDelegate:_cellStyleDelegate appearance:newAppearance];
	self.appearance = newAppearance;

	return [super getCellForTableView:tableView controller:controller];
}

- (CGFloat)getRowHeightForTableView:(QuickDialogTableView *)tableView {
	[self updateCellHeightWithDelegate:_cellStyleDelegate];
	return [super getRowHeightForTableView:tableView];
}

@end

@implementation A3SelectItemElement

- (id)init {
	self = [super init];
	if (self) {

	}

	return self;
}

- (UITableViewCell *)getCellForTableView:(QuickDialogTableView *)tableView controller:(QuickDialogController *)controller {
	QAppearance *newAppearance = [[self class] appearance];
	[self applyLabelElementAppearanceWithDelegate:_cellStyleDelegate appearance:newAppearance];
	self.appearance = newAppearance;

	static NSString *cellIdentifier;
	cellIdentifier = @"A3SelectItemTableViewCell";
	A3SelectItemTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	if (nil == cell) {
		cell = [[A3SelectItemTableViewCell alloc] initWithReuseIdentifier:cellIdentifier];
	}
	cell.checkMark.hidden = !self.selected;
	cell.textLabel.text = self.title;
	cell.textLabel.textColor = self.selected ?
			[UIColor colorWithRed:40.0 / 255.0 green:70.0 / 255.00 blue:115.0/255.0 alpha:1.0] :
			[UIColor colorWithRed:61.0 / 255.0 green:61.0 / 255.0 blue:61.0 / 255.0 alpha:1.0];
	cell.startRow = self.startRow;
	cell.endRow = self.endRow;
	return cell;
}

@end

@implementation A3ButtonElement

- (id)initWithTitle:(NSString *)title {
	self = [super initWithTitle:title];
	if (self) {
	}

	return self;
}

- (UITableViewCell *)getCellForTableView:(QuickDialogTableView *)tableView controller:(QuickDialogController *)controller {
	QAppearance *newAppearance = [[self class] appearance];
	[self applyButtonElementAppearanceWithDelegate:_cellStyleDelegate appearance:newAppearance];
	self.appearance = newAppearance;

	return [super getCellForTableView:tableView controller:controller];
}

- (CGFloat)getRowHeightForTableView:(QuickDialogTableView *)tableView {
	[self updateCellHeightWithDelegate:_cellStyleDelegate];
	return [super getRowHeightForTableView:tableView];
}

@end

@implementation A3NumberEntryElement
@end

@implementation A3CurrencyEntryElement
@end

@implementation A3PercentEntryElement
@end

@implementation A3InterestEntryElement
@end

@implementation A3TermEntryElement
@end

@implementation A3FrequencyEntryElement
@end

@implementation A3DateEntryElement
@end
