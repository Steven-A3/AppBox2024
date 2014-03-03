//
//  A3TranslatorMessageCell.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 8/15/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import <CoreText/CoreText.h>
#import <AVFoundation/AVFoundation.h>
#import "A3TranslatorMessageCell.h"
#import "TranslatorHistory.h"
#import "A3Formatter.h"
#import "common.h"
#import "NSDate+TimeAgo.h"
#import "SFKImage.h"
#import "TranslatorFavorite.h"
#import "NSString+conversion.h"
#import "TranslatorHistory+manager.h"
#import "TranslatorGroup.h"
#import "A3AppDelegate.h"
#import "Reachability.h"
#import "A3TranslatorLanguage.h"
#import <MediaPlayer/MediaPlayer.h>

@interface A3TranslatorMessageCell () <AVSpeechSynthesizerDelegate>

@property (nonatomic, strong) UILabel *dateLabel;
@property (nonatomic, strong) NSLayoutConstraint *rightMessageWidth;
@property (nonatomic, strong) NSLayoutConstraint *rightMessageHeight;
@property (nonatomic, strong) NSLayoutConstraint *leftMessageHeight;
@property (nonatomic, strong) NSLayoutConstraint *leftMessageWidth;
@property (nonatomic, strong) UILabel *rightMessageLabel;
@property (nonatomic, strong) UILabel *leftMessageLabel;
@property (nonatomic, strong) UIButton *favoriteButton;
@property (nonatomic, strong) UIButton *speakButton;
@property (nonatomic, strong) AVSpeechSynthesizer *speechSynthesizer;
@property (nonatomic, strong) MPMoviePlayerController *googleSpeechPlayer;

@end

@implementation A3TranslatorMessageCell {
	BOOL _speakWithApple;
}

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
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(speakGoogleFinished) name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
    }
    return self;
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)prepareForReuse {
	[super prepareForReuse];

	[_favoriteButton removeFromSuperview];
	_favoriteButton = nil;

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

		[self speakButton];
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
			make.width.equalTo(@44);
			make.height.equalTo(@44);
		}];
	}
	return _favoriteButton;
}

- (UIButton *)speakButton {
	if ([self speechAvailableForLanguage:_messageEntity.group.targetLanguage]) {
		_speakWithApple = YES;
	} else if ([self googleSpeechAvailableForLanguage:_messageEntity.group.targetLanguage]) {
		_speakWithApple = NO;
	} else {
		return nil;
	}

	if (!_speakButton) {
		_speakButton = [UIButton buttonWithType:UIButtonTypeSystem];
		_speakButton.titleLabel.font = [UIFont fontWithName:@"appbox" size:30];
		[_speakButton setTitle:@"b" forState:UIControlStateNormal];
		[_speakButton addTarget:self action:@selector(speakButtonAction) forControlEvents:UIControlEventTouchUpInside];

		[self addSubview:_speakButton];

		[_speakButton makeConstraints:^(MASConstraintMaker *make) {
			make.centerY.equalTo(_leftMessageView.centerY);
			make.left.equalTo(_leftMessageView.right);
			make.width.equalTo(@44);
			make.height.equalTo(@44);
		}];
	}
	return _speakButton;
}

- (AVSpeechSynthesizer *)speechSynthesizer {
	if (!_speechSynthesizer) {
		_speechSynthesizer = [AVSpeechSynthesizer new];
		_speechSynthesizer.delegate = self;
	}
	return _speechSynthesizer;
}

- (void)setSpeakButtonDefault {
	[_speakButton setTitle:@"b" forState:UIControlStateNormal];
}

- (void)setSpeakButtonPause {
	[_speakButton setTitle:@"l" forState:UIControlStateNormal];
}

- (void)setSpeakButtonContinue {
	[_speakButton setTitle:@"m" forState:UIControlStateNormal];
}

- (void)setSpeakButtonStop {
	[_speakButton setTitle:@"p" forState:UIControlStateNormal];
}

- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didStartSpeechUtterance:(AVSpeechUtterance *)utterance {
	[self setSpeakButtonPause];
	FNLOG();
}

- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didFinishSpeechUtterance:(AVSpeechUtterance *)utterance {
	[self setSpeakButtonDefault];
	FNLOG();
}

- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didPauseSpeechUtterance:(AVSpeechUtterance *)utterance {
	[self setSpeakButtonContinue];
	FNLOG();
}

- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didContinueSpeechUtterance:(AVSpeechUtterance *)utterance {
	[self setSpeakButtonPause];
	FNLOG();
}

- (void)speakButtonAction {
	if (_speakWithApple) {
		if ([self.speechSynthesizer isPaused]) {
			[self.speechSynthesizer continueSpeaking];
			return;
		}
		if ([self.speechSynthesizer isSpeaking]) {
			[self.speechSynthesizer pauseSpeakingAtBoundary:AVSpeechBoundaryImmediate];
			return;
		}
		AVSpeechSynthesisVoice *voice = [AVSpeechSynthesisVoice voiceWithLanguage:[self speechLanguageForLanguage:_messageEntity.group.targetLanguage]];
		AVSpeechUtterance *utterance = [[AVSpeechUtterance alloc] initWithString:_messageEntity.translatedText];
		utterance.voice = voice;
		[self.speechSynthesizer speakUtterance:utterance];
	} else {
		[self speakGoogleSpeechWithLanguage];
	}
}

