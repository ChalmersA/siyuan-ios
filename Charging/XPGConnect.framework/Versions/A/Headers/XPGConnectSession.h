//
//  XPGConnectSession.h
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
#import "XPGPeerID.h"
#import <CoreBluetooth/CoreBluetooth.h>

/**
 Indicates the current state of a given peer
 within a session.
 */
typedef NS_ENUM(NSInteger, XPGSessionState) {
    /**
     The peer is not (or no longer) with this session.
     */
	kXPGSessionStateNotConnected = 0,
    /**
     A connection to this peer is currently
     being established.
     */
    kXPGSessionStateConnecting,
    /**
     The peer is connected to this session.
     */
    kXPGSessionStateConnected,
    /**
     The connection was Timeout.
     */
    kXPGSessionStateConnectTimeout,
};

/**
 Indicates whether the delivery of data should be
 guaranteed.
 */
typedef NS_ENUM(NSInteger, XPGSessionSendDataMode) {
    /**
     We guarantee the delivery of each message,
     re-transmitting it as needed.
     */
    kXPGSessionSendDataReliable = 1,
    /**
     Shoot and forget type of delivery. No retry.
     */
    kXPGSessionSendDataUnreliable = 2,
};

@protocol XPGConnectSessionDelegate;

/**
 An XPGConnectSession object facilitates the communication among
 all peers in a session.
 
 # Setting up session
 
 To set up a session, your app must do the following:
 
 1. Create an XPGPeerID object that represents this local browser,
    and use it to initialize the session object.
 1. Add peers to the session using a browser object.
 1. Wait until the session calls your delegate's
    session:peer:didChangeState: method with XPGSessionStateConnected
    as the new state.
 
 # Communicating with peers
 
 Once you have set up the session, your app can send data to
 other peers in the session by calling one of the following
 methods:
 
 + sendData:toPeers:withMode:error sends an NSData object to
 the specified peers.
 
    On each recipient device, the delegate's session:didReceiveData:fromPeer:
 method is called when the data object has been fully received.
 
 + sendResourceAtURL:withName:toPeer:withCompletionHandle: sends
 the contents from an NSURL object to the specified peer.
 The URL can be either a local file URL or a Web URL. The
 completionHandler block is called when the resource is fully
 received by the recipient peer or when an error occurs during
 transmission.
 
    This method returns an NSProgress object that you can use to
 cancel the transfer or to check the current status of the transfer.
 
    On the recipient device, the session calls its delegate's
 session:didStartReceivingResourceWithName:fromPeer:withProgress:
 method when the device begins receiving the resource, and calls
 its session:didFinishReceivingResourceWithName:fromPeer:atURL:withError:
 method when the resource has been fully received or when an
 error occurs.
 
 + startStreamWithName:toPeer:error: creates a connected stream
 that you can use to send data to the specified peer.
 
    On the recipient device, the session calls its delegate's
 session:didReceiveStream:withName:fromPeer: method with an
 NSInputStream object that represents the other side of
 the communication.
 
 # Managing peers manually
 
 @TODO: Will implement this feature later.
 
 # Disconnecting
 
 To leave a session, your app must call disconnect.
 
 */
@interface XPGConnectSession : NSObject

/**
 An identifier that uniquely identifies the device
 on which your app is currently running.
 */
@property (nonatomic, readonly) XPGPeerID *peerID;

/**
 An array of all connected peers in this session.
 This array holds the XPGPeerID information.
 */
@property (nonatomic, readonly) NSArray *connectedPeers;

/**
 The delegate object that handles all session related events.
 */
@property (nonatomic, assign) id<XPGConnectSessionDelegate> delegate;

/**
 Creates a XPGConnectSession object.
 
 @param peerID An identifier to represent the local app.
 @return An initialized XPGConnectSession object.
 */
- (id)initWithPeer:(XPGPeerID *)peerID;

/**
 Send a message encapsulated in the data object. This
 method call should be non-blocking. On the recipient
 device, the session object calls its delegate's
 session:didReceiveData:fromPeer: method if the data
 has been fully received.
 
 @param data A data object that contains the message to send.
 @param peerIDs An array contains all target peers who
        should receive this message.
 @param mode The data transfer mode, reliable or unreliable.
 @param error The address of an NSError pointer where
        an error object should be stored in case needed.
 */
