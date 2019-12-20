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

import Foundation

import SmarTagLib
import SmarTagCloudLibCommon
import SwiftyJSON
import CocoaMQTT

public class MqttProvider : CloudSyncProvider{
    
    public static let NAME = "MQTT"
    
    public static func buildSettingsViewController()->UIViewController?{
        let storyboard = UIStoryboard(name: "MQTTParameterSettings",
                                      bundle: Bundle(for: MQTTParametersViewController.self))
        return storyboard.instantiateInitialViewController()
    }
    
    private static let SENSOR_DATA_TOPIC = "/sensorData"
    private static let SENSOR_EVENT_TOPIC = "/eventData"
    private static let SENSOR_EXTREME_TOPIC = "/extremes"
    
    private let config: MqttConfigStorage
    private let tagId: String
    
    private var client:CocoaMQTT?
    
    public init(tagId:String, config: MqttConfigStorage){
        self.tagId = tagId
        self.config = config
    }
    
    public func connect(onSuccess:@escaping (Connection)->(),onError:@escaping (SmarTagCloudSyncError)->()) {
        guard let address = config.address else{
            onError(SmarTagCloudSyncError.invalidAddress)
            return
        }
        
        //
        client = CocoaMQTT(clientID: tagId, host: address, port: config.port)
        client?.allowUntrustCACertificate=true
        client?.enableSSL=config.useTls
        client?.keepAlive=60
        client?.cleanSession=true
        client?.username = config.userName
        client?.password = config.password
        client?.didConnectAck = { conn , ack in
            print(ack.description)
            if let error = ack.toError{
                onError(error)
            }else{
                onSuccess(conn)
            }
        }
        _ = client?.connect()
    }
    
    public func uploadSamples(conn: Connection, samples: [DataSample], currentLocation:Location?, onSuccess:@escaping (Connection)->(),onError:@escaping (SmarTagCloudSyncError)->()) {
        guard let mqtt = conn as? CocoaMQTT else{
            onError(SmarTagCloudSyncError.invalidHandle)
            return
        }
        
        let sensorData = JSON(samples.sensorSamples.map{$0.toJson}).rawString()
        let eventData = JSON(samples.eventSamples.map{$0.toJson}).rawString()
        if let data = sensorData{
            mqtt.didPublishMessage = { mqtt, msg ,id in
                mqtt.didPublishMessage = { mqtt, msg , id in
                    onSuccess(conn)
                }
                
                if let eventData = eventData{
                    mqtt.publish(self.tagId+MqttProvider.SENSOR_EVENT_TOPIC, withString: eventData, qos: .qos0)
                }
            }
            
            mqtt.publish(tagId+MqttProvider.SENSOR_DATA_TOPIC, withString: data, qos: .qos0)
        }
    }
    
    public func uploadSamples(conn: Connection, extremeData: TagExtreme, currentLocation:Location?, onSuccess: @escaping (Connection) -> (), onError: @escaping (SmarTagCloudSyncError) -> ()) {
        
        guard let mqtt = conn as? CocoaMQTT else{
            onError(SmarTagCloudSyncError.invalidHandle)
            return
        }
        if let data = extremeData.toJson.rawString(){
            mqtt.didPublishMessage = { mqtt, msg , id in
                onSuccess(conn)
            }
            mqtt.publish(tagId+MqttProvider.SENSOR_EXTREME_TOPIC, withString: data, qos: .qos0)
        }
        
    }
    
    public func disconnect(conn: Connection) {
        guard let mqtt = conn as? CocoaMQTT else{
            return
        }
        mqtt.didDisconnect = { conn , error in
            if(error != nil){
                print(error!)
            }
        }
        mqtt.disconnect()
    }
}

extension CocoaMQTT : Connection {}

extension CocoaMQTTConnAck {
    var toError:SmarTagCloudSyncError? {
        switch self {
        case .unacceptableProtocolVersion:
            return SmarTagCloudSyncError.unacceptableProtocolVersion
        case .identifierRejected:
            return SmarTagCloudSyncError.identifierRejected
        case .serverUnavailable:
            return SmarTagCloudSyncError.serverUnavailable
        case .badUsernameOrPassword:
            return SmarTagCloudSyncError.badUsernameOrPassword
        case .notAuthorized:
            return SmarTagCloudSyncError.notAuthorized
        case .reserved:
            return SmarTagCloudSyncError.unknown
        case .accept:
            return nil
        }
    }
}
