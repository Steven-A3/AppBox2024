//
//  A3TranslatorMessageViewController.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 8/14/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3TranslatorMessageViewController.h"
#import "A3UIDevice.h"
#import "TranslatorHistory.h"
#import "NSManagedObject+MagicalRecord.h"
#import "NSManagedObject+MagicalFinders.h"
#import "A3TranslatorMessageCell.h"
#import "NSManagedObjectContext+MagicalThreading.h"
#import "NSManagedObjectContext+MagicalSaves.h"
#import "common.h"
#import "AFHTTPRequestOperation.h"
#import "AFJSONRequestOperation.h"
#import "A3TranslatorLanguageTVDelegate.h"
#import "A3TranslatorLanguage.h"
#import "A3LanguagePickerController.h"
#import "UIViewController+A3AppCategory.h"
#import "SFKImage.h"

@interface A3TranslatorMessageViewController () <UITextFieldDelegate, UITextViewDelegate, UITableViewDelegate, UITableViewDataSource, A3TranslatorMessageCellDelegate, UIKeyInput, A3TranslatorLanguageTVDelegateDelegate, A3LanguagePickerControllerDelegate>

// Language Select
@property (nonatomic, strong) UIView *languageSelectView;
@property (nonatomic, strong) UITextField *sourceLanguageSelectTextField;
@property (nonatomic, strong) UITextField *targetLanguageSelectTextField;
@property (nonatomic, strong) UIView *textEntryBarView;
@property (nonatomic, strong) UIButton *translateButton;
@property (nonatomic, strong) UITextView *textView;
@property (nonatomic, strong) NSLayoutConstraint *textEntryBarViewBottomConstraint;
@property (nonatomic, strong) NSLayoutConstraint *textEntryBarViewHeightConstraint;
@property (nonatomic, strong) UITableView *messageTableView;
@property (nonatomic, strong) NSArray *messages;
@property (nonatomic, copy) NSString *originalText;
@property (nonatomic, weak) A3TranslatorMessageCell *selectedCell;
@property (readwrite, retain) UIView *inputView;
@property (nonatomic, strong) UITableView *searchResultsTableView;
@property (nonatomic, strong) A3TranslatorLanguageTVDelegate *searchResultsDelegate;
@property (nonatomic, strong) NSArray *languages;
@property (nonatomic, weak) A3LanguagePickerController *sourceLanguagePicker;
@property (nonatomic, weak) A3LanguagePickerController *targetLanguagePicker;
@property (nonatomic, strong) UIButton *setSourceLanguageButton;
@property (nonatomic, strong) UIButton *setTargetLanguageButton;
@property (nonatomic, strong) NSLayoutConstraint *setTargetLanguageButtonConstraint;
@property (nonatomic, strong) TranslatorHistory *translatingMessage;
@property (nonatomic, strong) UIBarButtonItem *toolbarDeleteButton;
@property (nonatomic, strong) UIBarButtonItem *toolbarSetFavoriteButton;
@property (nonatomic, strong) UIBarButtonItem *toolbarUnsetFavoriteButton;
@property (nonatomic, strong) UIBarButtonItem *toolbarShareButton;

@end

static NSString *const kTranslatorMessageCellID = @"TranslatorMessageCellID";

@implementation A3TranslatorMessageViewController {
	CGFloat _keyboardHeight;
    BOOL    _copyOriginalText;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.

	self.view.backgroundColor = [UIColor whiteColor];

	[self addTextEntryView];

	if ([_translatedTextLanguage length]) {
		[self setTitleWithSelectedLanguage];
		[self setupMessageTableView];
		[self rightBarButtonEditButton];
	} else {
		self.title = @"New Translator";

		_languages = [A3TranslatorLanguage findAllWithDetectLanguage:YES ];
		[self addLanguageSelectView];
		[self searchResultsTableView];
	}

	[self layoutTextEntryBarViewAnimated:NO ];
	[self observeKeyboard];
	[self registerContentSizeCategoryDidChangeNotification];

	[self.view layoutIfNeeded];
}

- (void)rightBarButtonEditButton {
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStylePlain target:self action:@selector(editButtonAction)];
}

- (void)contentSizeDidChange:(NSNotification *)notification {
	[_messageTableView reloadData];
	[_searchResultsTableView reloadData];
	[self layoutTextEntryBarViewAnimated:NO];
}

- (void)dealloc {
	[self removeObserver];
}

- (void)setTitleWithSelectedLanguage {
	self.title = [NSString stringWithFormat:@"%@ to %@",
											[A3TranslatorLanguage localizedNameForCode:_originalTextLanguage],
											[A3TranslatorLanguage localizedNameForCode:_translatedTextLanguage]];
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

- (void)setupMessageTableView {
	[self messageTableView];
	[_messageTableView registerClass:[A3TranslatorMessageCell class] forCellReuseIdentifier:kTranslatorMessageCellID];
//	[self addTapGestureRecognizer];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

	FNLOG();
	if (_messageTableView) {
		[self scrollToBottomAnimated:NO ];
		[_textView becomeFirstResponder];

		[self.view layoutIfNeeded];
	}
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];

	if (_sourceLanguagePicker) {
		[_sourceLanguageSelectTextField becomeFirstResponder];
	} else if (_targetLanguagePicker) {
		[_targetLanguageSelectTextField becomeFirstResponder];
	}
	_sourceLanguagePicker = nil;
	_targetLanguagePicker = nil;

	if (_selectItem) {
		NSUInteger index = [self.messages indexOfObject:_selectItem];
		if (index != NSNotFound) {
			[_messageTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
		} else {
			FNLOG(@"Selected Item NOT Found!");
		}

		_selectItem = nil;
	}

	if ([_languageSelectView superview] && [self isFirstResponder]) {
		[_targetLanguageSelectTextField becomeFirstResponder];
	}
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];

	[self.navigationController setToolbarHidden:YES animated:NO];

	if ([_delegate respondsToSelector:@selector(translatorMessageViewControllerWillDismiss:)]) {
		[_delegate translatorMessageViewControllerWillDismiss:self];
	}
}