- (void)sendData:(NSData *)data toPeers:(NSArray *)peerIDs withMode:(XPGSessionSendDataMode)mode error:(NSError **)error;

/**
 Sends the content of a URL to one specified peer. This
 method is non-blocking.
 
 On the sending side, the completion handler block is called
 when delivery succeeds or when an error occurs.
 
 On the recipient side, the session calls its delegate method
 session:didStartReceivingResourceWithName:fromPeer:withProgress:
 as soon as it begins receiving. A NSProgress object provided
 by this method can be used to cancel the transfer or to
 check the transfer status.
 
 Once delivery succeeds, the recipient side session calls its
 delegate method
 session:didFinishReceivingResourceWithName:fromPeer:atURL:withError:.
 The received resource is saved in a temporary location, and
 the app is responsible for moving it to a permanent location
 before that delegate method returns.
 
 @param resourceURL A file or HTTP URL.
 @param resourceName A name for the resource. Also will be used
        as the base name when saving the resource.
 @param peerID The target recipient peer.
 @param completionHandler A block gets called when the delivery
        succeeds or fails. Upon success, the handler is called with
        a nil error object; upon failure, the handler is called
        with an error object indicating what went wrong.
 @return A NSProgress object that can be used to check the
        transfer status or even cancel the transfer.
 */
- (NSProgress *)sendResourceAtURL:(NSURL *)resourceURL withName:(NSString *)resourceName toPeer:(XPGPeerID *)peerID withCompletionHandler:(void (^)(NSError *error))completionHandler;

/**
 Opens a byte stream to a target recipient peer.
 This method is non-blocking.
 
 @TODO: Finish this API document.
 */


- (NSOutputStream *)startStreamWithName:(NSString *)streamName toPeer:(XPGPeerID *)peerID error:(NSError *)error;

- (BOOL)sendData:(NSData *)data toPeer:(XPGPeerID *)peerID withContext:(NSString *)context error:(NSError **)error;

// @TODO: Why do we need the following two methods?
// Can they be moved to somewhere else like a subclass?
- (BOOL)readDataFromPeer:(XPGPeerID *)peerID withContext:(NSString *)context error:(NSError **)error;

- (BOOL)updateRSSIToPeer:(XPGPeerID*)peerID;

@end

/**
 This protocol defines methods to handle session-related
 events.
 */
@protocol XPGConnectSessionDelegate <NSObject>

@required

/**
 Called when the state of a peer (connected or
 connecting) gets changed.
 
 The state could be one of the following values:
 
 - kXPGSessionStateConnected: the peer accepted the
    invitation and now it's connected in the session.
 - kXPGSessionStateNotConnected: the peer refused the
    invitation, or a previously connected peer is
    lost.
 
 @param session The peer gets state changed belongs to
        this session.
 @param peerID The peer that gets its state changed.
 @param state The new state of the peer in the session.
 */
- (void)session:(XPGConnectSession *)session peer:(XPGPeerID *)peerID didChangeState:(XPGSessionState)state;

/**
 Called when a NSData object has been received from
 a peer.
 
 @param session The session used to transfer data.
 @param data An object containing the data.
 @param peerID The peer identifier of the sender.
 */
- (void)session:(XPGConnectSession *)session didReceiveData:(NSData *)data fromPeer:(XPGPeerID *)peerID withContext:(NSString *)context;

- (void)session:(XPGConnectSession *)session peer:(XPGPeerID *)peerID didFoundServices:(NSArray*)servicesList characteristics:(NSDictionary *)characteristicList;

//TODO:发送数据确认
- (void)session:(XPGConnectSession *)session didSendData:(NSData *)data forPeer:(XPGPeerID *)peerID withContext:(NSString *)context;

//TODO:回调信号强度RSSI
- (void)session:(XPGConnectSession *)session didReceiveRSSI:(NSNumber *)rssi fromPeer:(XPGPeerID *)peerID;

@end


@interface XPGConnectSession (XPGConnectSessionCustomDiscovery)

// Connect a peer to the session once connection data is received
- (void)connectPeer:(XPGPeerID *)peerID withNearbyConnectionData:(NSData *)data timeout:(NSTimeInterval)timeout;

- (id<CBPeripheralDelegate>)setupPeerForAnalytics:(XPGPeerID *)peerID;

- (void)setupPeer:(XPGPeerID *)peerID;

// Cancel connection attempt with a peer
- (void)cancelConnectPeer:(XPGPeerID *)peerID;

@end