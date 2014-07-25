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
	TranslatorGroup *group = [TranslatorGroup MR_findFirstOrderedByAttribute:@"order" ascending:NO];
	NSString *largestInOrder = group.order;
	NSString *nextLargestInOrder = [NSString orderStringWithOrder:[largestInOrder integerValue] + 100000];
	FNLOG(@"nextLargestInOrder = %@", nextLargestInOrder);

	self.order = nextLargestInOrder;
}

@end
