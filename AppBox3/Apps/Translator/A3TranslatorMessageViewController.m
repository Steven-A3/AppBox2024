//
//  A3TranslatorMessageViewController.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 8/14/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3TranslatorMessageViewController.h"
#import "TranslatorHistory.h"
#import "A3TranslatorMessageCell.h"
#import "AFHTTPRequestOperation.h"
#import "A3TranslatorLanguageTVDelegate.h"
#import "A3TranslatorLanguage.h"
#import "A3LanguagePickerController.h"
#import "UIViewController+NumberKeyboard.h"
#import "Reachability.h"
#import "A3AppDelegate.h"
#import "UIViewController+A3Addition.h"
#import "TranslatorGroup.h"
#import "TranslatorHistory+manager.h"
#import "UIViewController+tableViewStandardDimension.h"
#import "TranslatorGroup+manage.h"
#import "UIViewController+iPad_rightSideView.h"
#import "NSString+conversion.h"
#import "TranslatorFavorite.h"
#import "NSManagedObject+extension.h"
#import "NSManagedObjectContext+extension.h"
#import "A3SyncManager.h"
#import "A3UIDevice.h"
#import "A3UserDefaults+A3Addition.h"

static NSString *const kTranslatorDetectLanguageCode = @"Detect";
static NSString *const A3AnimationKeyOpacity = @"opacity";
const NSInteger kTranslatorAlertViewType_ToolBarDelete = 1;
const NSInteger kTranslatorAlertViewType_DeleteAll = 2;

@interface A3TranslatorMessageViewController ()
		<UITextFieldDelegate, UITextViewDelegate, UITableViewDelegate, UITableViewDataSource,
		A3TranslatorMessageCellDelegate, UIKeyInput, A3TranslatorLanguageTVDelegateDelegate,
		A3SearchViewControllerDelegate, UIPopoverControllerDelegate, UIActionSheetDelegate,
		UIActivityItemSource, A3ViewControllerProtocol>

// Language Select
@property (nonatomic, strong) UIView *languageSelectView;
@property (nonatomic, strong) UITextField *sourceLanguageSelectTextField;
@property (nonatomic, strong) UITextField *targetLanguageSelectTextField;
@property (nonatomic, strong) UIView *textEntryBarView;
@property (nonatomic, strong) UIButton *translateButton;
@property (nonatomic, strong) UITextView *textView;
@property (nonatomic, strong) MASConstraint *textEntryBarViewBottomConstraint;
@property (nonatomic, strong) MASConstraint *textEntryBarViewHeightConstraint;
@property (nonatomic, strong) UITableView *messageTableView;
@property (nonatomic, strong) NSArray *messages;
@property (nonatomic, copy) NSString *originalText;
@property (nonatomic, weak) A3TranslatorMessageCell *selectedCell;
@property (nonatomic, readwrite, retain) UIView *inputView;
@property (nonatomic, strong) UITableView *searchResultsTableView;
@property (nonatomic, strong) A3TranslatorLanguageTVDelegate *searchResultsDelegate;
@property (nonatomic, strong) NSArray *languages;
@property (nonatomic, strong) A3LanguagePickerController *sourceLanguagePicker;
@property (nonatomic, strong) A3LanguagePickerController *targetLanguagePicker;
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
@property (nonatomic, strong) UINavigationController *modalNavigationController;
@property (nonatomic, strong) A3LanguagePickerController *languagePickerController;
@property (nonatomic, strong) A3TranslatorLanguage *languageListManager;

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
		self.title = NSLocalizedString(@"New Translator", @"New Translator");

        _languages = [self.languageListManager translationLanguageAddingDetectLanguage:YES];
        
		[self addLanguageSelectView];
		[self searchResultsTableView];
	}

	[self layoutTextEntryBarViewAnimated:NO ];

	[self.view layoutIfNeeded];

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityDidChange:) name:kReachabilityChangedNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillChangeFrameNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cloudStoreDidImport) name:A3NotificationCloudCoreDataStoreDidImport object:nil];
	[self registerContentSizeCategoryDidChangeNotification];

	[self setupBarButtons];
}

- (void)cloudStoreDidImport {
	if (![_translatedTextLanguage length]) return;

	_messages = nil;
	[_messageTableView reloadData];
}

