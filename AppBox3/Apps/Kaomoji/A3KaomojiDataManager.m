//
//  A3KaomojiDataManager.m
//  AppBox3
//
//  Created by Byeong-Kwon Kwak on 2/4/17.
//  Copyright © 2017 ALLABOUTAPPS. All rights reserved.
//

#import "A3KaomojiDataManager.h"
#import "CGColor+Additions.h"
#import "UIColor+A3Addition.h"
#import "KaomojiFavorite+CoreDataClass.h"
#import "NSManagedObject+extension.h"
#import "NSManagedObjectContext+extension.h"
#import "NSMutableArray+A3Sort.h"
#import "A3KaomojiDrillDownViewController.h"
#import "NSManagedObject+extension.h"
#import "NSManagedObjectContext+extension.h"
#import "A3SyncManager.h"

NSString *const A3KaomojiKeyCategory = @"category";
NSString *const A3KaomojiKeyContents = @"contents";

@implementation A3KaomojiDataManager

+ (A3KaomojiDataManager *)instance {
	A3KaomojiDataManager *dataManager = [A3KaomojiDataManager new];
	return dataManager;
}

- (NSArray *)contentsArray {
	if (!_contentsArray) {
		_contentsArray = @[
				@{
						A3KaomojiKeyCategory: @"Happy",
						A3KaomojiKeyContents: @[
						@"(≧∇≦)/",
						@"(*^▽^*)",
						@"∩( ・ω・)∩",
						@"( ・ω・)",
						@"(◑‿◐)",
						@"( ´ ▽ ` )ﾉ",
						@"(*⌒▽⌒*)θ～♪",
						@"(*＾v＾*)",
						@"( ^_^)／",
						@"o(≧∇≦o)"
				]},
				@{
						A3KaomojiKeyCategory: @"Smug",
						A3KaomojiKeyContents: @[
						@"（￣ー￣）",
						@"(￣^￣)",
						@"（￣へ￣）",
						@"(￣ェ￣;)",
						@"（￣～￣;）",
						@"ー(￣～￣)ξ",
						@"(`へ´*)ノ",
						@"(-、-)",
						@"(｡•ˇ‸ˇ•｡)",
						@"(￣ω￣;)"
				]},
				@{
						A3KaomojiKeyCategory: @"Shy",
						A3KaomojiKeyContents: @[
						@"(>_<)>",
						@"(^_^;)",
						@"(^^ゞ",
						@"(^^;)",
						@"(#^.^#)",
						@"（＠´＿｀＠）",
						@"(⌒_⌒;)",
						@"（*/∇＼*）",
						@"(*^^*)",
						@"(〃￣ω￣〃ゞ",
						@"(*´∀`*)",
						@"(‘-‘*)",
						@"(*´ｪ｀*)",
						@"(#｀ε´#ゞ",
						@"(*ﾉ▽ﾉ)",
						@"（。-＿-。）",
						@"((*ﾉωﾉ)",
						@"(*´∀`*)",
						@"(*´_ゝ｀)",
						@"（/｡＼)",
						@"(/ω＼)",
						@"(#／。＼#)",
				]},
				@{
						A3KaomojiKeyCategory: @"Sad",
						A3KaomojiKeyContents: @[
						@"(ToT)",
						@"(Ｔ▽Ｔ)",
						@"( p_q)",
						@"(。┰ω┰。)",
						@"(ㄒoㄒ)",
						@"（´＿｀）",
						@"╥﹏╥",
						@"p(´⌒｀｡q)",
						@"( ≧Д≦)",
						@"ヽ(●ﾟ´Д｀ﾟ●)ﾉﾟ",
						@"(个_个)",
						@"｡゜(｀Д´)゜｡",
						@"o(；△；)o",
						@"((´д｀))",
						@".・゜゜・（／。＼）・゜゜・．",
						@"（；￣д￣）",
						@"((o(;△;)o))",
						@"{{p´Д｀q}}",
						@"(/□＼*)・゜",
						@"⊙︿⊙",
						@"╥﹏╥",
						@"o(╥﹏╥)o",
						@"(;*△*;)",
						@"☆￣(＞。☆",
						@"(。_＋)＼",
						@"／(x~x)＼",
						@"/(*ι*)ヾ",
						@"~(>_< 。)＼)",
						@"(ノ>< )ノ",
						@"ヘ（。□°）ヘ",
				]},
				@{
						A3KaomojiKeyCategory: @"Surprised",
						A3KaomojiKeyContents: @[
						@"（￣□￣；）",
						@"（　ﾟ Дﾟ）",
						@"（゜◇゜）",
						@"（／．＼）",
						@"（／_＼）",
						@"(／。＼)",
						@"ヽ(ﾟДﾟ)ﾉ",
						@"(ノдヽ)",
						@"(∑(O_O；)",
						@"＼(>o< )／",
						@"Σ(゜ロ゜;)",
						@"(」゜ロ゜)」",
						@"(*ﾟﾛﾟ)",
						@"((((；゜Д゜)))",
						@"( ꒪Д꒪)ノ",
						@"(ﾉﾟ0ﾟ)ﾉ~",
						@"(((( ;°Д°))))",
						@"Σ(゜゜)",
						@"⊙０⊙",
						@"w(°ｏ°)w",
						@"(○o○)",
						@"щ(゜ロ゜щ)",
				]},
				@{
						A3KaomojiKeyCategory: @"Love",
						A3KaomojiKeyContents: @[
						@"（*´▽｀*）",
						@"(*°∀°)=3",
						@"(´∀｀)♡",
						@"(｡･ω･｡)ﾉ♡",
						@"（＿´ω｀）",
						@"(o⌒．⌒o)",
						@"♥（ﾉ´∀`）",
						@"(ღ˘⌣˘ღ)",
						@"(‘∀'●)♡",
						@"♡o｡.(✿ฺ｡ ✿ฺ)",
						@"ヽ(愛´∀｀愛)ノ",
						@"（人´∀`*）",
						@"（●´∀｀）ノ♡",
						@"(´ ▽｀).。ｏ♡",
						@"(●♡∀♡)",
						@"(｡'▽'｡)♡",
						@"♡＾▽＾♡",
						@"（´ω｀♡%）",
						@"(´ε｀ )♡",
						@"|°з°|",
						@"|(￣3￣)|",
						@"（￣ε￣＠）",
						@"（○゜ε＾○）",
						@"(☆´3｀)",
						@"(‘ε')",
						@"（*＾3＾）",
						@"（＿ε＿）",
						@"～(^з^)-☆",
						@"(´ε｀*)",
						@"(○´3｀)ﾉ",
						@"(-ε- )",
						@"(*￣з￣)",
						@"(TεT)",
						@"（＠ーεー＠）",
						@"ლ(|||⌒εー|||)ლ",
				]},
				@{
						A3KaomojiKeyCategory: @"Worried",
						A3KaomojiKeyContents: @[
						@"(ーー;)",
						@"( ；´Д｀)",
						@"（；￣ェ￣）",
						@"( ´△｀)",
						@"⊙﹏⊙",
						@"ミ●﹏☉ミ",
						@"(-‘๏_๏'-)",
						@"(⊙…⊙ )",
						@"ヽ(￣д￣;)ノ",
						@"(￣◇￣;)",
						@"（−＿−；）",
						@"(~_~;)",
						@"ヽ(￣д￣;)ノ",
						@"（°o°；）",
						@"ヽ（゜ロ゜；）ノ",
				]},
				@{
						A3KaomojiKeyCategory: @"Depressed",
						A3KaomojiKeyContents: @[
						@"＿|￣|○",
						@"orz",
						@"OTL",
						@"（◞‸◟）",
						@"(´・ω・｀)",
						@"(-д-；)",
						@"(ｏ´_｀ｏ)",
						@"(*´Д｀)=з",
						@"(∥￣■￣∥)",
						@"(´・＿・`)",
				]},
				@{
						A3KaomojiKeyCategory: @"Dissatisfied",
						A3KaomojiKeyContents: @[
						@"(*￣m￣)",
						@"(￢_￢;)",
						@"(￣︿￣)",
						@"(ᗒᗣᗕ)՞",
						@"(￣ ￣|||)",
						@"(︶︹︺)",
						@"(；⌣̀_⌣́)",
				]},
				@{
						A3KaomojiKeyCategory: @"Mellow",
						A3KaomojiKeyContents: @[
						@"ヽ（´ー｀）┌",
						@"ヽ(＊⌒∇^)ﾉ",
						@" ¯\\_(ツ)_/¯",
						@"ヽ(。_°)ノ",
						@"ヽ( ´¬`)ノ",
						@"ヽ（*ω。）ノ",
						@"（＾～＾）",
				]},
				@{
						A3KaomojiKeyCategory: @"Laughing",
						A3KaomojiKeyContents: @[
						@"（＾_＾）",
						@"（＾_＾）v",
						@"(＾▽＾)",
						@"（・∀・）",
						@"（⌒▽⌒）",
						@"（＾ｖ＾）",
						@"（’-’*)",
						@"(゜∀゜)",
				]},
				@{
						A3KaomojiKeyCategory: @"Apologizing",
						A3KaomojiKeyContents: @[
						@"m(_ _)m",
						@"< (_ _)>",
						@"m(._.)m",
						@"（ﾉ´д｀）",
						@"＜(。_。)＞",
						@"(シ_ _)シ",
						@"ｍ（＿　＿；；ｍ",
				]},

		];
#ifdef DEBUG
		NSInteger numberOfKaomoji = 0;
		for (NSDictionary *group in _contentsArray) {
			numberOfKaomoji += [group[A3KaomojiKeyContents] count];
		}
		FNLOG(@"Total: %ld", (long)numberOfKaomoji);
#endif
	}
	return _contentsArray;
}

