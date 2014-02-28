//
//  A3DateCalcTableRowData.m
//  A3TeamWork
//
//  Created by jeonghwan kim on 13. 10. 12..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3DateCalcTableRowData.h"

@implementation A3DateCalcTableRowData

- (A3DateCalcTableRowData *)initCellWithText:(NSString *)aText Detail:(NSString *)aDetail Height:(NSInteger)aHeight AccessoryType:(AccessoryType)accessoryType
{
    self = [[A3DateCalcTableRowData alloc] init];
    
    if (self) {
        self.cellIdentifier = kCellIdentifier_Common;
        self.textString = aText;
        self.detailTextString = aDetail;
        self.height = aHeight;
        self.accessoryType = accessoryType;
    }
    
    return self;
}

- (A3DateCalcTableRowData *)initSeparatorWithText:(NSString *)aText Height:(NSInteger)aHeight AccessoryType:(AccessoryType)accessoryType
{
    self = [[A3DateCalcTableRowData alloc] init];
    
    if (self) {
        self.cellIdentifier = kCellIdentifier_Separator;
        self.textString = aText;
        self.height = aHeight;
        self.accessoryType = accessoryType;
    }
    
    return self;
}

- (A3DateCalcTableRowData *)initCellWithText:(NSString *)aText Detail:(NSString *)aDetail Height:(NSInteger)aHeight AccessoryType:(AccessoryType)accessoryType CellIdentifier:(NSString *)cellIdentifier
{
    self = [[A3DateCalcTableRowData alloc] init];
    
    if (self) {
        self.cellIdentifier = cellIdentifier;
        self.textString = aText;
        self.detailTextString = aDetail;
        self.height = aHeight;
        self.accessoryType = accessoryType;
    }
    
    return self;
}

@end
