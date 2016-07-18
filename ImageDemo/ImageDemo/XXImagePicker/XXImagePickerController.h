//
//  XXImagePickerController.h
//  XXImagePicker
//
//  Created by XUE on 16/7/5.
//  Copyright © 2016年 XUE. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol XXImagePickerControllerDelegate

- (void)xxImagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info;

@end

@interface XXImagePickerController : UIImagePickerController

- (instancetype)initWithRatio: (float)ratio;

@property (nonatomic, weak) id<XXImagePickerControllerDelegate> delegateXX;

@end
