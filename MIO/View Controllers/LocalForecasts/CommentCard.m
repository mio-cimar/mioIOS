//
//  CommentCard.m
//  MIO
//
//  Created by Ronny Libardo Bustos Jiménez on 10/8/17.
//  Copyright © 2017 MIO CIMAR. All rights reserved.
//

#import "CommentCard.h"

@interface CommentCard ()

@property (strong, nonatomic) IBOutlet UIView *content;

@end

@implementation CommentCard

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if(self)
    {
        [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([CommentCard class]) owner:self options:nil];
        CGRect frame            = self.frame;
        
        self.content.frame  = CGRectMake(0, 0, CGRectGetWidth(frame), CGRectGetHeight(frame));
        [self addSubview:self.content];
    }
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if(self)
    {
        [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([CommentCard class]) owner:self options:nil];
        CGRect frame            = self.frame;
        
        self.content.frame  = CGRectMake(0, 0, CGRectGetWidth(frame), CGRectGetHeight(frame));
        [self addSubview:self.content];
    }
    
    return self;
}

@end
