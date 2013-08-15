//
//  A3TranslatorMessageViewController.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 8/14/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import <CoreText/CoreText.h>
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

@interface A3TranslatorMessageViewController () <UITextFieldDelegate, UITextViewDelegate, UITableViewDelegate, UITableViewDataSource>

// Language Select
@property (nonatomic, strong) UIView *languageSelectView;
@property (nonatomic, strong) UITextField *sourceLanguageSelectTextField;
@property (nonatomic, strong) UITextField *targetLanguageSelectTextField;
@property (nonatomic, strong) UIView *textEntryBarView;
@property (nonatomic, strong) UITextView *textView;
@property (nonatomic, strong) NSLayoutConstraint *textEntryBarViewBottomConstraint;
@property (nonatomic, strong) NSLayoutConstraint *textEntryBarViewHeightConstraint;
@property (nonatomic, strong) UITableView *messageTableView;
@property (nonatomic, strong) NSArray *messages;
@property (nonatomic, strong) NSString *originalText;

@end

static NSString *const kTranslatorMessageCellID = @"TranslatorMessageCellID";

@implementation A3TranslatorMessageViewController

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

	self.title = @"New Translator";

	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancelButtonAction)];

	self.view.backgroundColor = [UIColor whiteColor];
    self.view.clipsToBounds = YES;

	[self addLanguageSelectView];
	[self addTextEntryView];

	[self observeKeyboard];

	[self messageTableView];
	[_messageTableView registerClass:[A3TranslatorMessageCell class] forCellReuseIdentifier:kTranslatorMessageCellID];

	[self addTapGestureRecognizer];
    
    [self layoutTextEntryBarViewAnimated:NO ];

}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

	[self scrollToBottomAnimated:NO ];
}

- (void)addTapGestureRecognizer {
	UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureHandler)];
	[self.view addGestureRecognizer:gestureRecognizer];
}

- (void)tapGestureHandler {
	[_sourceLanguageSelectTextField resignFirstResponder];
	[_targetLanguageSelectTextField resignFirstResponder];
	[_textView resignFirstResponder];
}

- (void)cancelButtonAction {
	[self.messageTableView setEditing:!_messageTableView.isEditing];
}

- (void)addLanguageSelectView {
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

	UIButton *setSourceLanguageButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[setSourceLanguageButton setImage:[self selectLanguageButtonImage] forState:UIControlStateNormal];
	[contentsView addSubview:setSourceLanguageButton];

	[setSourceLanguageButton makeConstraints:^(MASConstraintMaker *make) {
		make.top.equalTo(contentsView.top);
		make.right.equalTo(contentsView.right).with.offset(-4.0);
		make.width.equalTo(@37.0);
		make.height.equalTo(@37.0);
	}];

	UIButton *setTargetLanguageButton = [UIButton buttonWithType:UIButtonTypeSystem];
	[setTargetLanguageButton setImage:[self addButtonImage] forState:UIControlStateNormal];
	[contentsView addSubview:setTargetLanguageButton];

	[setTargetLanguageButton makeConstraints:^(MASConstraintMaker *make) {
		make.bottom.equalTo(contentsView.bottom);
		make.right.equalTo(contentsView.right).with.offset(-10.0);
		make.width.equalTo(@37.0);
		make.height.equalTo(@37.0);
	}];
}

- (UIImage *)addButtonImage {
	return [UIImage imageNamed:@"add05"];
}

- (UIImage *)selectLanguageButtonImage {
	return [UIImage imageNamed:@"arrow"];
}

- (UILabel *)leftLabel {
	UILabel *leftLabel = [UILabel new];
	leftLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
	leftLabel.textColor = [UIColor colorWithRed:142.0/255.0 green:142.0/255.0 blue:142.0/255.0 alpha:1.0];
	return leftLabel;
}

- (UITextField *)textFieldForLanguageSelect {
	UITextField *textField = [UITextField new];
	textField.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
	textField.textColor = [UIColor blackColor];
	textField.delegate = self;
	textField.clearButtonMode = UITextFieldViewModeWhileEditing;
	textField.leftViewMode = UITextFieldViewModeAlways;
	return textField;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

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
	line.backgroundColor = [UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1.0];
	[_textEntryBarView addSubview:line];

	[line makeConstraints:^(MASConstraintMaker *make) {
		make.top.equalTo(_textEntryBarView.top);
		make.left.equalTo(_textEntryBarView.left);
		make.right.equalTo(_textEntryBarView.right);
		make.height.equalTo( @1 );
	}];

	_textView = [UITextView new];
	_textView.backgroundColor = [UIColor colorWithRed:251.0/255.0 green:251.0/255.0 blue:251.0/255.0 alpha:1.0];
	_textView.layer.borderColor = [UIColor colorWithRed:199.0/255.0 green:199.0/255.0 blue:204.0/255.0 alpha:1.0].CGColor;
	_textView.layer.borderWidth = 1.0;
	_textView.layer.cornerRadius = 5.0;
	_textView.delegate = self;
	_textView.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
	[_textEntryBarView addSubview:_textView];

    [_textView makeConstraints:^(MASConstraintMaker *make) {
		make.edges.equalTo(_textEntryBarView).insets(UIEdgeInsetsMake(8.0, 8.0, 8.0, 86.0));
	}];


	UIButton *translateButton = [UIButton buttonWithType:UIButtonTypeSystem];
	[translateButton setTitle:@"Translate" forState:UIControlStateNormal];
	translateButton.titleLabel.font = [UIFont systemFontOfSize:17.0];
	[translateButton setTitleColor:[UIColor colorWithRed:142.0 / 255.0 green:142.0 / 255.0 blue:147.0 / 255.0 alpha:1.0] forState:UIControlStateNormal];
	[translateButton addTarget:self action:@selector(translateAction) forControlEvents:UIControlEventTouchUpInside];
	[_textEntryBarView addSubview:translateButton];

	[translateButton makeConstraints:^(MASConstraintMaker *make) {
		make.bottom.equalTo(_textEntryBarView.bottom);
		make.width.equalTo(@86.0);
		make.height.equalTo(@42.0);
		make.right.equalTo(_textEntryBarView.right);
	}];
}

