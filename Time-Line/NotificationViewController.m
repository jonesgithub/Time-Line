//
//  NotificationViewController.m
//  Time-Line
//
//  Created by IF on 14-10-11.
//  Copyright (c) 2014年 zhilifang. All rights reserved.
//

#import "NotificationViewController.h"
#import "Calendar.h"
#import "AT_Account.h"
#import "CircleDrawView.h"

@interface NotificationViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic,retain) UITableView *tableView;
@property (nonatomic,retain) NSMutableArray *selectIndexPathArr;
@property (nonatomic,assign) BOOL isSelect;
@property (nonatomic,retain) NSMutableArray *calendarArr;
@property (nonatomic,strong) NSMutableArray *calendarLs;
@end

@implementation NotificationViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationItem setHidesBackButton:YES animated:YES];
    
    self.selectIndexPathArr=[NSMutableArray arrayWithCapacity:0];
    self.calendarArr=[NSMutableArray arrayWithCapacity:0];
    self.tableView=[[UITableView alloc] initWithFrame:[[UIScreen mainScreen] bounds] style:UITableViewStyleGrouped];
    self.tableView.dataSource=self;
    self.tableView.delegate=self;
    [self.view addSubview:self.tableView];
    
    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 40)];
    UILabel* titlelabel=[[UILabel alloc]initWithFrame:titleView.frame];
    titlelabel.textAlignment = NSTextAlignmentCenter;
    titlelabel.font =[UIFont fontWithName:@"Helvetica Neue" size:20.0];
    titlelabel.text = @"Notifications";
    titlelabel.textColor = [UIColor whiteColor];
    [titleView addSubview:titlelabel];
    self.navigationItem.titleView =titleView;
    
    self.navigationItem.hidesBackButton=YES;
    UIButton *leftBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    [leftBtn setBackgroundImage:[UIImage imageNamed:@"Icon_BackArrow"] forState:UIControlStateNormal];
    leftBtn.frame=CGRectMake(0, 2, 21, 25);
    [leftBtn addTarget:self action:@selector(notificationTobackSetingView) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem=[[UIBarButtonItem alloc] initWithCustomView:leftBtn];
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.calendarArr removeAllObjects];
    
    NSArray *atAccountLs= [AT_Account MR_findAll];
    for (AT_Account *atAccount in atAccountLs) {
        NSPredicate *pre=[NSPredicate predicateWithFormat:@"atAccount==%@",atAccount];
        NSArray * caArr= [Calendar MR_findAllWithPredicate:pre];
        [self.calendarArr addObject:caArr];
    }
    self.calendarLs=[[Calendar MR_findAll] mutableCopy];
    
}



-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    
    for (Calendar *calendar in self.calendarLs) {
        calendar.isNotification=@(0);
        for (NSIndexPath *indexPath in self.selectIndexPathArr) {
            Calendar *ca= [[self.calendarArr objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
            if ([calendar.cid isEqualToString:ca.cid]) {
                calendar.isNotification=@(1);
            }
        }
        [[NSManagedObjectContext MR_defaultContext ] MR_saveToPersistentStoreAndWait];
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.calendarArr.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *arr=self.calendarArr[section];
    return arr.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 40.f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSArray *calendarListArr=self.calendarArr[section];
    Calendar *tmpObj=[calendarListArr objectAtIndex:0];
    NSString *returnStr=@"";
    if ([tmpObj.type intValue]==AccountTypeGoogle) {
        returnStr=[NSString stringWithFormat:@"  GOOGLE(%@)",tmpObj.account];
    }else if([tmpObj.type intValue]==AccountTypeLocal){
        returnStr=[NSString stringWithFormat:@"  IF(%@)",tmpObj.account];
    }
    
    UILabel *label=[[UILabel alloc] init] ;
    label.frame=CGRectMake(2, 18, 300, 22);
    label.backgroundColor=[UIColor clearColor];
    label.textColor=[UIColor grayColor];
    label.text=returnStr;
    
    UIView *sectionView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 22)];
    [sectionView setBackgroundColor:[UIColor clearColor]];
    [sectionView addSubview:label];
    return sectionView;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier=@"cellNotification";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell==nil) {
        cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    NSArray *viewarr=[cell.contentView subviews];
    for (UIView *view in viewarr) {
        [view removeFromSuperview];
    }
    
    NSArray *calendarListArr=[self.calendarArr objectAtIndex:indexPath.section];
    Calendar *ca=[calendarListArr objectAtIndex:indexPath.row];
    if (!self.isSelect) {
        if ([ca.isNotification intValue]==1) {//是默认
            cell.accessoryType=UITableViewCellAccessoryCheckmark;
            [self.selectIndexPathArr addObject:indexPath];
            if (indexPath.section==self.calendarArray.count-1) {
                if(indexPath.row==calendarListArr.count-1){
                    self.isSelect=YES;
                }
            }
        }
     }
    
    CircleDrawView *cd=[[CircleDrawView alloc] initWithFrame:CGRectMake(0, 2, 40, 40)];
    cd.hexString=ca.backgroundColor;
    [cell.contentView addSubview: cd];
    
    UILabel *contextLab=[[UILabel alloc] initWithFrame:CGRectMake(cd.frame.size.width, 2, 215, 40)];
    [contextLab setBackgroundColor:[UIColor clearColor]];
    contextLab.lineBreakMode=NSLineBreakByTruncatingMiddle;
    if ([ca.type intValue ]==AccountTypeGoogle) {
        [contextLab setText:ca.summary];
    }else if([ca.type intValue ]==AccountTypeLocal){
        [contextLab setText:ca.summary];
    }
    [cell.contentView addSubview:contextLab];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UITableViewCell * cell=(UITableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
    if (cell.accessoryType==UITableViewCellAccessoryCheckmark) {
        cell.accessoryType=UITableViewCellAccessoryNone;
        [self.selectIndexPathArr removeObject:indexPath];
    }else{
        cell.accessoryType=UITableViewCellAccessoryCheckmark;
        [self.selectIndexPathArr addObject:indexPath];
    }
}

-(void) notificationTobackSetingView{
    [self.navigationController popViewControllerAnimated:YES];
}
@end
