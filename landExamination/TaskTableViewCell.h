//
//  TaskTableViewCell.h
//  landExamination
//
//  Created by xianglong on 2017/9/27.
//  Copyright © 2017年 JiangsuJiyang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MissionModel.h"

@interface TaskTableViewCell : UITableViewCell
+(instancetype)cell;
-(void)showContent;
-(void)hideContent;
-(void)setMissionModel:(MissionModel *)missionmodel number:(NSInteger) num;
@property (weak, nonatomic) IBOutlet UIView *taskID;
@property (weak, nonatomic) IBOutlet UIView *content;
@property (weak, nonatomic) IBOutlet UILabel *num;
@property (weak, nonatomic) IBOutlet UILabel *TDBHLb;
@property (weak, nonatomic) IBOutlet UILabel *TBBHLb;
@property (weak, nonatomic) IBOutlet UILabel *ZQMCLb;
@property (weak, nonatomic) IBOutlet UILabel *WTNDLb;
@property (weak, nonatomic) IBOutlet UILabel *DKBHLb;
@property (weak, nonatomic) IBOutlet UILabel *XMMCLb;
@property (weak, nonatomic) IBOutlet UILabel *YDDWLb;
@property (weak, nonatomic) IBOutlet UILabel *YDMJLb;
@property (weak, nonatomic) IBOutlet UILabel *TDZLLb;
@property (weak, nonatomic) IBOutlet UILabel *PZWHLb;
@property (weak, nonatomic) IBOutlet UILabel *TDZHLb;
@property (weak, nonatomic) IBOutlet UILabel *WTLXLb;
@property (weak, nonatomic) IBOutlet UILabel *HCZTLb;
@property (weak, nonatomic) IBOutlet UILabel *HTLY_TITLE;
@property (weak, nonatomic) IBOutlet UILabel *HTLYLb;
@property (weak, nonatomic) IBOutlet UIButton *toCheck;



@property (strong, nonatomic) UITableView *table;


@end
