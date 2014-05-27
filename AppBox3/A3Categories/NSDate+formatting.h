//
//  NSDate+formatting.h
//  A3TeamWork
//
//  Created by A3 on 11/4/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (formatting)
- (NSString *)a3FullStyleString;
- (NSString *)a3FullCustomStyleString;
- (NSString *)a3FullStyleStringByRemovingYearComponent;
- (NSString *)a3FullStyleWithTimeString;   // kjh
- (NSString *)a3LongStyleString;   // kjh
- (NSString *)a3ShortStyleString;   // kjh

// KJH - SalesCalc, ExpenseList
- (NSString *)a3HistoryDateString;
@end
