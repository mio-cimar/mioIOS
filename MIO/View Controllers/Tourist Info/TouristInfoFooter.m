//
//  TouristInfoFooter.m
//  MIO
//
//  Created by Fabricio Rodriguez on 3/10/19.
//  Copyright © 2019 MIO CIMAR. All rights reserved.
//

#import "TouristInfoFooter.h"

@implementation TouristInfoFooter

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([TouristInfoFooter class]) owner:self options:nil];
        CGRect frame = self.frame;
        self.content.frame  = CGRectMake(0, 0, CGRectGetWidth(frame), CGRectGetHeight(frame));
        [self addSubview:self.content];
        [self setup];
    }
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([TouristInfoFooter class]) owner:self options:nil];
        CGRect frame = self.frame;
        self.content.frame  = CGRectMake(0, 0, CGRectGetWidth(frame), CGRectGetHeight(frame));
        [self addSubview:self.content];
        [self setup];
    }
    return self;
}

-(void) setup {
    self.ictInformation.text = LocalizedString(@"tourist-info-ict-info");
}
@end
