//
//  WhoWeAreViewController.m
//  MIO
//
//  Created by Ronny Libardo on 10/8/16.
//  Copyright © 2016 MIO CIMAR. All rights reserved.
//

#import "WhoWeAreViewController.h"

@interface WhoWeAreViewController ()

@property (weak, nonatomic) IBOutlet UITextView *txtContent;
@property (weak, nonatomic) IBOutlet UILabel *lblCollaborators;

@end

@implementation WhoWeAreViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *contentFontFormattedHTML  = [LocalizedString(@"about-us-information") stringByAppendingString:[NSString stringWithFormat:@"<style>body{font-family: '%@'; font-size:%fpx;}</style>",
                                                                                        self.txtContent.font.fontName,
                                                                                        self.txtContent.font.pointSize]];
    
    self.txtContent.attributedText  = [[NSAttributedString alloc] initWithData:[contentFontFormattedHTML dataUsingEncoding:NSUnicodeStringEncoding]
                                                                       options:@{ NSDocumentTypeDocumentAttribute:NSHTMLTextDocumentType,                                                            NSCharacterEncodingDocumentAttribute: @(NSUTF8StringEncoding) }
                                                            documentAttributes: nil
                                                                         error: nil];
    
    self.lblCollaborators.text  = LocalizedString(@"about-us-contributors");
    
    self.navigationItem.title   = LocalizedString(@"about-us-title");
    
    [MIOAnalyticsManager trackScreen:@"About us" screenClass:[self.classForCoder description]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
