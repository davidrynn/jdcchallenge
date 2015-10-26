//
//  DRAPIUtility.m
//  JetChallengeNSB
//
//  Created by David Rynn on 10/22/15.
//  Copyright © 2015 David Rynn. All rights reserved.
//

#import "DRAPIUtility.h"
#import <AFNetworking.h>
#import <AFOAuth2Manager.h>

#import "DRKeys.h"

@implementation DRAPIUtility


- (void)getImagesCount:(NSNumber*)count
            imageBlock:(void (^)(UIImage *, NSIndexPath *))imageBlock
       completionBlock:(void (^)())completion
{
    
    for (NSInteger i = 0; i < [count integerValue]; i++) {

    NSOperationQueue* queue = [[NSOperationQueue alloc] init];
    queue.maxConcurrentOperationCount = 10;
    __block NSInteger returnedCount=0;
    
    
    NSOperationQueue* imageQueue = [[NSOperationQueue alloc] init];
    imageQueue.maxConcurrentOperationCount = 10;
    
    NSURL *instagramImagesURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.instagram.com/v1/tags/jetdotcom/media/recent?client_id=%@", CLIENT_ID]];
    

    
        NSURLRequest* request = [NSURLRequest requestWithURL:instagramImagesURL];
        AFHTTPRequestOperation* operation =
        [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
        
        operation.responseSerializer = [AFJSONResponseSerializer serializer];
        
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation* operation,
                                            id responseObject) {
            
            NSDictionary* responseDictionary = (NSDictionary*)responseObject;
            
            [imageQueue addOperationWithBlock:^{
                
                NSIndexPath* indexpath =
                [NSIndexPath indexPathForRow:i inSection:0];
                NSLog(@"%@",responseDictionary[@"image"]);
                NSData* imageData =
                [NSData dataWithContentsOfURL:
                 [NSURL URLWithString:responseDictionary[@"image"]]];
                UIImage* imageImage = [UIImage imageWithData:imageData];
                if (!imageImage) {
                    imageImage = [UIImage imageNamed:@"spacedog_A_3 "];
                }
                NSOperation *imageOp = [NSBlockOperation blockOperationWithBlock:^{
                    imageBlock(imageImage, indexpath);
                }];
                NSOperation *checkCompleteOp = [NSBlockOperation blockOperationWithBlock:^{
                    returnedCount++;
                    if (returnedCount==10) {
                        if (completion) {
                            completion();
                        }
                    }
                }];
                [checkCompleteOp addDependency:imageOp];
                [[NSOperationQueue mainQueue] addOperation:imageOp];
                [[NSOperationQueue mainQueue] addOperation:checkCompleteOp];
            }];
            
        }
                                  failure:nil];
        
        [queue addOperation:operation];
    }
}
@end
