//
//  A3TranslatorLanguageTVDelegate.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 8/17/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3TranslatorLanguageTVDelegate.h"
#import "A3TranslatorLanguage.h"

@implementation A3TranslatorLanguageTVDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [_languages count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *CellIdentifier = @"Cell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

	if (nil == cell) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
	}
	// Configure the cell...
	A3TranslatorLanguage *language = _languages[indexPath.row];
	cell.textLabel.text = [language name];

	return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[_delegate tableView:tableView didSelectLanguage:_languages[indexPath.row]];
}

@end
