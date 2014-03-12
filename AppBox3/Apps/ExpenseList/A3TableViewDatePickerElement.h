//
//  A3TableViewDatePickerElement.h
//  A3TeamWork
//
//  Created by jeonghwan kim on 11/28/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "A3JHTableViewElement.h"

@interface A3TableViewDatePickerElement : A3JHTableViewElement

@property (nonatomic, strong) NSDate *dateValue;
@property (nonatomic, strong) CellValueChangedBlock cellValueChangedBlock;
@property (nonatomic, readonly) CGFloat height;

@end
