//
//  CommentsSlider.m
//  MIO
//
//  Created by Ronny Libardo Bustos Jiménez on 15/8/17.
//  Copyright © 2017 MIO CIMAR. All rights reserved.
//

#import "CommentsSlider.h"

@interface CommentsSlider () <UIScrollViewDelegate>

@property (strong, nonatomic) IBOutlet UIView *content;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@property (nonatomic) NSInteger nextPageXOrigin;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cardsContainerWidth;
@property (weak, nonatomic) IBOutlet UIView *cardsContainer;

@end

@implementation CommentsSlider

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if(self)
    {
        [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([CommentsSlider class]) owner:self options:nil];
        CGRect frame            = self.frame;
        
        self.content.frame  = CGRectMake(0, 0, CGRectGetWidth(frame), CGRectGetHeight(frame));
        [self addSubview:self.content];
    }
    
    self.scrollView.delegate    = self;
    
    return self;
}

- (void)setupWithNumberOfPages:(NSInteger)pages {
    CGFloat width   = self.scrollView.frame.size.width;
    
    self.pageControl.numberOfPages      = pages;
    self.cardsContainerWidth.constant   = width * pages;
}

- (void)addPage:(UIView *)page {
    CGFloat width   = self.scrollView.frame.size.width;
    CGFloat height  = self.scrollView.frame.size.height;
    
    [self.cardsContainer addSubview:page];
    
    page.frame              = CGRectMake(self.nextPageXOrigin, 0, width, height);
    
    self.nextPageXOrigin    += width;
}

- (void)reset {
    [self setupWithNumberOfPages:1];
    [self.cardsContainer.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    self.nextPageXOrigin    = 0;
    
    CGRect frame                    = self.scrollView.frame;
    frame.origin.x                  = 0;
    frame.origin.y                  = 0;
    
    [self.scrollView setContentOffset:CGPointZero];
    self.pageControl.currentPage    = 0;
    
    self.didMoveToPage = nil;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)sender {
    uint page = sender.contentOffset.x / self.scrollView.frame.size.width;
    self.pageControl.currentPage = page;
    if (self.didMoveToPage) {
        self.didMoveToPage(page);
    }
}

- (void)goToPage:(CGFloat)page {
    self.pageControl.currentPage    = page;
    
    [self.scrollView setContentOffset:CGPointMake(self.scrollView.frame.size.width * page, 0)];
}

- (CGRect)cardFrame {
    return self.cardsContainer.frame;
}

@end
