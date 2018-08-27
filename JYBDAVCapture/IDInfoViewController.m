//
//  IDInfoViewController.m
//  IDCardRecognition
//
//  Created by tianxiuping on 2018/6/27.
//  Copyright © 2018年 XP. All rights reserved.
//

#import "IDInfoViewController.h"
#import "JYBDCardIDInfo.h"

@interface IDInfoViewController ()<UITableViewDelegate,UITableViewDataSource>


@property (strong, nonatomic)  NSMutableArray *dataArr;
@property (strong, nonatomic)  UITableView *tableView;
@end

@implementation IDInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
  
    self.navigationItem.title = @"扫描信息";
    self.view.backgroundColor = [UIColor whiteColor];
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 84, self.view.bounds.size.width, self.view.bounds.size.height-84) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    
    UIView *hearView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 200)];
    UIImageView *imageV = [[UIImageView alloc]initWithFrame:CGRectMake(15, 0, self.tableView.frame.size.width-30, 200)];
    imageV.image = self.IDImage;
    [hearView addSubview:imageV];
    self.tableView.tableHeaderView = hearView;
    
    if (self.IDInfo)
    {
       [self.dataArr addObject:[NSString stringWithFormat:@"卡号: %@",_IDInfo.num]];
        [self.dataArr addObject:[NSString stringWithFormat:@"姓名: %@",_IDInfo.name]];
        [self.dataArr addObject:[NSString stringWithFormat:@"性别: %@",_IDInfo.gender]];
        [self.dataArr addObject:[NSString stringWithFormat:@"民族: %@",_IDInfo.nation]];
        [self.dataArr addObject:[NSString stringWithFormat:@"地址: %@",_IDInfo.address]];
        [self.dataArr addObject:[NSString stringWithFormat:@"签发机关: %@",_IDInfo.issue]];
        [self.dataArr addObject:[NSString stringWithFormat:@"有效期: %@",_IDInfo.valid]];
    }
    
    if (self.cardInfo)
    {
        [self.dataArr addObject:[NSString stringWithFormat:@"银行卡号：%@",self.cardInfo.bankNumber]];
        [self.dataArr addObject:[NSString stringWithFormat:@"银行卡类型：%@",self.cardInfo.bankName]];
    }
    
    [self.tableView reloadData];
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArr.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 46;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"cellId"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cellId"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    cell.textLabel.textColor = [UIColor blackColor];
    cell.textLabel.text = [self.dataArr objectAtIndex:indexPath.row];
    
    return cell;
}

- (NSMutableArray *)dataArr
{
    if (!_dataArr) {
        _dataArr = [[NSMutableArray alloc]init];
    }
    return _dataArr;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
