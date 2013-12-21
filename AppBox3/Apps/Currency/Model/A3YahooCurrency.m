//
//  A3YahooCurrency.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 7/12/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3YahooCurrency.h"

@interface A3YahooCurrency ()

@property (nonatomic, strong) id object;

@end

@implementation A3YahooCurrency

- (id)initWithObject:(id)object {
	self = [super init];
	if (self) {
		_object = object;
	}
	return self;
}

- (NSString *)name {
	return _object[@"resource"][@"fields"][@"name"];
}

- (NSString *)currencyCode {
	return [_object[@"resource"][@"fields"][@"symbol"] substringToIndex:3];
}

- (NSNumber *)rateToUSD {
	return @([_object[@"resource"][@"fields"][@"price"] floatValue]);
}

- (NSDate *)updated {
	return [NSDate dateWithTimeIntervalSince1970:[_object[@"resource"][@"fields"][@"ts"] integerValue]];
}

@end
