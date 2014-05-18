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
#import "UIViewController+A3AppCategory.h"
#import "A3HolidaysEditCell.h"
#import "A3HolidaysAddToDaysCounterViewController.h"
#import "A3ImageCropperViewController.h"
#import "A3HolidaysFlickrDownloadManager.h"
#import "UIViewController+A3Addition.h"
#import "A3HolidaysPageViewController.h"
#import "UIViewController+tableViewStandardDimension.h"

@interface A3HolidaysEditViewController () <UIActionSheetDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIPopoverControllerDelegate, A3ImageCropperDelegate>

@property (nonatomic, strong) NSArray *holidaysForCountry;
@property (nonatomic, strong) NSMutableArray *excludedHolidays;
@property (nonatomic, strong) UIPopoverController *imagePickerPopoverController;

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

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;

	UIBarButtonItem *addToDaysCounter = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"addToDaysCounter"] style:UIBarButtonItemStylePlain target:self action:@selector(addToDaysCounter:)];
	self.navigationItem.leftBarButtonItem = addToDaysCounter;

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

	if ([self isBeingDismissed]) {
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
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"This will rest all settigns.\nNo data will be deleted." delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Reset All" otherButtonTitles:nil];
	[actionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex == actionSheet.destructiveButtonIndex) {
		[[NSUserDefaults standardUserDefaults] removeObjectForKey:[HolidayData keyForExcludedHolidaysForCountry:_countryCode]];
		[[NSUserDefaults standardUserDefaults] synchronize];
        _excludedHolidays = nil;
		[self.tableView reloadData];
		_dataUpdated = YES;
	}
}

#pragma mark - Setup data

- (void)setCountryCode:(NSString *)countryCode {
	_countryCode = [countryCode mutableCopy];
	HolidayData *holidayData = [HolidayData new];
	_holidaysForCountry = [holidayData holidaysForCountry:_countryCode year:[HolidayData thisYear] fullSet:YES ];
	NSArray *excludedList = [[NSUserDefaults standardUserDefaults] objectForKey:[HolidayData keyForExcludedHolidaysForCountry:_countryCode]];
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
				cell.textLabel.text = @"Reset Show/Hide Settings";
				cell.textLabel.textColor = self.view.tintColor;
				break;
			case 2:
			{

				if ([[A3HolidaysFlickrDownloadManager sharedInstance] hasUserSuppliedImageForCountry:_countryCode]) {
					cell.textLabel.textColor = [UIColor colorWithRed:255.0/255.0 green:58.0/255.0 blue:48.0/255.0 alpha:1.0];
					cell.textLabel.text = @"Delete Wallpaper";
					UIImageView *imageView = [[A3HolidaysFlickrDownloadManager sharedInstance] thumbnailOfUserSuppliedImageForCountryCode:_countryCode];
					imageView.layer.borderColor = [UIColor colorWithWhite:1.0 alpha:1.0].CGColor;
					imageView.layer.borderWidth = 0.1;
					imageView.layer.cornerRadius = 15;
					imageView.layer.masksToBounds = YES;
					cell.accessoryView = imageView;
				} else {
					cell.textLabel.textColor = [UIColor blackColor];
					cell.textLabel.text = @"Choose Wallpaper";
					cell.accessoryView = [self cameraButton];
				}
				break;
			}
			case 3:{
				cell.textLabel.text = @"Show Lunar Date";
				UISwitch *switchControl = [self lunarSwitch];
				[switchControl setOn:[HolidayData needToShowLunarDatesForCountryCode:_countryCode]];
				cell.accessoryView = switchControl;
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
			[self pickWallpaper];
			break;
		case 3: {
			UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
			[self lunarOnOff:(UISwitch *) cell.accessoryView];
		}
	}
}

- (UIButton *)cameraButton {
	UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
	[button setImage:[UIImage imageNamed:@"camera.png"] forState:UIControlStateNormal];
	[button addTarget:self action:@selector(pickWallpaper) forControlEvents:UIControlEventTouchUpInside];
	[button sizeToFit];
	return button;
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
	[[NSUserDefaults standardUserDefaults] setObject:_excludedHolidays forKey:[HolidayData keyForExcludedHolidaysForCountry:_countryCode]];
	[[NSUserDefaults standardUserDefaults] synchronize];

	_dataUpdated = YES;
}

- (UISwitch *)lunarSwitch {
	UISwitch *lunarControl = [UISwitch new];
	[lunarControl addTarget:self action:@selector(lunarOnOff:) forControlEvents:UIControlEventValueChanged];
	return lunarControl;
}

- (void)pickWallpaper {
	A3HolidaysFlickrDownloadManager *downloadManager = [A3HolidaysFlickrDownloadManager sharedInstance];
	if ([downloadManager hasUserSuppliedImageForCountry:_countryCode]) {
		[downloadManager deleteImageForCountryCode:_countryCode];
		[self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:2]] withRowAnimation:UITableViewRowAnimationNone];

		_dataUpdated = YES;
	} else {
		UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
		imagePickerController.modalPresentationStyle = UIModalPresentationCurrentContext;
		imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
		imagePickerController.delegate = self;

		if (IS_IPHONE) {
			[self presentViewController:imagePickerController animated:YES completion:nil];
		} else {
			_imagePickerPopoverController = [[UIPopoverController alloc] initWithContentViewController:imagePickerController];
			UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:2]];
			[_imagePickerPopoverController presentPopoverFromRect:[self.view convertRect:cell.frame fromView:self.tableView] inView:self.view permittedArrowDirections:UIPopoverArrowDirectionDown animated:YES];
			_imagePickerPopoverController.delegate = self;
		}
	}
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
	if (IS_IPHONE) {
		[self dismissViewControllerAnimated:YES completion:nil];
	} else {
		[_imagePickerPopoverController dismissPopoverAnimated:YES];
		_imagePickerPopoverController = nil;
	}

	UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];
	if (image) {
		A3ImageCropperViewController *cropper = [[A3ImageCropperViewController alloc] initWithImage:image withHudView:nil];
		cropper.delegate = self;
		[self.navigationController pushViewController:cropper animated:YES];
	} else {
        [self dismissImagePickerController];
	}
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissImagePickerController];
}

- (void)dismissImagePickerController {
    if (IS_IPAD) {
        [_imagePickerPopoverController dismissPopoverAnimated:YES];
        _imagePickerPopoverController = nil;
    } else {
        [self dismissViewControllerAnimated:YES completion:NULL];
    }
}

- (void)restoreNavigationBarBackground {
	[self.navigationController.navigationBar setBackgroundImage:nil forBarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
	[self.navigationController.navigationBar setShadowImage:nil];
}

- (void)imageCropper:(A3ImageCropperViewController *)cropper didFinishCroppingWithImage:(UIImage *)image {
	[[A3HolidaysFlickrDownloadManager sharedInstance] saveUserSuppliedImage:image forCountryCode:_countryCode];
	_dataUpdated = YES;

	double delayInSeconds = 0.5;
	dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
	dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
		[self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:2]] withRowAnimation:UITableViewRowAnimationNone];
	});
	[self restoreNavigationBarBackground];
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)imageCropperDidCancel:(A3ImageCropperViewController *)cropper {
	[self restoreNavigationBarBackground];
	[self.navigationController popViewControllerAnimated:YES];
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
