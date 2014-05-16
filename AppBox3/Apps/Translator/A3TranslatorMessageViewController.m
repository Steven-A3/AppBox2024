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
#import "common.h"
#import "AFHTTPRequestOperation.h"
#import "A3TranslatorLanguageTVDelegate.h"
#import "A3TranslatorLanguage.h"
#import "A3LanguagePickerController.h"
#import "UIViewController+A3AppCategory.h"
#import "Reachability.h"
#import "A3AppDelegate.h"
#import "UIViewController+A3Addition.h"
#import "TranslatorGroup.h"
#import "NSString+conversion.h"
#import "TranslatorHistory+manager.h"
#import "UIViewController+tableViewStandardDimension.h"
#import "A3AppDelegate+appearance.h"

static NSString *const kTranslatorDetectLanguageCode = @"Detect";

@interface A3TranslatorMessageViewController () <UITextFieldDelegate, UITextViewDelegate, UITableViewDelegate, UITableViewDataSource, A3TranslatorMessageCellDelegate, UIKeyInput, A3TranslatorLanguageTVDelegateDelegate, A3SearchViewControllerDelegate, UIPopoverControllerDelegate, UIActionSheetDelegate>

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
@property (nonatomic, strong) UIView *networkPrompter;
@property (nonatomic, strong) NSLayoutConstraint *messageTableViewBottomConstraint;
@property (nonatomic, strong) UIView *sameLanguagePrompter;
@property (nonatomic, strong) UIPopoverController *sharePopoverController;

@end

static NSString *const kTranslatorMessageCellID = @"TranslatorMessageCellID";

@implementation A3TranslatorMessageViewController {
	CGFloat _keyboardHeight;
    BOOL    _copyOriginalText;
	BOOL 	_holdFirstResponder;
	NSUInteger _numberOfMessagesBeforeTranslation;
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

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityDidChange:) name:kReachabilityChangedNotification object:nil];

	[self setupBarButtons];
}

- (void)applicationDidEnterBackground:(NSNotification *)notification {
	if ([_messageTableView isEditing]) {
		[self editButtonAction];
	}
}

- (void)reachabilityDidChange:(NSNotification *)notification {
	Reachability *reachability = (Reachability *)[notification object];

	if (reachability.isReachable) {
		[self setTranslateButtonEnabled];

		[self messageTableViewBottomToTextEntryView];
		[self.networkPrompter removeFromSuperview];
		self.networkPrompter = nil;

		[self.view layoutIfNeeded];
	} else {
		[self setTranslateButtonEnabled];
		[self networkPrompter];
	}
}

- (void)cleanUp {
	FNLOG();
	[self removeObserver];
}

- (void)rightBarButtonEditButton {
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editButtonAction)];
}

