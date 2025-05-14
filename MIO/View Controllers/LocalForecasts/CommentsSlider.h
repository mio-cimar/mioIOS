//
//  CommentsSlider.h
//  MIO
//
//  Created by Ronny Libardo Bustos Jiménez on 15/8/17.
//  Copyright © 2017 MIO CIMAR. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CommentsSlider : UIView

@property (copy, nonatomic) void (^didMoveToPage)(NSInteger page);

- (void)setupWithNumberOfPages:(NSInteger)pages;
- (void)addPage:(UIView *)page;
- (void)goToPage:(CGFloat)page;
- (void)reset;
- (CGRect)cardFrame;


@end
