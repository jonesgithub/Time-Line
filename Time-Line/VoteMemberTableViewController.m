//
//  VoteMemberTableViewController.m
//  Go2
//
//  Created by IF on 15/5/26.
//  Copyright (c) 2015年 zhilifang. All rights reserved.
//

#import "VoteMemberTableViewController.h"
#import "FriendInfoTableViewCell.h"
#import "MemberDataModel.h"
#import "UIImageView+WebCache.h"

@interface VoteMemberTableViewController ()

@end

@implementation VoteMemberTableViewController
@synthesize voteMemberArr;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Voted" ;
    UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftBtn setFrame:CGRectMake(0, 0, 17 , 17)];
    [leftBtn setTag:1];
    [leftBtn setBackgroundImage:[UIImage imageNamed:@"go2_cross"] forState:UIControlStateNormal] ;
    [leftBtn addTarget:self action:@selector(backToEventView) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftBtn] ;
    

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return voteMemberArr.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.01f;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 55.f;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.01f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    FriendInfoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"memberVoteCellId"];
    if (!cell) {
        cell = (FriendInfoTableViewCell *)[[[NSBundle mainBundle] loadNibNamed:@"FriendInfoTableViewCell" owner:self options:nil] lastObject];
        //  cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    MemberDataModel *memberData = [self.voteMemberArr objectAtIndex:indexPath.section];
    
    NSString *_urlStr = [[NSString stringWithFormat:@"%@/%@", BASEURL_IP, memberData.imgBig] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"%@", _urlStr);
    NSURL *url = [NSURL URLWithString:_urlStr];
    [cell.addFriendBtn setHidden:YES] ;//隐藏添加朋友按钮
    [cell.userHead sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"smile_1"] completed:nil];
    
    if (memberData.nickname && ![@"" isEqualToString:memberData.nickname]) { //如果有别名就显示别名
        cell.nickName.text = memberData.nickname;
    }else {
        cell.nickName.text = memberData.nickname;
    }
    return cell;
}


#pragma mark - Table view delegate
// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(void)backToEventView{
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
