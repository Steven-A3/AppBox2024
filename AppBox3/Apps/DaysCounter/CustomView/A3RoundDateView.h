//
//  A3RoundDateView.h
//  A3TeamWork
//
//  Created by coanyaa on 2013. 11. 8..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface A3RoundDateView : UIView{
    UILabel *_dateLabel;
}

@property (strong, nonatomic) UIColor *fillColor;
@property (strong, nonatomic) UIColor *strokColor;
@property (readonly,nonatomic) UILabel *dateLabel;
@property (strong, nonatomic) NSDate *date;
@end