- (void)removeObserver {
	[self removeContentSizeCategoryDidChangeNotification];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:A3NotificationCloudCoreDataStoreDidImport object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
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

		FNLOG();
		[self removeObserver];
	}
}

- (void)dealloc {
	[self removeObserver];
}

- (void)willMoveToParentViewController:(UIViewController *)parent {
	[super willMoveToParentViewController:parent];

	if (!parent) {
		[_sourceLanguageSelectTextField resignFirstResponder];
		[_targetLanguageSelectTextField resignFirstResponder];
	}
}

- (void)applicationDidEnterBackground:(NSNotification *)notification {
	if ([_messageTableView isEditing]) {
		[self editButtonAction];
	}
	[self resignFirstResponder];
}

- (BOOL)resignFirstResponder {
	[_sourceLanguageSelectTextField resignFirstResponder];
	[_targetLanguageSelectTextField resignFirstResponder];
	[_textView resignFirstResponder];
	return [super resignFirstResponder];
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

- (A3TranslatorLanguage *)languageListManager {
    if (!_languageListManager) {
        _languageListManager = [A3TranslatorLanguage new];
    }
    return _languageListManager;
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
	self.title = [NSString stringWithFormat:NSLocalizedString(@"%@ to %@", @"%@ to %@"),
											[self.languageListManager localizedNameForCode:_originalTextLanguage],
											[self.languageListManager localizedNameForCode:_translatedTextLanguage]];
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

	FNLOG(@"%ld, %ld, %ld, %ld", (long)[self isMovingToParentViewController], (long)[self isMovingFromParentViewController], (long)[self isBeingPresented], (long)[self isBeingDismissed]);
    if ([self isMovingToParentViewController]) {
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

	FNLOG(@"%ld, %ld, %ld, %ld", (long)[self isMovingToParentViewController], (long)[self isMovingFromParentViewController], (long)[self isBeingPresented], (long)[self isBeingDismissed]);
    if ([self isMovingToParentViewController]) {
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
	if ([self.navigationController.navigationBar isHidden]) {
		[self.navigationController setNavigationBarHidden:NO animated:NO];
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
    if (IS_IPAD) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Delete All", @"Delete All") style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
            [self deleteAllMessages];
        }]];
        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"Cancel") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [alertController dismissViewControllerAnimated:YES completion:NULL];
        }]];
        alertController.modalInPopover = UIModalPresentationPopover;
        
        UIPopoverPresentationController *popover = alertController.popoverPresentationController;
        popover.barButtonItem = barButtonItem;
        popover.permittedArrowDirections = UIPopoverArrowDirectionAny;
        
        [self presentViewController:alertController animated:YES completion:NULL];
    }
    else
    {
        [self showDeleteAllActionSheet];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    [self setFirstActionSheet:nil];
    
	if (actionSheet.tag == 192874 && buttonIndex == actionSheet.destructiveButtonIndex) {
		[self deleteAllMessages];
	}
    else if (actionSheet.tag == kTranslatorAlertViewType_ToolBarDelete && buttonIndex == actionSheet.destructiveButtonIndex) {
        [self deleteSelectedMessageItems];
    }
}

#pragma mark ActionSheet Rotation Related
- (void)rotateFirstActionSheet {
    NSInteger currentActionSheetTag = [self.firstActionSheet tag];
    [super rotateFirstActionSheet];
    [self setFirstActionSheet:nil];
    
    [self showActionSheetAdaptivelyInViewWithTag:currentActionSheetTag];
}

- (void)showActionSheetAdaptivelyInViewWithTag:(NSInteger)actionSheetTag {
    switch (actionSheetTag) {
        case 192874:
            [self showDeleteAllActionSheet];
            break;
            
        case kTranslatorAlertViewType_ToolBarDelete:
            [self showDeleteTranslationActionSheet];
            break;
            
        default:
            break;
    }
}

- (void)showDeleteAllActionSheet {
    UIActionSheet *askDeleteAll = [[UIActionSheet alloc] initWithTitle:nil
                                                              delegate:self
                                                     cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel")
                                                destructiveButtonTitle:NSLocalizedString(@"Delete All", @"Delete All")
                                                     otherButtonTitles:nil];
    askDeleteAll.tag = 192874;
    [askDeleteAll showInView:self.view];
    [self setFirstActionSheet:askDeleteAll];
}

