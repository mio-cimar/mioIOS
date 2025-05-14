//
//  MIOLocalForecastHelpViewController.m
//  MIO
//
//  Created by Alonso Vega on 7/20/16.
//  Copyright © 2016 MIO CIMAR. All rights reserved.
//



#import "MIOLocalForecastHelpViewController.h"

@interface MIOLocalForecastHelpViewController ()

@property (nonatomic) MIOSettingsLanguages selectedLanguage;
@property (nonatomic) MIOSettingsHeightMeasureUnits selectedHeightMeasureUnit;
@property (nonatomic) MIOSettingsSpeedMeasureUnits selectedSpeedMeasureUnit;

@property (weak, nonatomic) IBOutlet UILabel *lblTime;
@property (weak, nonatomic) IBOutlet UILabel *lblWaveDirection;
@property (weak, nonatomic) IBOutlet UILabel *llblWaveHeight;
@property (weak, nonatomic) IBOutlet UILabel *lblWaveHeightMax;
@property (weak, nonatomic) IBOutlet UILabel *lblWavePeriod;
@property (weak, nonatomic) IBOutlet UILabel *lblWindDirection;
@property (weak, nonatomic) IBOutlet UILabel *lblWindSpeed;
@property (weak, nonatomic) IBOutlet UILabel *lblWindBurst;
@property (weak, nonatomic) IBOutlet UILabel *lblWaveDirectionTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblWaveHeightTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblWaveHeightMaxTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblWavePeriodTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblWindDirectionTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblWindSpeedTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblWindBurstTitle;

@property (weak, nonatomic) IBOutlet UILabel *lblWaveHeightRange;
@property (weak, nonatomic) IBOutlet UILabel *lblWaveHeight3;
@property (weak, nonatomic) IBOutlet UILabel *lblWaveHeight2;
@property (weak, nonatomic) IBOutlet UILabel *lblWaveHeight1;
@property (weak, nonatomic) IBOutlet UILabel *lblWaveHeightMinus1;

@property (weak, nonatomic) IBOutlet UILabel *lblWindSpeedRange;
@property (weak, nonatomic) IBOutlet UILabel *lblWindSpeed40;
@property (weak, nonatomic) IBOutlet UILabel *lblWindSpeed29;
@property (weak, nonatomic) IBOutlet UILabel *lblWindSpeed22;
@property (weak, nonatomic) IBOutlet UILabel *lblWindSpeedMinus22;
@property (weak, nonatomic) IBOutlet UILabel *lblWindAndWavesToDirection;
@property (weak, nonatomic) IBOutlet UILabel *lblWindAndWavesFromDirection;
@property (weak, nonatomic) IBOutlet UIImageView *wavesAndWindToDirection;
@property (weak, nonatomic) IBOutlet UILabel *lblSymbology;
@property (weak, nonatomic) IBOutlet UILabel *lblImportant;
@property (weak, nonatomic) IBOutlet UILabel *lblImportantFirst;
@property (weak, nonatomic) IBOutlet UILabel *lblImportantSecond;
@property (weak, nonatomic) IBOutlet UILabel *lblImportantThird;
@property (weak, nonatomic) IBOutlet UINavigationBar *navigationBar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneButton;

@end

#define DEGREES_TO_RADIANS(x) (M_PI * (x) / 180.0)

