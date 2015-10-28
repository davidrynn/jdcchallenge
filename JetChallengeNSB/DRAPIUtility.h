//
//  DRAPIUtility.h
//  JetChallengeNSB
//
//  Created by David Rynn on 10/22/15.
//  Copyright © 2015 David Rynn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface DRAPIUtility : NSObject

- (void)getImagesPage: (NSUInteger) pageNumber
           imageBlock:(void (^)(UIImage *, NSIndexPath *))imageBlock
      completionBlock:(void (^)())completion;
@end
