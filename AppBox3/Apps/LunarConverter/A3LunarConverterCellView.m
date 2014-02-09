//
//  A3LunarConverterCellView.m
//  A3TeamWork
//
//  Created by coanyaa on 13. 10. 14..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3LunarConverterCellView.h"

@implementation A3LunarConverterCellView

- (void)addPadLayoutConstraints
{
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_dateLabel
                                                     attribute:NSLayoutAttributeWidth
                                                     relatedBy:NSLayoutRelationLessThanOrEqual
                                                        toItem:nil
                                                     attribute:NSLayoutAttributeWidth multiplier:1.0 constant:_dateLabel.frame.size.width]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_dateLabel
                                                     attribute:NSLayoutAttributeLeading
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeLeading multiplier:1.0 constant:_dateLabel.frame.origin.x]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_dateLabel
                                                     attribute:NSLayoutAttributeCenterY
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_dateLabel
                                                     attribute:NSLayoutAttributeWidth
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:nil
                                                     attribute:NSLayoutAttributeWidth multiplier:1.0 constant:_dateLabel.frame.size.width]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_descriptionLabel
                                                     attribute:NSLayoutAttributeCenterY
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_descriptionLabel
                                                     attribute:NSLayoutAttributeLeading
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:_dateLabel
                                                     attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:8.0]];
    
    // action button의 유무에 의해서 descriptionLabel의 constant 값이 달라짐
    if( _actionButton ){
        [self addConstraint:[NSLayoutConstraint constraintWithItem:_actionButton
                                                         attribute:NSLayoutAttributeCenterY
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self
                                                         attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:_actionButton
                                                         attribute:NSLayoutAttributeWidth
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:nil
                                                         attribute:NSLayoutAttributeWidth multiplier:1.0 constant:_actionButton.frame.size.width]];
        
        [self addConstraint:[NSLayoutConstraint constraintWithItem:_actionButton
                                                         attribute:NSLayoutAttributeTrailing
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self
                                                         attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:-15.0]];
        
        [self addConstraint:[NSLayoutConstraint constraintWithItem:_descriptionLabel
                                                         attribute:NSLayoutAttributeTrailing
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:_actionButton
                                                         attribute:NSLayoutAttributeLeading multiplier:1.0 constant:-4.0]];
        
    }
    else{
        [self addConstraint:[NSLayoutConstraint constraintWithItem:_descriptionLabel
                                                         attribute:NSLayoutAttributeTrailing
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self
                                                         attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:-15.0]];
    }
}

- (void)addPhoneLayoutConstraints
{
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_dateLabel
                                                     attribute:NSLayoutAttributeWidth
                                                     relatedBy:NSLayoutRelationLessThanOrEqual
                                                        toItem:nil
                                                     attribute:NSLayoutAttributeWidth multiplier:1.0 constant:_dateLabel.frame.size.width]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_dateLabel
                                                     attribute:NSLayoutAttributeHeight
                                                     relatedBy:NSLayoutRelationLessThanOrEqual
                                                        toItem:nil
                                                     attribute:NSLayoutAttributeHeight multiplier:1.0 constant:_dateLabel.frame.size.height]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_descriptionLabel
                                                     attribute:NSLayoutAttributeHeight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:nil
                                                     attribute:NSLayoutAttributeHeight multiplier:1.0 constant:_descriptionLabel.frame.size.height]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_dateLabel
                                                     attribute:NSLayoutAttributeLeading
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeLeading multiplier:1.0 constant:_dateLabel.frame.origin.x]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_dateLabel
                                                     attribute:NSLayoutAttributeTop
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeTop multiplier:1.0 constant:10]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_descriptionLabel
                                                     attribute:NSLayoutAttributeLeading
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeLeading multiplier:1.0 constant:_descriptionLabel.frame.origin.x]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_descriptionLabel
                                                     attribute:NSLayoutAttributeTrailing
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:-15.0]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_descriptionLabel
                                                     attribute:NSLayoutAttributeBottom
                                                     relatedBy:NSLayoutRelationLessThanOrEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-10.0]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_descriptionLabel
                                                     attribute:NSLayoutAttributeTop
                                                     relatedBy:NSLayoutRelationGreaterThanOrEqual
                                                        toItem:_dateLabel
                                                     attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0]];
    
    if( _actionButton ){
        [self addConstraint:[NSLayoutConstraint constraintWithItem:_actionButton
                                                         attribute:NSLayoutAttributeTop
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self
                                                         attribute:NSLayoutAttributeTop multiplier:1.0 constant:_actionButton.frame.origin.y]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:_actionButton
                                                         attribute:NSLayoutAttributeTrailing
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self
                                                         attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:-15.0]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:_actionButton
                                                         attribute:NSLayoutAttributeHeight
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:nil
                                                         attribute:NSLayoutAttributeHeight multiplier:1.0 constant:_actionButton.frame.size.height]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:_actionButton
                                                         attribute:NSLayoutAttributeWidth
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:nil
                                                         attribute:NSLayoutAttributeWidth multiplier:1.0 constant:_actionButton.frame.size.width]];
    }
}

