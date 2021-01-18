//
//  A3TableViewDatePickerCell.m
//  A3TeamWork
//
//  Created by jeonghwan kim on 11/28/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3TableViewDatePickerCell.h"

@implementation A3TableViewDatePickerCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        CGRect rect = [super bounds];
        if (IS_IPAD) {
            rect.size.height = 216;
        }
        _datePicker = [[UIDatePicker alloc] initWithFrame:rect];
        if (@available(iOS 13.4, *)) {
            _datePicker.preferredDatePickerStyle = UIDatePickerStyleWheels;
        }
        [self addSubview:_datePicker];
        //_datePicker.autoresizingMask = ~(NSUInteger)0;
        [_datePicker makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.centerX);
            make.centerY.equalTo(self.centerY);
        }];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}



@end
