//
//  A3PercentCalcHistoryCell.m
//  A3TeamWork
//
//  Created by jeonghwan kim on 13. 10. 26..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3PercentCalcHistoryCell.h"
#import "A3DefaultColorDefines.h"

@implementation A3PercentCalcHistoryCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        _dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, 100.0, 30.0)];
        _dateLabel.textColor = COLOR_HISTORYCELL_DATE;
        
        _factorLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, 100.0, 30.0)];
        _factorLabel.textColor = [UIColor colorWithRed:77.0/255.0 green:77.0/255.0 blue:77.0/255.0 alpha:1.0];

        [self.contentView addSubview:_dateLabel];
        [self.contentView addSubview:_factorLabel];

        [self setupConstraint];
    }
    return self;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
//    [self setupConstraint];
//    _factorLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
//    [_factorLabel sizeToFit];
    [super layoutSubviews];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setupConstraint
{
    NSNumber * leftInset = @15;
//    if (IS_IPAD) {
//        leftInset = @28;
//    }
    [_dateLabel makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@10);
        make.leading.equalTo(leftInset);
    }];
    
    [_factorLabel makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_dateLabel.bottom).with.offset(10.0);
        make.leading.equalTo(leftInset);
        make.right.equalTo(self.right).with.offset(-15.0);
    }];
    
    _dateLabel.font = [UIFont systemFontOfSize:12];
//    _factorLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
//    _factorLabel.adjustsFontSizeToFitWidth = YES;
    [_dateLabel sizeToFit];
//    [_factorLabel sizeToFit];
//    (lldb) po text
//    1.25 = 5 × 25%{
//        NSColor = "UIDeviceWhiteColorSpace 0 1";
//        NSFont = "<UICTFont: 0xde33f30> font-family: \".HelveticaNeueInterface-M3\"; font-weight: normal; font-style: normal; font-size: 12.00pt";
//        NSParagraphStyle = "Alignment 0, LineSpacing 0, ParagraphSpacing 0, ParagraphSpacingBefore 0, HeadIndent 0, TailIndent 0, FirstLineHeadIndent 0, LineHeight 0/0, LineHeightMultiple 0, LineBreakMode 4, Tabs (\n    28L,\n    56L,\n    84L,\n    112L,\n    140L,\n    168L,\n    196L,\n    224L,\n    252L,\n    280L,\n    308L,\n    336L\n), DefaultTabInterval 0, Blocks (null), Lists (null), BaseWritingDirection -1, HyphenationFactor 0, TighteningFactor 0, HeaderLevel 0";
//        NSShadow = "NSShadow {0, -1} color = {(null)}";
}

@end