- (void)contentSizeDidChange:(NSNotification *)notification {
	[_messageTableView reloadData];
	[_searchResultsTableView reloadData];
	[self layoutTextEntryBarViewAnimated:NO];
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
    if (self.isMovingToParentViewController) {
        if (_messageTableView) {
            [self scrollToBottomAnimated:NO ];
            [_textView becomeFirstResponder];
            
            [self.view layoutIfNeeded];
        } else {
            [_targetLanguageSelectTextField becomeFirstResponder];
        }
    }
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
    
    if (self.isMovingToParentViewController) {
        if (_selectItem) {
            NSUInteger index = [self.messages indexOfObject:_selectItem];
            if (index != NSNotFound) {
                [_messageTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
            } else {
                FNLOG(@"Selected Item NOT Found!");
            }
            
            _selectItem = nil;
        } else if ([_languageSelectView superview]) {
            [_targetLanguageSelectTextField becomeFirstResponder];
        }
    } else {
        if (_sourceLanguagePicker) {
            [_sourceLanguageSelectTextField becomeFirstResponder];
        } else if (_targetLanguagePicker) {
            [_targetLanguageSelectTextField becomeFirstResponder];
        }
        _sourceLanguagePicker = nil;
        _targetLanguagePicker = nil;
    }
	if (![[A3AppDelegate instance].reachability isReachable]) {
		[self networkPrompter];
	}
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];

	[self.navigationController setToolbarHidden:YES animated:NO];

	if ([_delegate respondsToSelector:@selector(translatorMessageViewControllerWillDismiss:)]) {
		[_delegate translatorMessageViewControllerWillDismiss:self];
	}

	if (self.isMovingFromParentViewController) {
		UIView *view = [[UIScreen mainScreen] snapshotViewAfterScreenUpdates:NO];
		[self.view addSubview:view];
		[self cleanUp];
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
	[self setupBarButtons];

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

- (void)deleteAllAction:(UIBarButtonItem *)barButtonItem {
	UIActionSheet *askDeleteAll = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Delete All" otherButtonTitles:nil];
	askDeleteAll.tag = 192874;
	[askDeleteAll showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
	if (actionSheet.tag == 192874 && buttonIndex == actionSheet.destructiveButtonIndex) {
		[self deleteAllMessages];
	}
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
    _originalTextLanguage = kTranslatorDetectLanguageCode;
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
    line1.backgroundColor = A3UITableViewSeparatorColor;
	[contentsView addSubview:line1];

	[line1 makeConstraints:^(MASConstraintMaker *make) {
		make.top.equalTo(contentsView.top).with.offset(37.0);
		make.left.equalTo(contentsView.left).with.offset(IS_IPHONE ? 15.0 : 28.0);
		make.right.equalTo(contentsView.right);
		make.height.equalTo( IS_RETINA ? @0.5 : @1.0 );
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
    line2.backgroundColor = A3UITableViewSeparatorColor;
	[contentsView addSubview:line2];

	[line2 makeConstraints:^(MASConstraintMaker *make) {
		make.bottom.equalTo(contentsView.bottom);
		make.left.equalTo(contentsView.left).with.offset(IS_IPHONE ? 15.0 : 28.0);
		make.right.equalTo(contentsView.right);
		make.height.equalTo( IS_RETINA ? @0.5 : @1.0 );
	}];

	_setSourceLanguageButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[_setSourceLanguageButton setImage:[self selectLanguageButtonImage] forState:UIControlStateNormal];
	[_setSourceLanguageButton addTarget:self action:@selector(selectSourceLanguageButtonAction) forControlEvents:UIControlEventTouchUpInside];
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
	[_setTargetLanguageButton addTarget:self action:@selector(selectTranslatedLanguageButtonAction) forControlEvents:UIControlEventTouchUpInside];
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
	A3LanguagePickerController *viewController = [[A3LanguagePickerController alloc] initWithLanguages:[A3TranslatorLanguage findAllWithDetectLanguage:detectLanguage]];
	viewController.delegate = self;
	viewController.selectedCode = detectLanguage ? _originalTextLanguage : _translatedTextLanguage;
	[self presentSubViewController:viewController];
	return viewController;
}

- (void)searchViewController:(UIViewController *)viewController itemSelectedWithItem:(NSString *)selectedItem {
	if (viewController == _sourceLanguagePicker) {
		_originalTextLanguage = selectedItem;
		_sourceLanguageSelectTextField.text = [A3TranslatorLanguage localizedNameForCode:selectedItem];
		[_sourceLanguageSelectTextField becomeFirstResponder];
	} else {
		[self setTranslatedTextLanguage:selectedItem];
		_targetLanguageSelectTextField.text = [A3TranslatorLanguage localizedNameForCode:selectedItem];
		[_targetLanguageSelectTextField becomeFirstResponder];
	}
	[self layoutLanguageSelectView];
}

- (void)languagePickerController:(A3LanguagePickerController *)controller didSelectLanguage:(A3TranslatorLanguage *)language {
	if (controller == _sourceLanguagePicker) {
		_sourceLanguageSelectTextField.text = language.name;
		_originalTextLanguage = language.code;
		[_sourceLanguageSelectTextField becomeFirstResponder];
	} else {
		_targetLanguageSelectTextField.text = language.name;
		[self setTranslatedTextLanguage:language.code];
		[_targetLanguageSelectTextField becomeFirstResponder];
	}
	[self layoutLanguageSelectView];
}

- (void)emptySearchResultTableView{
	_searchResultsDelegate.languages = nil;
	[_searchResultsTableView reloadData];
}

- (void)hideKeyboard {
	[_sourceLanguageSelectTextField resignFirstResponder];
	[_targetLanguageSelectTextField resignFirstResponder];
	[_textView resignFirstResponder];
}

- (void)selectSourceLanguageButtonAction {
	[self hideKeyboard];
	[self emptySearchResultTableView];
	_sourceLanguagePicker = [self presentLanguagePickerControllerWithDetectLanguage:YES ];
}

- (void)selectTranslatedLanguageButtonAction {
	[self hideKeyboard];
	[self emptySearchResultTableView];
	_targetLanguagePicker = [self presentLanguagePickerControllerWithDetectLanguage:NO ];
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
	UITextField *textField = notification.object;
    FNLOG(@"%@", textField.text);
	BOOL includeDetectLanguage = (textField == _sourceLanguageSelectTextField);
	_searchResultsDelegate.languages = [A3TranslatorLanguage filteredArrayWithArray:_languages searchString:textField.text includeDetectLanguage:includeDetectLanguage ];
	[_searchResultsTableView reloadData];
	[_searchResultsTableView setHidden:![_searchResultsDelegate.languages count]];

	NSString *enteredText = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" "]];
	A3TranslatorLanguage *match = [A3TranslatorLanguage findLanguageInArray:_languages searchString:enteredText];
	if (textField == _sourceLanguageSelectTextField) {
		if (match) {
			_sourceLanguageSelectTextField.text = match.name;
			_originalTextLanguage = match.code;
			[self emptySearchResultTableView];
		} else {
			_originalTextLanguage = nil;
		}
	} else if (textField == _targetLanguageSelectTextField) {
		if (match) {
			_targetLanguageSelectTextField.text = match.name;
			[self setTranslatedTextLanguage:match.code];
			[self emptySearchResultTableView];
		} else {
			[self setTranslatedTextLanguage:nil];
		}
	}
	[self layoutLanguageSelectView];

	[self setTranslateButtonEnabled];
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
    [self setTranslateButtonEnabled];
}

- (UIView *)sameLanguagePrompter {
	if (!_sameLanguagePrompter) {
		_sameLanguagePrompter = [UIView new];
		[self.view addSubview:_sameLanguagePrompter];

		[_sameLanguagePrompter makeConstraints:^(MASConstraintMaker *make) {
			make.left.equalTo(self.view.left);
			make.right.equalTo(self.view.right);
			make.top.equalTo(_languageSelectView ? _languageSelectView.bottom : self.view.bottom);
			make.height.equalTo(@30);
		}];

		UILabel *messageLabel = [UILabel new];
		messageLabel.textColor = [UIColor purpleColor];
		if (IS_IPHONE) {
			messageLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
		} else {
			messageLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
		}
		messageLabel.textAlignment = NSTextAlignmentCenter;
		messageLabel.text = @"Please change \"From\" or \"To\" language.";
		[messageLabel sizeToFit];
		[_sameLanguagePrompter addSubview:messageLabel];

		[messageLabel makeConstraints:^(MASConstraintMaker *make) {
			make.edges.equalTo(_networkPrompter);
		}];

		[[messageLabel layer] addAnimation:[self blinkAnimation] forKey:@"opacity"];

		[self.view layoutIfNeeded];
	}
	return _sameLanguagePrompter;
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
	[_translateButton setTitleColor:[[A3AppDelegate instance] themeColor] forState:UIControlStateNormal];
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

/*! self.networkPrompter will connected to _textEntryBarView to determine its position
 * Network availability should be notified to self(viewController) and it must remove from the superview
 * when network is being available.
 */
- (UIView *)networkPrompter {
	if (!_networkPrompter) {
		FNLOG();
		_networkPrompter = [[UIView alloc] initWithFrame:CGRectZero];
        _networkPrompter.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.1];
		[self.view addSubview:_networkPrompter];

		[_networkPrompter makeConstraints:^(MASConstraintMaker *make) {
			make.width.equalTo(self.view.width);
			make.height.equalTo(@35);
			make.centerX.equalTo(self.view.centerX);
			make.bottom.equalTo(_textEntryBarView.top);
		}];

		[self messageTableViewBottomToNetworkPrompter];

		[self.view layoutIfNeeded];

		UILabel *messageLabel = [UILabel new];
		messageLabel.textColor = [UIColor blackColor];
		if (IS_IPHONE) {
			messageLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
		} else {
			messageLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
		}
        messageLabel.textAlignment = NSTextAlignmentCenter;
		messageLabel.text = @"Internet connection is not available.";
		[messageLabel sizeToFit];
		[_networkPrompter addSubview:messageLabel];

		[messageLabel makeConstraints:^(MASConstraintMaker *make) {
			make.edges.equalTo(_networkPrompter);
		}];

		[[messageLabel layer] addAnimation:[self blinkAnimation] forKey:@"opacity"];

        [self.view layoutIfNeeded];
	}
	return _networkPrompter;
}

- (CABasicAnimation *)blinkAnimation {
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    [animation setFromValue:[NSNumber numberWithFloat:1.0]];
    [animation setToValue:[NSNumber numberWithFloat:0.2]];
    [animation setDuration:1.0f];
    [animation setTimingFunction:[CAMediaTimingFunction
                                  functionWithName:kCAMediaTimingFunctionLinear]];
    [animation setAutoreverses:YES];
    [animation setRepeatCount:HUGE_VALF];
    
    return animation;
}

#pragma mark ---------------------------------------
#pragma mark --- Translate Action
#pragma mark ---------------------------------------

- (void)translateAction {
	_textView.text = [_textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	if ([_textView.text length]) {

		_translateButton.enabled = NO;

		TranslatorHistory *firstObject = nil;
		if ([_messages count]) {
			firstObject = [_messages firstObject];
		}
		_translatingMessage = [TranslatorHistory MR_createEntity];
		if (firstObject) {
			_translatingMessage.group = firstObject.group;
		}
		_translatingMessage.originalText = _textView.text;
		self.originalText = _textView.text; // Save to async operation
		_translatingMessage.date = [NSDate date];

		[[[MagicalRecordStack defaultStack] context] MR_saveToPersistentStoreAndWait];

		if ([_languageSelectView superview]) {
			[self switchToMessageView];
		}

		if (firstObject) {
			_messages = nil;
			[self messages];
		} else {
			_messages = @[_translatingMessage];
		}
		_numberOfMessagesBeforeTranslation = [_messages count];

		NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:[self.messages count] - 1 inSection:0];
		[_messageTableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationNone];

		[self layoutTextEntryBarViewAnimated:YES ];

		_textView.text = @"";

		[self setupBarButtons];

		dispatch_async(dispatch_get_main_queue(), ^{
			[self askTranslateWithText:_originalText];
		});
	}
}

- (void)switchToMessageView {
	[self setupMessageTableView];
	[self rightBarButtonEditButton];

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
	if (![_originalTextLanguage isEqualToString:kTranslatorDetectLanguageCode]) {
		[urlString appendString:@"&source="];
		[urlString appendString:[A3TranslatorLanguage googleCodeFromAppleCode:_originalTextLanguage]];
	}
	[urlString appendString:@"&q="];
	[urlString appendString:[originalText stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] ];

	NSURL *url = [NSURL URLWithString:urlString];
	FNLOG(@"%@", urlString);

	NSURLRequest *translateRequest = [NSURLRequest requestWithURL:url];
	AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:translateRequest];
	operation.responseSerializer = [AFJSONResponseSerializer serializer];
	[operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id JSON) {
		NSArray *translations = [[JSON objectForKey:@"data"] objectForKey:@"translations"];

		FNLOG(@"Detected Language: %@", [[translations lastObject] objectForKey:@"detectedSourceLanguage"]);
		FNLOG(@"Translated Text: %@", [[translations lastObject] objectForKey:@"translatedText"]);
		NSString *translatedString = [[[translations lastObject] objectForKey:@"translatedText"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
		if (![translatedString length]) {
			translatedString = @"?";
		}

		NSString *detectedLanguage = [A3TranslatorLanguage appleCodeFromGoogleCode:
				[[translations lastObject] objectForKey:@"detectedSourceLanguage"] ] ;
		if (![detectedLanguage length]) {
			detectedLanguage = [_originalTextLanguage isEqualToString:kTranslatorDetectLanguageCode] ? @"en" : _originalTextLanguage;
		}
		[self addTranslatedString:translatedString detectedSourceLanguage:detectedLanguage];
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		FNLOG(@"****************************************************\nFail to translation: %@\n**********************************************************", operation.response.description);
		FNLOG(@"%@%@%@%@", [error localizedDescription], [error localizedFailureReason], [error localizedRecoveryOptions], [error localizedRecoverySuggestion]);
	}];

	[operation start];
}

- (void)addTranslatedString:(NSString *)translatedString detectedSourceLanguage:(NSString *)detectedLanguage {
	if (_translatingMessage.group && (![_translatingMessage.group.sourceLanguage isEqualToString:detectedLanguage] || ![_translatingMessage.group.targetLanguage isEqualToString:_translatedTextLanguage])) {
		_translatingMessage.group = nil;
	}

	if (!_translatingMessage.group) {
		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"sourceLanguage == %@ AND targetLanguage == %@", detectedLanguage, _translatedTextLanguage];
		NSArray *groupCandidates = [TranslatorGroup MR_findAllWithPredicate:predicate];
		if ([groupCandidates count]) {
			_translatingMessage.group = groupCandidates[0];
		} else if (![groupCandidates count]) {
			TranslatorGroup *newGroup = [TranslatorGroup MR_createEntity];
			newGroup.sourceLanguage = detectedLanguage;
			newGroup.targetLanguage = _translatedTextLanguage;

			NSString *largestInOrder = [TranslatorGroup MR_findLargestValueForAttribute:@"order"];
			NSString *nextLargestInOrder = [NSString orderStringWithOrder:[largestInOrder integerValue] + 100000];
			FNLOG(@"nextLargestInOrder = %@", nextLargestInOrder);

			newGroup.order = nextLargestInOrder;
			_translatingMessage.group = newGroup;
		}
	}

	NSMutableString *translated = [NSMutableString stringWithCapacity:400];
	[translated setString:translatedString];

	[translated replaceOccurrencesOfString:@"&#39;" withString:@"'" options:0 range:NSMakeRange(0, [translated length])];

	_translatingMessage.translatedText = translated;

	[[[MagicalRecordStack defaultStack] context] MR_saveToPersistentStoreAndWait];

	_originalTextLanguage = detectedLanguage;

	// Reload data from persistent store
	_messages = nil;
	[_messageTableView reloadData];

	FNLOG(@"Before %ld : After %ld", (long)_numberOfMessagesBeforeTranslation, (long)[_messages count]);
	if (_numberOfMessagesBeforeTranslation != [_messages count]) {
		[self.messageTableView reloadData];
    } else {
		NSIndexPath *lastIndexPath = [NSIndexPath indexPathForRow:[self.messages count] - 1 inSection:0];
		[_messageTableView reloadRowsAtIndexPaths:@[lastIndexPath] withRowAnimation:UITableViewRowAnimationNone];
	}

	[self scrollToBottomAnimated:NO];
	[self setTitleWithSelectedLanguage];
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

	BOOL sameLanguageSelected = [_originalTextLanguage isEqualToString:_translatedTextLanguage];

	[_translateButton setEnabled:
			[[Reachability reachabilityWithHostname:@"www.google.com"] isReachable] &&
					[trimmed length] &&
					[_translatedTextLanguage length] &&
					_originalTextLanguage != nil &&
					!sameLanguageSelected ];

	if (_languageSelectView) {
		if (sameLanguageSelected) {
			[self sameLanguagePrompter];
		} else if (_sameLanguagePrompter) {
			[_sameLanguagePrompter removeFromSuperview];
			_sameLanguagePrompter = nil;
		}
	}
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
		}];
		[self messageTableViewBottomToTextEntryView];
	}
	return _messageTableView;
}

