//
//  A3ClockFoldingView.m
//  A3TeamWork
//
//  Created by Sanghyun Yu on 2013. 11. 27..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3ClockFoldingView.h"
#import "A3ClockFoldPaperView.h"
#import "A3ClockDataManager.h"


@implementation A3ClockFoldingView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        A3ClockFoldPaperView * paper = [[A3ClockFoldPaperView alloc] initWithFrame:self.bounds];
        [self setFrontView:paper];
        paper = [[A3ClockFoldPaperView alloc] initWithFrame:self.bounds];
        [self setBackView:paper];
        
//        [self setBackgroundColor:[UIColor greenColor]];
    }
    return self;
}

#pragma mark - protected
- (void)setFrontView:(UIView *)frontView
{
    [super setFrontView:frontView];
    
    [frontView makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.centerX).with.offset(0);
        make.centerY.equalTo(self.centerY).with.offset(0);
        make.width.equalTo(self.width).with.offset(0);
        make.height.equalTo(self.height).with.offset(0);
    }];
}

#pragma mark - public
- (void)foldingWithText:(NSString*)aText;
{
//    A3ClockFoldPaperView* paper = (A3ClockFoldPaperView*)self.frontView;

    /* //nonononono
//    if(paper != nil)// 이렇게 새로 생성하지 않으면 뷰들이 왼쪽위로 튄다...
//    {
//        NSString* strTemp = paper.lbTime.text;
//        paper = [[A3ClockFoldPaperView alloc] initWithFrame:self.bounds];
//        paper.lbTime.text = strTemp;
//        [self setFrontView:paper];
//    }
     */
    
//    if(paper.lbTime.text == nil ||
//       (paper.lbTime.text != nil && ![paper.lbTime.text isEqualToString:aText]))
//    {
//        paper = [[A3ClockFoldPaperView alloc] initWithFrame:self.bounds];
//        paper.lbTime.text = aText;
//        
//        [self setBackView:paper];
//        [self tick:SBTickerViewTickDirectionDown animated:YES completion:nil];
//    }
    
    
    A3ClockFoldPaperView * paper = (A3ClockFoldPaperView *)self.frontView;
    
    
    if(paper.lbTime.text == nil ||
       (paper.lbTime.text != nil && ![paper.lbTime.text isEqualToString:aText]))
    {
        paper = [[A3ClockFoldPaperView alloc] initWithFrame:self.bounds];
        paper.lbTime.text = aText;
        
        [self setBackView:paper];
        
            [self tick:SBTickerViewTickDirectionDown animated:YES completion:nil];
    }
    else
    {
        paper = [[A3ClockFoldPaperView alloc] initWithFrame:self.bounds];
        paper.lbTime.text = aText;
        
        [self setBackView:paper];
        [self tick:SBTickerViewTickDirectionDown animated:NO completion:nil];// elf 수정중
    }
    
//    [self.frontView setba]
}


- (void)layoutIfNeeded
{
    [super layoutIfNeeded];
}

@end
