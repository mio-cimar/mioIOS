//
//  ContactContainerViewController.m
//  MIO
//
//  Created by Fabricio Rodriguez on 3/10/19.
//  Copyright © 2019 MIO CIMAR. All rights reserved.
//

#import "ContactContainerViewController.h"

@interface ContactContainerViewController ()
@property (weak, nonatomic) IBOutlet UIView *separator;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleConstraint;

@end

@implementation ContactContainerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = LocalizedString(@"contact-title");
    if (@available(iOS 11.0, *)) {
        self.navigationController.navigationBar.prefersLargeTitles = YES;
        self.titleLabel.text = nil;
        [self.separator setHidden:YES];
        self.navigationController.navigationBar.shadowImage = [[[UINavigationBar alloc] init] shadowImage];
        self.titleConstraint.constant = 0;
    } else {
        self.titleLabel.text = LocalizedString(@"contact-title");
        self.navigationItem.titleView = [[UIView alloc] init];
        self.separator.backgroundColor = [[UITableView alloc] init].separatorColor;
    }
}

@end
