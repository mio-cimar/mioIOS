//
//  MIOLocalForecastCommentViewController.m
//  MIO
//
//  Created by Ronny Libardo on 9/4/16.
//  Copyright © 2016 MIO CIMAR. All rights reserved.
//

#import "MIOLocalForecastCommentViewController.h"

#import "LocalForecastRegion.h"

//#import "YLMoment.h"

#import <AsyncImageView/AsyncImageView.h>
#import <Haneke/Haneke.h>

@interface MIOLocalForecastCommentViewController () <UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UITextView *txtContent;
@property (strong, nonatomic) NSString *glossaryContent;
@property (weak, nonatomic) IBOutlet UIImageView *imgMap;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *txtContentGlossaryTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *txtContentCommenTop;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (weak, nonatomic) IBOutlet UILabel *lblValidThru;
@property (nonatomic) MIOSettingsLanguages selectedLanguage;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *leftBarButtonItem;
@property (weak, nonatomic) IBOutlet UINavigationBar *navigationBar;

@end

@implementation MIOLocalForecastCommentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.activityIndicator startAnimating];
    
    self.selectedLanguage                   = [[[NSUserDefaults standardUserDefaults] objectForKey:kMIOLanguageKey] integerValue];
    
    [self setValidThruWithStartingDate:self.validThruStart andEndDate:self.validThruEnd];
    
    [self.segmentedControl setTitle:LocalizedString(@"comment-first-segment") forSegmentAtIndex:0];
    [self.segmentedControl setTitle:LocalizedString(@"comment-second-segment") forSegmentAtIndex:1];
    
    self.glossaryContent        = LocalizedString(@"comment-glossary");
    
    self.txtContent.delegate    = self;
    
    self.lblTitle.text          = self.selectedLanguage == MIOSettingsLanguageEnglish ? [self.forecastRegion.englishName capitalizedString] : [self.forecastRegion.name capitalizedString];
    
    [self.imgMap hnk_setImageFromURL:[NSURL URLWithString:self.forecastRegion.largeMapURL]];

    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    NSLog(@"font attributes");
    NSLog(@"%@", self.txtContent.font.fontName);
    NSLog(@"%f", self.txtContent.font.pointSize);
    NSString *contentFontFormattedHTML  = [self.commentContent stringByAppendingString:[NSString stringWithFormat:@"<style>body{font-family: '%@'; font-size:%fpx;}</style>",
                                                                                        self.txtContent.font.fontName,
                                                                                        self.txtContent.font.pointSize]];
    
    self.txtContent.attributedText  = [[NSAttributedString alloc] initWithData:[contentFontFormattedHTML dataUsingEncoding:NSUnicodeStringEncoding]
                                                                       options:@{ NSDocumentTypeDocumentAttribute:NSHTMLTextDocumentType,                                                            NSCharacterEncodingDocumentAttribute: @(NSUTF8StringEncoding) }
                                                            documentAttributes: nil
                                                                         error: nil];
}

- (void)textViewDidChange:(UITextView *)textView {
    CGSize size = [self.txtContent systemLayoutSizeFittingSize:self.txtContent.contentSize];
    
    CGRect frame            = self.txtContent.frame;
    frame.size.height       = size.height;
    self.txtContent.frame   = frame;
}

- (void)viewWillDisappear:(BOOL)animated {
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)dismiss:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:^{
    }];
}

- (IBAction)share:(UIBarButtonItem *)sender {
    if (self.segmentedControl.selectedSegmentIndex == 0) {
        [MIOAnalyticsManager trackEventWithCategory:@"Comment" action:@"Share"];

        NSLog(@"font attributes");
        NSLog(@"%@", self.txtContent.font.fontName);
        NSLog(@"%f", self.txtContent.font.pointSize);
        NSString *contentFontFormattedHTML  = [self.commentContent stringByAppendingString:[NSString stringWithFormat:@"<style>body{font-family: '%@'; font-size:%fpx;}</style>",
                                                                                           self.txtContent.font.fontName,
                                                                                           self.txtContent.font.pointSize]];
        
        NSAttributedString *content = [[NSAttributedString alloc] initWithData:[contentFontFormattedHTML dataUsingEncoding:NSUnicodeStringEncoding]
                                                                       options:@{ NSDocumentTypeDocumentAttribute:NSHTMLTextDocumentType,                                                            NSCharacterEncodingDocumentAttribute: @(NSUTF8StringEncoding) }
                                                            documentAttributes: nil
                                                                         error: nil];
        
        NSAttributedString *shareItem = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"\n\n"]];
        
        UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:@[LocalizedString(@"comment-local-forecast-share-title"), self.lblTitle.text, self.lblValidThru.text, shareItem, [content string]] applicationActivities:nil];
        
        activityController.excludedActivityTypes = @[ UIActivityTypePrint,
                                                      UIActivityTypeCopyToPasteboard,
                                                      UIActivityTypeAssignToContact,
                                                      UIActivityTypeSaveToCameraRoll,
                                                      UIActivityTypeAddToReadingList,
                                                      UIActivityTypeAirDrop ];
        
        [self presentViewController:activityController animated:YES completion:^{
        }];
    }
    else {
        [self dismiss:nil];
    }
}

