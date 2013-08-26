//
//  A3HolidaysViewController.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 8/22/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3HolidaysViewController.h"
#import "A3FlickrImageView.h"
#import "UIViewController+navigation.h"
#import "SFKImage.h"
#import "A3UIDevice.h"
#import "common.h"

static NSString *const kHolidayViewComponentBorderView = @"borderView";		// bounds equals to self.view.bounds
static NSString *const kHolidayViewComponentImageView = @"imageView";		// bounds equals to alledgeInsets -50
static NSString *const kHolidayViewComponentTableView = @"tableView";		// bounds eqauls to bottom inset 54 from self.view.bounds

@interface A3HolidaysViewController () <A3FlickrImageViewDelegate, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate>

@property (nonatomic, strong) A3FlickrImageView *backgroundImageView;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) NSMutableArray *viewComponents;
@property (nonatomic, strong) UILabel *photoLabel;
@property (nonatomic, strong) UIPageControl *pageControl;
@property (nonatomic, strong) UIView *footerView;
@property (nonatomic, strong) NSArray *countries;

@end

@implementation A3HolidaysViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

	[[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:YES];

	_countries = @[@"kr", @"us", @"jp", @"de"];

	[self.navigationController setNavigationBarHidden:YES];

	[self setupScrollView];
	[self setupFooterView];		// Page Control must be setup first, left refers its numberOfPages

	[self leftBarButtonAppsButton];

	[self.view layoutIfNeeded];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

	if (self.isMovingToParentViewController) {
		[_backgroundImageView displayImage];
		[_backgroundImageView updateImage];
	}
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];

	if (self.isMovingFromParentViewController) {
		[self.navigationController setNavigationBarHidden:NO];
		[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:YES];
	}
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Layout
- (void)viewDidLayoutSubviews {
	[super viewDidLayoutSubviews];

	CGFloat viewHeight = self.view.bounds.size.height;
	_scrollView.contentSize = CGSizeMake(self.view.bounds.size.width * _pageControl.numberOfPages, viewHeight);
	[self.viewComponents enumerateObjectsUsingBlock:^(NSDictionary *viewComponent, NSUInteger idx, BOOL *stop) {
		UIView *borderView = viewComponent[kHolidayViewComponentBorderView];
		[borderView setFrame:CGRectMake(self.view.bounds.size.width * idx, 0, self.view.bounds.size.width, viewHeight)];
		if (borderView.frame.origin.x == _scrollView.contentOffset.x) {
			[_scrollView bringSubviewToFront:borderView];
			borderView.clipsToBounds = NO;
		}
	}];
	FNLOG(@"contentSize %f", _scrollView.contentSize.width);
	FNLOG(@"contentOffset %f", _scrollView.contentOffset.x);
}

#pragma mark - Footer View / similar but white border color, clearColored background

- (void)setupFooterView {
	_footerView = [UIView new];
	[self.view addSubview:_footerView];

	[_footerView makeConstraints:^(MASConstraintMaker *make) {
		make.left.equalTo(self.view.left);
		make.right.equalTo(self.view.right);
		make.bottom.equalTo(self.view.bottom);
		make.height.equalTo(@44);
	}];

	UIView *line = [UIView new];
	line.backgroundColor = [UIColor clearColor];
	line.layer.borderColor = [UIColor colorWithWhite:1.0 alpha:0.8].CGColor;
	line.layer.borderWidth = IS_RETINA ? 0.25 : 0.5;
	[self.view addSubview:line];

	[line makeConstraints:^(MASConstraintMaker *make) {
		make.left.equalTo(self.view.left);
		make.right.equalTo(self.view.right);
		make.bottom.equalTo(self.view.bottom).with.offset(-44);
		make.height.equalTo(@1);
	}];

	[self photoLabel];
	[self setPhotoLabelText];

	[self pageControl];

	UIButton *listButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[listButton setImage:[[UIImage imageNamed:@"list"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
	[listButton addTarget:self action:@selector(listButtonAction) forControlEvents:UIControlEventTouchUpInside];
	[listButton setTintColor:[UIColor whiteColor]];
	[self.view addSubview:listButton];

	[listButton makeConstraints:^(MASConstraintMaker *make) {
		make.right.equalTo(_footerView.right).with.offset(IS_IPAD ? -28 : -15);
		make.centerY.equalTo(_footerView.centerY);
	}];
}

- (UIPageControl *)pageControl {
	if (!_pageControl) {
		_pageControl = [UIPageControl new];
		[_footerView addSubview:_pageControl];
		_pageControl.numberOfPages = [_viewComponents count];

		[_pageControl makeConstraints:^(MASConstraintMaker *make) {
			make.centerX.equalTo(_footerView.centerX);
			make.centerY.equalTo(_footerView.centerY);
		}];
	}
	return _pageControl;
}

- (UILabel *)photoLabel {
	if (!_photoLabel) {
		_photoLabel = [UILabel new];
		_photoLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption2];
		_photoLabel.textColor = [UIColor whiteColor];
		_photoLabel.numberOfLines = 2;
		_photoLabel.userInteractionEnabled = YES;
		[_footerView addSubview:_photoLabel];

		[_photoLabel makeConstraints:^(MASConstraintMaker *make) {
			make.left.equalTo(_footerView.left).with.offset(IS_IPAD ? 28 : 15);
			make.centerY.equalTo(_footerView.centerY);
		}];

		UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openURL)];
		[_photoLabel addGestureRecognizer:tapGestureRecognizer];
	}
	return _photoLabel;
}

