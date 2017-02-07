//
//  KaomojiFavorite+CoreDataProperties.m
//  AppBox3
//
//  Created by Byeong-Kwon Kwak on 2/4/17.
//  Copyright © 2017 ALLABOUTAPPS. All rights reserved.
//

#import "KaomojiFavorite+CoreDataProperties.h"

@implementation KaomojiFavorite (CoreDataProperties)

+ (NSFetchRequest<KaomojiFavorite *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"KaomojiFavorite"];
}

@dynamic order;
@dynamic uniqueID;

@end
