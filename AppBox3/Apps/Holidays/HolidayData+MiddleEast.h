//
//  HolidayMiddleEast.h
//  AppBox Pro
//
//  Created by bkk on 1/20/10.
//  Copyright 2010 AllAboutApps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HolidayData.h"

@interface HolidayData (MiddleEast)
- (NSMutableArray *)sa_HolidaysInYear:(NSUInteger)year;

- (NSMutableArray *)ae_HolidaysInYear:(NSUInteger)year;

- (NSMutableArray *)qa_HolidaysInYear:(NSUInteger)year;

- (NSMutableArray *)jo_HolidaysInYear:(NSUInteger)year;

- (NSMutableArray *)eg_HolidaysInYear:(NSUInteger)year;

- (NSMutableArray *)kw_HolidaysInYear:(NSUInteger)year;
@end