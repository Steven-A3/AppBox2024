//
//  A3DateCalcTableRowData.h
//  A3TeamWork
//
//  Created by jeonghwan kim on 13. 10. 12..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_OPTIONS(NSInteger, AccessoryType) {
    Accessory_None = 0,
    Accessory_Switch = 1 << 1,
    Accessory_Camera = 1 << 2,
    Accessory_Favor = 1 << 3,
    Accessory_ArrowDown = 1 << 4,
    Accessory_Disclosure = 1 << 5,
    Accessory_CheckMark = 1 << 6,
    Accessory_TextField = 1 << 7,
    Accessory_DetailLabel = 1 << 8
};

#define kCellIdentifier_Common    @"commonCell"
#define kCellIdentifier_Separator    @"separatorCell"
#define kCellIdentifier_TextField    @"A3DateCalcTextFieldCell"

@interface A3DateCalcTableRowData : NSObject

@property (strong, nonatomic) NSString * cellIdentifier;

#pragma mark - Common
@property (strong, nonatomic) NSString * textString;
@property (strong, nonatomic) NSString * detailTextString;
@property (assign, nonatomic) NSInteger height;
@property (assign, nonatomic) AccessoryType accessoryType;

- (A3DateCalcTableRowData *)initCellWithText:(NSString *)aText Detail:(NSString *)aDetail Height:(NSInteger)aHeight AccessoryType:(AccessoryType)accessoryType;
- (A3DateCalcTableRowData *)initSeparatorWithText:(NSString *)aText Height:(NSInteger)aHeight AccessoryType:(AccessoryType)accessoryType;
- (A3DateCalcTableRowData *)initCellWithText:(NSString *)aText Detail:(NSString *)aDetail Height:(NSInteger)aHeight AccessoryType:(AccessoryType)accessoryType CellIdentifier:(NSString *)cellIdentifier;

#pragma mark - Check & Switch
@property (assign, nonatomic) BOOL checked;
//
//#pragma mark - Calculation Type
//@property (assign, nonatomic) BOOL isSubtract;
//
//#pragma mark - Date Input
//@property (strong, nonatomic) NSNumber *year;
//@property (strong, nonatomic) NSNumber *month;
//@property (strong, nonatomic) NSNumber *day;

@end
