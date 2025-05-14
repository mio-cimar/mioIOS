//
//  RegionalForecastCommentViewController.m
//  MIO
//
//  Created by Ronny Libardo on 9/4/16.
//  Copyright © 2016 MIO CIMAR. All rights reserved.
//

#import "MIORegionalForecastCommentViewController.h"
#import "RegionalForecastType.h"

//#import "YLMoment.h"

#import <DateTools/DateTools.h>

@interface MIORegionalForecastCommentViewController () <UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UITextView *txtContent;
@property (strong, nonatomic) NSString *glossaryContent;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (nonatomic) MIOSettingsLanguages selectedLanguage;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *txtContentGlossaryTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *txtContentCommenTop;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *leftBarButtonItem;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *rightBarButtonItem;
@property (weak, nonatomic) IBOutlet UINavigationBar *navigationBar;
@property (copy, nonatomic) NSString *formattingText;

@end

@implementation MIORegionalForecastCommentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.selectedLanguage   = [[[NSUserDefaults standardUserDefaults] objectForKey:kMIOLanguageKey] integerValue];

    NSLog(@"font attributes");
    NSLog(@"%@", self.txtContent.font.fontName);
    NSLog(@"%f", self.txtContent.font.pointSize);
    self.formattingText     = [NSString stringWithFormat:@"<style>body{font-family: '%@'; font-size:%fpx;}</style>", self.txtContent.font.fontName, self.txtContent.font.pointSize];
    
    self.lblTitle.text      = self.selectedLanguage == MIOSettingsLanguageEnglish ? [self.forecast.englishName capitalizedString] : [self.forecast.name capitalizedString];
    
    [self.segmentedControl setTitle:LocalizedString(@"comment-first-segment") forSegmentAtIndex:0];
    [self.segmentedControl setTitle:LocalizedString(@"comment-second-segment") forSegmentAtIndex:1];
    
    self.glossaryContent        = LocalizedString(@"regional-forecast-comment-glossary");
    
    self.txtContent.delegate    = self;

    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    
    [MIOAnalyticsManager trackScreen:@"Comment" screenClass:[self.classForCoder description]];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    NSString *text  = self.selectedLanguage == MIOSettingsLanguageEnglish ? self.forecast.englishText : self.forecast.spanishText;

    NSString *contentFontFormattedHTML  = [text stringByAppendingString:self.formattingText];
    
    self.txtContent.attributedText  = [[NSAttributedString alloc] initWithData:[contentFontFormattedHTML dataUsingEncoding:NSUnicodeStringEncoding]
                                                                       options:@{ NSDocumentTypeDocumentAttribute:NSHTMLTextDocumentType,                                                            NSCharacterEncodingDocumentAttribute: @(NSUTF8StringEncoding) }
                                                            documentAttributes: nil
                                                                         error: nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)textViewDidChange:(UITextView *)textView {
    CGSize size = [self.txtContent systemLayoutSizeFittingSize:self.txtContent.contentSize];
    
    CGRect frame            = self.txtContent.frame;
    frame.size.height       = size.height;
    self.txtContent.frame   = frame;
}

- (IBAction)dismiss:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:^{
    }];
}

- (IBAction)share:(UIBarButtonItem *)sender {
    if (self.segmentedControl.selectedSegmentIndex == 0) {
        [MIOAnalyticsManager trackEventWithCategory:@"Comment" action:@"Share" ];
        NSString *text  = self.selectedLanguage == MIOSettingsLanguageEnglish ? self.forecast.englishText : self.forecast.spanishText;
        
        NSString *contentFontFormattedHTML  = [text stringByAppendingString:self.formattingText];
        
        NSAttributedString *content = [[NSAttributedString alloc] initWithData:[contentFontFormattedHTML dataUsingEncoding:NSUnicodeStringEncoding]
                                                                       options:@{ NSDocumentTypeDocumentAttribute:NSHTMLTextDocumentType,                                                            NSCharacterEncodingDocumentAttribute: @(NSUTF8StringEncoding) }
                                                            documentAttributes: nil
                                                                         error: nil];
        
        NSAttributedString *shareItem = [[NSAttributedString alloc] initWithString:@"\n\n"];
        
        UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:@[LocalizedString(@"comment-regional-forecast-share-title"), self.lblTitle.text, shareItem, [content string]] applicationActivities:nil];
        
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
        [MIOAnalyticsManager trackScreen:@"Comment" screenClass:[self.classForCoder description]];
        NSString *text  = self.selectedLanguage == MIOSettingsLanguageEnglish ? self.forecast.englishText : self.forecast.spanishText;

        NSString *contentFontFormattedHTML  = [text stringByAppendingString:self.formattingText];

        self.txtContent.attributedText  = [[NSAttributedString alloc] initWithData:[contentFontFormattedHTML dataUsingEncoding:NSUnicodeStringEncoding]
                                                                           options:@{ NSDocumentTypeDocumentAttribute:NSHTMLTextDocumentType,                                                            NSCharacterEncodingDocumentAttribute: @(NSUTF8StringEncoding) }
                                                                documentAttributes: nil
                                                                             error: nil];
        
        self.lblTitle.hidden                = NO;
        self.txtContentCommenTop.priority   = 999;
        self.txtContentGlossaryTop.priority = 249;
        
        self.leftBarButtonItem.enabled      = YES;
        self.leftBarButtonItem.tintColor    = self.view.tintColor;
        
        self.navigationBar.topItem.rightBarButtonItem.enabled   = YES;
        self.navigationBar.topItem.rightBarButtonItem.tintColor = self.view.tintColor;
    }
    else {
        [MIOAnalyticsManager trackScreen:@"Glossary" screenClass:[self.classForCoder description]];
        
        NSString *contentFontFormattedHTML  = [self.glossaryContent stringByAppendingString:self.formattingText];
        
        self.txtContent.attributedText  = [[NSAttributedString alloc] initWithData:[contentFontFormattedHTML dataUsingEncoding:NSUnicodeStringEncoding]
                                                                           options:@{ NSDocumentTypeDocumentAttribute:NSHTMLTextDocumentType,                                                            NSCharacterEncodingDocumentAttribute: @(NSUTF8StringEncoding) }
                                                                documentAttributes: nil
                                                                             error: nil];
        self.lblTitle.hidden            = YES;
        self.txtContentCommenTop.priority   = 249;
        self.txtContentGlossaryTop.priority = 999;
        
        self.navigationBar.topItem.rightBarButtonItem.enabled   = NO;
        self.navigationBar.topItem.rightBarButtonItem.tintColor = [UIColor clearColor];
    }
}

@end
