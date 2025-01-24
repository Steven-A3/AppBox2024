//
//  A3UnitDataManager.h
//  A3TeamWork
//
//  Created by kihyunkim on 13. 10. 18..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

BOOL validUnit(NSNumber *value);

@interface A3UnitDataManager : NSObject

- (NSArray *)allCategories;
- (NSString *)localizedCategoryNameForID:(NSInteger)index1;
- (NSString *)categoryNameForID:(NSInteger)index1;
- (NSMutableArray *)allUnitsSortedByLocalizedNameForCategoryID:(NSUInteger)categoryID;
- (NSString *)localizedUnitNameForUnitID:(NSInteger)unitID categoryID:(NSInteger)categoryID;
- (NSString *)unitNameForUnitID:(NSInteger)unitID categoryID:(NSInteger)categoryID;
- (NSString *)iconNameForID:(NSUInteger)index1;
- (NSString *)selectedIconNameForID:(NSUInteger)index1;
- (NSArray *)unitConvertItems;
- (NSArray *)unitConvertItemsForCategoryID:(NSUInteger)categoryID;
- (NSArray *)allFavorites;
- (NSArray *)favoritesForCategoryID:(NSInteger)categoryID;
- (void)saveFavorites:(NSArray *)favorites categoryID:(NSUInteger)categoryID;
- (void)addUnitToConvertItemForUnit:(NSUInteger)unitID categoryID:(NSUInteger)categoryID;
- (BOOL)isFavoriteForUnitID:(NSUInteger)unitID categoryID:(NSUInteger)categoryID;
- (void)saveUnitData:(id)data forKey:(NSString *)key;
- (NSMutableArray *)allUnitPriceFavorites;
- (NSMutableArray *)unitPriceFavoriteForCategoryID:(NSUInteger)categoryID;
- (void)saveUnitPriceFavorites:(NSArray *)favorites categoryID:(NSUInteger)categoryID;
- (void)saveUnitPriceData:(id)data forKey:(NSString *)key;
- (void)replaceConvertItems:(NSArray *)newConvertItems forCategory:(NSUInteger)categoryID;

extern const int numOfUnitType;
extern const int numberOfUnits[];
extern const char *unitTypes[];
extern const char *unitNames[][34];
extern const char *unitShortNames[][34];
extern const double conversionTable[][34];

@end
