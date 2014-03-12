//
//  A3TextViewElement.h
//  A3TeamWork
//
//  Created by jeonghwan kim on 12/30/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "A3JHTableViewElement.h"

@interface A3TextViewElement : A3JHTableViewElement
@property (nonatomic) CGFloat minHeight;
@property (nonatomic) CGFloat currentHeight;
@property (nonatomic, copy) NSString *placeHolder;
@property (nonatomic, copy) void (^onEditingBegin)(A3TextViewElement *, UITextView *);
@property (nonatomic, copy) void (^onEditingChange)(A3TextViewElement *, UITextView *);
@end