- (void)showDeleteTranslationActionSheet {
    UIActionSheet *askDeleteAll = [[UIActionSheet alloc] initWithTitle:nil
                                                              delegate:self
                                                     cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel")
                                                destructiveButtonTitle:[NSString stringWithFormat:NSLocalizedStringFromTable(@"%ld Delete Translation", @"StringsDict", nil), [_messageTableView.indexPathsForSelectedRows count]]
                                                     otherButtonTitles:nil];
    askDeleteAll.tag = kTranslatorAlertViewType_ToolBarDelete;
    [askDeleteAll showInView:self.view];
    [self setFirstActionSheet:askDeleteAll];
}

#pragma mark - Language Select View

- (void)addLanguageSelectView {
    FNLOG();
    
	_languageSelectView = [UIView new];
	_languageSelectView.clipsToBounds = YES;
	[self.view addSubview:_languageSelectView];

    CGFloat verticalOffset = 0;
    UIEdgeInsets safeAreaInsets = [[[UIApplication sharedApplication] keyWindow] safeAreaInsets];
    verticalOffset = safeAreaInsets.top - 20;
	[_languageSelectView makeConstraints:^(MASConstraintMaker *make) {
		make.top.equalTo(@(64.0 + verticalOffset));
		make.width.equalTo(self.view.width);
		make.height.equalTo(@74.0);
		make.centerX.equalTo(self.view.centerX);
	}];

	UIView *contentsView = [UIView new];
	[_languageSelectView addSubview:contentsView];

	[contentsView makeConstraints:^(MASConstraintMaker *make) {
		make.edges.equalTo(self.languageSelectView);
	}];

	_sourceLanguageSelectTextField = [self textFieldForLanguageSelect];
	_sourceLanguageSelectTextField.text = NSLocalizedString(@"Detect Language", @"Detect Language");
    _originalTextLanguage = kTranslatorDetectLanguageCode;
	UILabel *sourceLanguageLeftLabel = [self leftLabel];
	sourceLanguageLeftLabel.text = NSLocalizedString(@"From: ", @"From: ");
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
		make.height.equalTo(@(1.0 / [[UIScreen mainScreen] scale]));
	}];

	_targetLanguageSelectTextField = [self textFieldForLanguageSelect];
	UILabel *targetLanguageLeftLabel = [self leftLabel];
	targetLanguageLeftLabel.text = NSLocalizedString(@"To: ", @"To: ");
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
    
	A3LanguagePickerController *viewController = [[A3LanguagePickerController alloc] initWithLanguages:[self.languageListManager translationLanguageAddingDetectLanguage:detectLanguage]];
	viewController.delegate = self;
    
    NSMutableArray *selectedCodes = [NSMutableArray new];
    if (_originalTextLanguage) {
        [selectedCodes addObject:_originalTextLanguage];
    }
    if (_translatedTextLanguage) {
        [selectedCodes addObject:_translatedTextLanguage];
    }
    
    viewController.selectedCodes = selectedCodes;
    viewController.currentCode = detectLanguage ? _originalTextLanguage : _translatedTextLanguage;


	if (IS_IPHONE) {
		_modalNavigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
		[self presentViewController:_modalNavigationController animated:YES completion:NULL];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(languagePickerControllerDidDismiss:) name:A3NotificationChildViewControllerDidDismiss object:viewController];
	} else {
        [[[A3AppDelegate instance] rootViewController_iPad] presentRightSideViewController:viewController toViewController:nil];
	}
	return viewController;
}

- (void)languagePickerControllerDidDismiss:(NSNotification *)notification {
	if (notification.object == _modalNavigationController.childViewControllers[0]) {
		_modalNavigationController = nil;
	}
}