#pragma mark - Translate Action

- (void)translateAction {
	if ([_textView.text length]) {
		TranslatorHistory *newData = [TranslatorHistory MR_createEntity];
		newData.originalText = _textView.text;
        _originalText = _textView.text; // Save to async operation

		dispatch_async(dispatch_get_main_queue(), ^{
			[self askTranslateWithText:_originalText];
		});

		newData.date = [NSDate date];
		[[NSManagedObjectContext MR_contextForCurrentThread] MR_saveOnlySelfAndWait];

		_messages = nil;

		NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:[self.messages count] - 1 inSection:0];
		[_messageTableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationNone];

		_textView.text = @"";
		[self layoutTextEntryBarViewAnimated:YES ];
	}
}

static NSString *const GOOGLE_TRANSLATE_API_V2_URL = @"https://www.googleapis.com/language/translate/v2?key=AIzaSyC_0kMLRm92yGQlDz5fvPOVHwWJiw8EVdY&target=";

- (void)askTranslateWithText:(NSString *)originalText {
	NSMutableString *urlString = [NSMutableString stringWithString:GOOGLE_TRANSLATE_API_V2_URL];
	[urlString appendString:@"ko"];
	[urlString appendString:@"&q="];
	[urlString appendString:[originalText stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] ];

	NSURL *url = [NSURL URLWithString:urlString];
	FNLOG(@"%@", urlString);

	NSURLRequest *translateRequest = [NSURLRequest requestWithURL:url];

	AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:translateRequest success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
		NSArray *translations = [[JSON objectForKey:@"data"] objectForKey:@"translations"];

		FNLOG(@"%@", [[translations lastObject] objectForKey:@"detectedSourceLanguage"]);
		FNLOG(@"%@", [[translations lastObject] objectForKey:@"translatedText"]);
		NSMutableString *translated = [NSMutableString stringWithCapacity:400];
		NSString *translatedString = [[translations lastObject] objectForKey:@"translatedText"];
		if (translatedString) {
			[translated setString:translatedString];

			[translated replaceOccurrencesOfString:@"&#39;" withString:@"'" options:0 range:NSMakeRange(0, [translated length])];

			TranslatorHistory *lastData = [TranslatorHistory MR_findFirstOrderedByAttribute:@"date" ascending:NO];
			lastData.translatedText = translated;
			lastData.translatedLanguage = [[translations lastObject] objectForKey:@"detectedSourceLanguage"];
			[[NSManagedObjectContext MR_contextForCurrentThread] MR_saveOnlySelfAndWait];

			NSIndexPath *lastIndexPath = [NSIndexPath indexPathForRow:[self.messages count] - 1 inSection:0];
			[_messageTableView reloadRowsAtIndexPaths:@[lastIndexPath] withRowAnimation:UITableViewRowAnimationFade];
			[self scrollToBottomAnimated:YES];
		}
	} failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
		FNLOG(@"fail to download stock: %@", response.debugDescription);
	}];

	[operation start];
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

	[UIView animateWithDuration:animationDuration animations:^{
		_textEntryBarViewBottomConstraint.constant = -height;
		[self.view layoutIfNeeded];
	} completion:^(BOOL finished) {
		[self scrollToBottomAnimated:YES ];
	}];
}

- (void)keyboardWillHide:(NSNotification *)notification {
	NSDictionary *info = [notification userInfo];
	NSTimeInterval animationDuration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];

	[UIView animateWithDuration:animationDuration animations:^{
		_textEntryBarViewBottomConstraint.constant = 0.0;
        
		[self.view layoutIfNeeded];
	}];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[textField resignFirstResponder];
	return YES;
}

#pragma mark - UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView {
    [self layoutTextEntryBarViewAnimated:YES ];
}

- (void)layoutTextEntryBarViewAnimated:(BOOL)animated {
	CGRect boundingRect = [_textView.layoutManager usedRectForTextContainer:_textView.textContainer];
	_textEntryBarViewHeightConstraint.constant = boundingRect.size.height + 16.0 + 14.0;
	[self.view setNeedsLayout];
    
    double delayInSeconds = 0.1;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self scrollToBottomAnimated:animated ];
    });
}

#pragma mark - messages

- (NSArray *)messages {
	if (!_messages) {
		_messages = [TranslatorHistory MR_findAllSortedBy:@"date" ascending:YES];
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
		_messageTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
		_messageTableView.allowsMultipleSelectionDuringEditing = YES;
		[self.view addSubview:_messageTableView];

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
	[cell setMessageEntity:self.messages[indexPath.row]];
	return cell;
}

- (void)scrollToBottomAnimated:(BOOL)animated {
	if ([self.messages count]) {
		NSIndexPath *lastIndexPath = [NSIndexPath indexPathForRow:[_messages count] - 1 inSection:0];
		[self.messageTableView scrollToRowAtIndexPath:lastIndexPath atScrollPosition:UITableViewScrollPositionBottom animated:animated];
	}
}

@end
