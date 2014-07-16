//
//  TranslatorGroup(manage)
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 5/27/14 12:01 PM.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import "TranslatorGroup+manage.h"
#import "NSString+conversion.h"


@implementation TranslatorGroup (manage)

- (void)setupOrder {
	NSString *largestInOrder = [TranslatorGroup MR_findLargestValueForAttribute:@"order"];
	NSString *nextLargestInOrder = [NSString orderStringWithOrder:[largestInOrder integerValue] + 100000];
	FNLOG(@"nextLargestInOrder = %@", nextLargestInOrder);

	self.order = nextLargestInOrder;
}

- (void)moveChildesFromObject:(TranslatorGroup *)sourceObject {
	[self addTexts:sourceObject.texts];
}

@end
