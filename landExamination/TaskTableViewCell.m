//
//  TaskTableViewCell.m
//  landExamination
//
//  Created by xianglong on 2017/9/27.
//  Copyright © 2017年 JiangsuJiyang. All rights reserved.
//

#import "TaskTableViewCell.h"

@implementation TaskTableViewCell


+(instancetype)cell
{
    TaskTableViewCell *myCell = [[[NSBundle mainBundle] loadNibNamed:@"TaskTableViewCell" owner:self options:nil] lastObject];
    return myCell;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)showContent{
    _content.hidden = NO;
}
-(void)hideContent{
    _content.hidden = YES;
}

-(void)setMissionModel:(MissionModel *)missionmodel number:(NSInteger) num{
    _num.text = [NSString stringWithFormat:@"%ld",(long)num] ;
    _TDBHLb.text = missionmodel.GUID;
    _ZQMCLb.text = [NSString stringWithFormat:@"%@%@%@",missionmodel.SHENG,missionmodel.SHI,missionmodel.XIAN];
    _WTNDLb.text = missionmodel.ND;
    _TBBHLb.text = missionmodel.TBBH;
    _DKBHLb.text = missionmodel.DKBH;
    _XMMCLb.text = missionmodel.XMMC;
    _YDDWLb.text = missionmodel.YDDW;
    _YDMJLb.text = missionmodel.YDMJ;
    _TDZLLb.text = missionmodel.TDZL;
    _PZWHLb.text = missionmodel.PZWH;
    _TDZHLb.text = missionmodel.TDZH;
    _WTLXLb.text = missionmodel.WTLX;
    _HCZTLb.text = missionmodel.HCZT;
    _HTLYLb.text = missionmodel.HTLY;
    
    _HTLYLb.hidden = [missionmodel.isTH isEqualToString:@"0"];
    _HTLY_TITLE.hidden = [missionmodel.isTH isEqualToString:@"0"];
}
@end
