//
//  MoreViewController.m
//  MIO
//
//  Created by Fabricio Rodriguez on 3/8/19.
//  Copyright © 2019 MIO CIMAR. All rights reserved.
//

#import "MoreViewController.h"
#import "WebViewViewController.h"

@interface MoreViewController () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *versionLabel;
@property (weak, nonatomic) IBOutlet UILabel *developedBy;
@property (weak, nonatomic) IBOutlet UIButton *companyName;
@property (weak, nonatomic) IBOutlet UIView *headerDivider;
@property NSArray *elements;
@property (strong, nonatomic) NSURL *youtubeURL;
@end

@implementation MoreViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupLocalizableStrings];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.youtubeURL = [NSURL URLWithString:@"https://www.youtube.com/channel/UC7_s05gll66iBoWrB-I9cLA"];
    self.navigationController.view.backgroundColor = [UIColor whiteColor];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.headerDivider.backgroundColor = [UIColor colorWithRed:224/255.0 green:224/255.0 blue:224/255.0 alpha:1.0];
    if (@available(iOS 11.0, *)) {
        self.navigationController.navigationBar.prefersLargeTitles = YES;
        self.titleLabel.text = nil;
    } else {
        self.titleLabel.text = LocalizedString(@"more-title");
        self.navigationItem.titleView = [[UIView alloc] init];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(languageChanged:) name:kMIOLanguageModifiedKey object:nil];
}

- (void)languageChanged:(NSNotification *)notification {
    [self setupLocalizableStrings];
    [self.tableView reloadData];
}

- (void) setupLocalizableStrings {
    self.title = LocalizedString(@"more-title");
    self.developedBy.text = LocalizedString(@"settings-developed-by");
    self.elements = @[LocalizedString(@"menu-contact"),
                      LocalizedString(@"menu-settings"),
                      LocalizedString(@"settings-legal-disclaimer")];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.elements.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MoreCell"];
    
    cell.textLabel.text = [self.elements objectAtIndex:indexPath.row];
    cell.textLabel.font = [UIFont fontWithName:@"SFUIText-Regular" size:22.0f];
    cell.textLabel.textColor = [[UIColor alloc] initWithRed:0 green:0.69 blue:1 alpha:1];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case 0:
            [self performSegueWithIdentifier:@"Contact" sender:self];
            break;
        case 1:
            [self performSegueWithIdentifier:@"Settings" sender:self];
            break;
        case 2:
            [self performSegueWithIdentifier:@"LegalAdvice" sender:self];
            break;
        default:
            break;
    }
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"MoreToWebView"]) {
        WebViewViewController *webview = (WebViewViewController *) segue.destinationViewController;
        if(webview != nil){
            webview.webURL = @"https://www.youtube.com/channel/UC7_s05gll66iBoWrB-I9cLA";
        }
    }
}

- (IBAction)companyTapped:(id)sender {
//    NSURL *imactusURL = [NSURL URLWithString:@"http://www.imactus.com"];
//    
//    [MIOAnalyticsManager trackEventWithCategory:@"More link" action:[imactusURL absoluteString]];
//    
//    if ([[UIApplication sharedApplication] canOpenURL:imactusURL]) {
//        [[UIApplication sharedApplication] openURL:imactusURL options:@{} completionHandler:^(BOOL success) {
//            if (success) {
//                NSLog(@"Opened URL successfully");
//            } else {
//                NSLog(@"Failed to open URL");
//            }
//        }];
//    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