- (void)messageTableViewBottomToTextEntryView {
    if (!_messageTableView) return;
	if (_messageTableViewBottomConstraint) {
		[self.view removeConstraint:_messageTableViewBottomConstraint];
		_messageTableViewBottomConstraint = nil;
	}
	_messageTableViewBottomConstraint = [NSLayoutConstraint constraintWithItem:_messageTableView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:_textEntryBarView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0];
	[self.view addConstraint:_messageTableViewBottomConstraint];
}

- (void)messageTableViewBottomToNetworkPrompter {
    if (!_messageTableView) return;
	if (_messageTableViewBottomConstraint) {
		[self.view removeConstraint:_messageTableViewBottomConstraint];
		_messageTableViewBottomConstraint = nil;
	}
	_messageTableViewBottomConstraint = [NSLayoutConstraint constraintWithItem:_messageTableView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:_networkPrompter attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0];
	[self.view addConstraint:_messageTableViewBottomConstraint];
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

	CGPoint location;
	CGRect frame;
	if (_copyOriginalText) {
		frame = cell.rightMessageView.frame;
	} else {
		frame = cell.leftMessageView.frame;
	}
	location.x = frame.origin.x + frame.size.width / 2.0;
	location.y = frame.origin.y;
	location = [self.view convertPoint:location fromView:cell];
	CGRect menuLocation = CGRectMake(location.x, location.y, 0, 0);

    if (_keyboardHeight == 0.0) {
        self.inputView = [self myTransparentKeyboard];
    } else {
        self.inputView = nil;
    }

	_holdFirstResponder = YES;
	[self becomeFirstResponder];
    
	[menuController setTargetRect:menuLocation inView:self.view];
	[menuController setMenuVisible:YES animated:YES];

	_holdFirstResponder = NO;
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
    FNLOG();
	return !_messageTableView.isEditing;
}

