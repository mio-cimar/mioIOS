//
//  ForecastHeader.m
//  MIO
//
//  Created by Fabricio Rodriguez on 3/8/19.
//  Copyright © 2019 MIO CIMAR. All rights reserved.
//

#import "ForecastHeader.h"

@interface ForecastHeader()
@property (strong, nonatomic) IBOutlet UIView *content;
@end

@implementation ForecastHeader

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];

    if(self)
    {
        [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([ForecastHeader class]) owner:self options:nil];
        CGRect frame            = self.frame;

        self.content.frame  = CGRectMake(0, 0, CGRectGetWidth(frame), CGRectGetHeight(frame));
        [self addSubview:self.content];
    }

    return self;
}


- (instancetype)init
{
    self = [super init];
    if (self) {
        [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([ForecastHeader class]) owner:self options:nil];
        CGRect frame            = self.frame;

        self.content.frame  = CGRectMake(0, 0, CGRectGetWidth(frame), CGRectGetHeight(frame));
        [self addSubview:self.content];
    }
    return self;
}

@end
