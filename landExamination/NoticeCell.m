//
//  NoticeCell.m
//  landExamination
//
//  Created by xianglong on 2017/10/23.
//  Copyright © 2017年 Chinastis. All rights reserved.
//

#import "NoticeCell.h"

@implementation NoticeCell

+(instancetype)cell
{
    NoticeCell *myCell = [[[NSBundle mainBundle] loadNibNamed:@"NoticeCell" owner:self options:nil] lastObject];
    return myCell;
}

-(void)setMisson:(NoticeMission *)mission withType:(NSInteger)type{
    _GUID.text = [NSString stringWithFormat:@"任务编号：%@",mission.GUID];
    
    if(type == 0) {
        _contentLable.text = [NSString stringWithFormat:@"回退原因：%@",mission.CONTENT];
    } else {
        _contentLable.text = [NSString stringWithFormat:@"删除原因：%@",mission.CONTENT];
    }
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
