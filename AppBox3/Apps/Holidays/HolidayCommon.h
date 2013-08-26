/*
 *  HolidayCommon.h
 *  AppBox Pro
 *
 *  Created by Byeong Kwon Kwak on 6/26/09.
 *  Copyright 2009 ALLABOUTAPPS. All rights reserved.
 *
 */

#import <UIKit/UIKit.h>

int indexOfCountryCode(NSArray *array, NSString *code);
int indexOfCountryName(NSArray *array, NSString *name);
NSString *countryCodeAtIndex(NSArray *array, int index);
NSString *countryNameAtIndex(NSArray *array, int index);
NSString *countryNameForCode(NSArray *array, NSString *code);
NSString *countryCodeForName(NSArray *array, NSString *name);
UIImage *flagImageForCountryCode(NSString *code);
NSInteger sortHolidaysWithName(id array1, id array2, void *context);
NSInteger sortHolidaysWithDate(id array1, id array2, void *context);
