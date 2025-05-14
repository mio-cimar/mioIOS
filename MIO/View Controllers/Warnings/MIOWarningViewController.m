//
//  MIOWarningViewController.m
//  MIO
//
//  Created by Ronny Libardo on 9/14/16.
//  Copyright © 2016 MIO CIMAR. All rights reserved.
//

#import "MIOWarningViewController.h"

#import "Warning.h"

#import <DateTools/DateTools.h>

@interface MIOWarningViewController () <UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *warningTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *warningDetailLabel;
@property (weak, nonatomic) IBOutlet UILabel *warningDateLabel;
@property (weak, nonatomic) IBOutlet UITextView *warningDetailTextView;
@property (weak, nonatomic) IBOutlet UIImageView *warningImage;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textViewHeightConstraint;
@property (nonatomic) MIOSettingsLanguages selectedLanguage;

@end

@implementation MIOWarningViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.selectedLanguage                   = [[[NSUserDefaults standardUserDefaults] objectForKey:kMIOLanguageKey] integerValue];
    
    self.warningTitleLabel.text      = self.warning.title;
    self.warningDetailLabel.text     = self.warning.subtitle;
    
    NSString *imageName                 = [self.warning.level integerValue] == 0 ? @"advertencia-verde" : [self.warning.level integerValue] == 1 ? @"advertencia-amarilla" : @"advertencia-roja";
    
    self.warningImage.image             = [UIImage imageNamed:imageName];
    self.warningDateLabel.text          = [self.warning.date formattedDateWithFormat:self.selectedLanguage == MIOSettingsLanguageEnglish ?  @"MMM d, yyyy | h a" : @"d MMM, yyyy | h a" timeZone:[NSTimeZone localTimeZone] locale:[NSLocale localeWithLocaleIdentifier:self.selectedLanguage == MIOSettingsLanguageEnglish ? @"en_EN" : @"es_ES"]];

    NSString *warningFontFormattedHTML  = [self.warning.text stringByAppendingString:[NSString stringWithFormat:@"<style>body{font-family: '%@'; font-size:%fpx;}</style>",
                                                                           @"SFUIText-Regular",
                                                                           17.0]];

    
    self.warningDetailTextView.delegate         = self;
    
    self.warningDetailTextView.attributedText   = [[NSAttributedString alloc] initWithData:[warningFontFormattedHTML dataUsingEncoding:NSUnicodeStringEncoding]
                                                                                 options:@{ NSDocumentTypeDocumentAttribute:NSHTMLTextDocumentType,                                                            NSCharacterEncodingDocumentAttribute: @(NSUTF8StringEncoding) }
                                                                      documentAttributes: nil
                                                                                   error: nil];


    self.title = nil;
    [MIOAnalyticsManager trackScreen:@"Notification detail" screenClass:[self.classForCoder description]];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    self.textViewHeightConstraint.constant  = [self.warningDetailTextView sizeThatFits:CGSizeMake(self.warningDetailTextView.frame.size.width, CGFLOAT_MAX)].height;
    
    NSLog(@"%@", self.title);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)share:(UIBarButtonItem *)sender {
    [MIOAnalyticsManager trackEventWithCategory:@"Notification" action:@"Share"];
    
    NSString *warningFontFormattedHTML  = [self.warning.text stringByAppendingString:[NSString stringWithFormat:@"<style>body{font-family: '%@'; font-size:%fpx;}</style>",
                                                                                      self.warningDetailTextView.font.fontName,
                                                                                      self.warningDetailTextView.font.pointSize]];
    
    NSAttributedString *content   = [[NSAttributedString alloc] initWithData:[warningFontFormattedHTML dataUsingEncoding:NSUnicodeStringEncoding]
                                                                                   options:@{ NSDocumentTypeDocumentAttribute:NSHTMLTextDocumentType,                                                            NSCharacterEncodingDocumentAttribute: @(NSUTF8StringEncoding) }
                                                                        documentAttributes: nil
                                                                                     error: nil];
    
    NSAttributedString *shareItem = [[NSAttributedString alloc] initWithString:@"\n\n"];
    
    UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:@[[self.warning.title uppercaseString], self.warning.subtitle, self.warningDateLabel.text, shareItem, [content string]] applicationActivities:nil];
    
    activityController.excludedActivityTypes = @[ UIActivityTypePrint,
                                                  UIActivityTypeCopyToPasteboard,
                                                  UIActivityTypeAssignToContact,
                                                  UIActivityTypeSaveToCameraRoll,
                                                  UIActivityTypeAddToReadingList,
                                                  UIActivityTypeAirDrop ];
    
    [self.navigationController presentViewController:activityController animated:YES completion:^{
    }];
}

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange {
    [MIOAnalyticsManager trackEventWithCategory:@"Notification link" action:[URL absoluteString]];
    
    return YES;
}

@end