- (void)addTapGestureRecognizer {
	UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureHandler)];
	[self.view addGestureRecognizer:gestureRecognizer];
}

- (void)tapGestureHandler {
	FNLOG();
	[self resignFirstResponder];
	[_sourceLanguageSelectTextField resignFirstResponder];
	[_targetLanguageSelectTextField resignFirstResponder];
	[_textView resignFirstResponder];
}

- (void)editButtonAction {
	[_messageTableView setEditing:!_messageTableView.isEditing animated:YES];
	[self.navigationItem.rightBarButtonItem setTitle:_messageTableView.isEditing ? @"Done" : @"Edit"];

	if (_messageTableView.isEditing) {
		[_textEntryBarView setHidden:YES];
		[self addToolbar];
	} else {
		[self.navigationController setToolbarHidden:YES animated:YES];
		double delayInSeconds = 0.4;
		dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
		dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
			[_textEntryBarView setHidden:NO];
		});
	}
	[self resignFirstResponder];
	[_textView resignFirstResponder];
}

#pragma mark - Language Select View

- (void)addLanguageSelectView {
    FNLOG();
    
	_languageSelectView = [UIView new];
	_languageSelectView.clipsToBounds = YES;
	[self.view addSubview:_languageSelectView];

	[_languageSelectView makeConstraints:^(MASConstraintMaker *make) {
		make.top.equalTo(@64.0);
		make.width.equalTo(self.view.width);
		make.height.equalTo(@74.0);
		make.centerX.equalTo(self.view.centerX);
	}];

	UIView *contentsView = [UIView new];
	[_languageSelectView addSubview:contentsView];

	[contentsView makeConstraints:^(MASConstraintMaker *make) {
		make.edges.equalTo(_languageSelectView);
	}];

	_sourceLanguageSelectTextField = [self textFieldForLanguageSelect];
	_sourceLanguageSelectTextField.text = @"Detect Language";
	UILabel *sourceLanguageLeftLabel = [self leftLabel];
	sourceLanguageLeftLabel.text = @"From: ";
	[sourceLanguageLeftLabel sizeToFit];
	_sourceLanguageSelectTextField.leftView = sourceLanguageLeftLabel;

	[contentsView addSubview:_sourceLanguageSelectTextField];

	[_sourceLanguageSelectTextField makeConstraints:^(MASConstraintMaker *make) {
		make.left.equalTo(contentsView.left).with.offset(IS_IPHONE ? 15.0 : 28.0);
		make.top.equalTo(contentsView.top);
		make.right.equalTo(contentsView.right).with.offset(-52.0);
		make.height.equalTo(@37.0);
	}];

	[contentsView addSubview:_sourceLanguageSelectTextField];

	UIView *line1 = [UIView new];
    line1.backgroundColor = [UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:200.0/255.0];
	[contentsView addSubview:line1];

	[line1 makeConstraints:^(MASConstraintMaker *make) {
		make.top.equalTo(contentsView.top).with.offset(37.0);
		make.left.equalTo(contentsView.left).with.offset(IS_IPHONE ? 15.0 : 28.0);
		make.right.equalTo(contentsView.right);
		make.height.equalTo( @1.0 );
	}];

	_targetLanguageSelectTextField = [self textFieldForLanguageSelect];
	UILabel *targetLanguageLeftLabel = [self leftLabel];
	targetLanguageLeftLabel.text = @"To: ";
	[targetLanguageLeftLabel sizeToFit];
	_targetLanguageSelectTextField.leftView = targetLanguageLeftLabel;
	[contentsView addSubview:_targetLanguageSelectTextField];

	[_targetLanguageSelectTextField makeConstraints:^(MASConstraintMaker *make) {
		make.top.equalTo(contentsView.top).with.offset(38.0);
		make.left.equalTo(contentsView.left).with.offset(IS_IPHONE ? 15.0 : 28.0);
		make.right.equalTo(contentsView.right).with.offset(-52.0);
		make.height.equalTo(@37.0);
	}];

	UIView *line2 = [UIView new];
    line2.backgroundColor = [UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:200.0/255.0];
	[contentsView addSubview:line2];

	[line2 makeConstraints:^(MASConstraintMaker *make) {
		make.bottom.equalTo(contentsView.bottom);
		make.left.equalTo(contentsView.left).with.offset(IS_IPHONE ? 15.0 : 28.0);
		make.right.equalTo(contentsView.right);
		make.height.equalTo(@1.0);
	}];

	_setSourceLanguageButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[_setSourceLanguageButton setImage:[self selectLanguageButtonImage] forState:UIControlStateNormal];
	[_setSourceLanguageButton addTarget:self action:@selector(selectSourceLanguage) forControlEvents:UIControlEventTouchUpInside];
	_setSourceLanguageButton.tintColor = [self selectLanguageButtonTintColor];
	[contentsView addSubview:_setSourceLanguageButton];

	[_setSourceLanguageButton makeConstraints:^(MASConstraintMaker *make) {
		make.top.equalTo(contentsView.top);
		make.right.equalTo(contentsView.right).with.offset(-4.0);
		make.width.equalTo(@37.0);
		make.height.equalTo(@37.0);
	}];

	_setTargetLanguageButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[_setTargetLanguageButton setImage:[self addButtonImage] forState:UIControlStateNormal];
	[_setTargetLanguageButton addTarget:self action:@selector(selectTranslatedLanguage) forControlEvents:UIControlEventTouchUpInside];
	[contentsView addSubview:_setTargetLanguageButton];

	[_setTargetLanguageButton makeConstraints:^(MASConstraintMaker *make) {
		make.bottom.equalTo(contentsView.bottom);
		make.width.equalTo(@37.0);
		make.height.equalTo(@37.0);
	}];

	_setTargetLanguageButtonConstraint = [NSLayoutConstraint constraintWithItem:_setTargetLanguageButton
																	  attribute:NSLayoutAttributeRight
																	  relatedBy:NSLayoutRelationEqual
																		 toItem:contentsView
																	  attribute:NSLayoutAttributeRight
																	 multiplier:1.0
																	   constant:-10.0];
	[contentsView addConstraint:_setTargetLanguageButtonConstraint];
}

