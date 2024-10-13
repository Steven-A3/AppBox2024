//
//  AbbreviationFavorite+CoreDataProperties.m
//  AppBox3
//
//  Created by Byeong-Kwon Kwak on 1/26/17.
//  Copyright © 2017 ALLABOUTAPPS. All rights reserved.
//

#import "AbbreviationFavorite+CoreDataProperties.h"

@implementation AbbreviationFavorite (CoreDataProperties)

+ (NSFetchRequest<AbbreviationFavorite *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"AbbreviationFavorite_"];
}

@dynamic order;
@dynamic uniqueID;

@end