- (void)searchViewController:(UIViewController *)viewController itemSelectedWithItem:(NSString *)selectedItem {
	if (viewController == _sourceLanguagePicker) {
		_originalTextLanguage = selectedItem;
		_sourceLanguageSelectTextField.text = [self.languageListManager localizedNameForCode:selectedItem];
		[_sourceLanguageSelectTextField becomeFirstResponder];
	} else {
		[self setTranslatedTextLanguage:selectedItem];
		_targetLanguageSelectTextField.text = [self.languageListManager localizedNameForCode:selectedItem];
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

	NSString *enteredText = [textField.text stringByTrimmingSpaceCharacters];
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
	FNLOG();
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
	[self layoutLanguageSelectView];
}

/*! This will initialize a tableview and add it to self.view with layout information.
 */
- (UITableView *)searchResultsTableView {
	if (!_searchResultsTableView) {
		_searchResultsTableView = [UITableView new];

		[self.view addSubview:_searchResultsTableView];

        CGFloat verticalOffset = 0;
        UIEdgeInsets safeAreaInsets = [[[UIApplication sharedApplication] keyWindow] safeAreaInsets];
        verticalOffset = safeAreaInsets.top - 20;
        
		[_searchResultsTableView makeConstraints:^(MASConstraintMaker *make) {
			make.top.equalTo(self.view.top).with.offset(64 + 74 + verticalOffset);
			make.left.equalTo(self.view.left);
			make.right.equalTo(self.view.right);
			make.bottom.equalTo(self.textEntryBarView.top);
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
		messageLabel.text = NSLocalizedString(@"Please change \"From\" or \"To\" language.", @"Please change \"From\" or \"To\" language.");
		[messageLabel sizeToFit];
		[_sameLanguagePrompter addSubview:messageLabel];

		[messageLabel makeConstraints:^(MASConstraintMaker *make) {
			make.edges.equalTo(_networkPrompter);
		}];

		[[messageLabel layer] addAnimation:[self blinkAnimation] forKey:A3AnimationKeyOpacity];

		[self.view layoutIfNeeded];
	}
	return _sameLanguagePrompter;
}

#pragma mark - Message Text Entry View

- (void)addTextEntryView {
	_textEntryBarView = [UIView new];
	_textEntryBarView.backgroundColor = [UIColor colorWithRed:247.0/255.0 green:247.0/255.0 blue:247.0/255.0 alpha:1.0];
	[self.view addSubview:_textEntryBarView];

    CGFloat verticalOffset = 0;
    UIEdgeInsets safeAreaInsets = [[[UIApplication sharedApplication] keyWindow] safeAreaInsets];
    verticalOffset = safeAreaInsets.bottom;
    if (safeAreaInsets.top > 20) {
        UIView *bottomView = [UIView new];
        bottomView.backgroundColor = _textEntryBarView.backgroundColor;
        [_textEntryBarView addSubview:bottomView];
        
        [bottomView makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.textEntryBarView.bottom);
            make.left.equalTo(self.textEntryBarView.left);
            make.right.equalTo(self.textEntryBarView.right);
            make.bottom.equalTo(self.view.bottom);
        }];
    }
	[_textEntryBarView makeConstraints:^(MASConstraintMaker *make) {
		make.left.equalTo(self.view.left);
		make.right.equalTo(self.view.right);
        self.textEntryBarViewBottomConstraint = make.bottom.equalTo(self.view.bottom);
        self.textEntryBarViewHeightConstraint = make.height.equalTo(@(44 + verticalOffset));
	}];

	UIView *line = [UIView new];
    line.layer.borderColor = [UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1.0].CGColor;
    line.layer.borderWidth = IS_RETINA ? 0.25 : 0.5;
	[_textEntryBarView addSubview:line];

	[line makeConstraints:^(MASConstraintMaker *make) {
		make.top.equalTo(self.textEntryBarView.top);
		make.left.equalTo(self.textEntryBarView.left);
		make.right.equalTo(self.textEntryBarView.right);
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
		make.edges.equalTo(self.textEntryBarView).insets(UIEdgeInsetsMake(8.0, 8.0, 8.0, IS_IPHONE ? 88.0 : 110.0 ));
	}];

	_translateButton = [UIButton buttonWithType:UIButtonTypeSystem];
	[_translateButton setTitle:NSLocalizedString(@"Translate", @"Translate") forState:UIControlStateNormal];
	_translateButton.titleLabel.font = [UIFont boldSystemFontOfSize:17.0];
	_translateButton.titleLabel.adjustsFontSizeToFitWidth = YES;
	_translateButton.titleLabel.minimumScaleFactor = 0.5;
	[_translateButton setTitleColor:[[A3UserDefaults standardUserDefaults] themeColor] forState:UIControlStateNormal];
	[_translateButton setTitleColor:[UIColor colorWithRed:142.0/255.0 green:142.0/255.0 blue:147.0/255.0 alpha:1.0] forState:UIControlStateDisabled];
	[_translateButton addTarget:self action:@selector(translateAction) forControlEvents:UIControlEventTouchUpInside];
	[_translateButton setEnabled:NO];
	[_textEntryBarView addSubview:_translateButton];

	[_translateButton makeConstraints:^(MASConstraintMaker *make) {
		make.bottom.equalTo(self.textEntryBarView.bottom);
		make.width.equalTo(IS_IPHONE ? @86.0 : @110.0);
		make.height.equalTo(@42.0);
		make.right.equalTo(self.textEntryBarView.right);
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
			make.bottom.equalTo(self.textEntryBarView.top);
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
		messageLabel.text = NSLocalizedString(@"Internet connection is not available.", @"Internet connection is not available.");
		[messageLabel sizeToFit];
		[_networkPrompter addSubview:messageLabel];

		[messageLabel makeConstraints:^(MASConstraintMaker *make) {
			make.edges.equalTo(self.networkPrompter);
		}];

		[[messageLabel layer] addAnimation:[self blinkAnimation] forKey:A3AnimationKeyOpacity];

        [self.view layoutIfNeeded];
	}
	return _networkPrompter;
}

- (CABasicAnimation *)blinkAnimation {
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:A3AnimationKeyOpacity];
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
        NSManagedObjectContext *context = A3SyncManager.sharedSyncManager.persistentContainer.viewContext;
        _translatingMessage = [[TranslatorHistory alloc] initWithContext:context];
		_translatingMessage.uniqueID = [[NSUUID UUID] UUIDString];
		_translatingMessage.updateDate = [NSDate date];
		if (firstObject) {
			_translatingMessage.groupID = firstObject.groupID;
		}
		_translatingMessage.originalText = _textView.text;
		self.originalText = _textView.text; // Save to async operation

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
			[self askTranslateWithText:self.originalText];
		});
        [context saveContext];
	}
}