- (BOOL)becomeFirstResponder {
	[super becomeFirstResponder];
	if (!_holdFirstResponder) {
		[self resignFirstResponder];
	}
	return YES;
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
	CGFloat red, green, blue, alpha;
	[self.view.tintColor getRed:&red green:&green blue:&blue alpha:&alpha];

	NSArray *visibleCells = [_messageTableView visibleCells];
	CGFloat canvasHeight = _messageTableView.bounds.size.height;

	FNLOG(@"contentSize.height %f", _messageTableView.contentSize.height);
	FNLOG(@"contentOffset.y %f", _messageTableView.contentOffset.y);
	FNLOG(@"contentInset.top %f", _messageTableView.contentInset.top);
	FNLOG(@"contentInset.bottom %f", _messageTableView.contentInset.bottom);
	FNLOG(@"bounds.size.height %f", _messageTableView.bounds.size.height);

	for (A3TranslatorMessageCell *cell in visibleCells) {
		CGFloat cellPosition = cell.frame.origin.y + cell.frame.size.height - _messageTableView.contentOffset.y;

		alpha = MIN((cellPosition / (canvasHeight * 2.0)) + 0.5, 1.0);
		FNLOG(@"Position %f, Height %f, result %f", cellPosition, canvasHeight, alpha);

		cell.rightMessageView.tintColor = [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
	}
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
	[self resignFirstResponder];
	[_textView resignFirstResponder];
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

	_toolbarSetFavoriteButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"star01_on"] style:UIBarButtonItemStylePlain target:self action:@selector(setFavoriteActionFromToolbar)];

	_toolbarUnsetFavoriteButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"star01"] style:UIBarButtonItemStylePlain target:self action:@selector(unsetFavoriteActionFromToolbar)];

	_toolbarShareButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(shareActionFromToolbar:)];

	[self setEnabledForAllToolbarButtons:NO ];

	UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];

	[self.navigationController setToolbarHidden:NO animated:YES];
	[self.navigationController.toolbar setItems:@[_toolbarDeleteButton, space, _toolbarSetFavoriteButton, space, _toolbarUnsetFavoriteButton, space, _toolbarShareButton]
									   animated:YES];
}

