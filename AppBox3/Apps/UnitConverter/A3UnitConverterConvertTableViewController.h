//
//  A3UnitConverterConvertTableViewController.h
//  A3TeamWork
//
//  Created by kihyunkim on 13. 10. 12..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ATSDragToReorderTableViewController.h"
#import "UnitType.h"

extern NSString *const A3UnitConverterDataCellID;

@interface A3UnitConverterConvertTableViewController : UIViewController <UIActivityItemSource>

@property (nonatomic, strong) UnitType *unitType;
@property (nonatomic, assign) BOOL isFromMoreTableViewController;

@end
