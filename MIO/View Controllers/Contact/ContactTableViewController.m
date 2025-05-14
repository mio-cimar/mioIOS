//
//  ContactTableViewController.m
//  MIO
//
//  Created by Fabricio Rodriguez on 3/10/19.
//  Copyright © 2019 MIO CIMAR. All rights reserved.
//

#import "ContactTableViewController.h"
#import <CoreText/CTFont.h>

@interface ContactTableViewController ()
@property (nonatomic, strong) IBOutletCollection(UILabel) NSArray *phoneLabels;
@property (nonatomic, strong) IBOutletCollection(UILabel) NSArray *emailLabels;
@property (nonatomic, strong) IBOutletCollection(UILabel) NSArray *webSiteLabels;
@property (nonatomic, strong) IBOutletCollection(UILabel) NSArray *addressLabels;
@property (nonatomic, strong) IBOutletCollection(UILabel) NSArray *phones;
@property (nonatomic, strong) IBOutletCollection(UILabel) NSArray *emails;
@property (nonatomic, strong) IBOutletCollection(UILabel) NSArray *websites;
@property (nonatomic, strong) IBOutletCollection(UILabel) NSArray *adresses;
@property (weak, nonatomic) IBOutlet UITextView *aboutUs;
@property (weak, nonatomic) IBOutlet UILabel *oceanographicInformationModuleTitle;

@end

@implementation ContactTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSString *phoneLabelTitle = LocalizedString(@"contact-phone-title");
    NSString *emailLabelTitle = LocalizedString(@"contact-email-title");
    NSString *websiteLabelTitle = LocalizedString(@"contact-website-title");
    NSString *addressLabelTitle = LocalizedString(@"contact-address-title");
    for(UILabel* phoneLabel in self.phoneLabels){
        phoneLabel.text = phoneLabelTitle;
    }
    for(UILabel* emailLabel in self.emailLabels){
        emailLabel.text = emailLabelTitle;
    }
    for(UILabel* websiteLabel in self.webSiteLabels){
        websiteLabel.text = websiteLabelTitle;
    }
    for(UILabel* addressLabel in self.addressLabels){
        addressLabel.text = addressLabelTitle;
    }
    CALayer *layer = [[CALayer alloc] init];
    layer.frame = CGRectMake(16, 0, self.tableView.frame.size.width, 0.5);
    layer.backgroundColor = [[UIColor colorWithRed:224/255.0 green:224/255.0 blue:224/255.0 alpha:1.0] CGColor];
    [self.tableView.layer addSublayer:layer];
    CTFontRef font = CTFontCreateUIFontForLanguage(kCTFontUIFontSystem, 14, nil);
    NSString *contentFontFormattedHTML  = [LocalizedString(@"about-us-information") stringByAppendingString:
                                           [NSString stringWithFormat:@"<style>body{font-family: '%@'; font-size:%fpx; color:'#A1A1A1';}</style>", CTFontCopyFamilyName(font), self.aboutUs.font.pointSize]];
    self.aboutUs.attributedText  = [[NSAttributedString alloc] initWithData:
                                    [contentFontFormattedHTML dataUsingEncoding:NSUnicodeStringEncoding]
                                                                    options:@{ NSDocumentTypeDocumentAttribute:NSHTMLTextDocumentType,                                                            NSCharacterEncodingDocumentAttribute: @(NSUTF8StringEncoding) }
                                                         documentAttributes: nil
                                                                      error: nil];
    self.tableView.estimatedRowHeight = UITableViewAutomaticDimension;
    self.oceanographicInformationModuleTitle.text = LocalizedString(@"contact-oceanographic-module");
    for (UILabel *phone in self.phones) {
        UITapGestureRecognizer *phonesRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(phoneTapped:)];
        [phone addGestureRecognizer:phonesRecognizer];
    }
    for (UILabel *email in self.emails) {
        UITapGestureRecognizer *emailRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(emailTapped:)];
        [email addGestureRecognizer:emailRecognizer];
    }
    for (UILabel *website in self.websites) {
        UITapGestureRecognizer *websitesRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(websiteTapped:)];
        [website addGestureRecognizer:websitesRecognizer];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
}

- (void)phoneTapped:(UITapGestureRecognizer *)sender {
    UILabel *phoneLabel = (UILabel *) sender.view;
    NSString *text = phoneLabel.text;
    if (text != nil) {
        NSString *urlString = [text stringByReplacingOccurrencesOfString:@")" withString:@""];
        urlString = [urlString stringByReplacingOccurrencesOfString:@"(" withString:@""];
        urlString = [urlString stringByReplacingOccurrencesOfString:@"-" withString:@""];
        urlString = [urlString stringByReplacingOccurrencesOfString:@" " withString:@""];
        urlString = [urlString stringByReplacingOccurrencesOfString:@"506" withString:@""];
        NSString *finalText = [@"tel://" stringByAppendingString:urlString];
        NSURL *url = [NSURL URLWithString:finalText];
        if ([[UIApplication sharedApplication] canOpenURL:url]) {
            [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:^(BOOL success) {
                if (success) {
                    NSLog(@"Opened URL successfully");
                } else {
                    NSLog(@"Failed to open URL");
                }
            }];
        }
    }
}
- (void)emailTapped:(UITapGestureRecognizer *)sender {
    UILabel *emailLabel = (UILabel *) sender.view;
    NSString *text = emailLabel.text;
    if (text != nil) {
        NSString *finalText = [@"mailto:" stringByAppendingString:text];
        NSURL *url = [NSURL URLWithString:finalText];
        if ([[UIApplication sharedApplication] canOpenURL:url]) {
            [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:^(BOOL success) {
                if (success) {
                    NSLog(@"Opened URL successfully");
                } else {
                    NSLog(@"Failed to open URL");
                }
            }];
        }
    }
}
- (void)websiteTapped:(UITapGestureRecognizer *)sender {
    UILabel *websiteLabel = (UILabel *) sender.view;
    NSString *text = websiteLabel.text;
    if (text != nil) {
        NSURL *url = [NSURL URLWithString:text];
        if ([[UIApplication sharedApplication] canOpenURL:url]) {
            [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:^(BOOL success) {
                if (success) {
                    NSLog(@"Opened URL successfully");
                } else {
                    NSLog(@"Failed to open URL");
                }
            }];
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

@end