- (A3LanguagePickerController *)presentLanguagePickerControllerWithDetectLanguage:(BOOL)detectLanguage {
	A3LanguagePickerController *viewController = [[A3LanguagePickerController alloc] initWithStyle:UITableViewStylePlain];
	viewController.delegate = self;
	viewController.languages = [A3TranslatorLanguage findAllWithDetectLanguage:detectLanguage];
	[self presentSubViewController:viewController];
	return viewController;
}

- (void)selectSourceLanguage {
	_sourceLanguagePicker = [self presentLanguagePickerControllerWithDetectLanguage:YES ];
}

- (void)selectTranslatedLanguage {
	_targetLanguagePicker = [self presentLanguagePickerControllerWithDetectLanguage:NO ];
}

- (void)languagePickerController:(A3LanguagePickerController *)controller didSelectLanguage:(A3TranslatorLanguage *)language {
	if (controller == _sourceLanguagePicker) {
		_sourceLanguageSelectTextField.text = language.name;
		_originalTextLanguage = language.code;
	} else {
		_targetLanguageSelectTextField.text = language.name;
		[self setTranslatedTextLanguage:language.code];
	}
	[self layoutLanguageSelectView];
}

- (UIImage *)addButtonImage {
	return [[UIImage imageNamed:@"add02"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
}

- (UIImage *)selectLanguageButtonImage {
	return [[UIImage imageNamed:@"arrow"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
}

- (UIColor *)selectLanguageButtonTintColor {
	return [UIColor colorWithRed:204.0/255.0 green:204.0/255.0 blue:204.0/255.0 alpha:1.0];
}

- (void)layoutLanguageSelectView {

	if ([_originalTextLanguage length]) {
		_sourceLanguageSelectTextField.textColor = [self.view tintColor];
	} else {
		_sourceLanguageSelectTextField.textColor = [UIColor blackColor];
	}

	UIImage *buttonImage;
	CGFloat buttonOffset;
	if ([_translatedTextLanguage length]) {
		buttonImage = [self selectLanguageButtonImage];
		_setTargetLanguageButton.tintColor = [self selectLanguageButtonTintColor];
		buttonOffset = -4.0;
		_targetLanguageSelectTextField.textColor = [self.view tintColor];
	} else {
		buttonImage = [self addButtonImage];
		_setTargetLanguageButton.tintColor = [self.view tintColor];
		buttonOffset = -10.0;
		_targetLanguageSelectTextField.textColor = [UIColor blackColor];
	}
	[_setTargetLanguageButton setImage:buttonImage forState:UIControlStateNormal];
	_setTargetLanguageButtonConstraint.constant = buttonOffset;
	[_languageSelectView layoutIfNeeded];
}

- (UILabel *)leftLabel {
	UILabel *leftLabel = [UILabel new];
	leftLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
	leftLabel.textColor = [UIColor colorWithRed:142.0/255.0 green:142.0/255.0 blue:142.0/255.0 alpha:1.0];
	return leftLabel;
}

- (UITextField *)textFieldForLanguageSelect {
    FNLOG();
	UITextField *textField = [UITextField new];
	textField.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
	textField.textColor = [UIColor blackColor];
	textField.delegate = self;
	textField.clearButtonMode = UITextFieldViewModeNever;
	textField.leftViewMode = UITextFieldViewModeAlways;
	return textField;
}

- (void)setTranslatedTextLanguage:(NSString *)translatedTextLanguage {
	_translatedTextLanguage = [translatedTextLanguage mutableCopy];
	[self layoutLanguageSelectView];
	[self setTranslateButtonEnabled];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
	return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
	[self layoutLanguageSelectView];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldDidChange:) name:UITextFieldTextDidChangeNotification object:nil];
}

- (void)textFieldDidChange:(NSNotification *)notification {
    FNLOG();
	UITextField *textField = notification.object;
	BOOL includeDetectLanguage = (textField == _sourceLanguageSelectTextField);
	_searchResultsDelegate.languages = [A3TranslatorLanguage filteredArrayWithArray:_languages searchString:textField.text includeDetectLanguage:includeDetectLanguage ];
	[_searchResultsTableView reloadData];
	[_searchResultsTableView setHidden:![_searchResultsDelegate.languages count]];

	A3TranslatorLanguage *match = [A3TranslatorLanguage findLanguageInArray:_languages searchString:textField.text];
	if (textField == _sourceLanguageSelectTextField) {
		if (match) {
			_sourceLanguageSelectTextField.text = match.name;
			_originalTextLanguage = match.code;
		} else {
			_originalTextLanguage = nil;
		}
	} else if (textField == _targetLanguageSelectTextField) {
		if (match) {
			_targetLanguageSelectTextField.text = match.name;
			[self setTranslatedTextLanguage:match.code];
		} else {
			[self setTranslatedTextLanguage:nil];
		}
	}
	[self layoutLanguageSelectView];
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
	return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
	[self layoutLanguageSelectView];
}

/*! This will initialize a tableview and add it to self.view with layout information.
 */
- (UITableView *)searchResultsTableView {
	if (!_searchResultsTableView) {
		_searchResultsTableView = [UITableView new];

		[self.view addSubview:_searchResultsTableView];

		[_searchResultsTableView makeConstraints:^(MASConstraintMaker *make) {
			make.top.equalTo(self.view.top).with.offset(64 + 74);
			make.left.equalTo(self.view.left);
			make.right.equalTo(self.view.right);
			make.bottom.equalTo(_textEntryBarView.top);
		}];

		[self searchResultsDelegate];
		_searchResultsTableView.delegate = _searchResultsDelegate;
		_searchResultsTableView.dataSource = _searchResultsDelegate;

		[_searchResultsTableView setHidden:YES];
	}
	return _searchResultsTableView;
}

- (A3TranslatorLanguageTVDelegate *)searchResultsDelegate {
	if (!_searchResultsDelegate) {
		_searchResultsDelegate = [A3TranslatorLanguageTVDelegate new];
		_searchResultsDelegate.delegate = self;
	}
	return _searchResultsDelegate;
}

- (void)tableView:(UITableView *)tableView didSelectLanguage:(A3TranslatorLanguage *)language {
	if ([_sourceLanguageSelectTextField isFirstResponder]) {
		_sourceLanguageSelectTextField.text = language.name;
		_originalTextLanguage = language.code;
	} else if ([_targetLanguageSelectTextField isFirstResponder]) {
		_targetLanguageSelectTextField.text = language.name;
		[self setTranslatedTextLanguage:language.code];
	}
	_searchResultsDelegate.languages = nil;
	[_searchResultsTableView reloadData];
	[_searchResultsTableView setHidden:YES];

	[self layoutLanguageSelectView];
}

#pragma mark - Message Text Entry View

- (void)addTextEntryView {
	_textEntryBarView = [UIView new];
	_textEntryBarView.backgroundColor = [UIColor colorWithRed:247.0/255.0 green:247.0/255.0 blue:247.0/255.0 alpha:1.0];
	[self.view addSubview:_textEntryBarView];

	[_textEntryBarView makeConstraints:^(MASConstraintMaker *make) {
		make.left.equalTo(self.view.left);
		make.right.equalTo(self.view.right);
	}];
	_textEntryBarViewBottomConstraint = [NSLayoutConstraint constraintWithItem:_textEntryBarView
																	 attribute:NSLayoutAttributeBottom
																	 relatedBy:NSLayoutRelationEqual
																		toItem:self.view
																	 attribute:NSLayoutAttributeBottom
																	multiplier:1.0 constant:0.0];
	[self.view addConstraint:_textEntryBarViewBottomConstraint];
	_textEntryBarViewHeightConstraint = [NSLayoutConstraint constraintWithItem:_textEntryBarView
																	 attribute:NSLayoutAttributeHeight
																	 relatedBy:NSLayoutRelationEqual
																		toItem:nil
																	 attribute:NSLayoutAttributeNotAnAttribute
																	multiplier:0.0 constant:44.0];
	[self.view addConstraint:_textEntryBarViewHeightConstraint];

	UIView *line = [UIView new];
    line.layer.borderColor = [UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1.0].CGColor;
    line.layer.borderWidth = IS_RETINA ? 0.25 : 0.5;
	[_textEntryBarView addSubview:line];

	[line makeConstraints:^(MASConstraintMaker *make) {
		make.top.equalTo(_textEntryBarView.top);
		make.left.equalTo(_textEntryBarView.left);
		make.right.equalTo(_textEntryBarView.right);
		make.height.equalTo( @1 );
	}];

	_textView = [UITextView new];
	_textView.backgroundColor = [UIColor colorWithRed:251.0/255.0 green:251.0/255.0 blue:251.0/255.0 alpha:1.0];
	_textView.layer.borderColor = [UIColor colorWithRed:180.0/255.0 green:180.0/255.0 blue:190.0/255.0 alpha:1.0].CGColor;
	_textView.layer.borderWidth = IS_RETINA ? 0.25 : 0.5;
	_textView.layer.cornerRadius = 5.0;
	_textView.delegate = self;
	[_textEntryBarView addSubview:_textView];

    [_textView makeConstraints:^(MASConstraintMaker *make) {
		make.edges.equalTo(_textEntryBarView).insets(UIEdgeInsetsMake(8.0, 8.0, 8.0, 86.0));
	}];

	_translateButton = [UIButton buttonWithType:UIButtonTypeSystem];
	[_translateButton setTitle:@"Translate" forState:UIControlStateNormal];
	_translateButton.titleLabel.font = [UIFont boldSystemFontOfSize:17.0];
	[_translateButton setTitleColor:self.view.tintColor forState:UIControlStateNormal];
	[_translateButton setTitleColor:[UIColor colorWithRed:142.0/255.0 green:142.0/255.0 blue:147.0/255.0 alpha:1.0] forState:UIControlStateDisabled];
	[_translateButton addTarget:self action:@selector(translateAction) forControlEvents:UIControlEventTouchUpInside];
	[_translateButton setEnabled:NO];
	[_textEntryBarView addSubview:_translateButton];

	[_translateButton makeConstraints:^(MASConstraintMaker *make) {
		make.bottom.equalTo(_textEntryBarView.bottom);
		make.width.equalTo(@86.0);
		make.height.equalTo(@42.0);
		make.right.equalTo(_textEntryBarView.right);
	}];
}

#pragma mark - Translate Action

- (void)translateAction {
	_textView.text = [_textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	if ([_textView.text length]) {
		_translateButton.enabled = NO;

		_translatingMessage = [TranslatorHistory MR_createEntity];
		_translatingMessage.originalText = _textView.text;
		_translatingMessage.originalLanguage = _originalTextLanguage;
		_translatingMessage.translatedLanguage = _translatedTextLanguage;
		self.originalText = _textView.text; // Save to async operation
		_translatingMessage.date = [NSDate date];
		[[NSManagedObjectContext MR_contextForCurrentThread] MR_saveOnlySelfAndWait];

		_messages = nil;

		if ([_languageSelectView superview]) {
			[self switchToMessageView];

			dispatch_async(dispatch_get_main_queue(), ^{
				[self askTranslateWithText:_originalText];
			});
		} else {
			dispatch_async(dispatch_get_main_queue(), ^{
				[self askTranslateWithText:_originalText];
			});

			NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:[self.messages count] - 1 inSection:0];
			[_messageTableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationNone];

			[self layoutTextEntryBarViewAnimated:YES ];
		}
		_textView.text = @"";
	}
}

- (void)switchToMessageView {
	[self setupMessageTableView];
	[self rightBarButtonEditButton];

	[_messageTableView reloadData];

	[UIView animateWithDuration:0.3 animations:^{
		UIView *contentsView = [_languageSelectView subviews][0];
		CGRect newFrame = contentsView.frame;
		newFrame = CGRectOffset(newFrame, 0, -newFrame.size.height);
		contentsView.frame = newFrame;
	} completion:^(BOOL finished) {
		[_languageSelectView removeFromSuperview];
		_languageSelectView = nil;
		[_searchResultsTableView removeFromSuperview];
		_searchResultsTableView = nil;
		_sourceLanguageSelectTextField = nil;
		_targetLanguageSelectTextField = nil;
		_searchResultsDelegate = nil;
		_languages = nil;
		_sourceLanguagePicker = nil;
		_targetLanguagePicker = nil;
		_setSourceLanguageButton = nil;
		_setTargetLanguageButton = nil;
		_setTargetLanguageButtonConstraint = nil;
	}];
}

static NSString *const GOOGLE_TRANSLATE_API_V2_URL = @"https://www.googleapis.com/language/translate/v2?key=AIzaSyC_0kMLRm92yGQlDz5fvPOVHwWJiw8EVdY&target=";

- (void)askTranslateWithText:(NSString *)originalText {
	NSMutableString *urlString = [NSMutableString stringWithString:GOOGLE_TRANSLATE_API_V2_URL];
	[urlString appendString:[A3TranslatorLanguage googleCodeFromAppleCode:_translatedTextLanguage]];
//	if ([_originalTextLanguage length] && ![_originalTextLanguage isEqualToString:_translatedTextLanguage]) {
//		[urlString appendString:@"&source="];
//		[urlString appendString:[A3TranslatorLanguage googleCodeFromAppleCode:_originalTextLanguage]];
//	}
	[urlString appendString:@"&q="];
	[urlString appendString:[originalText stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] ];

	NSURL *url = [NSURL URLWithString:urlString];
	FNLOG(@"%@", urlString);

	NSURLRequest *translateRequest = [NSURLRequest requestWithURL:url];

	AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:translateRequest success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
		NSArray *translations = [[JSON objectForKey:@"data"] objectForKey:@"translations"];

		FNLOG(@"Detected Language: %@", [[translations lastObject] objectForKey:@"detectedSourceLanguage"]);
		FNLOG(@"Translated Text: %@", [[translations lastObject] objectForKey:@"translatedText"]);
		NSString *translatedString = [[[translations lastObject] objectForKey:@"translatedText"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
		if (![translatedString length]) {
			translatedString = @"?";
		}

        NSString *detectedLangauge = [A3TranslatorLanguage appleCodeFromGoogleCode:
                                      [[translations lastObject] objectForKey:@"detectedSourceLanguage"] ] ;
        if (![detectedLangauge length]) {
            detectedLangauge = @"en";
        }
		[self addTranslatedString:translatedString detectedSourceLanguage:detectedLangauge];
	} failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        
		FNLOG(@"****************************************************\nFail to translation: %@\n**********************************************************", response.debugDescription);
	}];

	[operation start];
}

- (void)addTranslatedString:(NSString *)translatedString detectedSourceLanguage:(NSString *)sourceLanguage {
	NSMutableString *translated = [NSMutableString stringWithCapacity:400];
	[translated setString:translatedString];

	[translated replaceOccurrencesOfString:@"&#39;" withString:@"'" options:0 range:NSMakeRange(0, [translated length])];

	_translatingMessage.translatedText = translated;
	_translatingMessage.originalLanguage = sourceLanguage;
	_translatingMessage.translatedLanguage = _translatedTextLanguage;
	[[NSManagedObjectContext MR_contextForCurrentThread] MR_saveOnlySelfAndWait];

	if ([sourceLanguage isEqualToString:_originalTextLanguage]) {
		NSIndexPath *lastIndexPath = [NSIndexPath indexPathForRow:[self.messages count] - 1 inSection:0];
		[_messageTableView reloadRowsAtIndexPaths:@[lastIndexPath] withRowAnimation:UITableViewRowAnimationFade];

		[self scrollToBottomAnimated:YES];
	} else {
		// Change title
		_messages = nil;
		_originalTextLanguage = sourceLanguage;
		[self setTitleWithSelectedLanguage];
		// Reload messages
		[_messageTableView reloadData];

		// Scroll to Bottom
		[self scrollToBottomAnimated:NO];
	}
}

#pragma mark - Keyboard Handler

- (void)observeKeyboard {
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillChangeFrameNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardWillShow:(NSNotification *)notification {
	NSDictionary *info = [notification userInfo];
	NSValue *kbFrame = [info objectForKey:UIKeyboardFrameEndUserInfoKey];
	NSTimeInterval animationDuration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
	CGRect keyboardFrame = [kbFrame CGRectValue];

	CGFloat height = IS_IPAD && IS_LANDSCAPE ? keyboardFrame.size.width : keyboardFrame.size.height;
	_keyboardHeight = height;

	[UIView animateWithDuration:animationDuration animations:^{
		_textEntryBarViewBottomConstraint.constant = -height;
		[self.view layoutIfNeeded];
	} completion:^(BOOL finished) {
		if (_messageTableView) {
			[self scrollToBottomAnimated:YES ];
		}
	}];
}

- (void)keyboardWillHide:(NSNotification *)notification {
	NSDictionary *info = [notification userInfo];
	NSTimeInterval animationDuration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];

	[UIView animateWithDuration:animationDuration animations:^{
		_textEntryBarViewBottomConstraint.constant = 0.0;
        
		[self.view layoutIfNeeded];
	}];
	_keyboardHeight = 0.0;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[textField resignFirstResponder];
	return YES;
}

#pragma mark - UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView {
    [self layoutTextEntryBarViewAnimated:YES ];
	[self setTranslateButtonEnabled];
}

