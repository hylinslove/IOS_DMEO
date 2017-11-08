//
//  MediaViewController.m
//  landExamination
//
//  Created by xianglong on 2017/10/12.
//  Copyright © 2017年 Chinastis. All rights reserved.
//

#import "MediaViewController.h"
#import "ImgPickCollectionViewCell.h"
#import "HCImage.h"
#import <Photos/Photos.h>
#import "ImageViewController.h"

@interface MediaViewController ()<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>


@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@end

@implementation MediaViewController{
    int width;
    int height;
    NSFileManager *manager;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //防止导航栏遮挡控件
    self.edgesForExtendedLayout = UIRectEdgeNone;
    manager = [NSFileManager defaultManager];
    [self initCollectionView];
    
    
}
-(void)initCollectionView{
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    UINib *nib = [UINib nibWithNibName:@"ImgPickCollectionViewCell" bundle: [NSBundle mainBundle]];
    [_collectionView registerNib:nib forCellWithReuseIdentifier:@"ImgCell"];
    
    CGRect screenFrame = [UIScreen mainScreen].bounds;
    width = screenFrame.size.width;
    height = screenFrame.size.height;
    
}
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    switch (_mediaType) {
        case 0:
            return _selectedPhotos.count;
            break;
        case 1:
            return _zzSelectedPhotos.count;
            break;
        case 2:
            return _selectedMP4.count;
            break;
    }
    
    return 0;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    
    ImgPickCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ImgCell" forIndexPath:indexPath];
    
    cell.imageView.image = nil;
    cell.deleteBtn.hidden = YES;
    cell.videoImageView.hidden = YES;
    [cell drawUI];
    cell.videoImageView.hidden = YES;
    if (_mediaType == 0) {
        //现场核查图片
        cell.imageView.image = [UIImage imageWithData:[NSData dataWithContentsOfFile:_selectedPhotos[indexPath.row]] scale:1];
       
    }else if(_mediaType == 1){
         //佐证图片
        cell.imageView.image = [UIImage imageWithData:[NSData dataWithContentsOfFile:_zzSelectedPhotos[indexPath.row]] scale:1];
    }else{
        //现场核查视频
        cell.imageView.image =  [self getImage: _selectedMP4[0]];
        cell.videoPath = _selectedMP4[0];
        
    }
    cell.deleteBtn.tag = indexPath.row;
    [cell.deleteBtn addTarget:self action:@selector(deleteBtnClik:) forControlEvents:UIControlEventTouchUpInside];
    return cell;
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    
    return CGSizeMake((width-22)/3,(width-22)/3 );
    
}

-(CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return 2;
}
-(CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return 4;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"select item at %ld",(long)indexPath.row);
    
    ImageViewController *previewVC = [[ImageViewController alloc]init];
    
    UIImage *image;
    switch (_mediaType) {
        case 0:
            image = [UIImage imageWithData:[NSData dataWithContentsOfFile:_selectedPhotos[indexPath.row]] scale:1];
            previewVC.imgage = image;
            break;
        case 1:
            image = [UIImage imageWithData:[NSData dataWithContentsOfFile:_zzSelectedPhotos[indexPath.row]] scale:1];
            previewVC.imgage = image;
            break;
        case 2:
            previewVC.videoPath =  _selectedMP4[0];
            break;
    }
    [self presentViewController:previewVC animated:YES completion:nil];
}

- (UIImage *)getImage:(NSString *)videoURL

{
    
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:videoURL] options:nil];
    
    AVAssetImageGenerator *gen = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    
    gen.appliesPreferredTrackTransform = YES;
    
    CMTime time = CMTimeMakeWithSeconds(0.0, 60);
    
    NSError *error = nil;
    
    CMTime actualTime;
    
    CGImageRef image = [gen copyCGImageAtTime:time actualTime:&actualTime error:&error];
    
    UIImage *thumb = [[UIImage alloc] initWithCGImage:image];
    
    CGImageRelease(image);
    
    return thumb;
    
}

//CollectionCell中点击叉
- (void)deleteBtnClik:(UIButton *)sender {
    
    
    switch (_mediaType) {
        case 0:
            [manager removeItemAtPath:_selectedPhotos[sender.tag] error:nil];
            [_selectedPhotos removeObjectAtIndex:sender.tag];
            break;
        case 1:
            [manager removeItemAtPath:_zzSelectedPhotos[sender.tag] error:nil];
            [_zzSelectedPhotos removeObjectAtIndex:sender.tag];
            break;
        case 2:
            [manager removeItemAtPath:_selectedMP4[sender.tag] error:nil];
            [_selectedMP4 removeObjectAtIndex:sender.tag];
            break;
    }
    
    [_collectionView performBatchUpdates:^{
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:sender.tag inSection:0];
        [_collectionView deleteItemsAtIndexPaths:@[indexPath]];
    } completion:^(BOOL finished) {
        [_collectionView reloadData];
    }];
    
    
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
