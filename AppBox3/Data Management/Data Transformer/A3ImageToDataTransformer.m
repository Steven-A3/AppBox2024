//
//  A3ImageToDataTransformer.m
//  AppBox3
//
//  Created by A3 on 4/16/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import "A3ImageToDataTransformer.h"

@implementation A3ImageToDataTransformer

+ (BOOL)allowsReverseTransformation {
	return YES;
}

+ (Class)transformedValueClass {
	return [NSData class];
}


- (id)transformedValue:(id)value {
	return UIImageJPEGRepresentation(value, 1.0);
}


- (id)reverseTransformedValue:(id)value {
	return [[UIImage alloc] initWithData:value];
}

@end
