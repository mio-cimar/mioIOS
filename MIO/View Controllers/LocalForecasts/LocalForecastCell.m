//
//  LocalForecastCell.m
//  MIO
//
//  Created by Ronny Libardo Bustos Jiménez on 20/8/17.
//  Copyright © 2017 MIO CIMAR. All rights reserved.
//

#import "LocalForecastCell.h"

@interface LocalForecastCell ()

@property (weak, nonatomic) IBOutlet UILabel *waves;
@property (weak, nonatomic) IBOutlet UILabel *wind;

@end

@implementation LocalForecastCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.waves.text = LocalizedString(@"local-forecast-waves");
    self.wind.text  = LocalizedString(@"local-forecast-wind");
    
    UIFont *font                                = [UIFont systemFontOfSize:20.0f];
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:LocalizedString(@"local-forecast-wave-direction")
                                                                                         attributes:@{NSFontAttributeName: [font fontWithSize:10.0f]}];
    
    [attributedString setAttributes:@{ NSFontAttributeName: [font fontWithSize:9.0f],
                                       NSBaselineOffsetAttributeName : @-5} range:NSMakeRange(4, 1)];
    self.lblWaveDirection.attributedText    = attributedString;
    
    NSMutableAttributedString *attributedString1 = [[NSMutableAttributedString alloc] initWithString:LocalizedString(@"local-forecast-significative-wave")
                                                                                          attributes:@{NSFontAttributeName: [font fontWithSize:10.0f]}];
    
    [attributedString1 setAttributes:@{ NSFontAttributeName: [font fontWithSize:9.0f], NSBaselineOffsetAttributeName : @-5} range:NSMakeRange(1, 4)];
    self.lblHeight.attributedText   = attributedString1;
    
    NSMutableAttributedString *attributedString2 = [[NSMutableAttributedString alloc] initWithString:LocalizedString(@"local-forecast-maximum-wave")
                                                                                          attributes:@{NSFontAttributeName: [font fontWithSize:10.0f]}];
    
    [attributedString2 setAttributes:@{ NSFontAttributeName: [font fontWithSize:9.0f], NSBaselineOffsetAttributeName : @-4} range:NSMakeRange(1, 4)];
    self.lblMaxHeight.attributedText    = attributedString2;
    
    NSMutableAttributedString *attributedString3 = [[NSMutableAttributedString alloc] initWithString:LocalizedString(@"local-forecast-wave-period")
                                                                                          attributes:@{NSFontAttributeName: [font fontWithSize:10.0f]}];
    
    [attributedString3 setAttributes:@{ NSFontAttributeName: [font fontWithSize:9.0f], NSBaselineOffsetAttributeName : @-4} range:NSMakeRange(1, 1)];
    self.lblWavePeriod.attributedText   = attributedString3;
    
    NSMutableAttributedString *attributedString4 = [[NSMutableAttributedString alloc] initWithString:LocalizedString(@"local-forecast-wind-direction")
                                                                                          attributes:@{NSFontAttributeName: [font fontWithSize:10.0f]}];
    
    [attributedString4 setAttributes:@{ NSFontAttributeName: [font fontWithSize:9.0f], NSBaselineOffsetAttributeName : @-4} range:NSMakeRange(4, 1)];
    self.lblWindDirection.attributedText    = attributedString4;
    
    self.lblWindSpeed.text  = LocalizedString(@"local-forecast-wind-speed");
    
    self.lblWindBurst.text  = LocalizedString(@"local-forecast-wind-burst");
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
