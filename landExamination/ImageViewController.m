//
//  ImageViewController.m
//  landExamination
//
//  Created by xianglong on 2017/10/17.
//  Copyright © 2017年 Chinastis. All rights reserved.
//

#import "ImageViewController.h"

@interface ImageViewController ()
- (IBAction)back:(id)sender;
@property (weak, nonatomic) IBOutlet UIImageView *ImageView;

@end

@implementation ImageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillLayoutSubviews{
    
    if (_imgage) {
        [self showImage];
    }
    if (_videoPath) {
        [self showViedo];
    }
    
}

- (void)showImage{
    
    _ImageView.hidden = NO;
    _ImageView.image = _imgage;
    
}

- (void)showViedo{
    NSURL *url = [NSURL fileURLWithPath:_videoPath];
    AVAsset *movieAsset = [AVURLAsset URLAssetWithURL:url options:nil];
    AVPlayerItem *playItem = [AVPlayerItem playerItemWithAsset:movieAsset];
    AVPlayer *player = [AVPlayer playerWithPlayerItem:playItem];
    AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:player];
    playerLayer.frame = self.view.frame;
    [self.view.layer addSublayer:playerLayer];
    [player play];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)back:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
