//
//  A3WalletItemViewController.m
//  A3TeamWork
//
//  Created by kihyunkim on 2013. 11. 22..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import <MediaPlayer/MediaPlayer.h>
#import "A3WalletItemViewController.h"
#import "A3WalletItemEditViewController.h"
#import "A3WalletItemTitleView.h"
#import "A3WalletItemFieldCell.h"
#import "A3WalletItemFieldActionCell.h"
#import "A3WalletItemPhotoFieldCell.h"
#import "A3WalletNoteCell.h"
#import "WalletData.h"
#import "WalletItem.h"
#import "WalletItem+Favorite.h"
#import "WalletFieldItem.h"
#import "A3AppDelegate.h"
#import "UIViewController+A3Addition.h"
#import "MWPhotoBrowser.h"
#import "UIViewController+NumberKeyboard.h"
#import "UIImage+Extension2.h"
#import "UITableView+utility.h"
#import "A3BasicWebViewController.h"
#import "WalletFieldItem+initialize.h"
#import "A3WalletItemTitleCell.h"
#import "WalletItem+initialize.h"
#import "NSDate+formatting.h"
#import "NSDateFormatter+A3Addition.h"
#import "WalletFavorite.h"
#import "WalletFavorite+initialize.h"


@interface A3WalletItemViewController () <UITextFieldDelegate, WalletItemEditDelegate, MWPhotoBrowserDelegate, MFMailComposeViewControllerDelegate, UITextViewDelegate, MFMessageComposeViewControllerDelegate>

@property (nonatomic, strong) NSMutableArray *fieldItems;
@property (nonatomic, strong) NSMutableDictionary *titleItem, *noteItem;
@property (nonatomic, strong) NSMutableDictionary *categoryItem;
@property (nonatomic, strong) NSMutableDictionary *emptyItem;
@property (nonatomic, strong) NSMutableArray *albumPhotos;
@property (nonatomic, weak) id copyingSourceView;
@property (nonatomic, strong) NSDictionary *category;

@end

@implementation A3WalletItemViewController
{
    NSIndexPath *currentIndexPath;
    UITextField *firstResponder;
}

extern NSString *const A3WalletItemTitleCellID;
extern NSString *const A3TableViewCellDefaultCellID;
NSString *const A3WalletItemFieldCellID = @"A3WalletItemFieldCell";
NSString *const A3WalletItemPhotoFieldCellID = @"A3WalletItemPhotoFieldCell";
NSString *const A3WalletItemFieldActionCellID = @"A3WalletItemFieldActionCell";
NSString *const A3WalletItemFieldNoteCellID = @"A3WalletNoteCell";

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

	self.title = NSLocalizedString(@"Details", @"Details");

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Edit", @"Edit") style:UIBarButtonItemStylePlain target:self action:@selector(editButtonAction:)];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.separatorInset = UIEdgeInsetsMake(0, (IS_IPAD)?28:15, 0, 0);
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);

    self.tableView.rowHeight = 74.0;
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.separatorColor = [self tableViewSeparatorColor];
    self.tableView.backgroundColor = [UIColor whiteColor];

    [self registerContentSizeCategoryDidChangeNotification];
}

- (void)removeObserver {
	[self removeContentSizeCategoryDidChangeNotification];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];

	if ([self isMovingFromParentViewController] || [self isBeingDismissed]) {
		FNLOG();
		[self removeObserver];
	}
}

- (void)dealloc {
	[self removeObserver];
}

- (void)contentSizeDidChange:(NSNotification *) notification
{
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSDictionary *)category {
	if (!_category) {
		_category = [WalletData categoryItemWithID:_item.categoryID];
	}
	return _category;
}

