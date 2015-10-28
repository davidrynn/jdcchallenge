//
//  DRCollectionViewController.m
//  JetChallengeNSB
//
//  Created by David Rynn on 10/22/15.
//  Copyright © 2015 David Rynn. All rights reserved.
//

#import "DRCollectionViewController.h"
#import "DRPictureCell.h"
#import "DRAPIUtility.h"

@interface DRCollectionViewController ()<UIGestureRecognizerDelegate, UIScrollViewDelegate>
@property (nonatomic, strong) NSMutableDictionary *images;
@property (nonatomic, strong) NSMutableArray *imagesArray;
@property (nonatomic, strong) UIImageView *fullScreenImageView;
@property (nonatomic, strong) UIImageView *originalImageView;
@property (nonatomic, strong) UIVisualEffectView *effectView;
@property (nonatomic, strong) DRAPIUtility *instagramApi;

@end
//TODO: Make it accessible

@implementation DRCollectionViewController

static NSString * const reuseIdentifier = @"Cell";

#pragma mark Custom Initializer

-(instancetype) init{
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    self = [super initWithCollectionViewLayout:layout];
    return self;
}

#pragma mark View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.collectionView setAccessibilityIdentifier:@"Image List"];
    [self.collectionView setAccessibilityLabel:@"Image List"];
    [self setAccessibilityLabel:@"Image List Controller"];
    
    
    [self.collectionView registerClass:[DRPictureCell class] forCellWithReuseIdentifier:reuseIdentifier];
    self.navigationController.hidesBarsOnSwipe = YES;
    
    self.title = @"Jet.com Challenge";
    
    [self setupLongGesture];
    [self.collectionView setShowsVerticalScrollIndicator:NO];
    
    NSIndexPath *newIndexPath = [NSIndexPath indexPathForItem:3 inSection:0];
    [self.collectionView scrollToItemAtIndexPath:newIndexPath atScrollPosition:UICollectionViewScrollPositionTop animated:NO];
    
    self.collectionView.backgroundColor = [UIColor whiteColor];
    
    self.instagramApi = [[DRAPIUtility alloc] init];
    self.images = [[NSMutableDictionary alloc] init];
    self.imagesArray = [[NSMutableArray alloc] initWithCapacity:39];
    for (NSUInteger i=0; i<39; i++) {
        [self.imagesArray addObject:[UIImage imageNamed:@"jdc"]];
    }
    [self setupDataForCollectionView];
    
}

