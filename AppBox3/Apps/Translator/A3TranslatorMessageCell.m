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
#import "SFKImage.h"
#import "NSManagedObjectContext+MagicalThreading.h"
#import "NSManagedObjectContext+MagicalSaves.h"

@interface A3TranslatorMessageCell ()

@property (nonatomic, strong) UILabel *dateLabel;
@property (nonatomic, strong) NSLayoutConstraint *rightMessageWidth;
@property (nonatomic, strong) NSLayoutConstraint *rightMessageHeight;
@property (nonatomic, strong) NSLayoutConstraint *leftMessageHeight;
@property (nonatomic, strong) NSLayoutConstraint *leftMessageWidth;
@property (nonatomic, strong) UILabel *rightMessageLabel;
@property (nonatomic, strong) UILabel *leftMessageLabel;
@property (nonatomic, strong) UIButton *favoriteButton;

@end

@implementation A3TranslatorMessageCell

static const CGFloat kTranslatorCellTopPadding = 35.0;
static const CGFloat kTranslatorCellBottomPadding = 10.0;
static const CGFloat kTranslatorCellLeftRightPadding = 15.0;
static const CGFloat kTranslatorCellRightMessageInsetLeft = 12.0;
static const CGFloat kTranslatorCellRightMessageInsetRight = 15.0;
static const CGFloat kTranslatorCellLeftMessageInsetLeft = 15.0;
static const CGFloat kTranslatorCellLeftMessageInsetRight = 12.0;
static const CGFloat kTranslatorCellMessageInsetTop = 5.0;
static const CGFloat kTranslatorCellMessageInsetBottom = 5.0;
static const CGFloat kTranslatorCellGapBetweenMessage = 15.0;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
		self.selectionStyle = UITableViewCellSelectionStyleDefault;
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
    
    self.selectionStyle = UITableViewCellSelectionStyleDefault;
}

+ (CGFloat)cellHeightWithData:(TranslatorHistory *)data bounds:(CGRect)bounds {
	CGFloat height = 0;
	if ([data.originalText length]) {
		CGRect boundingRect = boundingRectWithText(data.originalText, bounds);
//		FNLOGRECT(boundingRect);
		height += boundingRect.size.height;
		height += (kTranslatorCellMessageInsetTop + kTranslatorCellMessageInsetBottom);
		height = MAX(height, 35);
	}
	if ([data.translatedText length]) {
		CGRect boundingRect = boundingRectWithText(data.translatedText, bounds);
		height += boundingRect.size.height;
		height += (kTranslatorCellMessageInsetTop + kTranslatorCellMessageInsetBottom);
		height = MAX(height, 35);

		height += kTranslatorCellGapBetweenMessage;
	}
	height += kTranslatorCellTopPadding + kTranslatorCellBottomPadding;
//	FNLOG(@"%f", height);
	return height;
}

CGRect boundingRectWithText(NSString *text, CGRect bounds) {
	CGFloat maxWidth = bounds.size.width * 0.64;

    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:text attributes:@{NSFontAttributeName:[UIFont preferredFontForTextStyle:UIFontTextStyleBody], NSForegroundColorAttributeName:[UIColor blackColor]}];
    CTFramesetterRef frameSetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)attributedString);
    CGSize targetSize = CGSizeMake(maxWidth, CGFLOAT_MAX);
    CGSize fitSize = CTFramesetterSuggestFrameSizeWithConstraints(frameSetter, CFRangeMake(0, [attributedString length]), NULL, targetSize, NULL);
    CFRelease(frameSetter);

//	FNLOG(@"%f, %f", fitSize.width, fitSize.height);
	return CGRectMake(0.0, 0.0, fitSize.width, fitSize.height);
}

- (CGSize)intrinsicContentSize {
	return CGSizeMake(self.bounds.size.width, [[self class] cellHeightWithData:_messageEntity bounds:self.bounds]);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
	FNLOG(@"%@", self.selectedBackgroundView);
}

#pragma mark - SET MESSAGE ENTITY

