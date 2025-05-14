//
//  TouristInfoCollectionViewCell.h
//  MIO
//
//  Created by Fabricio Rodriguez on 3/10/19.
//  Copyright © 2019 MIO CIMAR. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TouristInfoCollectionViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *title;
@property (strong, nonatomic) IBOutlet UIView *content;
@property (strong, nonatomic) UIBezierPath *maskPath;
@property (strong, nonatomic) CAShapeLayer *maskLayer;
@end

NS_ASSUME_NONNULL_END
