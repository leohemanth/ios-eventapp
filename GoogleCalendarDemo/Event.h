//
//  Event.h
//  USCEvents
//
//  Created by Hemanth on 05/04/14.
//  Copyright (c) 2014 Andrew Davis. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Event : NSManagedObject

@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSString * desc;
@property (nonatomic, retain) NSDate * endDate;
@property (nonatomic, retain) NSString * googleid;
@property (nonatomic, retain) NSString * location;
@property (nonatomic, retain) NSString * summary;
<<<<<<< HEAD
@property (nonatomic, retain) NSString * fblink;

=======
@property (nonatomic,retain) NSString * fbid;
>>>>>>> c39cb7c1e3d6fe4093fa84c42be3f04932a7ad04
@end
