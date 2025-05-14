//
//  TouristInfoDetailViewController.m
//  MIO
//
//  Created by Fabricio Rodriguez on 3/10/19.
//  Copyright © 2019 MIO CIMAR. All rights reserved.
//

#import "TouristInfoDetailViewController.h"
#import "ImageViewerViewController.h"
#import <Haneke/Haneke.h>
@interface TouristInfoDetailViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;

@end

@implementation TouristInfoDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.titleLabel.text = self.information.title;
    self.descriptionLabel.text = self.information.descriptionText;
    self.navigationController.view.backgroundColor = [UIColor whiteColor];
    if(self.information.link && [self.information.link length] != 0) {
        NSURL *youtubeUrl = [NSURL URLWithString:self.information.link];
        NSURLComponents *components = [NSURLComponents componentsWithString:self.information.link];
        if(youtubeUrl) {
            NSString *thumbnailUrl = [NSString stringWithFormat: @"%@/%@/%@",@"https://img.youtube.com/vi", components.queryItems.firstObject.value , @"mqdefault.jpg"];
            [self.imageView hnk_setImageFromURL:[NSURL URLWithString:thumbnailUrl]];
        }
    }else if(self.information.mfImage) {
        [self.imageView hnk_setImageFromURL:[NSURL URLWithString:self.information.mfImage.url]];
    }
}
- (IBAction)imageTapped:(id)sender {
    if(self.information.link && [self.information.link length] != 0) {
        NSURL *youtubeUrl = [NSURL URLWithString:self.information.link];
        [UIApplication.sharedApplication openURL:youtubeUrl];
    }else {
        ImageViewerViewController *viewer = [self.storyboard instantiateViewControllerWithIdentifier:@"ImageViewerViewController"];
        if(viewer){
            viewer.image = self.imageView.image;
            UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:viewer];
            [nav.navigationBar setTranslucent:YES];
            [nav.navigationBar setBarTintColor:[UIColor blackColor]];
            [self presentViewController:nav animated:true completion:nil];
        }
    }
}

@end
