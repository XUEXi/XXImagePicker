//
//  XXImageEditViewController.h
//  ImageDemo
//
//  Created by XUE2 on 16/6/27.
//  Copyright © 2016年 XUE. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol XXImageEditViewControllerDelegate <NSObject>

- (void)imageEditViewControllerDidSaveImage: (UIImage *)image;

@end

@interface XXImageEditViewController : UIViewController

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, assign) float ratio;    // height/width
@property (nonatomic, weak) id<XXImageEditViewControllerDelegate> delegate;

@end
