//
//  NSDate(calculation)
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 5/8/14 11:56 AM.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import "NSDate+calculation.h"
#import "A3AppDelegate.h"

// This implementation uses calendar defined in AppDelegate
// [NSCalendar currentCalendar]는 원하지 않는 결과가 나올 수 있어 사용할 수 가 없음

@implementation NSDate (calculation)

- (NSDate *)firstDateOfMonth {
	NSCalendar *calendar = [[A3AppDelegate instance] calendar];
	NSDateComponents *components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:self];
	components.day = 1;
	components.hour = 12;
	return [calendar dateFromComponents:components];
}

- (NSDate *)dateByAddingCalendarMonth:(NSInteger)monthDifference {
	NSCalendar *calendar = [[A3AppDelegate instance] calendar];
	NSDateComponents *components = [NSDateComponents new];
	components.month = monthDifference;
	return [calendar dateByAddingComponents:components toDate:self options:0];
}

@end