- (void)shareActionFromToolbar:(UIBarButtonItem *)barButtonItem {
	NSArray *selectedIndexPaths = [_messageTableView indexPathsForSelectedRows];
	NSMutableString *shareMessage = [NSMutableString new];
	for (NSIndexPath *indexPath in selectedIndexPaths) {
		TranslatorHistory *item = _messages[indexPath.row];
		NSString *translatedLanguage = [A3TranslatorLanguage localizedNameForCode:item.group.targetLanguage];
		if ([item.originalText length] && [item.translatedText length] && [translatedLanguage length]) {
			[shareMessage appendString:[NSString stringWithFormat:@"\"%@\" is\n\"%@\"\nin %@", item.originalText, item.translatedText, translatedLanguage]];
		}
	}

	_sharePopoverController = [self presentActivityViewControllerWithActivityItems:@[shareMessage] fromBarButtonItem:barButtonItem];
	_sharePopoverController.delegate = self;
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
	_sharePopoverController = nil;
}

- (void)setFavoriteActionFromToolbar {
	NSArray *selectedIndexPaths = [_messageTableView indexPathsForSelectedRows];
	for (NSIndexPath *indexPath in selectedIndexPaths) {
		TranslatorHistory *item = _messages[indexPath.row];
		[item setAsFavoriteMember:YES];

		A3TranslatorMessageCell *cell = (A3TranslatorMessageCell *) [_messageTableView cellForRowAtIndexPath:indexPath];
		[cell changeFavoriteButtonImage];
	}
	[[[MagicalRecordStack defaultStack] context] MR_saveToPersistentStoreAndWait];
}