- (NSMutableArray *)fieldItems
{
	if (!_fieldItems) {
		[_item verifyNULLField];

		_fieldItems = [[NSMutableArray alloc] initWithArray:[_item fieldItemsArraySortedByFieldOrder]];
        
		// 데이타 없는 item은 표시하지 않는다.
		NSMutableArray *deleteTmp = [NSMutableArray new];
		for (WalletFieldItem *fieldItem in _fieldItems) {
			NSDictionary *field = [WalletData fieldOfFieldItem:fieldItem category:self.category];;
			if ([field[W_TYPE_KEY] isEqualToString:WalletFieldTypeDate]) {
				if (fieldItem.date == nil) {
					[deleteTmp addObject:fieldItem];
				}
			}
			else if ([field[W_TYPE_KEY] isEqualToString:WalletFieldTypeImage] || [field[W_TYPE_KEY] isEqualToString:WalletFieldTypeVideo]) {
				if (![fieldItem.hasImage boolValue] && ![fieldItem.hasVideo boolValue]) {
					[deleteTmp addObject:fieldItem];
				}
			}
			else if ([fieldItem.value length] == 0 && ![fieldItem.hasImage boolValue] && ![fieldItem.hasVideo boolValue]) {
				[deleteTmp addObject:fieldItem];
			}
		}
		[_fieldItems removeObjectsInArray:deleteTmp];

		[_fieldItems insertObject:self.titleItem atIndex:0];
		if (_showCategory) {
			[_fieldItems insertObject:self.categoryItem atIndex:1];
		}
        
		// note가 있을때만 표시한다.
		if (_item.note.length > 0) {
			[_fieldItems addObject:self.noteItem];
		} else {
			[_fieldItems addObject:self.emptyItem];
		}
	}

	return _fieldItems;
}

- (NSMutableDictionary *)titleItem
{
	if (!_titleItem) {
		_titleItem = [NSMutableDictionary dictionaryWithDictionary:@{@"title" : NSLocalizedString(@"Title", @"Title"), @"order":@""}];
	}
    
	return _titleItem;
}

- (NSMutableDictionary *)noteItem
{
	if (!_noteItem) {
		_noteItem = [NSMutableDictionary dictionaryWithDictionary:@{@"title" : NSLocalizedString(@"Note", @"Note"), @"order":@""}];
	}

	return _noteItem;
}

- (NSMutableDictionary *)categoryItem
{
	if (!_categoryItem) {
		_categoryItem = [NSMutableDictionary dictionaryWithDictionary:@{@"title" : NSLocalizedString(@"Category", @"Category"), @"order":@""}];
	}
    
	return _categoryItem;
}

- (NSMutableDictionary *)emptyItem {
	if (!_emptyItem) {
		_emptyItem = [NSMutableDictionary dictionaryWithDictionary:@{@"title" : @"Empty", @"order" : @""}];
	}
	return _emptyItem;
}


- (NSMutableArray *)albumPhotos
{
	if (!_albumPhotos) {
		_albumPhotos = [[NSMutableArray alloc] init];
        
		for (int i=0; i<self.fieldItems.count; i++) {
			if ([_fieldItems[i] isKindOfClass:[WalletFieldItem class]]) {
				WalletFieldItem *fieldItem = _fieldItems[i];
				if ([fieldItem.hasImage boolValue]) {
					MWPhoto *photo = [MWPhoto photoWithImage:[fieldItem photoImageInOriginalDirectory:YES]];
					[_albumPhotos addObject:photo];
				}
			}
		}
	}
    
	return _albumPhotos;
}

- (void)favorButtonAction:(UIButton *)button
{
	BOOL isFavorite = ![WalletFavorite isFavoriteForItemID:_item.uniqueID];
	[_item changeFavorite:isFavorite];
	button.selected = isFavorite;
}

- (void)photoButtonAction:(UIButton *)sender
{
	WalletFieldItem *fieldItem = _fieldItems[sender.tag];

	if ([fieldItem.hasVideo boolValue]) {
		MPMoviePlayerViewController *pvc = [[MPMoviePlayerViewController alloc] initWithContentURL:[fieldItem videoFileURLInOriginal:YES] ];
		[self presentViewController:pvc animated:YES completion:^{
			[pvc.moviePlayer play];
		}];
	}
	else if ([fieldItem.hasImage boolValue]) {
		// Create browser
		MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
		browser.displayActionButton = YES;
		browser.displayNavArrows = NO;
		browser.zoomPhotosToFill = YES;
		[browser setCurrentPhotoIndex:sender.tag];
        
		UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:browser];
        
		[self.navigationController presentViewController:nc animated:YES completion:NULL];
	}
}

- (void)editButtonAction:(id)sender
{
	UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"WalletPhoneStoryBoard" bundle:nil];
	A3WalletItemEditViewController *viewController = [storyBoard instantiateViewControllerWithIdentifier:@"A3WalletItemEditViewController"];
	viewController.delegate = self;
	viewController.item = [self.item MR_inContext:[NSManagedObjectContext MR_rootSavingContext]];
	viewController.hidesBottomBarWhenPushed = YES;
	viewController.alwaysReturnToOriginalCategory = self.alwaysReturnToOriginalCategory;
    
	UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:viewController];
	nav.modalPresentationStyle = UIModalPresentationCurrentContext;
	nav.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
	[self presentViewController:nav animated:YES completion:NULL];
}


