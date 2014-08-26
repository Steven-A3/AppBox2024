//
//  A3HolidaysEditViewController.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 9/1/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3HolidaysEditViewController.h"
#import "HolidayData.h"
#import "HolidayData+Country.h"
#import "UIViewController+NumberKeyboard.h"
#import "A3HolidaysEditCell.h"
#import "A3HolidaysAddToDaysCounterViewController.h"
#import "A3ImageCropperViewController.h"
#import "A3HolidaysFlickrDownloadManager.h"
#import "UIViewController+A3Addition.h"
#import "A3HolidaysPageViewController.h"
#import "UIViewController+tableViewStandardDimension.h"
#import "UITableView+utility.h"
#import "A3UserDefaults.h"

@interface A3HolidaysEditViewController () <UIActionSheetDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIPopoverControllerDelegate>

@property (nonatomic, strong) NSArray *holidaysForCountry;
@property (nonatomic, strong) NSMutableArray *excludedHolidays;
@property (nonatomic, strong) UIPopoverController *imagePickerPopoverController;
@property (nonatomic, strong) UIImagePickerController *imagePickerController;
@property (nonatomic, strong) NSIndexPath *currentIndexPath;
@property (nonatomic, strong) UIButton *cameraButton;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UISwitch *lunarSwitch;

@end

@implementation A3HolidaysEditViewController {
    BOOL _dataUpdated;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

static NSString *CellIdentifier = @"Cell";

- (void)viewDidLoad
{
    [super viewDidLoad];

//	UIBarButtonItem *addToDaysCounter = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"addToDaysCounter"] style:UIBarButtonItemStylePlain target:self action:@selector(addToDaysCounter:)];
//	self.navigationItem.leftBarButtonItem = addToDaysCounter;

	UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonAction:)];
    self.navigationItem.rightBarButtonItem = doneButton;

	self.tableView.showsVerticalScrollIndicator = NO;
	self.tableView.separatorColor = A3UITableViewSeparatorColor;
	self.tableView.separatorInset = A3UITableViewSeparatorInset;
	[self.tableView registerClass:[A3HolidaysEditCell class] forCellReuseIdentifier:CellIdentifier];

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

- (void)contentSizeDidChange:(NSNotification *)notification {
	[self.tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];

	if ([self isMovingToParentViewController]) {
		[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
	}
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];

	if ([self isMovingFromParentViewController]) {
		[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];

		[self removeObserver];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)addToDaysCounter:(UIBarButtonItem *)button {
	A3HolidaysAddToDaysCounterViewController *viewController = [[A3HolidaysAddToDaysCounterViewController alloc] initWithStyle:UITableViewStylePlain];
	viewController.countryCode = _countryCode;

	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
	[self presentViewController:navigationController animated:YES completion:nil];
}

- (void)doneButtonAction:(UIBarButtonItem *)button {
	[_delegate editViewController:self willDismissViewControllerWithDataUpdated:_dataUpdated];

	[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)resetButtonAction:(UIBarButtonItem *)button {
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"This will reset all settings.\nNo data will be deleted.", nil)
															 delegate:self
													cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel")
											   destructiveButtonTitle:NSLocalizedString(@"Reset All", @"Reset All")
													otherButtonTitles:nil];
	actionSheet.tag = 100;
	[actionSheet showInView:self.view];
}

#pragma mark - Setup data

- (void)setCountryCode:(NSString *)countryCode {
	_countryCode = [countryCode mutableCopy];
	HolidayData *holidayData = [HolidayData new];
	_holidaysForCountry = [holidayData holidaysForCountry:_countryCode year:[HolidayData thisYear] fullSet:YES ];
	NSArray *excludedList = [[A3UserDefaults standardUserDefaults] objectForKey:[HolidayData keyForExcludedHolidaysForCountry:_countryCode]];
	_excludedHolidays = [excludedList mutableCopy];

	self.title = [NSString stringWithFormat:@"%@ (%lu)",
			[[NSLocale currentLocale] displayNameForKey:NSLocaleCountryCode value:_countryCode], (unsigned long)[_holidaysForCountry count]];
}

