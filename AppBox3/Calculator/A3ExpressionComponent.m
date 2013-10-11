//
//  A3ExpressionComponent.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 9/24/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3ExpressionComponent.h"

NSString *kA3ExpressionKind = @"keyA3ExpressionKind";
NSString *kA3ExpressionArguments = @"keyA3ExpressionArguments";

@interface A3ExpressionComponent () <NSCoding>
@end

@implementation A3ExpressionComponent

- (id)initWithCoder:(NSCoder *)coder {
	self = [super init];
	if (self) {
		self.expressionKind = (A3ExpressionKind) [coder decodeIntegerForKey:kA3ExpressionKind];
		self.arguments = [[coder decodeObjectForKey:kA3ExpressionArguments] mutableCopy];
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
	[coder encodeInteger:_expressionKind forKey:kA3ExpressionKind];
	[coder encodeObject:self.arguments forKey:kA3ExpressionArguments];
}

- (NSMutableArray *)arguments {
	if (!_arguments) {
		_arguments = [NSMutableArray new];
	}
	return _arguments;
}

@end