- (NSArray *)favoritesArray {
	NSArray *results = [KaomojiFavorite findAllSortedBy:@"order" ascending:YES];
	return [results valueForKey:@"uniqueID"];
}

- (NSArray *)categoryColors {
	if (!_categoryColors) {
		_categoryColors = @[
				[UIColor colorFromHexString:@"FFE3E3"],
				[UIColor colorFromHexString:@"FFDEEB"],
				[UIColor colorFromHexString:@"F3D9FA"],
				[UIColor colorFromHexString:@"E5DBFF"],
				[UIColor colorFromHexString:@"DBE4FF"],
				[UIColor colorFromHexString:@"CCEDFF"],
				[UIColor colorFromHexString:@"C5F6FA"],
				[UIColor colorFromHexString:@"C3FAE8"],
				[UIColor colorFromHexString:@"D3F9D8"],
				[UIColor colorFromHexString:@"E9FAC8"],
				[UIColor colorFromHexString:@"FFF3BF"],
				[UIColor colorFromHexString:@"FFE8CC"],
		];
	}
	return _categoryColors;
}

- (NSArray *)titleColors {
	if (!_titleColors) {
		_titleColors = @[
				[UIColor colorFromHexString:@"F03E3E"],
				[UIColor colorFromHexString:@"D6336C"],
				[UIColor colorFromHexString:@"AE3EC9"],
				[UIColor colorFromHexString:@"7048E8"],
				[UIColor colorFromHexString:@"4263E8"],
				[UIColor colorFromHexString:@"1C7CD6"],
				[UIColor colorFromHexString:@"1098AD"],
				[UIColor colorFromHexString:@"0CA678"],
				[UIColor colorFromHexString:@"37B24D"],
				[UIColor colorFromHexString:@"74B816"],
				[UIColor colorFromHexString:@"F59F00"],
				[UIColor colorFromHexString:@"F76707"],
		];
	}
	return _titleColors;
}