-(void)setupDataForCollectionView {
    
    [self.instagramApi getImagesPage: 0 imageBlock:^(UIImage *image, NSIndexPath *indexPath) {
        
        [self.images setObject:image forKey:indexPath];
        [self.imagesArray replaceObjectAtIndex:indexPath.row+3 withObject:image];
        //if statements setting up for infinite cycle
        if (indexPath.row>=30) {
            [self.imagesArray replaceObjectAtIndex:indexPath.row-30 withObject:image];
        }
        if (indexPath.row<=2) {
            [self.imagesArray replaceObjectAtIndex:indexPath.row+36 withObject:image];
        }
        
        [self.collectionView reloadItemsAtIndexPaths:@[indexPath]];
        
    } completionBlock:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Gestures & Actions

- (void)fullScreenImageViewTapped:(UIGestureRecognizer *)gestureRecognizer {
    
    CGRect point=[self.view convertRect:self.originalImageView.bounds fromView:self.originalImageView];
    [UIView animateWithDuration:0.5
                     animations:^{
                         [(UIImageView *)gestureRecognizer.view setFrame:point];
                         [self.effectView setAlpha:0.0f];
                     }];
    [self performSelector:@selector(fullScreenAnimationDone:) withObject:[gestureRecognizer view] afterDelay:0.4];
}

-(void)fullScreenAnimationDone:(UIView  *)view
{
    [self.fullScreenImageView removeFromSuperview];
    [self.effectView removeFromSuperview];
    self.effectView = nil;
    self.fullScreenImageView = nil;
}

-(void)handleLongPress:(UIGestureRecognizer *) gesture {
    CGPoint touchPoint = [gesture locationInView:self.collectionView];
    NSIndexPath *selectedIndexPath = [self.collectionView indexPathForItemAtPoint: touchPoint];
    
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:
            if (selectedIndexPath) {
                [self.collectionView beginInteractiveMovementForItemAtIndexPath:selectedIndexPath];
            }
            break;
        case UIGestureRecognizerStateChanged:
            [self.collectionView updateInteractiveMovementTargetPosition:[gesture locationInView:gesture.view]];
        case UIGestureRecognizerStateEnded:
            [self.collectionView endInteractiveMovement];
        default:
            [self.collectionView cancelInteractiveMovement];
            break;
    }
}
-(void)setupLongGesture{
    
    UILongPressGestureRecognizer *longPressGesture =[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    
    [self.collectionView addGestureRecognizer:longPressGesture];
    
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return 39;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    DRPictureCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    [self configureCell:cell forIndexPath:indexPath];
    
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView moveItemAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath{
    
    //swap images in array in order to maintain order on dequeue
    UIImage *movedImage = self.imagesArray[sourceIndexPath.row];
    [self.imagesArray replaceObjectAtIndex:sourceIndexPath.row withObject:self.imagesArray[destinationIndexPath.row]];
    [self.imagesArray replaceObjectAtIndex:destinationIndexPath.row withObject:movedImage];
    
}

#pragma mark <UICollectionViewDelegate>

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    DRPictureCell *cell = (DRPictureCell *)[collectionView cellForItemAtIndexPath:indexPath];
    
    [cell setSelected:YES];
    
    [self setupViewsForSelectedCell:cell];
    [self setupEffectViewForSelectedCell];
    [self setupTapGestureForSelectedCell];
    
    CGRect tempPoint = CGRectMake(self.originalImageView.center.x, self.originalImageView.center.y, 0, 0);
    CGRect startingPoint = [self.view convertRect:tempPoint fromView:[collectionView cellForItemAtIndexPath:indexPath]];
    [self.fullScreenImageView setFrame:startingPoint];
    
    [UIView animateWithDuration:0.4
                     animations:^{
                         [self.fullScreenImageView
                          setFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
                         [self.effectView setAlpha:1.0f];
                     }];
}

-(void)setupViewsForSelectedCell:(DRPictureCell *) cell {
    self.originalImageView = cell.imageView;
    self.fullScreenImageView = [[UIImageView alloc] init];
    [self.fullScreenImageView setContentMode:UIViewContentModeScaleAspectFit];
    self.fullScreenImageView.image = [self.originalImageView image];
}

-(void)setupEffectViewForSelectedCell{
    
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    self.effectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    [self.effectView setAlpha:0.0f];
    [self.effectView setFrame:self.view.frame];
    
    [self.view addSubview:self.effectView];
    [self.view addSubview:self.fullScreenImageView];
}

-(void)setupTapGestureForSelectedCell{
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(fullScreenImageViewTapped:)];
    singleTap.numberOfTapsRequired = 1;
    singleTap.numberOfTouchesRequired = 1;
    [self.fullScreenImageView addGestureRecognizer:singleTap];
    [self.fullScreenImageView setUserInteractionEnabled:YES];
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    
    return 30.0;
}

-(CGSize)collectionView:(UICollectionView*)collectionView layout:(nonnull UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(nonnull NSIndexPath *)indexPath{
    
    CGFloat frameWidth = self.collectionView.frame.size.width;
    
    if (indexPath.row % 3 == 0) {
        CGFloat width = frameWidth - 50.0;
        return CGSizeMake(width, width);
    }
    
    return CGSizeMake((frameWidth/3)-25,(frameWidth/3)-25);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    
    return UIEdgeInsetsMake(0, 25, 0, 25);
}

#pragma mark - ScrollView Delegate

-(void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset{
    
    CGFloat contentOffsetWhenFullyScrolledBottom =self.collectionView.contentSize.height-self.collectionView.frame.size.height-64;
    
    if (velocity.y<0 && targetContentOffset->y < 0) {
        NSIndexPath *newIndexPath = [NSIndexPath indexPathForItem:34 inSection:0];
        [self.collectionView scrollToItemAtIndexPath:newIndexPath atScrollPosition:UICollectionViewScrollPositionTop animated:NO];
    }
    if (velocity.y>0 && targetContentOffset->y > contentOffsetWhenFullyScrolledBottom) {
        NSIndexPath *newIndexPath = [NSIndexPath indexPathForItem:2 inSection:0];
        [self.collectionView scrollToItemAtIndexPath:newIndexPath atScrollPosition:UICollectionViewScrollPositionTop animated:NO];
    }
}

#pragma mark - Additional Helpers

- (void)configureCell:(DRPictureCell *)cell forIndexPath:(NSIndexPath *)indexPath
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        
        if (self.imagesArray[indexPath.row])
        {
            cell.imageView.image = self.imagesArray[indexPath.row];
        }
    }];
}

@end
