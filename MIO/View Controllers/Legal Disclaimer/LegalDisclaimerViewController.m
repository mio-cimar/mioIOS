//
//  LegalDisclaimerViewController.m
//  MIO
//
//  Created by Ronny Libardo on 10/11/16.
//  Copyright © 2016 MIO CIMAR. All rights reserved.
//

#import "LegalDisclaimerViewController.h"
#import <CoreText/CTFont.h>

@interface LegalDisclaimerViewController ()

@property (weak, nonatomic) IBOutlet UITextView *txtLegalDisclaimer;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end

@implementation LegalDisclaimerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = LocalizedString(@"legal-disclaimer-title");
    if (@available(iOS 11.0, *)) {
        self.navigationController.navigationBar.prefersLargeTitles = YES;
        self.titleLabel.text = nil;
    } else {
        self.titleLabel.text = LocalizedString(@"legal-disclaimer-title");
        self.navigationItem.titleView = [[UIView alloc] init];
    }
    CTFontRef font = CTFontCreateUIFontForLanguage(kCTFontUIFontSystem, 14, nil);
    NSString *contentFontFormattedHTML          = [LocalizedString(@"legal-disclaimer-content") stringByAppendingString:[NSString stringWithFormat:@"<style>body{font-family: '%@'; font-size:%fpx;}</style>",
                                                                                                             CTFontCopyFamilyName(font),
                                                                                                             self.txtLegalDisclaimer.font.pointSize]];
    
    self.txtLegalDisclaimer.attributedText  = [[NSAttributedString alloc] initWithData:[contentFontFormattedHTML dataUsingEncoding:NSUnicodeStringEncoding]
                                                                       options:@{ NSDocumentTypeDocumentAttribute:NSHTMLTextDocumentType,                                                            NSCharacterEncodingDocumentAttribute: @(NSUTF8StringEncoding) }
                                                            documentAttributes: nil
                                                                         error: nil];
    [MIOAnalyticsManager trackScreen:@"Disclaimer" screenClass:[self.classForCoder description]];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
