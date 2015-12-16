//
//  A3UnitConverterConvertTableViewController.h
//  A3TeamWork
//
//  Created by kihyunkim on 13. 10. 12..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

@class A3UnitDataManager;

extern NSString *const A3UnitConverterDataCellID;

@interface A3UnitConverterConvertTableViewController : UIViewController <UIActivityItemSource>

@property (nonatomic, assign) NSUInteger categoryID;
@property (nonatomic, assign) BOOL isFromMoreTableViewController;
@property (nonatomic, strong) A3UnitDataManager *dataManager;

@end
