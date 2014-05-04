//
//  IFAUtils.m
//  Gusty
//
//  Created by Marcelo Schroeder on 14/08/09.
//  Copyright 2009 InfoAccent Pty Limited. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import <sys/utsname.h>
#import "IFACommon.h"

@implementation IFAUtils {
    
}

#pragma mark - Private

+(NSString*)ifa_pListPathForName:(NSString *)a_name bundle:(NSBundle*)a_bundle{
    NSBundle *l_bundle = a_bundle ? a_bundle : [NSBundle mainBundle];
    return [l_bundle pathForResource:a_name ofType:@"plist"];
}

#pragma mark - Public

+ (NSArray*) getPlistAsArray:(NSString *)pListName{
	return [self getPlistAsArray:pListName bundle:nil];
}

+ (NSArray*) getPlistAsArray:(NSString *)pListName bundle:(NSBundle*)a_bundle{
	NSString *plistPath = [self ifa_pListPathForName:pListName bundle:a_bundle];
	return [[NSArray alloc] initWithContentsOfFile:plistPath];
}

+ (NSDictionary*) getPlistAsDictionary:(NSString *)pListName{
    return [self getPlistAsDictionary:pListName bundle:nil];
}

+ (NSDictionary*) getPlistAsDictionary:(NSString *)pListName bundle:(NSBundle*)a_bundle{
	NSString *plistPath = [self ifa_pListPathForName:pListName bundle:a_bundle];
	return [[NSDictionary alloc] initWithContentsOfFile:plistPath];
}

+ (NSString *) getSetterNameFromPropertyName:(NSString *)propertyName{
	return [[@"set" stringByAppendingString:[propertyName capitalizedString]] stringByAppendingString:@":"];
}

+ (void) handleUnrecoverableError:(NSError *)anErrorContainer{
	//TODO: are we losing important info here?
	NSLog(@"Unrecoverable error - description: %@", [anErrorContainer localizedDescription]);
	NSLog(@"Unrecoverable error - failure reason: %@", [anErrorContainer localizedFailureReason]);
    NSArray* detailedErrors = [[anErrorContainer userInfo] objectForKey:NSDetailedErrorsKey];
    if(detailedErrors != nil && [detailedErrors count] > 0) {
		for(NSError* detailedError in detailedErrors) {
			NSLog(@"Unrecoverable error - user info from detailed errors: %@", [detailedError userInfo]);
		}
    }else{
		NSLog(@"Unrecoverable error - user info: %@", [anErrorContainer userInfo]);
    }
    NSAssert(NO, @"Unrecoverable Error: %@", [anErrorContainer localizedDescription]);
}

+ (NSError*) newErrorWithCode:(NSInteger)anErrorCode errorMessage:(NSString*)anErrorMessage{
	NSArray *keyArray = @[NSLocalizedDescriptionKey];
	NSArray *objArray = @[anErrorMessage];
	NSDictionary *userInfo = [NSDictionary dictionaryWithObjects:objArray forKeys:keyArray];
	return [[NSError alloc] initWithDomain:IFAErrorDomainCommon code:anErrorCode userInfo:userInfo];
}

+ (NSError*) newErrorContainer{
	NSArray *errors = [NSMutableArray array];
	NSArray *keyArray = @[NSDetailedErrorsKey];
	NSArray *objArray = @[errors];
	NSDictionary *userInfo = [NSDictionary dictionaryWithObjects:objArray forKeys:keyArray];
	return [[NSError alloc] initWithDomain:NSCocoaErrorDomain code:NSValidationMultipleErrorsError userInfo:userInfo];
}

+ (NSError*) newErrorContainerWithError:(NSError*)anError{
	NSError *errorContainer = [self newErrorContainer];
	[self addError:anError toContainer:errorContainer];
	return errorContainer;
}

+ (void) addError:(NSError*)anError toContainer:(NSError*)anErrorContainer{
	AssertNotNil(anError);
	AssertNotNil(anErrorContainer);
	AssertTrue([anErrorContainer code]==NSValidationMultipleErrorsError);
	id obj = [[anErrorContainer userInfo] valueForKey:NSDetailedErrorsKey];
	AssertNotNil(obj);
	AssertNotNilAndClass(obj, NSMutableArray);
	NSMutableArray *errors = obj;
	[errors addObject:anError];
}

+ (void) logBooleanWithLabel:(NSString*)a_label value:(BOOL)a_value{
	NSMutableString *l_label = [NSMutableString stringWithString:a_label];
	[l_label appendString:@": %@"];
	NSLog(l_label, a_value?@"YES":@"NO");
}

