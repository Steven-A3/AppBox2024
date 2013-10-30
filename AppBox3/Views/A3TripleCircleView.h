//
//  A3TripleCircleView.h
//  AppBox3
//
//  Created by A3 on 10/30/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>

// 고정된 크기의 세 개의 원을 보여주는 뷰 입니다.
// 크기는 31, 31로 고정되어 있습니다.
// 가운데 작은 원의 컬러를 바꿀 수 있습니다.
@interface A3TripleCircleView : UIView

@property (nonatomic, strong) UIColor *centerColor;

@end