- (void)unsetFavoriteActionFromToolbar {
	NSArray *selectedIndexPaths = [_messageTableView indexPathsForSelectedRows];
	for (NSIndexPath *indexPath in selectedIndexPaths) {
		TranslatorHistory *item = _messages[indexPath.row];
		[item setAsFavoriteMember:NO];

		A3TranslatorMessageCell *cell = (A3TranslatorMessageCell *) [_messageTableView cellForRowAtIndexPath:indexPath];
		[cell changeFavoriteButtonImage];
	}
	[[[MagicalRecordStack defaultStack] context] MR_saveToPersistentStoreAndWait];
}

- (void)deleteActionFromToolbar {
	NSArray *selectedIndexPaths = [_messageTableView indexPathsForSelectedRows];
	for (NSIndexPath *indexPath in selectedIndexPaths) {
		TranslatorHistory *itemToDelete = _messages[indexPath.row];
		[itemToDelete MR_deleteEntity];
	}
	[[[MagicalRecordStack defaultStack] context] MR_saveToPersistentStoreAndWait];

	// Reload messages
	_messages = nil;
	[self messages];

	[_messageTableView deleteRowsAtIndexPaths:selectedIndexPaths withRowAnimation:UITableViewRowAnimationAutomatic];

	[self setEnabledForAllToolbarButtons:NO];

	[self setupBarButtons];
}