- (IBAction)switchedContent:(UISegmentedControl *)sender {
    if (sender.selectedSegmentIndex == 0) {
        NSLog(@"font attributes");
        NSLog(@"%@", self.txtContent.font.fontName);
        NSLog(@"%f", self.txtContent.font.pointSize);
        NSString *contentFontFormattedHTML  = [self.commentContent stringByAppendingString:[NSString stringWithFormat:@"<style>body{font-family: '%@'; font-size:%fpx;}</style>",
                                                                                            self.txtContent.font.fontName,
                                                                                            self.txtContent.font.pointSize]];
        
        self.txtContent.attributedText  = [[NSAttributedString alloc] initWithData:[contentFontFormattedHTML dataUsingEncoding:NSUnicodeStringEncoding]
                                                                           options:@{ NSDocumentTypeDocumentAttribute:NSHTMLTextDocumentType,                                                            NSCharacterEncodingDocumentAttribute: @(NSUTF8StringEncoding) }
                                                                documentAttributes: nil
                                                                             error: nil];
        
        self.lblTitle.hidden                = NO;
        self.activityIndicator.hidden       = NO;
        self.imgMap.hidden                  = NO;
        self.lblValidThru.hidden            = NO;
        self.txtContentCommenTop.priority   = 999;
        self.txtContentGlossaryTop.priority = 249;
        [self.leftBarButtonItem setTitle: LocalizedString(@"help-done")];
        self.leftBarButtonItem.enabled      = YES;
        self.leftBarButtonItem.tintColor    = self.view.tintColor;
        
        self.navigationBar.topItem.rightBarButtonItem.enabled   = YES;
        self.navigationBar.topItem.rightBarButtonItem.tintColor = self.view.tintColor;
    }
    else {
        [MIOAnalyticsManager trackScreen:@"Glossary" screenClass:[self.classForCoder description]];
        NSLog(@"font attributes");
        NSLog(@"%@", self.txtContent.font.fontName);
        NSLog(@"%f", self.txtContent.font.pointSize);
        NSString *contentFontFormattedHTML  = [self.glossaryContent stringByAppendingString:[NSString stringWithFormat:@"<style>body{font-family: '%@'; font-size:%fpx;}</style>",
                                                                                            self.txtContent.font.fontName,
                                                                                            self.txtContent.font.pointSize]];
        
        self.txtContent.attributedText  = [[NSAttributedString alloc] initWithData:[contentFontFormattedHTML dataUsingEncoding:NSUnicodeStringEncoding]
                                                                           options:@{ NSDocumentTypeDocumentAttribute:NSHTMLTextDocumentType,                                                            NSCharacterEncodingDocumentAttribute: @(NSUTF8StringEncoding) }
                                                                documentAttributes: nil
                                                                             error: nil];;
        self.lblTitle.hidden            = YES;
        self.activityIndicator.hidden   = YES;
        self.imgMap.hidden              = YES;
        self.lblValidThru.hidden        = YES;
        self.txtContentCommenTop.priority   = 249;
        self.txtContentGlossaryTop.priority = 999;
        
        self.navigationBar.topItem.rightBarButtonItem.enabled   = NO;
        self.navigationBar.topItem.rightBarButtonItem.tintColor = [UIColor clearColor];
    }
}

- (void)setValidThruWithStartingDate:(NSDate *)startingDate andEndDate:(NSDate *)endDate {
//    YLMoment *forecastStartingMoment    = [YLMoment momentWithDate:startingDate];
//    forecastStartingMoment.timeZone     = [NSTimeZone localTimeZone];
//    forecastStartingMoment.locale       = [NSLocale localeWithLocaleIdentifier:self.selectedLanguage == MIOSettingsLanguageEnglish ? @"en_US" : @"es_ES"];
//
//    YLMoment *forecastEndMoment         = [YLMoment momentWithDate:endDate];
//    forecastEndMoment.timeZone          = [NSTimeZone localTimeZone];
//    forecastEndMoment.locale            = [NSLocale localeWithLocaleIdentifier:self.selectedLanguage == MIOSettingsLanguageEnglish ? @"en_US" : @"es_ES"];
//
//    self.lblValidThru.text              = [NSString stringWithFormat:@"%@ %@ %@ %@", LocalizedString(@"local-forecast-valid-from"), [forecastStartingMoment format:self.selectedLanguage == MIOSettingsLanguageEnglish ? @"EEEE, MMM dd" : @"EEEE dd MMM"], LocalizedString(@"local-forecast-valid-to"), [forecastEndMoment format:self.selectedLanguage == MIOSettingsLanguageEnglish ? @"EEEE, MMM dd, yyyy" : @"EEEE dd MMM, yyyy"]];
    printf("starting date start");
}


@end