+(void)appLogWithTitle:(NSString*)a_title 
               message:(NSString*)a_message 
              location:(CLLocation*)a_location 
                 error:(NSError*)a_error 
             showAlert:(BOOL)a_showAlert{
//    NSLog(@"%@ - %@", a_title, a_message);
    IFAApplicationLog *dbLogEntry = (IFAApplicationLog *) [[IFAPersistenceManager sharedInstance] instantiate:@"IFAApplicationLog"];
    dbLogEntry.date = [NSDate date];
    dbLogEntry.title = a_title;
    dbLogEntry.message = a_message;
    if (a_location) {
        dbLogEntry.isLocationAware = @(YES);
        dbLogEntry.latitude = @(a_location.coordinate.latitude);
        dbLogEntry.longitude = @(a_location.coordinate.longitude);
        dbLogEntry.horizontalAccuracy = @(a_location.horizontalAccuracy);
    }else{
        dbLogEntry.isLocationAware = @(NO);
    }
    if (a_error) {
        dbLogEntry.isError = @(YES);
        dbLogEntry.errorCode = @([a_error code]);
        dbLogEntry.errorDescription = [a_error localizedDescription];
    }else{
        dbLogEntry.isError = @(NO);
    }
    [[IFAPersistenceManager sharedInstance] save];
    if (a_showAlert) {
        if ([UIApplication sharedApplication].applicationState==UIApplicationStateActive) {
            [IFAUIUtils showAlertWithMessage:a_message title:a_title];
        }else if ([UIApplication sharedApplication].applicationState==UIApplicationStateBackground) {
            UILocalNotification *l_localNotification = [[UILocalNotification alloc] init];
            if (l_localNotification) {
                l_localNotification.alertBody = [NSString stringWithFormat:@"%@: %@", a_title, a_message];
                [[UIApplication sharedApplication] presentLocalNotificationNow:l_localNotification];
            }
        }
    }
}

+(void)appLogWithTitle:(NSString*)a_title message:(NSString*)a_message;{
    [self appLogWithTitle:a_title message:a_message location:nil error:nil showAlert:NO];
}

+(void)dispatchAsyncMainThreadBlock:(dispatch_block_t)a_block{
    dispatch_async(dispatch_get_main_queue(), a_block);
}

+(void)dispatchAsyncMainThreadBlock:(dispatch_block_t)a_block afterDelay:(NSTimeInterval)a_delay{
    dispatch_after([self dispatchTimeForDelay:a_delay], dispatch_get_main_queue(), a_block);
}

+(void)dispatchSyncMainThreadBlock:(dispatch_block_t)a_block{
    dispatch_sync(dispatch_get_main_queue(), a_block);
}

+(void)dispatchAsyncGlobalDefaultPriorityQueueBlock:(dispatch_block_t)a_block{
    [self dispatchAsyncGlobalQueueBlock:a_block priority:DISPATCH_QUEUE_PRIORITY_DEFAULT];
}

+(void)dispatchAsyncGlobalQueueBlock:(dispatch_block_t)a_block priority:(dispatch_queue_priority_t)a_priority{
    dispatch_async(dispatch_get_global_queue(a_priority, 0), a_block);
}

+ (dispatch_time_t)dispatchTimeForDelay:(NSTimeInterval)a_delay {
    int64_t l_delta = (int64_t)(1.0e9 * a_delay);
    dispatch_time_t l_dispatchTimeDelay = dispatch_time(DISPATCH_TIME_NOW, l_delta);
    return l_dispatchTimeDelay;
}

+(NSDictionary*)infoPList{
    return [self infoPListForBundle:nil];
}

+(NSDictionary*)infoPListForBundle:(NSBundle*)a_bundle{
    return [self getPlistAsDictionary:@"Info" bundle:a_bundle];
}

+(NSString*)appName{
    return [[self infoPList] objectForKey:@"CFBundleDisplayName"];
}

+(NSString*)appEdition{
    return [[self infoPList] objectForKey:@"IFAAppEdition"];
}

+(NSString*)appVersion{
    return [[self infoPList] objectForKey:@"CFBundleShortVersionString"];
}

+(NSString*)appBuildNumber{
    return [[self infoPList] objectForKey:@"CFBundleVersion"];
}

+(NSString*)appNameAndEdition{
    NSString *l_appName = [self appName];
    NSString *l_edition = [IFAUtils appEdition];
    if (l_edition) {
        return [NSString stringWithFormat:@"%@ %@", l_appName, l_edition];
    }else{
        return l_appName;
    }
}

+(NSString*)appVersionAndBuildNumber{
    return [NSString stringWithFormat:@"%@ (build %@)", [self appVersion], [IFAUtils appBuildNumber]];
}

+(NSString*)appFullName{
    return [NSString stringWithFormat:@"%@ %@", [self appNameAndEdition], [IFAUtils appVersionAndBuildNumber]];
}

+(NSString*)generateUuid{
    CFUUIDRef l_uuidRef = CFUUIDCreate(NULL);
    CFStringRef l_uuidStringRef = CFUUIDCreateString(NULL, l_uuidRef);
    NSString *l_uuid = (__bridge_transfer NSString*)l_uuidStringRef;
    CFRelease(l_uuidRef);
    return l_uuid;
}

