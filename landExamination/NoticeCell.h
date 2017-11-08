//
//  NoticeCell.h
//  landExamination
//
//  Created by xianglong on 2017/10/23.
//  Copyright © 2017年 Chinastis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NoticeMission.h"

@interface NoticeCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *GUID;
@property (weak, nonatomic) IBOutlet UILabel *contentLable;

+(instancetype)cell;
-(void)setMisson:(NoticeMission *)mission withType:(NSInteger)type;

@end
