//
//  A3CurrencyHistory3RowCell.h
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 8/8/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "A3CurrencyHistoryCell.h"

@interface A3CurrencyHistory3RowCell : A3CurrencyHistoryCell

@property (nonatomic, strong) NSArray *leftLabels, *rightLabels;
@property (nonatomic, strong) NSNumber *numberOfLines;

@end
