//
//  XXImageEditViewController.m
//  ImageDemo
//
//  Created by XUE2 on 16/6/27.
//  Copyright © 2016年 XUE. All rights reserved.
//

#import "XXImageEditViewController.h"

@interface XXImageEditViewController () <UIScrollViewDelegate>

@property (weak, nonatomic) UIView *maskView;
@property (weak, nonatomic) UIImageView *imageView;
@property (nonatomic, assign) CGRect rectCropped;
@property (weak, nonatomic) UIScrollView *scrollView;
@property (nonatomic, assign) BOOL didCenterImageView;

@end

#define EDIT_WINDOW_SIZE [UIApplication sharedApplication].keyWindow.bounds.size
#define DefaultRectCropped  CGRectMake(20, 20, EDIT_WINDOW_SIZE.width-40, EDIT_WINDOW_SIZE.height-80)

static NSString *const KEY_PATH = @"contentSize";
static CGFloat const OFFSET = -60;


@implementation XXImageEditViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setup];
    [self setupMask];
    [self setupActions];
    [self.scrollView addObserver:self forKeyPath:KEY_PATH options:0 context:nil];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
}

- (void)setupActions
{
    CGFloat leftMargin = 20, topMargin = 10;
    UIButton *leftCancel = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 80, 40)];
    [leftCancel setTitle:@"取消" forState:UIControlStateNormal];
    [leftCancel setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [leftCancel addTarget:self action:@selector(onDismissing) forControlEvents:UIControlEventTouchUpInside];
    [leftCancel sizeToFit];
    [leftCancel setFrame:CGRectMake(leftMargin, EDIT_WINDOW_SIZE.height-40-topMargin, leftCancel.bounds.size.width, leftCancel.bounds.size.height)];
    [self.view addSubview:leftCancel];
    [self.view bringSubviewToFront:leftCancel];
    
    UIButton *buttonSure = [[UIButton alloc] initWithFrame:CGRectMake(0, EDIT_WINDOW_SIZE.height-40, 80, 40)];
    [buttonSure setTitle:@"确定" forState:UIControlStateNormal];
    [buttonSure setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [buttonSure addTarget:self action:@selector(onSavingImage) forControlEvents:UIControlEventTouchUpInside];
    [buttonSure sizeToFit];
    [buttonSure setFrame:CGRectMake(EDIT_WINDOW_SIZE.width-buttonSure.bounds.size.width-leftMargin, EDIT_WINDOW_SIZE.height-40-topMargin, buttonSure.bounds.size.width, buttonSure.bounds.size.height)];
    [self.view addSubview:buttonSure];
    [self.view bringSubviewToFront:buttonSure];
}

- (void)setupMask
{
    CGMutablePathRef mPath = CGPathCreateMutable();
    CGPathAddPath(mPath, NULL, CGPathCreateWithRect(self.maskView.frame, NULL));
    CGPathAddPath(mPath, NULL, CGPathCreateWithRect(CGRectMake(0, 0, EDIT_WINDOW_SIZE.width, EDIT_WINDOW_SIZE.height), NULL));
    CAShapeLayer *rectLayer = [CAShapeLayer layer];
    rectLayer.path = mPath;
    rectLayer.fillRule = kCAFillRuleEvenOdd;
    [rectLayer setFillColor: [UIColor colorWithWhite:0x66/255.f alpha:0.8].CGColor];
    [self.view.layer addSublayer:rectLayer];
}

#pragma mark - Selectors

- (void)setup
{
    UIScrollView *scrollView;
    UIImageView *imageView;
    NSDictionary *viewsDictionary;
    
    // Create the scroll view and the image view.
    scrollView  = [[UIScrollView alloc] init];
    imageView = [[UIImageView alloc] init];
    
    // Add an image to the image view.
    [imageView setImage:self.image];
    
    // Add the scroll view to our view.
    [self.view addSubview:scrollView];
    
    // Add the image view to the scroll view.
    [scrollView addSubview:imageView];
    
    // Set the translatesAutoresizingMaskIntoConstraints to NO so that the views autoresizing mask is not translated into auto layout constraints.
    scrollView.translatesAutoresizingMaskIntoConstraints  = NO;
    imageView.translatesAutoresizingMaskIntoConstraints = NO;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.showsHorizontalScrollIndicator = NO;
    
    // Set the constraints for the scroll view and the image view.
    viewsDictionary = NSDictionaryOfVariableBindings(scrollView, imageView);
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[scrollView]|" options:0 metrics: 0 views:viewsDictionary]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[scrollView]|" options:0 metrics: 0 views:viewsDictionary]];
    [scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[imageView]|" options:0 metrics: 0 views:viewsDictionary]];
    [scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[imageView]|" options:0 metrics: 0 views:viewsDictionary]];
    CGFloat bottom = MAX(0, EDIT_WINDOW_SIZE.height-self.rectCropped.size.height-self.rectCropped.origin.y);
    [scrollView setContentInset:UIEdgeInsetsMake(self.rectCropped.origin.y, self.rectCropped.origin.x, bottom, self.rectCropped.origin.x)];
    self.scrollView = scrollView;
    self.imageView = imageView;
    self.scrollView.delegate = self;
    self.scrollView.minimumZoomScale = MAX(self.rectCropped.size.width/self.image.size.width, self.rectCropped.size.height/self.image.size.height);
    self.scrollView.maximumZoomScale = 6*self.scrollView.minimumZoomScale;
    [self.scrollView setZoomScale:self.scrollView.minimumZoomScale];
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.scrollView.bounces = YES;
    self.automaticallyAdjustsScrollViewInsets = NO;
}


#pragma mark - Getters

/*
 rect: (20, 20, width-40, height-80), save 60 for bottom buttons
 always center mask view
 */
- (CGRect)rectCropped
{
    CGRect rect = [self rectByEdgeVertical:20];
    if (CGRectIsEmpty(rect)) {
        self.ratio = 1;
        return [self rectByEdgeVertical:20];
    }
    return rect;
}

- (CGRect)rectByEdgeVertical: (CGFloat)edge
{
    if (edge >= (EDIT_WINDOW_SIZE.height+OFFSET)/2) {
        return CGRectZero;
    }
    CGFloat edgeVertical = edge;
    CGFloat height = ceilf(EDIT_WINDOW_SIZE.height-edgeVertical-(edgeVertical-OFFSET));
    CGFloat width = ceilf(height/self.ratio);
    if (width >= EDIT_WINDOW_SIZE.width) {
        return [self rectByEdgeVertical:edge+10];
    }else {
        CGFloat edgeHorizontal = ceilf((EDIT_WINDOW_SIZE.width-width)*0.5);
        return CGRectMake(edgeHorizontal, edgeVertical, width, height);
    }
}

- (UIView *)maskView
{
    if (!_maskView) {
        UIView *view = [[UIView alloc] initWithFrame:self.rectCropped];
        view.userInteractionEnabled = NO;
        [self.view addSubview:view];
        [self.view bringSubviewToFront:view];
        _maskView = view;
    }
    return _maskView;
}

#pragma mark - Actions

- (void)onDismissing
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)onSavingImage
{
    UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, NO, [UIScreen mainScreen].scale);
    [self.view drawViewHierarchyInRect:self.view.bounds afterScreenUpdates:YES];
    UIImage *snapshot = UIGraphicsGetImageFromCurrentImageContext();
    CGFloat scale = [UIScreen mainScreen].scale;
    CGImageRef imageRef = CGImageCreateWithImageInRect(snapshot.CGImage, CGRectMake(self.rectCropped.origin.x*scale, self.rectCropped.origin.y*scale, self.rectCropped.size.width*scale, self.rectCropped.size.height*scale));
    UIGraphicsEndImageContext();
    if ([self.delegate respondsToSelector:@selector(imageEditViewControllerDidSaveImage:)]) {
        UIImage *newImage = [UIImage imageWithCGImage:imageRef];
        CGSize imagesize = CGSizeMake(ceilf(self.image.size.width), ceilf(self.image.size.width*self.ratio));
        if (imagesize.height > self.image.size.height) {
            imagesize = CGSizeMake(ceilf(self.image.size.height/self.ratio), ceilf(self.image.size.height));
        }
        UIGraphicsBeginImageContext(imagesize);
        [newImage drawInRect:CGRectMake(0,0,imagesize.width,imagesize.height)];
        newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        [self.delegate imageEditViewControllerDidSaveImage:newImage];
    }
    [self onDismissing];
}


#pragma mark - Observer Value

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:KEY_PATH] && self.scrollView.contentSize.width > 0 && !self.didCenterImageView) {
        [self.scrollView setContentOffset:CGPointMake(ceilf((self.scrollView.contentSize.width-self.scrollView.bounds.size.width)/2), ceilf((self.scrollView.contentSize.height-self.scrollView.bounds.size.height-OFFSET)/2))];
        self.didCenterImageView = YES;
    }
}

#pragma mark - UIScrollView Delegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}


- (void)dealloc
{
    [self.scrollView removeObserver:self forKeyPath:KEY_PATH];
}


@end