- (void)setMessageEntity:(TranslatorHistory *)messageEntity {
	_messageEntity = messageEntity;

	self.dateLabel.text = [_messageEntity.date timeAgoWithLimit:60 * 60 * 24 dateFormat:NSDateFormatterShortStyle andTimeFormat:NSDateFormatterShortStyle];
	[self.dateLabel sizeToFit];

	if (_messageEntity.originalText) {
		CGRect textRect = boundingRectWithText(_messageEntity.originalText, self.bounds);
		textRect.size.width += 2.0;
		textRect.size.height += 1.0;
		CGRect boundingRect = UIEdgeInsetsInsetRect(textRect,
				UIEdgeInsetsMake(-kTranslatorCellMessageInsetTop, -kTranslatorCellRightMessageInsetLeft, -kTranslatorCellMessageInsetBottom, -kTranslatorCellRightMessageInsetRight));

		[self rightMessageView];
		_rightMessageWidth.constant = boundingRect.size.width;
		_rightMessageHeight.constant = MAX(boundingRect.size.height, 35);
		FNLOG(@"rightMessageHeight = %f", _rightMessageHeight.constant);

		_rightMessageLabel.text = _messageEntity.originalText;

		[self favoriteButton];
	}

	if (_messageEntity.translatedText) {
		CGRect textRect = boundingRectWithText(_messageEntity.translatedText, self.bounds);
		textRect.size.width += 2.0;
		textRect.size.height += 1.0;
		CGRect boundingRect = UIEdgeInsetsInsetRect(textRect,
				UIEdgeInsetsMake(-kTranslatorCellMessageInsetTop, -kTranslatorCellLeftMessageInsetLeft, -kTranslatorCellMessageInsetBottom, -kTranslatorCellLeftMessageInsetRight));

		[self leftMessageView];
		_leftMessageWidth.constant = boundingRect.size.width;
		_leftMessageHeight.constant = MAX(boundingRect.size.height, 35);

		_leftMessageLabel.text = [_messageEntity.translatedText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	}
	[self invalidateIntrinsicContentSize];
	[self layoutIfNeeded];
}

#pragma mark - Right Message View

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
			make.centerX.equalTo(_rightMessageView.centerX).with.offset(-3);
			make.centerY.equalTo(_rightMessageView.centerY).with.offset(0);
			make.width.equalTo(_rightMessageView.width).with.offset(-27);
		}];

		// Finally add gesture recognizer for copy paste.
		UILongPressGestureRecognizer *gestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressGestureHandler:)];
		[_rightMessageView addGestureRecognizer:gestureRecognizer];
        _rightMessageView.userInteractionEnabled = YES;
	}
	return _rightMessageView;
}

- (void)longPressGestureHandler:(UILongPressGestureRecognizer *)gestureRecognizer {
	if ([gestureRecognizer state] == UIGestureRecognizerStateBegan) {
		if ([_delegate respondsToSelector:@selector(cell:longPressGestureRecognized:)]) {
			[_delegate cell:self longPressGestureRecognized:gestureRecognizer];
		}
	}
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
			make.centerX.equalTo(_leftMessageView.centerX).with.offset(3);
			make.centerY.equalTo(_leftMessageView.centerY).with.offset(0);
			make.width.equalTo(_leftMessageView.width).with.offset(-27);
		}];

		// Finally add gesture recognizer for copy paste.
		UILongPressGestureRecognizer *gestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressGestureHandler:)];
		[_leftMessageView addGestureRecognizer:gestureRecognizer];
        _leftMessageView.userInteractionEnabled = YES;
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
		[self addSubview:_dateLabel];

		[_dateLabel makeConstraints:^(MASConstraintMaker *make) {
			make.top.equalTo(@14.0);
			make.centerX.equalTo(self.centerX);
		}];
	}
	return _dateLabel;
}

- (UIButton *)favoriteButton {
	if (!_favoriteButton) {
		_favoriteButton = [UIButton buttonWithType:UIButtonTypeCustom];
		[self changeFavoriteButtonImage];
		[_favoriteButton addTarget:self action:@selector(favoriteButtonAction) forControlEvents:UIControlEventTouchUpInside];

		[self addSubview:_favoriteButton];

		[_favoriteButton makeConstraints:^(MASConstraintMaker *make) {
			make.centerY.equalTo(_rightMessageView.centerY);
			make.right.equalTo(_rightMessageView.left).with.offset(-15);
		}];
	}
	return _favoriteButton;
}

- (void)changeFavoriteButtonImage {
	UIImage *image;
	if (_messageEntity.favorite.boolValue) {
		image = [UIImage imageNamed:@"star02_full"];
	} else {
		image = [UIImage imageNamed:@"star02"];
	}
	[_favoriteButton setImage:image forState:UIControlStateNormal];
}

- (void)favoriteButtonAction {
	_messageEntity.favorite = @(!_messageEntity.favorite.boolValue);
	[[NSManagedObjectContext MR_contextForCurrentThread] MR_saveOnlySelfAndWait];

	[self changeFavoriteButtonImage];
}

@end