- (void)switchToMessageView {
	[self setupMessageTableView];
	[self rightBarButtonEditButton];

	[UIView animateWithDuration:0.3 animations:^{
		UIView *contentsView = [self.languageSelectView subviews][0];
		CGRect newFrame = contentsView.frame;
		newFrame = CGRectOffset(newFrame, 0, -newFrame.size.height);
		contentsView.frame = newFrame;
	} completion:^(BOOL finished) {
		[self.languageSelectView removeFromSuperview];
        self.languageSelectView = nil;
		[self.searchResultsTableView removeFromSuperview];
        self.searchResultsTableView = nil;
        self.sourceLanguageSelectTextField = nil;
        self.targetLanguageSelectTextField = nil;
        self.searchResultsDelegate = nil;
        self.languages = nil;
        self.sourceLanguagePicker = nil;
        self.targetLanguagePicker = nil;
        self.setSourceLanguageButton = nil;
        self.setTargetLanguageButton = nil;
        self.setTargetLanguageButtonConstraint = nil;
	}];
}

static NSString *const AZURE_TRANSLATE_API_V3_URL = @"https://api.cognitive.microsofttranslator.com/translate?api-version=3.0&to=";

- (void)askTranslateWithText:(NSString *)originalText {
    NSMutableString *urlString = [NSMutableString stringWithString:AZURE_TRANSLATE_API_V3_URL];
    [urlString appendString:_translatedTextLanguage];
    if (![_originalTextLanguage isEqualToString:@"Detect"]) {
        [urlString appendFormat:@"&from=%@", _originalTextLanguage];
    }
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"POST"];
    [request setValue:[self.languageListManager microsoftAzureSubscriptionKey] forHTTPHeaderField:@"Ocp-Apim-Subscription-Key"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:@[@{@"Text":originalText}] options:NSJSONWritingPrettyPrinted error:&error];
    
    [request setHTTPBody:jsonData];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            FNLOG(@"%@", error.localizedDescription);
            return;
        }
        NSError *parseError;
        NSArray *jsonData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&parseError];
        if (parseError) {
            FNLOG(@"%@", parseError.localizedDescription);
            return;
        }
        NSDictionary *result = jsonData[0];
        
        NSString *detectedLanguage = _originalTextLanguage;
        if (result[@"detectedLanguage"]) {
            detectedLanguage = result[@"detectedLanguage"][@"language"];
        }
        NSString *translatedString = result[@"translations"][0][@"text"];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self addTranslatedString:translatedString detectedSourceLanguage:detectedLanguage];
        });

    }];
    [task resume];
}