- (void)setTranslateButtonEnabled {
	NSString *trimmed = [_textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	[_translateButton setEnabled:[trimmed length] && [_translatedTextLanguage length]];
}

- (void)layoutTextEntryBarViewAnimated:(BOOL)animated {
	FNLOG(@"%f, %f, %f, %f", _textView.contentInset.top, _textView.contentInset.bottom, _textView.contentInset.left, _textView.contentInset.right);
    _textView.contentInset = UIEdgeInsetsMake(-4.0, 0, 0, 0);
	CGRect boundingRect = [_textView.layoutManager usedRectForTextContainer:_textView.textContainer];
    FNLOGRECT(boundingRect);
	_textEntryBarViewHeightConstraint.constant = MAX(boundingRect.size.height, 16.0) + 8.0 * 2.0 + 5.0 * 2.0;
	_textView.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
	[self.view setNeedsLayout];
    
    double delayInSeconds = 0.1;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
		if (_messageTableView) {
			[self scrollToBottomAnimated:animated];
		}
	});
}

#pragma mark - messages

- (NSArray *)messages {
	if (!_messages) {
		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"originalLanguage == %@ AND translatedLanguage == %@", _originalTextLanguage, _translatedTextLanguage];
		_messages = [TranslatorHistory MR_findAllSortedBy:@"date" ascending:YES withPredicate:predicate];
	}
	return _messages;
}

