//
//  AutoScrollLabel_Macros.h
//
//  Created by Christopher Bess on 1/2/12.
//  Copyright (c) 2012 Qu. All rights reserved.
//

#ifndef AutoScrollLabel_Macros_h
#define AutoScrollLabel_Macros_h

#define HAS_ARC __has_feature(objc_arc)

#if HAS_ARC
#define NSRelease(OBJ) ;
#define NO_ARC(BLOCK_NO_ARC) ;
#define asl_retain strong
#else
#define NSRelease(OBJ) [OBJ release];
#define NO_ARC(BLOCK_NO_ARC) BLOCK_NO_ARC
#define asl_retain retain
#endif

#endif