//
//  TouristInfoCollectionViewCell.m
//  MIO
//
//  Created by Fabricio Rodriguez on 3/10/19.
//  Copyright © 2019 MIO CIMAR. All rights reserved.
//

#import "TouristInfoCollectionViewCell.h"

@implementation TouristInfoCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code

    self.maskPath = [UIBezierPath bezierPathWithRoundedRect:self.imageView.bounds byRoundingCorners:( UIRectCornerTopLeft | UIRectCornerTopRight) cornerRadii:CGSizeMake(14.0, 14.0)];
    self.maskLayer = [[CAShapeLayer alloc] init];
    self.maskLayer.frame = self.imageView.bounds;
    self.maskLayer.path  = self.maskPath.CGPath;
    self.imageView.layer.mask = self.maskLayer;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.maskPath = [UIBezierPath bezierPathWithRoundedRect:self.imageView.bounds byRoundingCorners:( UIRectCornerTopLeft | UIRectCornerTopRight) cornerRadii:CGSizeMake(14.0, 14.0)];
    self.maskLayer = [[CAShapeLayer alloc] init];
    self.maskLayer.frame = self.imageView.bounds;
    self.maskLayer.path  = self.maskPath.CGPath;
    self.imageView.layer.mask = self.maskLayer;
}

@end