#pragma mark - A3SharePopupViewDataSource

- (void)saveCoreData {
    NSManagedObjectContext *context = A3SyncManager.sharedSyncManager.persistentContainer.viewContext;
    if ([context hasChanges]) {
        NSError *saveError = nil;
        [context save:&saveError];
        if (saveError) {
            FNLOG(@"%@", saveError);
        }
    }
}

- (BOOL)isMemberOfFavorites:(NSString *)titleString {
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@", @"uniqueID", titleString];
	NSArray *result = [KaomojiFavorite findAllWithPredicate:predicate];
	return [result count] > 0;
}

- (void)addToFavorites:(NSString *)titleString {
    NSManagedObjectContext *context = A3SyncManager.sharedSyncManager.persistentContainer.viewContext;
    KaomojiFavorite *favorite = [[KaomojiFavorite alloc] initWithContext:context];
	favorite.uniqueID = titleString;
	[favorite assignOrderAsLast];
	[context saveIfNeeded];
}

- (void)removeFromFavorites:(NSString *)titleString {
    NSManagedObjectContext *context = A3SyncManager.sharedSyncManager.persistentContainer.viewContext;
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@", @"uniqueID", titleString];
	NSArray *result = [KaomojiFavorite findAllWithPredicate:predicate];
	if ([result count]) {
		for (KaomojiFavorite *favorite in result) {
            [context deleteObject:favorite];
		}
        [context saveIfNeeded];
    }
}

- (NSString *)stringForShare:(NSString *)titleString {
	return titleString;
}

- (NSString *)subjectForActivityType:(NSString *)activityType {
	if ([activityType isEqualToString:UIActivityTypeMail]) {
		return NSLocalizedString(@"Kaomoji reference on the AppBox Pro", nil);
	}
	return @"";
}

- (NSString *)placeholderForShare:(NSString *)titleString {
	return NSLocalizedString(@"Kaomoji reference on the AppBox Pro", nil);
}

#pragma mark - A3KaomojiDrillDownDataSource
// Favorites can delete or reorder the items

- (void)deleteItemForContent:(NSString *)content {
    NSManagedObjectContext *context = A3SyncManager.sharedSyncManager.persistentContainer.viewContext;
	NSArray *results = [KaomojiFavorite findByAttribute:@"uniqueID" withValue:content];
	if ([results count] > 0) {
		for (KaomojiFavorite *favorite in results) {
            [context deleteObject:favorite];
		}
        [context saveIfNeeded];
    }
}

- (void)moveItemForContent:(id)content fromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex {
    NSManagedObjectContext *context = A3SyncManager.sharedSyncManager.persistentContainer.viewContext;
	NSMutableArray *favoriteKeys = [[KaomojiFavorite findAllSortedBy:@"order" ascending:YES] mutableCopy];
	FNLOG(@"%@", favoriteKeys);
	[favoriteKeys moveItemInSortedArrayFromIndex:fromIndex toIndex:toIndex];
	FNLOG(@"%@", favoriteKeys);

    [context saveIfNeeded];
}

@end