- (NSMutableArray *)excludedHolidays {
	if (!_excludedHolidays) {
		_excludedHolidays = [NSMutableArray new];
	}
	return _excludedHolidays;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return [HolidayData needToShowLunarDatesOptionMenuForCountryCode:_countryCode] ? 4 : 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
	if (!section) return [_holidaysForCountry count];

    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 0) {
		A3HolidaysEditCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];

		// Configure the cell...
		NSDictionary *holiday = self.holidaysForCountry[indexPath.row];
		cell.nameLabel.text = holiday[kHolidayName];
		BOOL isPublic = [holiday[kHolidayIsPublic] boolValue];
		[cell.publicMarkView setHidden:!isPublic];
		[cell.publicLabel setHidden:!isPublic];
		if (IS_IPAD) {
			cell.dateLabel.text = [_pageViewController stringFromDate:holiday[kHolidayDate]];
		}
		cell.switchControl.tag = indexPath.row;
		[cell.switchControl addTarget:self action:@selector(switchControlAction:) forControlEvents:UIControlEventValueChanged];

		[cell.switchControl setOn:![_excludedHolidays containsObject:holiday[kHolidayName]]];

		return cell;
	} else {
		UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
		cell.textLabel.font = [UIFont systemFontOfSize:17];
		switch (indexPath.section) {
			case 1:
				cell.textLabel.text = NSLocalizedString(@"Reset Show/Hide Settings", @"Reset Show/Hide Settings");
				cell.textLabel.textColor = self.view.tintColor;
				break;
			case 2: {
				cell.textLabel.text = NSLocalizedString(@"Wallpaper", @"Wallpaper");
				if ([[A3HolidaysFlickrDownloadManager sharedInstance] hasUserSuppliedImageForCountry:_countryCode]) {
					_imageView = nil;
					cell.accessoryView = [self imageView];
				} else {
					cell.accessoryView = [self cameraButton];
				}
				break;
			}
			case 3:{
				cell.textLabel.text = NSLocalizedString(@"Show Lunar Date", @"Show Lunar Date");
				UISwitch *switchControl = [self lunarSwitch];
				[switchControl setOn:[HolidayData needToShowLunarDatesForCountryCode:_countryCode]];
				cell.accessoryView = switchControl;
				cell.selectionStyle = UITableViewCellSelectionStyleNone;
				break;
			}
		}
		return cell;
	}
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
	switch (indexPath.section) {
		case 1:
			[self resetButtonAction:nil];
			break;
		case 2:
            [self photoButtonAction];
			break;
		case 3: {
			UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
			[self lunarOnOff:(UISwitch *) cell.accessoryView];
		}
	}
}

- (UIButton *)cameraButton {
	if (!_cameraButton) {
		_cameraButton = [UIButton buttonWithType:UIButtonTypeCustom];
		[_cameraButton setImage:[UIImage imageNamed:@"camera.png"] forState:UIControlStateNormal];
        [_cameraButton addTarget:self action:@selector(photoButtonAction) forControlEvents:UIControlEventTouchUpInside];
		[_cameraButton sizeToFit];
	}
	return _cameraButton;
}

- (UIImageView *)imageView {
	if (!_imageView) {
		_imageView = [[A3HolidaysFlickrDownloadManager sharedInstance] thumbnailOfUserSuppliedImageForCountryCode:_countryCode];
		_imageView.contentMode = UIViewContentModeScaleAspectFill;
		_imageView.layer.borderColor = [UIColor colorWithWhite:1.0 alpha:1.0].CGColor;
		_imageView.layer.borderWidth = 0.1;
		_imageView.layer.cornerRadius = 15;
		_imageView.layer.masksToBounds = YES;
	}
	return _imageView;
}

- (void)switchControlAction:(UISwitch *)switchControl {
	NSDictionary *holiday = self.holidaysForCountry[switchControl.tag];
	if (switchControl.isOn) {
		[self.excludedHolidays removeObject:holiday[kHolidayName]];
	} else {
		if (![self.excludedHolidays containsObject:holiday[kHolidayName]]) {
			[self.excludedHolidays addObject:holiday[kHolidayName]];
		}
	}
	[[A3UserDefaults standardUserDefaults] setObject:_excludedHolidays forKey:[HolidayData keyForExcludedHolidaysForCountry:_countryCode]];
	[[A3UserDefaults standardUserDefaults] synchronize];

	_dataUpdated = YES;
}

- (UISwitch *)lunarSwitch {
	if (!_lunarSwitch) {
		_lunarSwitch = [UISwitch new];
		[_lunarSwitch addTarget:self action:@selector(lunarOnOff:) forControlEvents:UIControlEventValueChanged];
	}
	return _lunarSwitch;
}

- (void)photoButtonAction {
	self.currentIndexPath = [self.tableView indexPathForCellSubview:self.cameraButton];

	A3HolidaysFlickrDownloadManager *downloadManager = [A3HolidaysFlickrDownloadManager sharedInstance];
	UIActionSheet *actionSheet = [self actionSheetAskingImagePickupWithDelete:[downloadManager hasUserSuppliedImageForCountry:_countryCode] delegate:self];
	actionSheet.tag = 200;
    // TODO
#ifdef __IPHONE_8_0
    if (IS_IPAD) {
        UITableViewCell *cell = [self.tableView cellForCellSubview:_cameraButton];
        CGRect rect = [self.tableView convertRect:_cameraButton.frame fromView:cell.contentView];
        [actionSheet showFromRect:rect inView:self.view animated:NO];
    }
    else {
        [actionSheet showInView:self.view];
    }
#else
    [actionSheet showInView:self.view];
#endif
}