- (void)configureFloatingTextField:(JVFloatLabeledTextField *)txtFd
{
	txtFd.textColor = [UIColor colorWithRed:159.0/255.0 green:159.0/255.0 blue:159.0/255.0 alpha:1.0];
	txtFd.floatingLabelTextColor = [UIColor colorWithRed:0.0/255.0 green:0.0/255.0 blue:0.0/255.0 alpha:1.0];
	txtFd.font = [UIFont systemFontOfSize:17.0];
	txtFd.floatingLabelFont = [UIFont systemFontOfSize:14];
	txtFd.floatingLabelYPadding = @(-6);
	txtFd.delegate = self;
}

- (BOOL)detectDataText:(NSString *) text
{
	BOOL hasTextAction = NO;
	if (text) {
		NSDataDetector *detector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink | NSTextCheckingTypePhoneNumber error:nil];
		NSUInteger numberOfMatch = [detector numberOfMatchesInString:text options:0 range:NSMakeRange(0, text.length)];
		if (numberOfMatch > 0) {
			hasTextAction = YES;
		}
	}
    
	return hasTextAction;
}

- (BOOL)shouldCheckTextDataOfItem:(WalletFieldItem *) fieldItem
{
	NSDictionary *field = [WalletData fieldOfFieldItem:fieldItem category:self.category];;
	if ([field[W_TYPE_KEY] isEqualToString:WalletFieldTypeImage] || [field[W_TYPE_KEY] isEqualToString:WalletFieldTypeVideo]) {
		return NO;
	}
	else if ([field[W_TYPE_KEY] isEqualToString:WalletFieldTypeDate]) {
		return NO;
	}
	else {
		return YES;
	}
}

