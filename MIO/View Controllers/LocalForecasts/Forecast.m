//
//  Forecast.m
//  MIO
//
//  Created by Ronny Libardo Bustos Jiménez on 19/8/17.
//  Copyright © 2017 MIO CIMAR. All rights reserved.
//

#import "Forecast.h"

@interface Forecast ()

@property (strong, nonatomic) IBOutlet UIView *content;

@end

@implementation Forecast

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if(self)
    {
        [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([Forecast class]) owner:self options:nil];
        CGRect frame            = self.frame;
        
        self.content.frame  = CGRectMake(0, 0, CGRectGetWidth(frame), CGRectGetHeight(frame));
        [self addSubview:self.content];
    }
    
    return self;
}

@end
