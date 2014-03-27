//
//  A3TableViewEntryElement.h
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 10/22/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3TableViewElement.h"

typedef NS_ENUM(NSInteger, A3TableViewEntryInputType) {
	A3TableViewEntryTypeText = 0,
	A3TableViewEntryTypeCurrency,
	A3TableViewEntryTypeYears,
	A3TableViewEntryTypeInterestRates,

};

@interface A3TableViewEntryElement : A3TableViewElement

@property (nonatomic, copy) NSString *placeholder;
@property (assign) A3TableViewEntryInputType inputType;
@property (nonatomic, copy) void (^onEditingFinished)(A3TableViewEntryElement *, UITextField *);
@property (nonatomic, copy) void (^onEditingValueChanged)(A3TableViewEntryElement *, UITextField *);

@property (nonatomic, strong) id coreDataObject;
@property (nonatomic, copy) NSString *coreDataKey;
@end