#pragma mark - UIActionSheet delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex == actionSheet.cancelButtonIndex) return;

	switch (actionSheet.tag) {
		case 100: {
			if (buttonIndex == actionSheet.destructiveButtonIndex) {
				[[A3UserDefaults standardUserDefaults] removeObjectForKey:[HolidayData keyForExcludedHolidaysForCountry:_countryCode]];
				[[A3UserDefaults standardUserDefaults] synchronize];
				_excludedHolidays = nil;
				[self.tableView reloadData];
				_dataUpdated = YES;
			}
			break;
		}
		case 200: {
			if (buttonIndex == actionSheet.destructiveButtonIndex) {
				A3HolidaysFlickrDownloadManager *downloadManager = [A3HolidaysFlickrDownloadManager sharedInstance];
				[downloadManager deleteImageForCountryCode:_countryCode];
				[self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:2]] withRowAnimation:UITableViewRowAnimationNone];

				_dataUpdated = YES;
				return;
			}

			NSInteger myButtonIndex = buttonIndex;
			_imagePickerController = [[UIImagePickerController alloc] init];
			if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
				myButtonIndex++;
			if (actionSheet.destructiveButtonIndex>=0)
				myButtonIndex--;
			switch (myButtonIndex) {
				case 0:
					_imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
					_imagePickerController.allowsEditing = NO;
					break;
				case 1:
					_imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
					_imagePickerController.allowsEditing = NO;
					break;
				case 2:
					_imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
					_imagePickerController.allowsEditing = YES;
					break;
			}

			_imagePickerController.mediaTypes = @[(NSString *) kUTTypeImage];
			_imagePickerController.navigationBar.barStyle = UIBarStyleDefault;
			_imagePickerController.delegate = self;

			if (IS_IPAD) {
				if (_imagePickerController.sourceType == UIImagePickerControllerSourceTypeCamera) {
					_imagePickerController.showsCameraControls = YES;
					[self presentViewController:_imagePickerController animated:YES completion:NULL];
				}
				else {
					self.imagePickerPopoverController = [[UIPopoverController alloc] initWithContentViewController:_imagePickerController];
					self.imagePickerPopoverController.delegate = self;
					CGRect fromRect;
					if ([[A3HolidaysFlickrDownloadManager sharedInstance] hasUserSuppliedImageForCountry:_countryCode]) {
						UITableViewCell *cell = [self.tableView cellForCellSubview:_imageView];
						fromRect = [self.view convertRect:_imageView.frame fromView:cell];
					} else {
						UITableViewCell *cell = [self.tableView cellForCellSubview:_cameraButton];
						fromRect = [self.view convertRect:_cameraButton.frame fromView:cell];
					}
					[_imagePickerPopoverController presentPopoverFromRect:fromRect inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
				}
			}
			else {
				[self presentViewController:_imagePickerController animated:YES completion:NULL];
			}
			break;
		}
	}
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
	[self dismissImagePickerController];

	UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
	if (!image) {
		image = [info valueForKey:UIImagePickerControllerOriginalImage];
	}
	if (image) {
		[[A3HolidaysFlickrDownloadManager sharedInstance] saveUserSuppliedImage:image forCountryCode:_countryCode];
		_dataUpdated = YES;

		[self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:2]] withRowAnimation:UITableViewRowAnimationNone];
	}
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissImagePickerController];
	_imagePickerController = nil;
}

- (void)dismissImagePickerController {
    if (IS_IPAD && _imagePickerPopoverController) {
        [_imagePickerPopoverController dismissPopoverAnimated:YES];
        _imagePickerPopoverController = nil;
    } else {
        [_imagePickerController dismissViewControllerAnimated:YES completion:NULL];
    }
}

#pragma mark - UIPopoverController Delegate

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
	[self.imagePickerController dismissViewControllerAnimated:YES completion:nil];
	self.imagePickerController = nil;
	self.imagePickerPopoverController = nil;
}

- (void)lunarOnOff:(UISwitch *)switchControl {
	if (switchControl.isOn) {
		[HolidayData addCountryToShowLunarDatesSet:_countryCode];
	} else {
		[HolidayData removeCountryFromShowLunarDatesSet:_countryCode];
	}
	_dataUpdated = YES;
}

@end
