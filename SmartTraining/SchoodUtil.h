//
//  SchoodUtil.h
//  BTLE Transfer
//
//  Created by Honorato Rocha on 30/11/18.
//  Copyright © 2018 Apple. All rights reserved.
//

#ifndef LE_Transfer_SchoodUtil_h
#define LE_Transfer_SchoodUtil_h
#import <Foundation/Foundation.h>

@interface SchoodUtil: NSObject
+ (NSString *)extractSchoolId:(NSData *)input;
+ (NSString *)extractAlias:(NSData *)input;
+ (NSString *)extractCommandSeq:(NSData *)input;
+ (NSInteger)extractAdvType:(NSData *)input;
+ (NSInteger)extractAdvMode:(NSData *)input;
+ (NSInteger)extractAnswer:(NSData *)input;
+ (NSInteger)extractReserved:(NSData *)input;
@end

#endif
