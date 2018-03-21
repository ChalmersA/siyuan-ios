//
//  XPGPeerID.h
//  XPGConnect
//
//  This file is subject to the terms and conditions defined in
//  file 'LICENSE.txt', which is part of this source code package.
//
//  This XPG software is supplied to you by Xtreme Programming Group,
//  Inc. ("XPG") in consideration of your agreement to the following
//  terms, and your use, installation, modification or redistribution of
//  this XPG software constitutes acceptance of these terms.  If you do
//  not agree with these terms, please do not use, install, modify or
//  redistribute this XPG software.

//  In consideration of your agreement to abide by the following terms, and
//  subject to these terms, XPG grants you a non-exclusive license,
//  under XPG's copyrights in this original XPG software (the "XPG Software"),
//  to use and redistribute the XPG Software, in source and/or binary forms;
//  provided that if you redistribute the XPG Software, with or without
//  modifications, you must retain this notice and the following
//  text and disclaimers in all such redistributions of the XPG Software.
//  Neither the name, trademarks, service marks or logos of XPG Inc. may
//  be used to endorse or promote products derived from the XPG Software
//  without specific prior written permission from XPG.  Except as
//  expressly stated in this notice, no other rights or licenses, express or
//  implied, are granted by XPG herein, including but not limited to any
//  patent rights that may be infringed by your derivative works or by other
//  works in which the XPG Software may be incorporated.
//
//  The XPG Software is provided by XPG on an "AS IS" basis.  XPG
//  MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
//  THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
//  FOR A PARTICULAR PURPOSE, REGARDING THE XPG SOFTWARE OR ITS USE AND
//  OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
//
//  IN NO EVENT SHALL XPG BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
//  OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
//  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
//  INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
//  MODIFICATION AND/OR DISTRIBUTION OF THE XPG SOFTWARE, HOWEVER CAUSED
//  AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
//  STRICT LIABILITY OR OTHERWISE, EVEN IF XPG HAS BEEN ADVISED OF THE
//  POSSIBILITY OF SUCH DAMAGE.
//
//  ABOUT XPG:
//  Established since June 2005, Xtreme Programming Group, Inc. (XPG)
//  is a digital solutions company based in the United States and China.
//  XPG integrates cutting-edge hardware designs, mobile applications,
//  and cloud computing technologies to bring innovative products to the
//  marketplace. XPG's partners and customers include global leading
//  corporations in semiconductor, home appliances, health/wellness electronics,
//  toys and games, and automotive industries.
//  Visit www.xtremeprog.com for more information.
//
//  Copyright (C) 2013 Xtreme Programming Group, Inc. All Rights Reserved.
//


#import <Foundation/Foundation.h>

/**
 This class represents a peer in a session.
 
 XPGConnect framework is responsible for creating peer
 objects that represent other devices, while your app
 is responsible for creating a single peer object that
 represents itself.
 
 You can call initWithName: to create a peer ID, which
 the peer's name must be no longer than 63 bytes in
 UTF-8 encoding.
 */
@interface XPGPeerID : NSObject

/**
 The name of this peer, usually used for display.
 */
@property (nonatomic, copy) NSString *name;

/**
 Initializes a peer.
 
 @param name The name of this peer.
 @return Returns an initialized peer object.
 */
- (id)initWithName:(NSString *)name;

/**
 Get a peer uuid with NSString.
 @return Returns an NSString of peer object.
 */
- (NSString *)uuidString;

@end
