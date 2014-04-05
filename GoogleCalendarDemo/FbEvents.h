//
//  FbEvents.h
//  USCEvents
//
//  Created by Shreenidhi Bhat on 4/4/14.
//  Copyright (c) 2014 Andrew Davis. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FbEvents : NSObject
@property (nonatomic, retain) NSString * date;
@property (nonatomic, retain) NSString * desc;
@property (nonatomic, retain) NSDate * endDate;
@property (nonatomic, retain) NSString * googleid;
@property (nonatomic, retain) NSString * location;
@property (nonatomic, retain) NSString * summary;
@property (nonatomic,retain) NSString * fbid;
@end
