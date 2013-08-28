//
//  HolidayData+Country.h
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 8/26/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "HolidayData.h"

@interface HolidayData (Country)

- (NSArray *)supportedCountries;

- (NSMutableArray *)holidaysForCountry:(NSString *)countryCode year:(NSUInteger)year;
@end
