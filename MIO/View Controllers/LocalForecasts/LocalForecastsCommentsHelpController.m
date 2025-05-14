//
//  LocalForecastsCommentsHelpController.m
//  MIO
//
//  Created by Ronny Libardo Bustos Jiménez on 1/9/17.
//  Copyright © 2017 MIO CIMAR. All rights reserved.
//

#import "LocalForecastsCommentsHelpController.h"

@interface LocalForecastsCommentsHelpController ()

@property (weak, nonatomic) IBOutlet UITextView *glossary;
@property (weak, nonatomic) IBOutlet UIView *help;
@property (strong, nonatomic) NSString *glossaryFormattedContent;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (nonatomic) MIOSettingsLanguages selectedLanguage;
@property (weak, nonatomic) IBOutlet UILabel *lblSymbology;
@property (weak, nonatomic) IBOutlet UILabel *lblPrecautionLevels;
@property (weak, nonatomic) IBOutlet UILabel *lblImportant;
@property (weak, nonatomic) IBOutlet UILabel *lblImportantFirst;
@property (weak, nonatomic) IBOutlet UILabel *lblImportantSecond;
@property (weak, nonatomic) IBOutlet UILabel *lblImportantThird;
@property (weak, nonatomic) IBOutlet UILabel *lblPorts;
@property (weak, nonatomic) IBOutlet UILabel *lblSailing;
@property (weak, nonatomic) IBOutlet UILabel *lblSwimmers;
@property (weak, nonatomic) IBOutlet UILabel *lblProperCondition;
@property (weak, nonatomic) IBOutlet UILabel *lblCaution;
@property (weak, nonatomic) IBOutlet UILabel *lblHighCaution;
@property (weak, nonatomic) IBOutlet UILabel *lblExtremeCaution;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneButton;

@end

@implementation LocalForecastsCommentsHelpController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    self.selectedLanguage       = [[[NSUserDefaults standardUserDefaults] objectForKey:kMIOLanguageKey] integerValue];
    [self.segmentedControl setTitle:LocalizedString(@"local-forecast-comments-help-first-segment") forSegmentAtIndex:0];
    [self.segmentedControl setTitle:LocalizedString(@"local-forecast-comments-help-second-segment") forSegmentAtIndex:1];
    
    self.lblSymbology.text          = LocalizedString(@"help-symbology");
    self.lblPrecautionLevels.text   = LocalizedString(@"help-precaution-levels");
    self.lblImportant.text          = LocalizedString(@"help-important");
    self.lblImportantFirst.text     = LocalizedString(@"help-local-forecasts-comments-important-first");
    self.lblImportantSecond.text    = LocalizedString(@"help-local-forecasts-comments-important-second");
    self.lblImportantThird.text     = LocalizedString(@"help-local-forecasts-comments-important-third");
    self.lblProperCondition.text     = LocalizedString(@"help-local-forecast-proper-condition");
    self.lblCaution.text     = LocalizedString(@"help-local-forecast-caution-condition");
    self.lblHighCaution.text     = LocalizedString(@"help-local-forecast-high-caution-condition");
    self.lblExtremeCaution.text     = LocalizedString(@"help-local-forecast-extreme-caution-condition");
    self.lblSwimmers.text           = LocalizedString(@"help-swimmers");
    self.lblSailing.text            = LocalizedString(@"help-sailing");
    [self.doneButton setTitle: LocalizedString(@"help-done")];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    
    [MIOAnalyticsManager trackScreen:@"Help" screenClass:[self.classForCoder description]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    NSLog(@"font attributes");
    NSLog(@"%@", self.glossary.font.fontName);
    NSLog(@"%f", self.glossary.font.pointSize);
    self.glossaryFormattedContent = [LocalizedString(@"local-forecast-help-glossary") stringByAppendingString:[NSString stringWithFormat:@"<style>body{font-family: '%@'; font-size:%fpx;}</style>",
                                                                                         self.glossary.font.fontName,
                                                                                         self.glossary.font.pointSize]];
}

- (void)viewWillDisappear:(BOOL)animated {
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    [super viewWillDisappear:animated];
}

- (IBAction)switchedContent:(UISegmentedControl *)sender {
    if (sender.selectedSegmentIndex == 0) {
        [MIOAnalyticsManager trackScreen:@"Help" screenClass:[self.classForCoder description]];
        
        self.glossary.hidden            = YES;
        self.help.hidden                = NO;
        self.glossary.attributedText    = [[NSAttributedString alloc] initWithString:@""];
    }
    else {
        [MIOAnalyticsManager trackScreen:@"Glossary" screenClass:[self.classForCoder description]];
        
        self.glossary.hidden            = NO;
        self.help.hidden                = YES;
        self.glossary.attributedText    = [[NSAttributedString alloc] initWithData:[self.glossaryFormattedContent dataUsingEncoding:NSUnicodeStringEncoding]
                                                                         options:@{ NSDocumentTypeDocumentAttribute:NSHTMLTextDocumentType,                                                            NSCharacterEncodingDocumentAttribute: @(NSUTF8StringEncoding) }
                                                              documentAttributes: nil
                                                                           error: nil];
    }
}

- (IBAction)dismissModal:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end