- (void)doActionForTextData:(WalletFieldItem *)fieldItem andActionIndex:(NSUInteger)actionIdx
{
	NSDataDetector *detector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeAddress|NSTextCheckingTypeLink|NSTextCheckingTypePhoneNumber error:nil];
	NSTextCheckingResult *result = [detector firstMatchInString:fieldItem.value options:0 range:NSMakeRange(0, fieldItem.value.length)];
    
	if (result.resultType == NSTextCheckingTypeLink) {
		NSString *urlString = result.URL.absoluteString;
        
		NSString *myRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
		NSRange range = [urlString rangeOfString:myRegex options:NSRegularExpressionSearch];
        
		if (range.location != NSNotFound) {
			// email
			switch (actionIdx) {
				case 0:
				{
					// mail
					MFMailComposeViewController *picker = [[MFMailComposeViewController alloc]init];
					if (picker) {
						picker.mailComposeDelegate = self;
						NSString *mailAddress = [urlString substringWithRange:range];
						[picker setToRecipients:@[mailAddress]];  //받는 사람(배열의 형태로 넣어도 됩니다. )
						[picker setSubject:nil];  //제목
						[picker setMessageBody:nil isHTML:NO];     //내용
						[self presentViewController:picker animated:YES completion:NULL];
					}

					break;
				}
				case 1:
				{
					MFMessageComposeViewController *viewController = [[MFMessageComposeViewController alloc] init];
					if (viewController) {
						viewController.messageComposeDelegate = self;
						NSString *mailAddress = [urlString substringWithRange:range];
						viewController.recipients = @[mailAddress];
						[self presentViewController:viewController animated:YES completion:NULL];
					}
					break;
				}
				default:
					break;
			}
		}
		else {
			// just web address
			if (actionIdx == 0) {
				A3BasicWebViewController *viewController = [A3BasicWebViewController new];
				viewController.url = result.URL;
				viewController.showDoneButton = YES;
                viewController.titleString = NSLocalizedString(@"Website", "Website");

				UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
				[self presentViewController:navigationController animated:YES completion:nil];
			}
		}
	}
	else if (result.resultType == NSTextCheckingTypePhoneNumber) {
		// phone
		switch (actionIdx) {
			case 0:
			{
				// call
				NSString *urlString = [NSString stringWithFormat:@"tel://%@", result.phoneNumber];
				[[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
				break;
			}
			case 1: {
				MFMessageComposeViewController *viewController = [[MFMessageComposeViewController alloc] init];
				if (viewController) {
					viewController.messageComposeDelegate = self;
					viewController.recipients = @[result.phoneNumber];
					[self presentViewController:viewController animated:YES completion:NULL];
				}
				break;
			}
			default:
				break;
		}
	}
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
	[controller dismissViewControllerAnimated:YES completion:nil];
}

- (void)actionCellContentButtonAction:(UIButton *)sender
{
	if ([_fieldItems[sender.tag] isKindOfClass:[WalletFieldItem class]]) {
		WalletFieldItem *fieldItem = _fieldItems[sender.tag];
        
		if ([self shouldCheckTextDataOfItem:fieldItem]) {
			// 텍스트 액션 여부 확인
			BOOL hasTextAction = [self detectDataText:fieldItem.value];
			if (hasTextAction) {
				[self doActionForTextData:fieldItem andActionIndex:0];
			}
		}
	}
}

- (void)actionCellRight1ButtonAction:(UIButton *)sender
{
	if ([_fieldItems[sender.tag] isKindOfClass:[WalletFieldItem class]]) {
		WalletFieldItem *fieldItem = _fieldItems[sender.tag];
        
		if ([self shouldCheckTextDataOfItem:fieldItem]) {
			// 텍스트 액션 여부 확인
			BOOL hasTextAction = [self detectDataText:fieldItem.value];
			if (hasTextAction) {
				[self doActionForTextData:fieldItem andActionIndex:0];
			}
		}
	}
}

- (void)actionCellRight2ButtonAction:(UIButton *)sender
{
	if ([_fieldItems[sender.tag] isKindOfClass:[WalletFieldItem class]]) {
		WalletFieldItem *fieldItem = _fieldItems[sender.tag];
        
		if ([self shouldCheckTextDataOfItem:fieldItem]) {
			// 텍스트 액션 여부 확인
			BOOL hasTextAction = [self detectDataText:fieldItem.value];
			if (hasTextAction) {
				[self doActionForTextData:fieldItem andActionIndex:1];
			}
		}
	}
}

#pragma mark - MailComposerDelegate

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
	//상태 결과 값에 따라 처리
	switch (result) {
		case MFMailComposeResultCancelled:  // 취소.
		{
			break;
		}
		case MFMailComposeResultFailed: // 실패.
		{
			break;
		}
		case MFMailComposeResultSent:   //성공.
		{
			break;
		}
		default:
			break;
	}
	[self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - MWPhotoBrowserDelegate

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    return self.albumPhotos.count;
}

- (MWPhoto *)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    if (index < _albumPhotos.count)
        return [_albumPhotos objectAtIndex:index];
    return nil;
}

#pragma mark - WalletItemEditDelegate

-(void)walletItemEdited:(WalletItem *)item
{
    _fieldItems = nil;
    [self.tableView reloadData];
}

- (void)WalletItemDeleted
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - textView delegate

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
	[self showCopyMenuWithView:textView];
    return NO;
}

