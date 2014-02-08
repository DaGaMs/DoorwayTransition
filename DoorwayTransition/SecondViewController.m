//
//  SecondViewController.m
//  DoorwayTransition
//
//  Created by Benjamin Schuster-Boeckler on 08/02/2014.
//
//

#import "SecondViewController.h"

@interface SecondViewController ()
@property (weak, nonatomic) IBOutlet UIButton *backButton;

@end

@implementation SecondViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.view setNeedsLayout];
}

- (IBAction)didTapBackButton:(id)sender {
    NSLog(@"Should go back");
}

@end