- (void)addTranslatedString:(NSString *)translatedString detectedSourceLanguage:(NSString *)detectedLanguage {
	TranslatorGroup *group = [TranslatorGroup findFirstByAttribute:@"uniqueID" withValue:_translatingMessage.groupID];
	if (group && (![group.sourceLanguage isEqualToString:detectedLanguage] || ![group.targetLanguage isEqualToString:_translatedTextLanguage])) {
		_translatingMessage.groupID = nil;
	}

    NSManagedObjectContext *context = A3SyncManager.sharedSyncManager.persistentContainer.viewContext;
	if (!group) {
		NSString *uniqueID = [NSString stringWithFormat:@"%@-%@", detectedLanguage, _translatedTextLanguage];
		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"uniqueID == %@", uniqueID];
		TranslatorGroup *groupCandidate = [TranslatorGroup findFirstWithPredicate:predicate];
		if (groupCandidate) {
			_translatingMessage.groupID = groupCandidate.uniqueID;
		} else if (!groupCandidate) {
            TranslatorGroup *newGroup = [[TranslatorGroup alloc] initWithContext:context];
			newGroup.uniqueID = uniqueID;
			newGroup.updateDate = [NSDate date];
			[newGroup setupOrder];
			newGroup.sourceLanguage = detectedLanguage;
			newGroup.targetLanguage = _translatedTextLanguage;

			_translatingMessage.groupID = newGroup.uniqueID;
		}
	}

	NSMutableString *translated = [NSMutableString stringWithCapacity:400];
	[translated setString:translatedString];

	[translated replaceOccurrencesOfString:@"&#39;" withString:@"'" options:0 range:NSMakeRange(0, [translated length])];

	_translatingMessage.translatedText = translated;

    [context saveContext];

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

- (void)keyboardWillShow:(NSNotification *)notification {
	NSDictionary *info = [notification userInfo];
	NSValue *kbFrame = [info objectForKey:UIKeyboardFrameEndUserInfoKey];
	NSTimeInterval animationDuration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
	CGRect keyboardFrame = [kbFrame CGRectValue];

	CGFloat height = IS_IPAD && [UIWindow interfaceOrientationIsLandscape] ? keyboardFrame.size.width : keyboardFrame.size.height;
    height = keyboardFrame.size.height;
    
	_keyboardHeight = height;

	[UIView animateWithDuration:animationDuration animations:^{
		self.textEntryBarViewBottomConstraint.offset = -height;
		[self.view layoutIfNeeded];
	} completion:^(BOOL finished) {
		if (self.messageTableView) {
			[self scrollToBottomAnimated:YES ];
		}
	}];
}

- (void)keyboardWillHide:(NSNotification *)notification {
	NSDictionary *info = [notification userInfo];
	NSTimeInterval animationDuration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];

	[UIView animateWithDuration:animationDuration animations:^{
        CGFloat verticalOffset = 0;
        UIEdgeInsets safeAreaInsets = [[[UIApplication sharedApplication] keyWindow] safeAreaInsets];
        verticalOffset = -safeAreaInsets.bottom;
		self.textEntryBarViewBottomConstraint.offset = verticalOffset;
        
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
	_textEntryBarViewHeightConstraint.offset = MAX(boundingRect.size.height, 16.0) + 8.0 * 2.0 + 5.0 * 2.0;
	_textView.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
	[self.view setNeedsLayout];
    
    double delayInSeconds = 0.1;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
		if (self.messageTableView) {
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
		if ([self respondsToSelector:@selector(inputAssistantItem)]) {
			self.inputAssistantItem.leadingBarButtonGroups = @[];
			self.inputAssistantItem.trailingBarButtonGroups = @[];
		}
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
    _toolbarDeleteButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(deleteActionFromToolbar:)];

	_toolbarSetFavoriteButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"star01_on"] style:UIBarButtonItemStylePlain target:self action:@selector(setFavoriteActionFromToolbar)];

	_toolbarUnsetFavoriteButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"star01"] style:UIBarButtonItemStylePlain target:self action:@selector(unsetFavoriteActionFromToolbar)];

	_toolbarShareButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(shareActionFromToolbar:)];

	[self setEnabledForAllToolbarButtons:NO ];

	UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];

	[self.navigationController setToolbarHidden:NO animated:YES];
	[self.navigationController.toolbar setItems:@[_toolbarDeleteButton, space, _toolbarSetFavoriteButton, space, _toolbarUnsetFavoriteButton, space, _toolbarShareButton]
									   animated:YES];
}