#pragma mark - UITableViewDataSource

- (UITableView *)messageTableView {
	if (!_messageTableView) {
		_messageTableView = [UITableView new];
		_messageTableView.delegate = self;
		_messageTableView.dataSource = self;
		_messageTableView.showsVerticalScrollIndicator = NO;
		_messageTableView.allowsSelection = NO;
		_messageTableView.allowsSelectionDuringEditing = YES;
		_messageTableView.allowsMultipleSelectionDuringEditing = YES;
		_messageTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
		if ([_languageSelectView superview]) {
			[self.view insertSubview:_messageTableView belowSubview:_languageSelectView];
		} else {
			[self.view addSubview:_messageTableView];
		}

		[_messageTableView makeConstraints:^(MASConstraintMaker *make) {
			make.top.equalTo(@64.0);
			make.left.equalTo(self.view.left);
			make.right.equalTo(self.view.right);
			make.bottom.equalTo(_textEntryBarView.top);
		}];
	}
	return _messageTableView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [self.messages count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	TranslatorHistory *data = [self.messages objectAtIndex:indexPath.row];
	return [A3TranslatorMessageCell cellHeightWithData:data bounds:self.view.bounds];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	A3TranslatorMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:kTranslatorMessageCellID forIndexPath:indexPath];
	if (!cell) {
		cell = [[A3TranslatorMessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kTranslatorMessageCellID];
	}
    cell.delegate = self;
	[cell setMessageEntity:self.messages[indexPath.row]];
	return cell;
}

#pragma mark - UITableViewDelegate

- (void)scrollToBottomAnimated:(BOOL)animated {
	if ([self.messages count]) {
		NSIndexPath *lastIndexPath = [NSIndexPath indexPathForRow:[_messages count] - 1 inSection:0];
		[_messageTableView scrollToRowAtIndexPath:lastIndexPath atScrollPosition:UITableViewScrollPositionBottom animated:animated];
	}
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	return indexPath;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
	return indexPath;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSArray *selectedRows = [tableView indexPathsForSelectedRows];
	if ([selectedRows count]) {
		[self setEnabledForAllToolbarButtons:YES];
	}
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSArray *selectedRows = [tableView indexPathsForSelectedRows];
	if (![selectedRows count]) {
		[self setEnabledForAllToolbarButtons:NO];
	}
}


- (void)cell:(A3TranslatorMessageCell *)cell longPressGestureRecognized:(UILongPressGestureRecognizer *)gestureRecognizer {
    _selectedCell = cell;
    _copyOriginalText = gestureRecognizer.view == cell.rightMessageView;

	UIMenuController *menuController = [UIMenuController sharedMenuController];

	CGPoint location = [gestureRecognizer locationInView:self.view];
	CGRect menuLocation = CGRectMake(location.x, location.y, 0, 0);

    if (_keyboardHeight == 0.0) {
        self.inputView = [self myTransparentKeyboard];
    } else {
        self.inputView = nil;
    }

	[self becomeFirstResponder];
    
	[menuController setTargetRect:menuLocation inView:self.view];
	[menuController setMenuVisible:YES animated:YES];

    FNLOGRECT(menuLocation);
}

- (UIView *)myTransparentKeyboard {
    UIView *keyboardView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 0.0, 0.0)];
    keyboardView.backgroundColor = [UIColor clearColor];
    return keyboardView;
}

