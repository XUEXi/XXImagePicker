//
//  XXImagePickerController.m
//  XXImagePicker
//
//  Created by XUE on 16/7/5.
//  Copyright © 2016年 XUE. All rights reserved.
//

#import "XXImagePickerController.h"
#import "XXImageEditViewController.h"

@interface XXImagePickerController () <XXImageEditViewControllerDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (nonatomic, assign) float ratio;
@property (nonatomic, strong) NSDictionary *infoDictionary;

@end

@implementation XXImagePickerController

- (instancetype)initWithRatio: (float)ratio
{
    self = [super init];
    if (self) {
        self.ratio = ratio;
        self.delegate = self;
        self.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    return self;
}

#pragma mark - UIImagePickerController Delegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    if (self.ratio != 0) {
        XXImageEditViewController *vc = [[XXImageEditViewController alloc] init];
        vc.image = [info valueForKey:UIImagePickerControllerOriginalImage];
        vc.ratio = self.ratio;
        vc.delegate = self;
        [picker pushViewController:vc animated:NO];
        self.infoDictionary = info;

    }else {
        [picker dismissViewControllerAnimated:YES completion:^{
            if ([self.delegate respondsToSelector:@selector(imagePickerController:didFinishPickingMediaWithInfo:)]) {
                [self.delegateXX xxImagePickerController:self didFinishPickingMediaWithInfo:info];
            }
        }];
    }
}

#pragma mark - XXImageEditViewController Delegate

- (void)imageEditViewControllerDidSaveImage:(UIImage *)image
{
    if ([self.delegate respondsToSelector:@selector(imagePickerController:didFinishPickingMediaWithInfo:)]) {
        
        NSMutableDictionary *mDictionary = [NSMutableDictionary dictionaryWithDictionary:self.infoDictionary];
        [mDictionary setValue:image forKey:UIImagePickerControllerEditedImage];
        self.infoDictionary = [NSDictionary dictionaryWithDictionary:mDictionary];
        [self.delegateXX xxImagePickerController:self didFinishPickingMediaWithInfo:self.infoDictionary];
        
        [self dismissViewControllerAnimated:NO completion:nil];
    }
}

- (void)dealloc
{
}

@end