+(void)forceCrash {
    NSLog(@"About to force a crash...");
    NSAssert(NO, @"Forced crash!");
}

+(NSString*)stringFromResource:(NSString *)a_resourceName type:(NSString*)a_resourceType{
    NSString *l_filePath = [[NSBundle mainBundle] pathForResource:a_resourceName ofType:a_resourceType];
    NSString *l_string = nil;
    if (l_filePath) {  
        l_string = [NSString stringWithContentsOfFile:l_filePath encoding:NSASCIIStringEncoding error:NULL];
    }
//    NSLog(@"m_stringFromResource: %@", l_string);
    return l_string;
}

+(NSArray*)toArrayIfRequiredFromObject:(id)a_object{
    if ([a_object isKindOfClass:[NSArray class]] || a_object==nil) {
        return a_object;
    }else {
        return @[a_object];
    }
}

+(Class)classForPropertyNamed:(NSString *)a_propertyName inClass:(Class)a_class{
    if (!a_propertyName || !a_class) {
        return NULL;
    }
    Class l_class = NULL;
    objc_property_t l_property = class_getProperty(a_class, [a_propertyName UTF8String]);
    if (l_property) {
        NSString *l_propertyAttributes = @(property_getAttributes(l_property));
        static NSString * const k_propertyClassNameStartDelimiter = @"T@\"";
        static NSString * const k_propertyClassNameEndDelimiter = @"\",";
        NSRange l_startRange = [l_propertyAttributes rangeOfString:k_propertyClassNameStartDelimiter];
        NSRange l_endRange = [l_propertyAttributes rangeOfString:k_propertyClassNameEndDelimiter];
        NSRange l_classNameRange = NSMakeRange(l_startRange.length, l_endRange.location-l_startRange.length);
        NSString *l_className = [l_propertyAttributes substringWithRange:l_classNameRange];
        l_class = NSClassFromString(l_className);
    }
    return l_class;
}

+(Class)classForPropertyNamed:(NSString *)a_propertyName inClassNamed:(NSString*)a_className{
    return [self classForPropertyNamed:a_propertyName inClass:NSClassFromString(a_className)];
}

+(BOOL)deviceSupportsVibration{
//    NSLog(@"[UIDevice currentDevice].model: %@", [UIDevice currentDevice].model);
    return [[UIDevice currentDevice].model isEqualToString:@"iPhone"];
}

+(BOOL)nilOrEmptyForString:(NSString*)a_string{
    return a_string==nil || [[a_string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length]==0;
}

+(BOOL)isProductionAps {

	NSString * provisioning = [[NSBundle mainBundle] pathForResource:@"embedded.mobileprovision" ofType:nil];
	if(!provisioning)
		return YES;	//AppStore
    
	NSString * contents = [NSString stringWithContentsOfFile:provisioning encoding:NSASCIIStringEncoding error:nil];
	if(!contents)
		return YES;
    
	NSRange start = [contents rangeOfString:@"<?xml"];
	NSRange end = [contents rangeOfString:@"</plist>"];
	start.length = end.location + end.length - start.location;
    
	NSString * profile =[contents substringWithRange:start];
	if(!profile)
		return YES;
    
	NSData * profileData = [profile dataUsingEncoding:NSUTF8StringEncoding];
	NSString *error = nil;;
	NSPropertyListFormat format;
	NSDictionary* plist = [NSPropertyListSerialization propertyListFromData:profileData mutabilityOption:NSPropertyListImmutable format:&format errorDescription:&error];
    
	NSDictionary * entitlements = [plist objectForKey:@"Entitlements"];
    //	NSNumber * allowNumber = [entitlements objectForKey:@"get-task-allow"];
    
	//could be development or production
	NSString * apsGateway = [entitlements objectForKey:@"aps-environment"];
    
	if(!apsGateway) {
        NSAssert(NO, @"Provisioning profile does not have APS entry");
	}
    
	if([apsGateway isEqualToString:@"development"])
		return NO;
    
	return YES;

}

+ (BOOL)isIOS7OrGreater {
    return !(floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1);
}

+ (NSString *)hardwareType {
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *l_hardwareType = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    return l_hardwareType;
}

+ (NSString *)encodeForUrlByAddingPercentEscapesWithOriginalString:(NSString *)a_originalString {
    NSString *l_encodedString = CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
            (__bridge CFStringRef)(a_originalString), NULL, CFSTR(""), kCFStringEncodingUTF8));
    return l_encodedString;
}

+ (NSString *)encodeForUrlByAddingPercentEscapesIncludingReservedCharactersWithOriginalString:(NSString *)a_originalString {
    NSString *l_encodedString = CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
            (__bridge CFStringRef)(a_originalString), NULL, CFSTR(":/?#[]@!$&'()*+,;="), kCFStringEncodingUTF8));
    return l_encodedString;
}


@end