- (void)copy:(id)sender {
    if (!_selectedCell) return;
    _copyOriginalText ? [self copyOriginalString] : [self copyTranslatedString];
}

// UIMenuController requires that we can become first responder or it won't display
- (BOOL)canBecomeFirstResponder
{
	return !_messageTableView.isEditing;
}

- (void)copyTranslatedString {
	FNLOG();
	if (_selectedCell) {
		NSIndexPath *indexPath = [_messageTableView indexPathForCell:_selectedCell];
		TranslatorHistory *history = self.messages[indexPath.row];
		[UIPasteboard generalPasteboard].string = history.translatedText;
	}
}

- (void)copyOriginalString {
	FNLOG();
	if (_selectedCell) {
		NSIndexPath *indexPath = [_messageTableView indexPathForCell:_selectedCell];
		TranslatorHistory *history = self.messages[indexPath.row];
		[UIPasteboard generalPasteboard].string = history.originalText;
	}
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	if (_messageTableView) {
		[self setupTintColorForMessageView];
	}
}

- (void)setupTintColorForMessageView {
	static NSArray *bubbleColors = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        bubbleColors = @[
                         [UIColor colorWithRed:81.0/255.0 green:192.0/255.0 blue:250.0/255.0 alpha:1.0],
                         [UIColor colorWithRed:74.0/255.0 green:186.0/255.0 blue:251.0/255.0 alpha:1.0],
                         [UIColor colorWithRed:68.0/255.0 green:181.0/255.0 blue:252.0/255.0 alpha:1.0],
                         [UIColor colorWithRed:60.0/255.0 green:174.0/255.0 blue:252.0/255.0 alpha:1.0],
                         [UIColor colorWithRed:52.0/255.0 green:168.0/255.0 blue:252.0/255.0 alpha:1.0],
                         [UIColor colorWithRed:46.0/255.0 green:162.0/255.0 blue:252.0/255.0 alpha:1.0],
                         [UIColor colorWithRed:40.0/255.0 green:157.0/255.0 blue:253.0/255.0 alpha:1.0],
                         [UIColor colorWithRed:32.0/255.0 green:150.0/255.0 blue:252.0/255.0 alpha:1.0],
                         [UIColor colorWithRed:26.0/255.0 green:144.0/255.0 blue:254.0/255.0 alpha:1.0],
                         [UIColor colorWithRed:17.0/255.0 green:138.0/255.0 blue:254.0/255.0 alpha:1.0],
                         [UIColor colorWithRed:12.0/255.0 green:132.0/255.0 blue:255.0/255.0 alpha:1.0],
                         [UIColor colorWithRed:11.0/255.0 green:126.0/255.0 blue:254.0/255.0 alpha:1.0],
                         ];
    });

	NSArray *visibleCells = [_messageTableView visibleCells];
	for (A3TranslatorMessageCell *cell in visibleCells) {
		CGFloat cellPosition = cell.frame.origin.y - _messageTableView.contentOffset.y + _keyboardHeight;
		CGRect screenBounds = [[UIScreen mainScreen] bounds];
		CGFloat screenHeight = (IS_LANDSCAPE ? screenBounds.size.width : screenBounds.size.height) - 64.0;
		NSUInteger positionIndex = MIN( MAX(ceil(cellPosition / screenHeight / (1.0 / [bubbleColors count])), 0) , 11);
//		FNLOG(@"%d, %f, %f, %f", positionIndex, cellPosition, screenHeight, _keyboardHeight);

		cell.rightMessageView.tintColor = bubbleColors[positionIndex];
	}
}