- (void)setEnabledForAllToolbarButtons:(BOOL)enabled {
	[_toolbarDeleteButton setEnabled:enabled];
	[_toolbarSetFavoriteButton setEnabled:enabled];
	[_toolbarUnsetFavoriteButton setEnabled:enabled];
	[_toolbarShareButton setEnabled:enabled];
}

#pragma mark - messages

- (NSPredicate *)predicateForMessages {
	return [NSPredicate predicateWithFormat:@"group.sourceLanguage == %@ AND group.targetLanguage == %@", _originalTextLanguage, _translatedTextLanguage];
}

- (NSArray *)messages {
	if (!_messages) {
		_messages = [TranslatorHistory MR_findAllSortedBy:@"date" ascending:YES withPredicate:[self predicateForMessages]];
	}
	return _messages;
}

- (void)deleteAllMessages {
	[TranslatorHistory MR_deleteAllMatchingPredicate:[self predicateForMessages]];

	[[[MagicalRecordStack defaultStack] context] MR_saveToPersistentStoreAndWait];

	_messages = nil;
	[self messages];

	[self.messageTableView reloadData];

	[self.messageTableView setEditing:NO];
	[self setupBarButtons];
}

- (void)setupBarButtons {
	if (self.messageTableView.isEditing) {
		if ([self.messages count]) {
			self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Delete All" style:UIBarButtonItemStylePlain target:self action:@selector(deleteAllAction:)];
		} else {
			self.navigationItem.leftBarButtonItem = nil;
			self.navigationItem.hidesBackButton = YES;
		}
		[self rightBarButtonDoneButton];
	} else {
		self.navigationItem.leftBarButtonItem = nil;
		self.navigationItem.hidesBackButton = NO;
	}
	if ([_messageTableView isEditing]) {
		if ([self.messages count]) {
			self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Delete All" style:UIBarButtonItemStylePlain target:self action:@selector(deleteAllAction:)];
		}
		self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(editButtonAction)];
		self.navigationItem.hidesBackButton = YES;
	} else {
		self.navigationItem.leftBarButtonItem = nil;
		[self rightBarButtonEditButton];
		self.navigationItem.hidesBackButton = NO;
	}
}

- (void)doneButtonAction:(UIBarButtonItem *)button {
	[self editButtonAction];
}

@end
