//
//  CSViewController.m
//  CircleSlider
//
//  Created by Yongjia Liu on 14-1-28.
//  Copyright (c) 2014年 Yongjia Liu. All rights reserved.
//

#import "CSViewController.h"
#import "CSCircleSlider.h"
@interface CSViewController ()

@end

@implementation CSViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor=[UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:1];
    CSCircleSlider *slider=[[CSCircleSlider alloc]initWithFrame:CGRectMake(0, 60, SLIDER_SIZE, SLIDER_SIZE)];
    [slider addTarget:self action:@selector(newValue:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:slider];
    // Do any additional setup after loading the view from its nib.
}
-(void)newValue:(CSCircleSlider*)slider{
    //TBCircularSlider *slider = (TBCircularSlider*)sender;
    NSLog(@"Slider Value %d",slider.angle);
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
