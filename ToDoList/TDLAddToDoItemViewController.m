//
//  ToDoList_AddToDoItemViewController.m
//  ToDoList
//
//  Created by Anthony Oliveri on 12/23/13.
//  Copyright (c) 2013 Anthony Oliveri. All rights reserved.
//

#import "TDLAddToDoItemViewController.h"

@interface TDLAddToDoItemViewController ()

@property TDLAppDelegate *appDelegate;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneButton;

@end


@implementation TDLAddToDoItemViewController


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
    self.appDelegate = [[UIApplication sharedApplication] delegate];
    [self.textField becomeFirstResponder];
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if(sender != self.doneButton) return;
}


// Make done button on keyboard dismiss the keyboard
-(IBAction)textFieldReturn:(id)sender
{
    [sender resignFirstResponder];
}
    
    
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
