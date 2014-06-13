//
//  NSNumberFormatter+Extention.h
//  A3TeamWork
//
//  Created by jeonghwan kim on 12/28/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSNumberFormatter (Extension)
+(NSString *)exponentStringFromNumber:(NSNumber *)aNumber;
+(NSString *)currencyStringExceptedSymbolFromNumber:(NSNumber *)aNumber;
@end