#pragma mark - Share action

- (void)shareActionFromToolbar:(UIBarButtonItem *)barButtonItem {
	_sharePopoverController =
			[self presentActivityViewControllerWithActivityItems:@[self]
											   fromBarButtonItem:barButtonItem
											   completionHandler:^() {
												   _sharePopoverController = nil;
											   }];
	_sharePopoverController.delegate = self;
}

- (NSString *)shareContentsAsHTML:(BOOL)asHTML {
	NSArray *selectedIndexPaths = [_messageTableView indexPathsForSelectedRows];
	NSMutableString *shareMessage = [NSMutableString new];
	NSString *translatedLanguage = nil;
	NSString *lineBreak = asHTML ? @"</br>" : @"\n";
	for (NSIndexPath *indexPath in selectedIndexPaths) {
		TranslatorHistory *item = _messages[indexPath.row];
		TranslatorGroup *group = [TranslatorGroup findFirstByAttribute:@"uniqueID" withValue:item.groupID];
		translatedLanguage = [self.languageListManager localizedNameForCode:group.targetLanguage];
		if ([item.originalText length] && [item.translatedText length] && [translatedLanguage length]) {
			[shareMessage appendString:[NSString stringWithFormat:@"\"%@\" is \"%@\"%@", item.originalText, item.translatedText, lineBreak]];
		}
	}
	[shareMessage appendFormat:@"in %@", translatedLanguage];
	return shareMessage;
}

- (NSString *)activityViewController:(UIActivityViewController *)activityViewController subjectForActivityType:(NSString *)activityType
{
	if ([activityType isEqualToString:UIActivityTypeMail]) {
		return NSLocalizedString(@"Translator using AppBox Pro", nil);
	}

	return @"";
}

- (id)activityViewController:(UIActivityViewController *)activityViewController itemForActivityType:(NSString *)activityType
{
	if ([activityType isEqualToString:UIActivityTypeMail]) {
		return [self shareMailMessageWithHeader:NSLocalizedString(@"I'd like to share a translation with you.", nil)
									   contents:[[self shareContentsAsHTML:YES ] stringByAppendingString:@"<br/>"]
										   tail:NSLocalizedString(@"You can translate more in the AppBox Pro.", nil)];
	}
	else {
		return [self shareContentsAsHTML:NO ];
	}
}

- (id)activityViewControllerPlaceholderItem:(UIActivityViewController *)activityViewController
{
	return NSLocalizedString(@"Share Translator Data", nil);
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
	_sharePopoverController = nil;
}

#pragma mark - Favorite Action

- (void)setFavoriteActionFromToolbar {
	NSArray *selectedIndexPaths = [_messageTableView indexPathsForSelectedRows];
	for (NSIndexPath *indexPath in selectedIndexPaths) {
		TranslatorHistory *item = _messages[indexPath.row];
		[item setAsFavoriteMember:YES];

		A3TranslatorMessageCell *cell = (A3TranslatorMessageCell *) [_messageTableView cellForRowAtIndexPath:indexPath];
		[cell changeFavoriteButtonImage];
	}
    NSManagedObjectContext *context = A3SyncManager.sharedSyncManager.persistentContainer.viewContext;
    [context saveContext];
}

- (void)unsetFavoriteActionFromToolbar {
	NSArray *selectedIndexPaths = [_messageTableView indexPathsForSelectedRows];
	for (NSIndexPath *indexPath in selectedIndexPaths) {
		TranslatorHistory *item = _messages[indexPath.row];
		[item setAsFavoriteMember:NO];

		A3TranslatorMessageCell *cell = (A3TranslatorMessageCell *) [_messageTableView cellForRowAtIndexPath:indexPath];
		[cell changeFavoriteButtonImage];
	}
    NSManagedObjectContext *context = A3SyncManager.sharedSyncManager.persistentContainer.viewContext;
    [context saveContext];
}

