//
//  ViewController.m
//  ImageDemo
//
//  Created by XUE on 16/7/5.
//  Copyright © 2016年 XUE. All rights reserved.
//

#import "ViewController.h"
#import "XXImagePickerController.h"

@interface ViewController () <XXImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UITextField *textField;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.imageView.layer.borderColor = [UIColor grayColor].CGColor;
    self.imageView.layer.borderWidth = 0.5;
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;//:completeSettings = none

    self.textField.keyboardType = UIKeyboardTypeDecimalPad;
}

- (IBAction)onTappingImage:(id)sender {
    float ratio = self.textField.text.floatValue;
    
    //  ratio = height / width
    XXImagePickerController *controller = [[XXImagePickerController alloc] initWithRatio:ratio];
    controller.delegateXX = self;
    [self presentViewController:controller animated:YES completion:nil];
}

- (void)xxImagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    UIImage *image = [info valueForKey:UIImagePickerControllerEditedImage];
    if (!image) {
        image = [info valueForKey:UIImagePickerControllerOriginalImage];
    }
    self.imageView.image = image;
}

@end
