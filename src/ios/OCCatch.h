//
//  OCCatch.h
//  wifi-rssi
//
//  Created by Zhihui Tang on 2018-01-05.
//  Copyright © 2018 Zhihui Tang. All rights reserved.
//

#ifndef ObjecException_h
#define ObjecException_h

#import <Foundation/Foundation.h>

NS_INLINE NSException * _Nullable tryBlock(void(^_Nonnull tryBlock)(void)) {
    @try {
        tryBlock();
    }
    @catch (NSException *exception) {
        return exception;
    }
    return nil;
}

#endif /* OCCatch_h */