- (void)deleteActionFromToolbar:(UIBarButtonItem *)barButtonItem {
    NSArray *selectedIndexPaths = [_messageTableView indexPathsForSelectedRows];
    
    if (IS_IPAD) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        if ([selectedIndexPaths count] == [_messages count]) {
            [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Delete All", @"Delete All") style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
                [self deleteAllMessages];
            }]];
        }
        else {
            [alertController addAction:[UIAlertAction actionWithTitle:[NSString stringWithFormat:NSLocalizedStringFromTable(@"%ld Delete Translation", @"StringsDict", nil), [selectedIndexPaths count]] style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
                [self deleteSelectedMessageItems];
            }]];
        }

        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"Cancel") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [alertController dismissViewControllerAnimated:YES completion:NULL];
        }]];
        alertController.modalInPopover = UIModalPresentationPopover;

        UIPopoverPresentationController *popover = alertController.popoverPresentationController;
        popover.barButtonItem = barButtonItem;
        popover.permittedArrowDirections = UIPopoverArrowDirectionAny;
        
        [self presentViewController:alertController animated:YES completion:NULL];
    }
    else
    {
        if ([selectedIndexPaths count] == [_messages count]) {
            [self showDeleteAllActionSheet];
        }
        else {
            [self showDeleteTranslationActionSheet];
        }
    }
}

- (void)deleteSelectedMessageItems
{
	NSArray *selectedIndexPaths = [_messageTableView indexPathsForSelectedRows];
    NSManagedObjectContext *context = A3SyncManager.sharedSyncManager.persistentContainer.viewContext;
    for (NSIndexPath *indexPath in selectedIndexPaths) {
        TranslatorHistory *itemToDelete = _messages[indexPath.row];
        [TranslatorFavorite deleteAllMatchingPredicate:[NSPredicate predicateWithFormat:@"historyID == %@", itemToDelete.uniqueID]];
        [context deleteObject:itemToDelete];
    }

    // Reload messages
    _messages = nil;
    [self messages];
    
    [_messageTableView deleteRowsAtIndexPaths:selectedIndexPaths withRowAnimation:UITableViewRowAnimationAutomatic];

    [context saveContext];

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
	return [NSPredicate predicateWithFormat:@"groupID == %@", [NSString stringWithFormat:@"%@-%@", _originalTextLanguage, _translatedTextLanguage]];
}

- (NSArray *)messages {
	if (!_messages) {
		_messages = [TranslatorHistory findAllSortedBy:@"updateDate" ascending:YES withPredicate:[self predicateForMessages]];
	}
	return _messages;
}

- (void)deleteAllMessages {
	NSPredicate *predicate = [self predicateForMessages];
	[TranslatorHistory deleteAllMatchingPredicate:predicate];
	[TranslatorFavorite deleteAllMatchingPredicate:predicate];

    NSManagedObjectContext *context = A3SyncManager.sharedSyncManager.persistentContainer.viewContext;
    [context saveContext];

	_messages = nil;
	[self messages];
    [self.messageTableView reloadData];
    
    if ([_messages count] == 0) {
        [self editButtonAction];
        self.navigationItem.rightBarButtonItem = nil;
    }
    else {
        [self.messageTableView setEditing:NO];
        [self setupBarButtons];
    }
}

- (void)setupBarButtons {
	if (self.messageTableView.isEditing) {
		if ([self.messages count]) {
			self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Delete All", @"Delete All")
																					 style:UIBarButtonItemStylePlain
																					target:self
																					action:@selector(deleteAllAction:)];
		} else {
			self.navigationItem.leftBarButtonItem = nil;
			self.navigationItem.hidesBackButton = YES;
		}
		[self rightBarButtonDoneButton];
	} else {
		self.navigationItem.leftBarButtonItem = nil;
		self.navigationItem.hidesBackButton = NO;
		if ([self.messages count]) {
			[self rightBarButtonEditButton];
		}
	}
}

- (void)doneButtonAction:(UIBarButtonItem *)button {
	[self editButtonAction];
}

@end
