//
//  AbbreviationFavorite+CoreDataProperties.h
//  AppBox3
//
//  Created by Byeong-Kwon Kwak on 1/26/17.
//  Copyright © 2017 ALLABOUTAPPS. All rights reserved.
//

#import "AbbreviationFavorite+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface AbbreviationFavorite (CoreDataProperties)

+ (NSFetchRequest<AbbreviationFavorite *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *order;
@property (nullable, nonatomic, copy) NSString *uniqueID;

@end

NS_ASSUME_NONNULL_END
