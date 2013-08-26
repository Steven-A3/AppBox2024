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
- (NSMutableArray *)sa_HolidaysInYear:(NSNumber *)yearObj;

- (NSMutableArray *)ae_HolidaysInYear:(NSNumber *)yearObj;

- (NSMutableArray *)qa_HolidaysInYear:(NSNumber *)yearObj;

- (NSMutableArray *)jo_HolidaysInYear:(NSNumber *)yearObj;

- (NSMutableArray *)eg_HolidaysInYear:(NSNumber *)yearObj;

- (NSMutableArray *)kw_HolidaysInYear:(NSNumber *)yearObj;
@end