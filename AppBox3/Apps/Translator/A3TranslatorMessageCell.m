//
//  A3TranslatorMessageCell.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 8/15/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import <CoreText/CoreText.h>
#import "A3TranslatorMessageCell.h"
#import "TranslatorHistory.h"
#import "A3Formatter.h"
#import "common.h"
#import "NSDate+TimeAgo.h"

@interface A3TranslatorMessageCell ()

@property (nonatomic, strong) UIImageView *rightMessageView;
@property (nonatomic, strong) UIImageView *leftMessageView;
@property (nonatomic, strong) UILabel *dateLabel;
@property (nonatomic, strong) NSLayoutConstraint *rightMessageWidth;
@property (nonatomic, strong) NSLayoutConstraint *rightMessageHeight;
@property (nonatomic, strong) NSLayoutConstraint *leftMessageHeight;
@property (nonatomic, strong) NSLayoutConstraint *leftMessageWidth;
@property (nonatomic, strong) UILabel *rightMessageLabel;
@property (nonatomic, strong) UILabel *leftMessageLabel;

@end

@implementation A3TranslatorMessageCell

static const CGFloat kTranslatorCellTopPadding = 35.0;
static const CGFloat kTranslatorCellBottomPadding = 18.0;
static const CGFloat kTranslatorCellLeftRightPadding = 27.0;
static const CGFloat kTranslatorCellMessageInset = 10.0;
static const CGFloat kTranslatorCellGapBetweenMessage = 10.0;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)prepareForReuse {
	[super prepareForReuse];

	[_rightMessageView removeFromSuperview];
	_rightMessageView = nil;
	_rightMessageWidth = nil;
	_rightMessageHeight = nil;
	_rightMessageLabel = nil;

	[_leftMessageView removeFromSuperview];
	_leftMessageView = nil;
	_leftMessageHeight = nil;
	_leftMessageWidth = nil;
	_leftMessageLabel = nil;
}

+ (CGFloat)cellHeightWithData:(TranslatorHistory *)data bounds:(CGRect)bounds {
	CGFloat height = kTranslatorCellTopPadding + kTranslatorCellBottomPadding;
	if ([data.originalText length]) {
		CGRect boundingRect = [self boundingRectWithText:data.originalText withBounds:bounds];
		FNLOGRECT(boundingRect);
		height += boundingRect.size.height;
		height += kTranslatorCellMessageInset * 2.0;
	}
	if ([data.translatedText length]) {
		CGRect boundingRect = [self boundingRectWithText:data.translatedText withBounds:bounds];
		height += boundingRect.size.height;
		height += kTranslatorCellMessageInset * 2.0;
		height += kTranslatorCellGapBetweenMessage;
	}
	FNLOG(@"%f", height);
	return height;
}

+ (CGRect)boundingRectWithText:(NSString *)text withBounds:(CGRect)bounds {
	CGFloat maxWidth = bounds.size.width * 0.64;

    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:text attributes:@{NSFontAttributeName:[UIFont preferredFontForTextStyle:UIFontTextStyleBody], NSForegroundColorAttributeName:[UIColor blackColor]}];
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)attributedString);
    CGSize targetSize = CGSizeMake(maxWidth, CGFLOAT_MAX);
    CGSize fitSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0, [attributedString length]), NULL, targetSize, NULL);
    CFRelease(framesetter);

	return CGRectMake(0.0, 0.0, fitSize.width, fitSize.height);
//
//    return [attributedString boundingRectWithSize:CGSizeMake(maxWidth, CGFLOAT_MAX)
//							  options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesDeviceMetrics | NSStringDrawingUsesFontLeading
//							  context:nil];

//	return [text boundingRectWithSize:CGSizeMake(maxWidth, CGFLOAT_MAX)
//							  options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesDeviceMetrics | NSStringDrawingUsesFontLeading
//						   attributes:@{NSFontAttributeName:[UIFont preferredFontForTextStyle:UIFontTextStyleBody], NSForegroundColorAttributeName:[UIColor blackColor]}
//							  context:nil];
}