@implementation MIOLocalForecastHelpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.lblSymbology.text                  = LocalizedString(@"help-symbology");
    self.lblImportant.text                  = LocalizedString(@"help-important");
    
    self.lblImportantFirst.text             = LocalizedString(@"help-local-forecasts-forecast-important-first");
    self.lblImportantSecond.text            = LocalizedString(@"help-local-forecasts-forecast-important-second");
    self.lblImportantThird.text             = LocalizedString(@"help-local-forecasts-forecast-important-third");
    self.lblWindAndWavesFromDirection.text  = LocalizedString(@"help-wind-direction-from");
    self.lblWindAndWavesToDirection.text    = LocalizedString(@"help-wind-direction-to");
    [self.doneButton setTitle: LocalizedString(@"help-done")];
    
    self.selectedLanguage           = [[[NSUserDefaults standardUserDefaults] objectForKey:kMIOLanguageKey] integerValue];
    self.selectedSpeedMeasureUnit   = [[[NSUserDefaults standardUserDefaults] objectForKey:kMIOSpeedMeasureUnitKey] integerValue];
    self.selectedHeightMeasureUnit  = [[[NSUserDefaults standardUserDefaults] objectForKey:kMIOHeightMeasureUnitKey] integerValue];

    
    self.navigationBar.topItem.title = LocalizedString(@"help-title");
    
    self.lblTime.text           = LocalizedString(@"help-time");
    
    self.lblWaveDirection.text  = LocalizedString(@"help-wave-direction");
    
    self.llblWaveHeight.text    = [NSString stringWithFormat:@"%@ (%@)", LocalizedString(@"help-wave-height"), self.selectedHeightMeasureUnit == MIOSettingsHeightMeasureUnitMeters ? LocalizedString(@"measure-unit-meter") : LocalizedString(@"settings-measure-unit-feet")];
    
    self.lblWaveHeightMax.text  = [NSString stringWithFormat:@"%@ (%@)", LocalizedString(@"help-wave-height-max"), self.selectedHeightMeasureUnit == MIOSettingsHeightMeasureUnitMeters ? LocalizedString(@"measure-unit-meter") : LocalizedString(@"settings-measure-unit-feet")];
    
    self.lblWavePeriod.text     = LocalizedString(@"help-wave-period");
    
    self.lblWindDirection.text  = LocalizedString(@"help-wind-direction");
    
    self.lblWindSpeed.text      = [NSString stringWithFormat:@"%@ (%@)", LocalizedString(@"help-wind-speed"), self.selectedSpeedMeasureUnit == MIOSettingsSpeedMeasureUnitKilometers ? LocalizedString(@"measure-unit-kilometer") : LocalizedString(@"measure-unit-knot")];
    
    self.lblWindBurst.text      = [NSString stringWithFormat:@"%@ (%@)", LocalizedString(@"help-wind-burst"), self.selectedSpeedMeasureUnit == MIOSettingsSpeedMeasureUnitKilometers ? LocalizedString(@"measure-unit-kilometer") : LocalizedString(@"measure-unit-knot")];
    
    self.lblWindSpeedTitle.text  = LocalizedString(@"local-forecast-wind-speed");
    
    self.lblWindBurstTitle.text  = LocalizedString(@"local-forecast-wind-burst");
    
    
    UIFont *font                                = [UIFont fontWithName:@"SFUIText-Regular" size:20.0f];
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:LocalizedString(@"local-forecast-wave-direction")
                                                                                         attributes:@{NSFontAttributeName: [font fontWithSize:13.0f]}];
    
    [attributedString setAttributes:@{ NSBaselineOffsetAttributeName : @-8, NSFontAttributeName: [font fontWithSize:11.0f] } range:NSMakeRange(4, 1)];
    self.lblWaveDirectionTitle.attributedText    = attributedString;
    
    NSMutableAttributedString *attributedString1 = [[NSMutableAttributedString alloc] initWithString:LocalizedString(@"local-forecast-significative-wave")
                                                              attributes:@{NSFontAttributeName: [font fontWithSize:13.0f]}];
    
    [attributedString1 setAttributes:@{ NSBaselineOffsetAttributeName : @-8, NSFontAttributeName: [font fontWithSize:11.0f] } range:NSMakeRange(1, 4)];
    self.lblWaveHeightTitle.attributedText   = attributedString1;
    
    NSMutableAttributedString *attributedString2 = [[NSMutableAttributedString alloc] initWithString:LocalizedString(@"local-forecast-maximum-wave")
                                                              attributes:@{NSFontAttributeName: [font fontWithSize:13.0f]}];
    
    [attributedString2 setAttributes:@{ NSBaselineOffsetAttributeName : @-8, NSFontAttributeName: [font fontWithSize:11.0f] } range:NSMakeRange(1, 4)];
    self.lblWaveHeightMaxTitle.attributedText    = attributedString2;
    
    NSMutableAttributedString *attributedString3 = [[NSMutableAttributedString alloc] initWithString:LocalizedString(@"local-forecast-wave-period")
                                                              attributes:@{NSFontAttributeName: [font fontWithSize:13.0f]}];
    
    [attributedString3 setAttributes:@{ NSBaselineOffsetAttributeName : @-8, NSFontAttributeName: [font fontWithSize:11.0f] } range:NSMakeRange(1, 1)];
    self.lblWavePeriodTitle.attributedText   = attributedString3;
    
    NSMutableAttributedString *attributedString4 = [[NSMutableAttributedString alloc] initWithString:LocalizedString(@"local-forecast-wind-direction")
                                                              attributes:@{NSFontAttributeName: [font fontWithSize:13.0f]}];
    
    [attributedString4 setAttributes:@{ NSBaselineOffsetAttributeName : @-8, NSFontAttributeName: [font fontWithSize:11.0f] } range:NSMakeRange(4, 1)];
    self.lblWindDirectionTitle.attributedText    = attributedString4;
    
    self.lblWaveHeightRange.text    = LocalizedString(@"help-wave-height-range");
    self.lblWindSpeedRange.text     = LocalizedString(@"help-wind-speed-range");
    
    double windSpeedMultiplier      = self.selectedSpeedMeasureUnit == MIOSettingsSpeedMeasureUnitKilometers ? kKilometersMultiplier : kKnotMultiplier;
    NSString *windSpeedMeasureUnit  = self.selectedSpeedMeasureUnit == MIOSettingsSpeedMeasureUnitKilometers ? LocalizedString(@"measure-unit-kilometer") : LocalizedString(@"measure-unit-knot");
    
    self.lblWindSpeed40.text        = [NSString stringWithFormat:@"> %g %@", round(kFirstWindRange * windSpeedMultiplier), windSpeedMeasureUnit];
    self.lblWindSpeed29.text        = [NSString stringWithFormat:@"> %g %@", round(kSecondWindRange * windSpeedMultiplier), windSpeedMeasureUnit];
    self.lblWindSpeed22.text        = [NSString stringWithFormat:@"> %g %@", round(kThirdWindRange * windSpeedMultiplier), windSpeedMeasureUnit];
    self.lblWindSpeedMinus22.text   = [NSString stringWithFormat:@"< %g %@", round(kThirdWindRange * windSpeedMultiplier), windSpeedMeasureUnit];
    
    double waveHeightMultiplier     = self.selectedHeightMeasureUnit == MIOSettingsHeightMeasureUnitMeters ? kMeterMultiplier : kFeetMultiplier;
    NSString *waveHeightMeasureUnit = self.selectedHeightMeasureUnit == MIOSettingsHeightMeasureUnitMeters ? LocalizedString(@"measure-unit-meter") : LocalizedString(@"settings-measure-unit-feet");
    
    self.lblWaveHeight3.text        = [NSString stringWithFormat:@"> %g %@", (floorf((kFirstWaveRange * waveHeightMultiplier) * 10 + 0.5) / 10), waveHeightMeasureUnit];
    self.lblWaveHeight2.text        = [NSString stringWithFormat:@"> %g %@", (floorf((kSecondWaveRange * waveHeightMultiplier) * 10 + 0.5) / 10), waveHeightMeasureUnit];
    self.lblWaveHeight1.text        = [NSString stringWithFormat:@"> %g %@", (floorf((kThirdWaveRange * waveHeightMultiplier) * 10 + 0.5) / 10), self.selectedHeightMeasureUnit == MIOSettingsHeightMeasureUnitMeters ? [LocalizedString(@"measure-unit-meter") substringWithRange:NSMakeRange(0, LocalizedString(@"measure-unit-meter").length - 1)] : waveHeightMeasureUnit];
    self.lblWaveHeightMinus1.text   = [NSString stringWithFormat:@"< %g %@", (floorf((kThirdWaveRange * waveHeightMultiplier) * 10 + 0.5) / 10), self.selectedHeightMeasureUnit == MIOSettingsHeightMeasureUnitMeters ? [LocalizedString(@"measure-unit-meter") substringWithRange:NSMakeRange(0, LocalizedString(@"measure-unit-meter").length - 1)] : waveHeightMeasureUnit];
    
    self.wavesAndWindToDirection.transform = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(35.0));
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    
    [MIOAnalyticsManager trackScreen:@"Help" screenClass:[self.classForCoder description]];
}

- (void)viewWillDisappear:(BOOL)animated {
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    [super viewWillDisappear:animated];
}

- (IBAction)dismissModal:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
