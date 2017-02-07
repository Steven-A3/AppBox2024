//
//  A3DrillDownDataSourceProtocols.h
//  AppBox3
//
//  Created by Byeong-Kwon Kwak on 2/7/17.
//  Copyright © 2017 ALLABOUTAPPS. All rights reserved.
//

#ifndef A3DrillDownDataSourceProtocols_h
#define A3DrillDownDataSourceProtocols_h


#endif /* A3DrillDownDataSourceProtocols_h */

@protocol A3DrillDownDataSource <NSObject>

- (void)deleteItemForContent:(id)content;
- (void)moveItemForContent:(id)content fromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex;

@end
