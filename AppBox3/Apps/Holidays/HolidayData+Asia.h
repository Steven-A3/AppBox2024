//
//  HolidayAsia.h
//  AppBox Pro
//
//  Created by bkk on 1/20/10.
//  Copyright 2010 AllAboutApps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HolidayData.h"

@interface HolidayData (Asia)

- (NSMutableArray *)cn_HolidaysInYear:(NSNumber *)yearObj;

- (NSMutableArray *)id_HolidaysInYear:(NSNumber *)yearObj;

- (NSMutableArray *)sg_HolidaysInYear:(NSNumber *)yearObj;

- (NSMutableArray *)mo_HolidaysInYear:(NSNumber *)yearObj;

- (NSMutableArray *)hk_HolidaysInYear:(NSNumber *)yearObj;

- (NSMutableArray *)kr_HolidaysInYear:(NSNumber *)yearObj;

- (NSMutableArray *)jp_HolidaysInYear:(NSNumber *)yearObj;

- (NSMutableArray *)ph_HolidaysInYear:(NSNumber *)yearObj;

- (NSMutableArray *)tw_HolidaysInYear:(NSNumber *)yearObj;

- (NSMutableArray *)nz_HolidaysInYear:(NSNumber *)yearObj;

- (NSMutableArray *)au_HolidaysInYear:(NSNumber *)yearObj;

- (NSMutableArray *)my_HolidaysInYear:(NSNumber *)yearObj;

- (NSMutableArray *)in_HolidaysInYear:(NSUInteger)year;

- (NSMutableArray *)bd_HolidaysInYear:(NSNumber *)yearObj;

- (NSMutableArray *)pk_HolidaysInYear:(NSNumber *)yearObj;

- (NSMutableArray *)th_HolidaysInYear:(NSNumber *)yearObj;
@end