- (void)changeFavoriteButtonImage {
	UIImage *image;
	if (_messageEntity.favorite) {
		image = [UIImage imageNamed:@"star02_on"];
	} else {
		image = [UIImage imageNamed:@"star02"];
	}
	[_favoriteButton setImage:image forState:UIControlStateNormal];
}

- (void)favoriteButtonAction {
	[_messageEntity setAsFavoriteMember:_messageEntity.favorite == nil];

	[self changeFavoriteButtonImage];
}

- (BOOL)speechAvailableForLanguage:(NSString *)language {
	NSArray *voices = [AVSpeechSynthesisVoice speechVoices];
	return [voices indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
		BOOL result = [[[obj valueForKeyPath:@"language"] substringToIndex:2] isEqualToString:language];
		if (result) *stop = YES;
		return result;
	}] != NSNotFound;
}

- (NSString *)speechLanguageForLanguage:(NSString *)language {
	NSArray *voices = [AVSpeechSynthesisVoice speechVoices];
	if ([language isEqualToString:@"en"]) {
		return [self supportedVoiceLanguageForLanguage:language defaultCode:@"en-US" inArray:voices];
	} else if ([language isEqualToString:@"es"]) {
		return [self supportedVoiceLanguageForLanguage:language defaultCode:@"es-ES" inArray:voices];
	} else if ([language isEqualToString:@"fr"]) {
		return [self supportedVoiceLanguageForLanguage:language defaultCode:@"fr-FR" inArray:voices];
	} else if ([language isEqualToString:@"nl"]) {
		return [self supportedVoiceLanguageForLanguage:language defaultCode:@"nl-NL" inArray:voices];
	} else if ([language isEqualToString:@"pt"]) {
		return [self supportedVoiceLanguageForLanguage:language defaultCode:@"pt-PT" inArray:voices];
	} else if ([[language substringToIndex:2] isEqualToString:@"zh"]) {
		return [self supportedVoiceLanguageForLanguage:language defaultCode:@"zh-CN" inArray:voices];
	} else {
		NSInteger idx = [voices indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
			BOOL result = [[[obj valueForKeyPath:@"language"] substringToIndex:2] isEqualToString:language];
			if (result) *stop = YES;
			return result;
		}];
		if (idx != NSNotFound) return [voices[idx] valueForKeyPath:@"language"];
	}
	return nil;
}

- (NSString *)supportedVoiceLanguageForLanguage:(NSString *)language defaultCode:(NSString *)defaultCode inArray:(NSArray *)voices {
	NSString *languageCode = [NSString stringWithFormat:@"en-%@", [[NSLocale currentLocale] objectForKey:NSLocaleCountryCode]];
	NSInteger idx = [voices indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
		BOOL result = [[obj valueForKeyPath:@"language"] isEqualToString:languageCode];
		if (result) *stop = YES;
		return result;
	}];
	if (idx != NSNotFound) {
		return languageCode;
	} else {
		return defaultCode;
	}
}

/*! Apple Language Code and Google language code is different in few languages like
 * he(Hebrew in Apple) is iw(Hebrew in Google), fil(Filipino in Apple) is tl(Google)
 * zh-Hans(Apple) is zh-CN(Google), zh-Hant(Apple) is zh-TW(Google)
 * \param language code must be Apple language code rather than Google language code
 * \param
 * \returns
 */
- (BOOL)googleSpeechAvailableForLanguage:(NSString *)language {
	if (![[A3AppDelegate instance].reachability isReachable]) return NO;
	NSSet *googleSpeeches = [NSSet setWithArray:@[@"mk", @"hr", @"sr", @"ht", @"is", @"ca", @"sw", @"af", @"lv", @"vi", @"cy", @"sq"]];
	return [googleSpeeches member:language] != nil;
}

#define GOOGLE_LISTEN_URL	@"http://translate.google.com/translate_tts?ie=UTF-8&tl="

- (void)speakGoogleSpeechWithLanguage {
	if (![[A3AppDelegate instance].reachability isReachable]) {
		return;
	}

	NSMutableString *urlString = [NSMutableString stringWithCapacity:300];
	[urlString appendString:GOOGLE_LISTEN_URL];
	[urlString appendString:[A3TranslatorLanguage googleCodeFromAppleCode:_messageEntity.group.targetLanguage]];
	[urlString appendString:@"&q="];
	[urlString appendString:[_messageEntity.translatedText stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];

	FNLOG(@"%@", urlString);

	_googleSpeechPlayer = [[MPMoviePlayerController alloc] initWithContentURL:[NSURL URLWithString:urlString]];
	_googleSpeechPlayer.movieSourceType = MPMovieSourceTypeStreaming;
	[_googleSpeechPlayer prepareToPlay];
	[_googleSpeechPlayer play];

	[self.speakButton setHidden:YES];
}

- (void)speakGoogleFinished {
	FNLOG();
	_googleSpeechPlayer = nil;
	[self.speakButton setHidden:NO];
}

@end