- (void)constructView
{
    if( _dateLabel == nil ){
        _dateLabel = [[UILabel alloc] initWithFrame:(_isPadStyle ? CGRectMake(28, 24, 290, 36) : CGRectMake(15, 10, 261, 36))];
//        _dateLabel.backgroundColor = [UIColor lightGrayColor];
        _dateLabel.font = [UIFont systemFontOfSize:30.0];
        _dateLabel.adjustsFontSizeToFitWidth = YES;
        _dateLabel.numberOfLines = 1;
        _dateLabel.minimumScaleFactor = 0.3f;
        _dateLabel.textAlignment = NSTextAlignmentLeft;
        _dateLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        [_dateLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self addSubview:_dateLabel];
    }
    else{
        _dateLabel.frame = (_isPadStyle ? CGRectMake(28, 24, 290, 36) : CGRectMake(15, 10, 261, 36));
    }
    
    if( _descriptionLabel == nil ){
        _descriptionLabel = [[UILabel alloc] initWithFrame:(_isPadStyle ? CGRectMake(334, 31, 302 + (_actionButton ? 0 : 48), 21) : CGRectMake(15, 45, 289, 21))];
//        _descriptionLabel.backgroundColor = [UIColor greenColor];
        _descriptionLabel.font = [UIFont systemFontOfSize:17.0];
        _descriptionLabel.textAlignment = (_isPadStyle ? NSTextAlignmentRight : NSTextAlignmentLeft);
        [_descriptionLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self addSubview:_descriptionLabel];
    }
    else{
        _descriptionLabel.frame = (_isPadStyle ? CGRectMake(334, 31, 302 + (_actionButton ? 0 : 48), 21) : CGRectMake(15, 45, 289, 21));
        _descriptionLabel.textAlignment = (_isPadStyle ? NSTextAlignmentRight : NSTextAlignmentLeft);
    }
    
    if( [self.constraints count] > 0 ){
        [self removeConstraints:self.constraints];
    }
    
    
    if( _isPadStyle ){
        [self addPadLayoutConstraints];
        
    }
    else{
        [self addPhoneLayoutConstraints];
    }
}

- (void)awakeFromNib
{
    _isPadStyle = (self.frame.size.width > 320);
    [self constructView];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _isPadStyle = (frame.size.width > 320);
        [self constructView];
    }
    return self;
}

//- (void)layoutSubviews
//{
//    _isPadStyle = (self.frame.size.width > 320);
//    [self constructView];
//}

- (void)setPadStyle:(BOOL)isPadStyle
{
    _isPadStyle = isPadStyle;
    [self constructView];
}

- (BOOL)isPadStyle
{
    return _isPadStyle;
}

- (void)setActionButton:(UIButton *)actionButton
{
    if( _actionButton ){
        [_actionButton removeFromSuperview];
        _actionButton = nil;
    }
    _actionButton = actionButton;
    [_actionButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self addSubview:_actionButton];
    [self constructView];
}


/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

@end
