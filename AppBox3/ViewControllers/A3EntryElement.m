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

#define A3QElementSetHeight		self.height = DEVICE_IPAD ? A3_TABLE_VIEW_ROW_HEIGHT_IPAD : A3_TABLE_VIEW_ROW_HEIGHT_IPHONE

@implementation A3EntryElement

- (id)initWithTitle:(NSString *)string Value:(NSString *)param Placeholder:(NSString *)string1 {
	self = [super initWithTitle:string Value:param Placeholder:string1];
	if (self) {
		A3QElementSetHeight;
	}

	return self;
}

@end

@implementation A3LabelElement

- (id)initWithTitle:(NSString *)string Value:(id)value {
	self = [super initWithTitle:string Value:value];
	if (self) {
		A3QElementSetHeight;
	}

	return self;
}

@end

@implementation A3ButtonElement

- (id)initWithTitle:(NSString *)title {
	self = [super initWithTitle:title];
	if (self) {
		A3QElementSetHeight;
	}

	return self;
}

@end

@implementation A3NumberEntryElement

- (id)initWithTitle:(NSString *)string Value:(NSString *)param Placeholder:(NSString *)string1 {
	self = [super initWithTitle:string Value:param Placeholder:string1];
	if (self) {
		A3QElementSetHeight;
	}

	return self;
}

@end

@implementation A3CurrencyEntryElement

- (id)initWithTitle:(NSString *)string Value:(NSString *)param Placeholder:(NSString *)string1 {
	self = [super initWithTitle:string Value:param Placeholder:string1];
	if (self) {
		A3QElementSetHeight;
	}

	return self;
}

@end

@implementation A3TermEntryElement

- (id)initWithTitle:(NSString *)string Value:(NSString *)param Placeholder:(NSString *)string1 {
	self = [super initWithTitle:string Value:param Placeholder:string1];
	if (self) {
		A3QElementSetHeight;
	}

	return self;
}

@end

@implementation A3InterestEntryElement

- (id)initWithTitle:(NSString *)string Value:(NSString *)param Placeholder:(NSString *)string1 {
	self = [super initWithTitle:string Value:param Placeholder:string1];
	if (self) {
		A3QElementSetHeight;
	}

	return self;
}

@end

@implementation A3FrequencyEntryElement

- (id)initWithTitle:(NSString *)string Value:(NSString *)param Placeholder:(NSString *)string1 {
	self = [super initWithTitle:string Value:param Placeholder:string1];
	if (self) {
		A3QElementSetHeight;
	}

	return self;
}

@end

@implementation A3DateEntryElement

- (id)initWithTitle:(NSString *)string Value:(NSString *)param Placeholder:(NSString *)string1 {
	self = [super initWithTitle:string Value:param Placeholder:string1];
	if (self) {
		A3QElementSetHeight;
	}

	return self;
}

@end

@implementation A3PercentEntryElement

- (id)initWithTitle:(NSString *)string Value:(NSString *)param Placeholder:(NSString *)string1 {
	self = [super initWithTitle:string Value:param Placeholder:string1];
	if (self) {
		A3QElementSetHeight;
	}

	return self;
}

@end