#pragma mark - textField delegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
	FNLOG();
	[self showCopyMenuWithView:textField];

	return NO;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
	currentIndexPath = [self.tableView indexPathForCellSubview:textField];
	FNLOG(@"current text field indexpath : %@", [currentIndexPath description]);
    firstResponder = textField;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return self.fieldItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;

	if (_fieldItems[indexPath.row] == self.titleItem) {
		A3WalletItemTitleCell *titleCell = [tableView dequeueReusableCellWithIdentifier:A3WalletItemTitleCellID forIndexPath:indexPath];
		titleCell.titleTextField.text = [_item.name length] ? _item.name : NSLocalizedString(@"New Item", @"New Item");
		titleCell.titleTextField.delegate = self;
		titleCell.favoriteButton.selected = [WalletFavorite isFavoriteForItemID:_item.uniqueID];

        NSDateFormatter *dateFormatter = [NSDateFormatter new];
        if (IS_IPAD || [NSDate isFullStyleLocale]) {
            dateFormatter.dateStyle = NSDateFormatterFullStyle;
            dateFormatter.timeStyle = NSDateFormatterShortStyle;
            dateFormatter.doesRelativeDateFormatting = YES;
        }
        else {
            dateFormatter.dateFormat = [dateFormatter customFullWithTimeStyleFormat];
        }
        
		titleCell.timeLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Updated %@", @"Updated %@"), [dateFormatter stringFromDate:_item.updateDate]];
        
		// To prevent adding multiple times
		[titleCell.favoriteButton removeTarget:self action:@selector(favorButtonAction:) forControlEvents:UIControlEventTouchUpInside];
		[titleCell.favoriteButton addTarget:self action:@selector(favorButtonAction:) forControlEvents:UIControlEventTouchUpInside];

		cell = titleCell;
	}
    else if (_fieldItems[indexPath.row] == self.noteItem) {
        // note
        A3WalletNoteCell *noteCell = [tableView dequeueReusableCellWithIdentifier:A3WalletItemFieldNoteCellID forIndexPath:indexPath];
        [noteCell setupTextView];
        noteCell.textView.delegate = self;
		[noteCell setNoteText:_item.note];

        cell = noteCell;
    }
    else if (_fieldItems[indexPath.row] == self.categoryItem) {
        
        A3WalletItemFieldCell *textCell = [tableView dequeueReusableCellWithIdentifier:A3WalletItemFieldCellID forIndexPath:indexPath];
        textCell.selectionStyle = UITableViewCellSelectionStyleNone;
        [self configureFloatingTextField:textCell.valueTextField];
        
        textCell.valueTextField.floatingLabelFont = [UIFont systemFontOfSize:14];
        textCell.valueTextField.font = [UIFont systemFontOfSize:17];
        textCell.valueTextField.textColor = [UIColor colorWithRed:159.0/255.0 green:159.0/255.0 blue:159.0/255.0 alpha:1.0];
        textCell.valueTextField.placeholder = NSLocalizedString(@"Category", @"Category");
		NSDictionary *category = [WalletData categoryItemWithID:_item.categoryID];
		textCell.valueTextField.text = category[W_NAME_KEY];

        cell = textCell;
    }
    else if ([_fieldItems[indexPath.row] isKindOfClass:[WalletFieldItem class]]) {
        WalletFieldItem *fieldItem = _fieldItems[indexPath.row];
		NSDictionary *field = [WalletData fieldOfFieldItem:fieldItem category:self.category];;
        if ([fieldItem.hasImage boolValue] || [fieldItem.hasVideo boolValue]) {
            A3WalletItemPhotoFieldCell *photoCell = [tableView dequeueReusableCellWithIdentifier:A3WalletItemPhotoFieldCellID forIndexPath:indexPath];
            
            photoCell.selectionStyle = UITableViewCellSelectionStyleNone;
			[self configureFloatingTextField:photoCell.valueTextField];
            photoCell.valueTextField.placeholder = field[W_NAME_KEY];
			photoCell.valueTextField.text = @" ";
			photoCell.photoButton.hidden = NO;

			UIImage *photo = fieldItem.thumbnailImage;
			photo = [photo imageByScalingProportionallyToSize:CGSizeMake(120, 120)];
			[photoCell.photoButton setBackgroundImage:photo forState:UIControlStateNormal];
            
			[photoCell.photoButton addTarget:self action:@selector(photoButtonAction:) forControlEvents:UIControlEventTouchUpInside];
			photoCell.photoButton.tag = indexPath.row;
            photoCell.photoButton.backgroundColor = [UIColor redColor];

			if ([fieldItem.hasVideo boolValue]) {
				UIImageView *markView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"video"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
				markView.tintColor = [UIColor whiteColor];
				[photoCell.photoButton addSubview:markView];
				[markView makeConstraints:^(MASConstraintMaker *make) {
					make.center.equalTo(photoCell.photoButton);
					make.width.equalTo(@15);
					make.height.equalTo(@9);
				}];
			}

			cell = photoCell;
        }
        else if ([field[W_TYPE_KEY] isEqualToString:WalletFieldTypeDate]) {
            
            A3WalletItemFieldCell *dateCell = [tableView dequeueReusableCellWithIdentifier:A3WalletItemFieldCellID forIndexPath:indexPath];
            
            dateCell.selectionStyle = UITableViewCellSelectionStyleNone;
            [self configureFloatingTextField:dateCell.valueTextField];
            
            dateCell.valueTextField.placeholder = field[W_NAME_KEY];
            if (fieldItem.date) {
                if (IS_IPAD || [NSDate isFullStyleLocale]) {
                    dateCell.valueTextField.text = [self fullStyleDateStringFromDate:fieldItem.date withShortTime:NO];
                }
                else {
                    dateCell.valueTextField.text = [self customFullStyleDateStringFromDate:fieldItem.date withShortTime:NO];
                }
            }
            else {
                dateCell.valueTextField.text = @"";
            }
            
            cell = dateCell;
        }
        else {
            FNLOG(@"fieldItem field: %@", field);
            // 텍스트 액션 여부 확인
            BOOL hasTextAction = [self detectDataText:fieldItem.value];
            
            if (hasTextAction && ([field[W_TYPE_KEY] isEqualToString:WalletFieldTypePhone] || [field[W_TYPE_KEY] isEqualToString:WalletFieldTypeEmail] || [field[W_TYPE_KEY] isEqualToString:WalletFieldTypeURL])) {
                A3WalletItemFieldActionCell *actionCell = [tableView dequeueReusableCellWithIdentifier:A3WalletItemFieldActionCellID forIndexPath:indexPath];
                
                actionCell.selectionStyle = UITableViewCellSelectionStyleNone;
                [self configureFloatingTextField:actionCell.valueTextField];

                actionCell.valueTextField.floatingLabelTextColor = [UIColor colorWithRed:0.0/255.0 green:122.0/255.0 blue:255.0/255.0 alpha:1];
                
                actionCell.valueTextField.placeholder = field[W_NAME_KEY];
                actionCell.valueTextField.text = fieldItem.value;
                actionCell.valueTextField.enabled = NO;
                
                actionCell.contentBtn.tag = indexPath.row;
                actionCell.rightBtn1.tag = indexPath.row;
                actionCell.rightBtn2.tag = indexPath.row;
                
//                [actionCell.contentBtn addTarget:self action:@selector(actionCellContentButtonAction:) forControlEvents:UIControlEventTouchUpInside];
                [actionCell.rightBtn1 addTarget:self action:@selector(actionCellRight1ButtonAction:) forControlEvents:UIControlEventTouchUpInside];
                [actionCell.rightBtn2 addTarget:self action:@selector(actionCellRight2ButtonAction:) forControlEvents:UIControlEventTouchUpInside];
                
                NSDataDetector *detector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeAddress|NSTextCheckingTypeLink|NSTextCheckingTypePhoneNumber error:nil];
                NSTextCheckingResult *result = [detector firstMatchInString:fieldItem.value options:0 range:NSMakeRange(0, fieldItem.value.length)];
                
                if (result.resultType == NSTextCheckingTypeLink && ([field[W_TYPE_KEY] isEqualToString:WalletFieldTypeEmail] || [field[W_TYPE_KEY] isEqualToString:WalletFieldTypeURL]) ) {
                    NSString *urlString = result.URL.absoluteString;
                    
                    NSString *myRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
                    NSRange range = [urlString rangeOfString:myRegex options:NSRegularExpressionSearch];
                    
                    if (range.location != NSNotFound) {
                        // email
                        actionCell.rightBtn1.hidden = NO;
                        actionCell.rightBtn2.hidden = NO;
                        [actionCell.rightBtn1 setImage:[UIImage imageNamed:@"mail"] forState:UIControlStateNormal];
                        [actionCell.rightBtn2 setImage:[UIImage imageNamed:@"message"] forState:UIControlStateNormal];
                    }
                    else {
                        // just web address
                        actionCell.rightBtn1.hidden = YES;
                        actionCell.rightBtn2.hidden = YES;
                        [actionCell.contentBtn addTarget:self action:@selector(actionCellContentButtonAction:) forControlEvents:UIControlEventTouchUpInside];
                        actionCell.selectionStyle = UITableViewCellSelectionStyleGray;
                    }
                }
                else if (result.resultType == NSTextCheckingTypePhoneNumber && [field[W_TYPE_KEY] isEqualToString:WalletFieldTypePhone]) {
                    NSString *urlString = [NSString stringWithFormat:@"tel://%@", [fieldItem value]];
                    BOOL canOpen = [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:urlString]];
                    actionCell.rightBtn1.hidden = canOpen ? NO : YES;
                    actionCell.rightBtn2.hidden = NO;
                    [actionCell.rightBtn1 setImage:[UIImage imageNamed:@"call"] forState:UIControlStateNormal];
                    [actionCell.rightBtn2 setImage:[UIImage imageNamed:@"message"] forState:UIControlStateNormal];
                }
                else {
                    actionCell.rightBtn1.hidden = YES;
                    actionCell.rightBtn2.hidden = YES;
                }
                
                cell = actionCell;
            }
            else {
                A3WalletItemFieldCell *textCell = [tableView dequeueReusableCellWithIdentifier:A3WalletItemFieldCellID forIndexPath:indexPath];
                
                textCell.selectionStyle = UITableViewCellSelectionStyleNone;
                [self configureFloatingTextField:textCell.valueTextField];
                
                textCell.valueTextField.placeholder = field[W_NAME_KEY];
                textCell.valueTextField.text = fieldItem.value;
                
                cell = textCell;
            }
        }
    } else if (_fieldItems[indexPath.row] == self.emptyItem) {
		UITableViewCell *emptyCell = [tableView dequeueReusableCellWithIdentifier:A3TableViewCellDefaultCellID forIndexPath:indexPath];
		emptyCell.selectionStyle = UITableViewCellSelectionStyleNone;
		cell = emptyCell;
	}
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    WalletFieldItem *fieldItem = _fieldItems[indexPath.row];
    if (!fieldItem || ![fieldItem isKindOfClass:[WalletFieldItem class]]) {
        return;
    }

	NSDictionary *field = [WalletData fieldOfFieldItem:fieldItem category:self.category];;
    if ([field[W_TYPE_KEY] isEqualToString:WalletFieldTypeURL]) {
        A3WalletItemFieldActionCell *actionCell = (A3WalletItemFieldActionCell *)[tableView cellForRowAtIndexPath:indexPath];
        [self performSelector:@selector(actionCellContentButtonAction:) withObject:actionCell.contentBtn];
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.fieldItems objectAtIndex:indexPath.row] == self.noteItem) {
		if (!_item.note) return 74.0;
        
        NSDictionary *textAttributes = @{
                                         NSFontAttributeName : [UIFont systemFontOfSize:17]
                                         };
        
        NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:_item.note attributes:textAttributes];
        UITextView *txtView = [[UITextView alloc] init];
        [txtView setAttributedText:attributedString];
        float margin = IS_IPAD ? 49:31;
        CGSize txtViewSize = [txtView sizeThatFits:CGSizeMake(self.view.frame.size.width-margin, 1000)];
        float cellHeight = txtViewSize.height + 20;
        
        float defaultCellHeight = 180.0;
        
        if (cellHeight < defaultCellHeight) {
            return defaultCellHeight;
        }
        else {
            return cellHeight;
        }
    }
    else if (indexPath.row == 0) {
        
        return IS_RETINA ? 74.5 : 75.0;
    }
    
    return 74.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *foot = [UIView new];
    return foot;
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return NO;
}