#pragma mark - UITextInputDelegate, it is for holding keyboard on screen.

- (BOOL)hasText {
	return NO;
}

- (void)insertText:(NSString *)text {

}

- (void)deleteBackward {

}

#pragma mark - UIToolbar

- (void)addToolbar {
	_toolbarDeleteButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(deleteActionFromToolbar)];

	[SFKImage setDefaultFont:[UIFont fontWithName:@"appbox" size:33.0]];
	[SFKImage setDefaultColor:[UIColor whiteColor]];
	_toolbarSetFavoriteButton = [[UIBarButtonItem alloc] initWithImage:[SFKImage imageNamed:@"i"] style:UIBarButtonItemStylePlain target:self action:@selector(setFavoriteActionFromToolbar)];

	_toolbarUnsetFavoriteButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"star01"] style:UIBarButtonItemStylePlain target:self action:@selector(unsetFavoriteActionFromToolbar)];

	_toolbarShareButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(shareActionFromToolbar)];

	[self setEnabledForAllToolbarButtons:NO ];

	UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];

	[self.navigationController setToolbarHidden:NO animated:YES];
	[self.navigationController.toolbar setItems:@[_toolbarDeleteButton, space, _toolbarSetFavoriteButton, space, _toolbarUnsetFavoriteButton, space, _toolbarShareButton]
									   animated:YES];
}