- (void)setPhotoLabelText {
	NSString *owner = [[NSUserDefaults standardUserDefaults] objectForKey:kA3HolidayScreenImageOwner];
	self.photoLabel.text = [NSString stringWithFormat:@"by %@\non flickr", owner];
}

- (void)flickrImageViewImageUpdated:(A3FlickrImageView *)view {
	[self setPhotoLabelText];
}

- (void)openURL {
	NSURL *url = [NSURL URLWithString:[[NSUserDefaults standardUserDefaults] objectForKey:kA3HolidayScreenImageURL]];
	UIApplication *application = [UIApplication sharedApplication];
	if (url && [application canOpenURL:url]) {
		[application openURL:url];
	}
}

- (void)listButtonAction {

}

#pragma mark - Setup ScrollView
- (void)setupScrollView {
	_scrollView = [UIScrollView new];
	_scrollView.backgroundColor = [UIColor clearColor];
	_scrollView.pagingEnabled = YES;
	_scrollView.delegate = self;
	_scrollView.directionalLockEnabled = YES;
	[self.view addSubview:_scrollView];

	[_scrollView makeConstraints:^(MASConstraintMaker *make) {
		make.edges.equalTo(self.view);
	}];

	[self setupScrollViewContents];
}

- (void)setupScrollViewContents {
	_viewComponents = [NSMutableArray new];

	CGFloat viewWidth = self.view.bounds.size.width;
	CGFloat viewHeight = self.view.bounds.size.height;
	NSInteger idx = 0;
	for (NSString *country in _countries) {
		// Border view
		UIView *borderView = [UIView new];
		borderView.frame = CGRectMake(idx * viewWidth, 0, viewWidth, viewHeight);
		borderView.tag = idx;
		borderView.backgroundColor = [UIColor clearColor];
		borderView.clipsToBounds = YES;
		[_scrollView addSubview:borderView];

		A3FlickrImageView *imageView = [A3FlickrImageView new];
		imageView.delegate = self;
		imageView.tag = idx;
		[borderView addSubview:imageView];

		[imageView makeConstraints:^(MASConstraintMaker *make) {
			make.edges.equalTo(borderView).insets(UIEdgeInsetsMake(-50, -50, -50, -50));
		}];

		UIInterpolatingMotionEffect *interpolationHorizontal = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.x" type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
		interpolationHorizontal.minimumRelativeValue = @-50.0;
		interpolationHorizontal.maximumRelativeValue = @50.0;

		UIInterpolatingMotionEffect *interpolationVertical = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.y" type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
		interpolationVertical.minimumRelativeValue = @-50.0;
		interpolationVertical.maximumRelativeValue = @50.0;

		[imageView addMotionEffect:interpolationHorizontal];
		[imageView addMotionEffect:interpolationVertical];

		[imageView displayImage];
		[imageView updateImageWithCountryCode:country];

		UITableView *tableView = [self tableView];
		tableView.tag = idx;
		[borderView addSubview:tableView];

		[tableView makeConstraints:^(MASConstraintMaker *make) {
			make.edges.equalTo(borderView).insets(UIEdgeInsetsMake(0, 0, 54, 0));
		}];

		[self.viewComponents addObject:@{
				kHolidayViewComponentBorderView : borderView,
				kHolidayViewComponentImageView : imageView,
				kHolidayViewComponentTableView : tableView
		}];
	}
}

#pragma mark - Setup TableView

static NSString *const CellIdentifier = @"myCellIdentifier";

- (UITableView *)tableView {
	UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
	tableView.dataSource = self;
	tableView.delegate = self;
	tableView.backgroundView = nil;
	tableView.backgroundColor = [UIColor clearColor];
	tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:CellIdentifier];
	return tableView;
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 30;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];

	if (!cell) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
	}

    cell.backgroundColor = [UIColor clearColor];
	cell.textLabel.text = [NSString stringWithFormat:@"My name is %d", tableView.tag];
	cell.textLabel.textColor = [UIColor whiteColor];
	cell.selectionStyle = UITableViewCellSelectionStyleNone;

    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	[super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
	if (scrollView == _scrollView) {
        FNLOG(@"%f, %f", scrollView.contentSize.height, scrollView.bounds.size.height);

		NSInteger currentPage = (NSInteger) (scrollView.contentOffset.x / self.view.bounds.size.width);
		UIView *borderView = _viewComponents[currentPage][kHolidayViewComponentBorderView];
		[_scrollView bringSubviewToFront:borderView];
		borderView.clipsToBounds = NO;
	}
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
	if (scrollView == _scrollView) {
		[_viewComponents enumerateObjectsUsingBlock:^(NSDictionary *viewComponent, NSUInteger idx, BOOL *stop) {
			UIView *borderView = viewComponent[kHolidayViewComponentBorderView];
			borderView.clipsToBounds = YES;
		}];
	}
}

@end
