//
//  XPGServiceBrowser.h
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
#import <CoreBluetooth/CoreBluetooth.h>

@class XPGPeerID;
@class XPGConnectSession;

@protocol XPGServiceBrowserDelegate;

/**
 Type defined to identify the transportation machanism
 between devices.
 */
typedef NS_ENUM(NSInteger, XPGConnectTransportType) {
    /**
     A combination of various transportation layer,
     which is not yet supported.
     */
    kXPGConnectTransportTypeAll = 0,
    /**
     Bluetooth Low Energe transport layer.
     */
	kXPGConnectTransportTypeBLE = 1,
    /**
     UDP transport layer.
     */
    kXPGConnectTransportTypeUDP = 2,
    /**
     TCP transport layer.
     */
    kXPGConnectTransportTypeTCP = 3
};

/**
 This class provides functions to help the app developer
 to easily search targeted services, and facilitates the
 ability to easily invite those service providers to
 join a session.
 
 We can search services by two conditions, one is
 serviceType and the other is transportType. serviceType
 is usually a string that is being advertised by the
 service provider, such as "socket", "scale", etc. While
 transportType is a constant to identify the transportation
 mechanism, which refers to Bluetooth Low Energe or UDP
 or TCP, etc.
 
 App developer would specify either or both of the search
 conditions, for example, they can query service providers
 as "socket"@"tcp", or "scale"@"ble". For now, the
 transportType condition is a must, but we can envision
 that in the future, app developer can search the field
 without prior knowing what the device transportation
 layer would be.
 */
@interface XPGServiceBrowser : NSObject

/**
 The peer ID that is used to uniquely identify this
 instance. This value is set when you initialize the
 object, and cannot be changed later on.
 */
@property (nonatomic, readonly) XPGPeerID *peerID;

/**
 Service type string to represent what kind of service(s)
 the app is looking for. Some possible values could be
 "socket", "scale", "blood pressure", etc.
 
 This value is set when you initialize the
 object, and cannot be changed later on.
 */
@property (nonatomic, readonly) NSString *serviceType;

/**
 Transportation mechanism used among various devices.
 The possible values are defined in kXPGConnectTransportType.
 
 This value is set when you initialize the
 object, and cannot be changed later on.
 */
@property (nonatomic, readonly) XPGConnectTransportType transportType;

/**
 The delegate object that handles various event callbacks.
 */
@property (assign, nonatomic) id<XPGServiceBrowserDelegate> delegate;

/**
 A list of <code>NSString</code> objects representing the service(s) to scan for.
 */
@property (nonatomic, copy) NSArray *serviceTargets;

/**
 Initialize a service browser object.
 
 @param peerID The unique ID that is used to identify this browser.
 @param serviceType This is a string that is less than 15 characters
        to specify the name of the interested service. You can pass
        a nil value if you don't want to specify this.
 @param transportType Transport layer used for this service browser.
 @return Returns an initialized service browser object, or nil
        if any error occurred.
 */
- (id)initWithPeer:(XPGPeerID *)peerID serviceType:(NSString *)serviceType transportType:(XPGConnectTransportType)transportType;

/**
 return the delegate instance
 */
- (id<CBCentralManagerDelegate>)getCentralManagerDelegate;

/**
 set CBCentralManager from XAnalytics
 */
- (void)setCentralManager:(CBCentralManager*)centralManager;

/**
 Start the browsing activity.
 
 When the browsing failed to start, delegate's browser:didNotStartBrowsing:
 will be called.
 
 When there is any peer that being found, delegate's
 browser:foundPeer:withServiceInfo will be called.
 
 You can call stopBrowsing to stop the browsing activity, otherwise
 the framework will keep calling delegate's methods accordingly.
 */
- (void)startBrowsing;

/**
 Stop the browsing activity. After this method call,
 no more delegate's methods will be called.
 */
- (void)stopBrowsing;

/**
 Invites a discovered peer to join a session.
 
 @param peerID Peer ID that identifies the party device being invited.
 @param session XPGConnectSession that the invited party will be join.
 @param context An arbitrary piece of data that is being sent to the
        invited party. This data can be used to provide further
        information to the invited party for making decision of
        whether it should join or not.
 @param timeout The amount of time to wait for the invited peer to
        respond to the invitation. This timeout is measured in seconds.
        If any non-positive value is provided, the default value
        30 seconds is used.
 */
- (void)invitePeer:(XPGPeerID *)peerID toSession:(XPGConnectSession *)session withContext:(NSData *)context timeout:(NSTimeInterval)timeout;

@end

/**
 This protocol defines methods that handle the callbacks from
 XPGServiceBrowser.
 */
@protocol XPGServiceBrowserDelegate <NSObject>

@optional

/**
 Called when a browser failed to start the browsing activity.
 
 @param browser The browser object that failed to start browsing.
 @param error An error indicating what went wrong.
 */
- (void)browser:(XPGServiceBrowser *)browser didNotStartBrowsing:(NSError *)error;


- (void)browserDidStartBrowsing:(XPGServiceBrowser *)browser;

@required

/**
 Called when a peer is found.
 
 @param browser The browser object that found the peer.
 @param peerID The unique ID that identifies the peer being found.
 @param serviceInfo The information advertised by the discovered
        peer. @TODO: Specify the content here more.
 */
- (void)browser:(XPGServiceBrowser *)browser foundPeer:(XPGPeerID *)peerID withServiceInfo:(NSDictionary *)serviceInfo;

/**
 Called when a peer is lost. This callback informs your app
 that the specified peer is no longer available to communicate
 with, and you can remove its name from the user interface.
 
 @param browser The browser object that lost the peer.
 @param peerID The unique ID that identifies the peer disappeared.
 */
- (void)browser:(XPGServiceBrowser *)browser lostPeer:(XPGPeerID *)peerID;

@end