- (void)shareActionFromToolbar {
	NSArray *selectedIndexPaths = [_messageTableView indexPathsForSelectedRows];
	NSMutableString *shareMessage = [NSMutableString new];
	for (NSIndexPath *indexPath in selectedIndexPaths) {
		TranslatorHistory *item = _messages[indexPath.row];
		[shareMessage appendString:[NSString stringWithFormat:@"\"%@\" is\n\"%@\"\nin %@", item.originalText, item.translatedText, [A3TranslatorLanguage localizedNameForCode:item.translatedLanguage]]];
	}

	UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:@[shareMessage] applicationActivities:nil];
	[self presentViewController:activityController animated:YES completion:nil];
}

- (void)setFavoriteActionFromToolbar {
	NSArray *selectedIndexPaths = [_messageTableView indexPathsForSelectedRows];
	for (NSIndexPath *indexPath in selectedIndexPaths) {
		TranslatorHistory *item = _messages[indexPath.row];
		[item setFavorite:@YES];

		A3TranslatorMessageCell *cell = (A3TranslatorMessageCell *) [_messageTableView cellForRowAtIndexPath:indexPath];
		[cell changeFavoriteButtonImage];
	}
	[[NSManagedObjectContext MR_contextForCurrentThread] MR_saveOnlySelfAndWait];
}

- (void)unsetFavoriteActionFromToolbar {
	NSArray *selectedIndexPaths = [_messageTableView indexPathsForSelectedRows];
	for (NSIndexPath *indexPath in selectedIndexPaths) {
		TranslatorHistory *item = _messages[indexPath.row];
		[item setFavorite:@NO];

		A3TranslatorMessageCell *cell = (A3TranslatorMessageCell *) [_messageTableView cellForRowAtIndexPath:indexPath];
		[cell changeFavoriteButtonImage];
	}
	[[NSManagedObjectContext MR_contextForCurrentThread] MR_saveOnlySelfAndWait];
}

- (void)deleteActionFromToolbar {
	NSArray *selectedIndexPaths = [_messageTableView indexPathsForSelectedRows];
	for (NSIndexPath *indexPath in selectedIndexPaths) {
		TranslatorHistory *itemToDelete = _messages[indexPath.row];
		[itemToDelete MR_deleteEntity];
	}
	[[NSManagedObjectContext MR_contextForCurrentThread] MR_saveOnlySelfAndWait];

	// Reload messages
	_messages = nil;
	[self messages];

	[_messageTableView deleteRowsAtIndexPaths:selectedIndexPaths withRowAnimation:UITableViewRowAnimationAutomatic];

	[self setEnabledForAllToolbarButtons:NO];
}

- (void)setEnabledForAllToolbarButtons:(BOOL)enabled {
	[_toolbarDeleteButton setEnabled:enabled];
	[_toolbarSetFavoriteButton setEnabled:enabled];
	[_toolbarUnsetFavoriteButton setEnabled:enabled];
	[_toolbarShareButton setEnabled:enabled];
}

@end
