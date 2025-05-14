//
//  ImageViewerViewController.m
//  MIO
//
//  Created by Fabricio Rodriguez on 3/12/19.
//  Copyright © 2019 MIO CIMAR. All rights reserved.
//

#import "ImageViewerViewController.h"

@interface ImageViewerViewController ()<UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *closeBarButtonItem;

@end

@implementation ImageViewerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.imageView.image = self.image;
    [self.closeBarButtonItem setTitle:LocalizedString(@"tourist-imageviewer-exit")];
}

- (IBAction)close:(id)sender {
    [self.navigationController dismissViewControllerAnimated:true completion:nil];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}

@end