- (CGRect)boundingRectWithText:(NSString *)text {
	CGFloat maxWidth = self.bounds.size.width * 0.64;

	NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:text attributes:@{NSFontAttributeName:[UIFont preferredFontForTextStyle:UIFontTextStyleBody], NSForegroundColorAttributeName:[UIColor blackColor]}];
	CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)attributedString);
	CGSize targetSize = CGSizeMake(maxWidth, CGFLOAT_MAX);
	CGSize fitSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0, [attributedString length]), NULL, targetSize, NULL);
	CFRelease(framesetter);

	return CGRectMake(0.0, 0.0, fitSize.width, fitSize.height);

//	return [text boundingRectWithSize:CGSizeMake(maxWidth, CGFLOAT_MAX)
//							  options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesDeviceMetrics | NSStringDrawingUsesFontLeading
//						   attributes:@{NSFontAttributeName:[UIFont preferredFontForTextStyle:UIFontTextStyleBody], NSForegroundColorAttributeName:[UIColor blackColor]}
//							  context:nil];
}

- (CGSize)intrinsicContentSize {
	return CGSizeMake(self.bounds.size.width, [[self class] cellHeightWithData:_messageEntity bounds:self.bounds]);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setMessageEntity:(TranslatorHistory *)messageEntity {
	_messageEntity = messageEntity;

	self.dateLabel.text = [_messageEntity.date timeAgo];
	[self.dateLabel sizeToFit];

	if (_messageEntity.originalText) {
		CGRect boundingRect = CGRectInset([self boundingRectWithText:_messageEntity.originalText], -(kTranslatorCellMessageInset), -kTranslatorCellMessageInset);
		FNLOGRECT(boundingRect);

		[self rightMessageView];
		_rightMessageWidth.constant = boundingRect.size.width + 20.0;
		_rightMessageHeight.constant = boundingRect.size.height + 2.0;

		_rightMessageLabel.text = _messageEntity.originalText;
	}

	if (_messageEntity.translatedText) {
		CGRect boundingRect = CGRectInset([self boundingRectWithText:_messageEntity.translatedText], -(kTranslatorCellMessageInset), -kTranslatorCellMessageInset);

		[self leftMessageView];
		_leftMessageWidth.constant = boundingRect.size.width + 20.0;
		_leftMessageHeight.constant = boundingRect.size.height + 2.0;

		_leftMessageLabel.text = _messageEntity.translatedText;
	}
	[self invalidateIntrinsicContentSize];
	[self layoutIfNeeded];
}

- (UIImageView *)rightMessageView {
	if (!_rightMessageView) {
		_rightMessageView = [UIImageView new];
		UIImage *originalTextImage = [[UIImage imageNamed:@"ballon_right"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
		_rightMessageView.image = originalTextImage;
		_rightMessageView.tintColor = [UIColor colorWithRed:12.0/255.0 green:132.0/255.0 blue:255.0/255.0 alpha:1.0];
		[self.contentView addSubview:_rightMessageView];

		[_rightMessageView makeConstraints:^(MASConstraintMaker *make) {
			make.top.equalTo(self.contentView.top).with.offset(kTranslatorCellTopPadding);
			make.right.equalTo(self.contentView.right).with.offset(-kTranslatorCellLeftRightPadding);
		}];

		_rightMessageWidth = [NSLayoutConstraint constraintWithItem:_rightMessageView
														  attribute:NSLayoutAttributeWidth
														  relatedBy:NSLayoutRelationEqual
															 toItem:nil
														  attribute:NSLayoutAttributeNotAnAttribute
														 multiplier:0.0
														   constant:222.0];
		[self.contentView addConstraint:_rightMessageWidth];
		_rightMessageHeight = [NSLayoutConstraint constraintWithItem:_rightMessageView
														  attribute:NSLayoutAttributeHeight
														  relatedBy:NSLayoutRelationEqual
															 toItem:nil
														  attribute:NSLayoutAttributeNotAnAttribute
														 multiplier:0.0
														   constant:37.0];
		[self.contentView addConstraint:_rightMessageHeight];

		_rightMessageLabel = [self messageLabel];
		_rightMessageLabel.textColor = [UIColor whiteColor];
		[_rightMessageView addSubview:_rightMessageLabel];

		[_rightMessageLabel makeConstraints:^(MASConstraintMaker *make) {
			make.edges.equalTo(_rightMessageView).insets(UIEdgeInsetsMake(kTranslatorCellMessageInset, kTranslatorCellMessageInset + 5.0, kTranslatorCellMessageInset, kTranslatorCellMessageInset + 5.0));
		}];

	}
	return _rightMessageView;
}

- (UIImageView *)leftMessageView {
	if (!_leftMessageView) {
		_leftMessageView = [UIImageView new];
		UIImage *originalTextImage = [[UIImage imageNamed:@"ballon_left"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
		_leftMessageView.image = originalTextImage;
		_leftMessageView.tintColor = [UIColor colorWithRed:229.0/255.0 green:229.0/255.0 blue:234.0/255.0 alpha:1.0];
		[self.contentView addSubview:_leftMessageView];

		[_leftMessageView makeConstraints:^(MASConstraintMaker *make) {
			make.bottom.equalTo(self.contentView.bottom).with.offset(-kTranslatorCellBottomPadding);
			make.left.equalTo(self.contentView.left).with.offset(kTranslatorCellLeftRightPadding);
		}];

		_leftMessageWidth = [NSLayoutConstraint constraintWithItem:_leftMessageView
														 attribute:NSLayoutAttributeWidth
														 relatedBy:NSLayoutRelationEqual
															toItem:nil
														 attribute:NSLayoutAttributeNotAnAttribute
														multiplier:0.0
														  constant:222.0];
		[self.contentView addConstraint:_leftMessageWidth];
		_leftMessageHeight = [NSLayoutConstraint constraintWithItem:_leftMessageView
														   attribute:NSLayoutAttributeHeight
														   relatedBy:NSLayoutRelationEqual
															  toItem:nil
														   attribute:NSLayoutAttributeNotAnAttribute
														  multiplier:0.0
															constant:37.0];
		[self.contentView addConstraint:_leftMessageHeight];

		_leftMessageLabel = [self messageLabel];
		_leftMessageLabel.textColor = [UIColor blackColor];
		[_leftMessageView addSubview:_leftMessageLabel];

		[_leftMessageLabel makeConstraints:^(MASConstraintMaker *make) {
			make.edges.equalTo(_leftMessageView).insets(UIEdgeInsetsMake(kTranslatorCellMessageInset, kTranslatorCellMessageInset * 2.0, kTranslatorCellMessageInset, kTranslatorCellMessageInset));
		}];
	}
	return _leftMessageView;
}

- (UILabel *)messageLabel {
	UILabel *label = [UILabel new];
	label.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
	label.lineBreakMode = NSLineBreakByWordWrapping;
	label.numberOfLines = 0;
	return label;
}

- (UILabel *)dateLabel {
	if (!_dateLabel) {
		_dateLabel = [UILabel new];
		_dateLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption2];
		_dateLabel.textColor = [UIColor colorWithRed:142.0/255.0 green:142.0/255.0 blue:147.0/255.0 alpha:1.0];
		[self.contentView addSubview:_dateLabel];

		[_dateLabel makeConstraints:^(MASConstraintMaker *make) {
			make.top.equalTo(@14.0);
			make.centerX.equalTo(self.contentView.centerX);
		}];
	}
	return _dateLabel;
}

- (void)layoutSubviews {
	[super layoutSubviews];

	FNLOGRECT(_leftMessageView.frame);
	FNLOGRECT(_leftMessageLabel.frame);
}

@end
