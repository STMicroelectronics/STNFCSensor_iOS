 /*
  * Copyright (c) 2018  STMicroelectronics – All rights reserved
  * The STMicroelectronics corporate logo is a trademark of STMicroelectronics
  *
  * Redistribution and use in source and binary forms, with or without modification,
  * are permitted provided that the following conditions are met:
  *
  * - Redistributions of source code must retain the above copyright notice, this list of conditions
  * and the following disclaimer.
  *
  * - Redistributions in binary form must reproduce the above copyright notice, this list of
  * conditions and the following disclaimer in the documentation and/or other materials provided
  * with the distribution.
  *
  * - Neither the name nor trademarks of STMicroelectronics International N.V. nor any other
  * STMicroelectronics company nor the names of its contributors may be used to endorse or
  * promote products derived from this software without specific prior written permission.
  *
  * - All of the icons, pictures, logos and other images that are provided with the source code
  * in a directory whose title begins with st_images may only be used for internal purposes and
  * shall not be redistributed to any third party or modified in any way.
  *
  * - Any redistributions in binary form shall not include the capability to display any of the
  * icons, pictures, logos and other images that are provided with the source code in a directory
  * whose title begins with st_images.
  *
  * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR
  * IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY
  * AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER
  * OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
  * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
  * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
  * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
  * OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY
  * OF SUCH DAMAGE.
  */

import CoreLocation
import SmarTagLib

import Foundation

 public enum SmarTagCloudSyncError : Error, CustomStringConvertible {
    
    case invalidAddress
    case unacceptableProtocolVersion
    case identifierRejected
    case serverUnavailable
    case badUsernameOrPassword
    case notAuthorized
    case invalidHandle
    case invalidData
    case unknown
    
    public var description: String {
        switch self {
        case .invalidAddress:
            return "invalidAddress"
        case .unacceptableProtocolVersion:
            return "unacceptableProtocolVersion"
        case .identifierRejected:
            return "identifierRejected"
        case .serverUnavailable:
            return "serverUnavailable"
        case .badUsernameOrPassword:
            return "badUsernameOrPassword"
        case .notAuthorized:
            return "notAuthorized"
        case .invalidHandle:
            return "invalidHandle"
        case .invalidData:
            return "invalidData"
        case .unknown:
            return "unknown"
        }
    }
    
 }
 
public protocol Connection { }

public protocol ConnectionCallback {
    func onSuccess(conn:Connection)
    func onFail(error:SmarTagCloudSyncError)
}

public protocol PublishCallback {
    func onSuccess()
    func onFail(error:SmarTagCloudSyncError)
}

 public struct Location {
    public let latitude:Double
    public let longitude:Double
    public let timestamp:Date
    
    public init(latitude:Double = 0.0,
                longitude:Double = 0.0,
                timestamp:Date = Date() ){
        self.latitude = latitude
        self.longitude = longitude
        self.timestamp = timestamp
    }
    
 }
 
public protocol CloudSyncProvider {
    static var NAME:String {get}
        
    func connect(onSuccess:@escaping (Connection)->(),onError:@escaping (SmarTagCloudSyncError)->())
    
    func uploadSamples(conn:Connection, samples:[DataSample],currentLocation:Location?, onSuccess:@escaping (Connection)->(),onError:@escaping (SmarTagCloudSyncError)->())
    
    func uploadSamples(conn:Connection, extremeData:TagExtreme,currentLocation:Location?,onSuccess:@escaping (Connection)->(),onError:@escaping (SmarTagCloudSyncError)->())
    
    func disconnect(conn:Connection)
}


