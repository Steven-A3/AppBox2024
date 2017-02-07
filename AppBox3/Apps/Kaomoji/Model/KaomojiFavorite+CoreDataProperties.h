//
//  KaomojiFavorite+CoreDataProperties.h
//  AppBox3
//
//  Created by Byeong-Kwon Kwak on 2/4/17.
//  Copyright © 2017 ALLABOUTAPPS. All rights reserved.
//

#import "KaomojiFavorite+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface KaomojiFavorite (CoreDataProperties)

+ (NSFetchRequest<KaomojiFavorite *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *order;
@property (nullable, nonatomic, copy) NSString *uniqueID;

@end

NS_ASSUME_NONNULL_END
