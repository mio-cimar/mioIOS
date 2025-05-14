//
//  LocalForecastCommentCell.m
//  MIO
//
//  Created by Ronny Libardo Bustos Jiménez on 16/8/17.
//  Copyright © 2017 MIO CIMAR. All rights reserved.
//

#import "LocalForecastCommentCell.h"

@interface LocalForecastCommentCell ()

@end

@implementation LocalForecastCommentCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self.morningDisclaimer setTransform:CGAffineTransformMakeRotation(-M_PI / 2)];
    [self.afternoonDisclaimer setTransform:CGAffineTransformMakeRotation(-M_PI / 2)];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
