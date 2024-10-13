//
//  DaysCounterFavorite+extension.m
//  AppBox3
//
//  Created by A3 on 7/17/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import <AppBoxKit/AppBoxKit.h>
#import "DaysCounterFavorite+extension.h"

@class DaysCounterEvent_;

@implementation DaysCounterFavorite_(extension)

- (DaysCounterEvent_ *)event {
	return [DaysCounterEvent_ findFirstByAttribute:@"uniqueID" withValue:self.eventID];
}

@end
