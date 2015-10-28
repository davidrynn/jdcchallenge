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

- (void)getImagesPage: (NSUInteger) pageNumber
                   imageBlock:(void (^)(UIImage *, NSIndexPath *))imageBlock
              completionBlock:(void (^)())completion
{
    __block UIImage *placeholderImage = [UIImage imageNamed:@"jdc"];
    __block NSInteger returnedCount=0;
    
    for (NSInteger i = 0; i < 33; i++) {
        
        NSOperationQueue* queue = [[NSOperationQueue alloc] init];
        queue.maxConcurrentOperationCount = 10;
        
        NSOperationQueue* imageQueue = [[NSOperationQueue alloc] init];
        imageQueue.maxConcurrentOperationCount = 10;
        
        NSURL *instagramImagesURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.instagram.com/v1/tags/jetdotcom/media/recent?client_id=%@&count=33", CLIENT_ID]];
        
        NSURLRequest* request = [NSURLRequest requestWithURL:instagramImagesURL];
        AFHTTPRequestOperation* operation =
        [[AFHTTPRequestOperation alloc] initWithRequest:request];
        
        operation.responseSerializer = [AFJSONResponseSerializer serializer];
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation* operation,
                                                   id responseObject) {
            
            NSDictionary* responseDictionary = (NSDictionary*)responseObject;
            
            
            [imageQueue addOperationWithBlock:^{
                
                NSIndexPath* indexpath = [NSIndexPath indexPathForRow:i inSection:0];
                NSArray *dataArray =responseDictionary[@"data"];
                NSData* imageData = [NSData dataWithContentsOfURL:
                                     [NSURL URLWithString:dataArray[i][@"images"][@"low_resolution"][@"url"]]];
                
                UIImage* instagramImage = [UIImage imageWithData:imageData];
                if (!instagramImage) {
                    instagramImage = placeholderImage;
                }
                NSOperation *imageOperation = [NSBlockOperation blockOperationWithBlock:^{
                    imageBlock(instagramImage, indexpath);
                }];
                NSOperation *checkCompleteOperation = [NSBlockOperation blockOperationWithBlock:^{
                    returnedCount++;
                    if (returnedCount==33) {
                        if (completion) {
                            completion();
                        }
                    }
                }];
                [checkCompleteOperation addDependency:imageOperation];
                [[NSOperationQueue mainQueue] addOperation:imageOperation];
                [[NSOperationQueue mainQueue] addOperation:checkCompleteOperation];
            }];
            
        }
                                         failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
                                             NSLog(@"APIUtility failure: %@", error.localizedDescription);
                                         }];
        
        [queue addOperation:operation];
    };
}
@end