#pragma mark - UIResponder

- (void)showCopyMenuWithView:(UIView *)view {
	NSString *text = [view valueForKey:@"text"];
	if (![text length]) {
		return;
	}

	dispatch_async(dispatch_get_main_queue(), ^{
		[self becomeFirstResponder];

		CGRect frame = view.frame;

		UIMenuController *copyMenu = [UIMenuController sharedMenuController];
		UITableViewCell *cell = [self.tableView cellForCellSubview:view];
		if ([view isKindOfClass:[UITextField class]]) {
			UITextField *textField = (UITextField *) view;
			NSStringDrawingContext *context = [NSStringDrawingContext new];
			CGRect bounds = [textField.text boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:textField.font} context:context];
			frame.size.width = bounds.size.width;
			frame.size.height += 10.0;
			[copyMenu setTargetRect:frame inView:cell];
			copyMenu.arrowDirection = UIMenuControllerArrowLeft;
		} else {
			frame.size.width = 20;
			[copyMenu setTargetRect:frame inView:cell];
			copyMenu.arrowDirection = UIMenuControllerArrowDown;
		}
		[copyMenu setMenuVisible:YES animated:YES];

		_copyingSourceView = view;
	});
}

- (BOOL)canBecomeFirstResponder
{
	return YES;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
	BOOL retValue = NO;

	if (action == @selector(copy:))
	{
		retValue = YES;
	}
	else
	{
		// Pass the canPerformAction:withSender: message to the superclass
		// and possibly up the responder chain.
		retValue = [super canPerformAction:action withSender:sender];
	}

	return retValue;
}

- (void)copy:(id)sender {
	if (!_copyingSourceView) {
		return;
	}
	UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
	NSString *stringToCopy;
	stringToCopy = [_copyingSourceView valueForKey:@"text"];

	[pasteboard setString:stringToCopy];
}

@end
