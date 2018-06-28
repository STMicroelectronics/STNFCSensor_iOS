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
 
public enum AccelerationEvent : UInt8 {
    case wakeUp = 0x01
    case orientation = 0x02
    case singleTap = 0x04
    case doubleTap = 0x08
    case freeFall = 0x10
    case tilt = 0x20

 }
 
 extension UInt8 {
    public func toAccelerationEvents()->[AccelerationEvent]{
        var events:[AccelerationEvent] = [];
        for i in 0...7 {
            let mask = UInt8(1<<i);
            if let event = AccelerationEvent(rawValue:(self & mask)){
                events.append(event)
            }
        }
        return events;
    }
 }
 
 public enum Orientation: UInt8{
    
    case unknown = 0x00
    case up_right = 0x01
    case top = 0x02
    case down_left = 0x03
    case bottom = 0x04
    case up_left = 0x05
    case down_right = 0x06
 }
 
 extension UInt8 {
    public func toOrientation()->Orientation{
        return Orientation(rawValue:self) ?? .unknown;
    }
 }
  
public struct EventDataSample{
    public let date:Date
    public let acceleration:Float?
    public let accelerationEvents:[AccelerationEvent]
    public let currentOrientation:Orientation
}
 
public struct SensorDataSample{
    public let date:Date
    public let temperature:Float?
    public let humidity:Float?
    public let pressure:Float?
    public let acceleration:Float?
    
    init(date:Date,temperature:Float?, humidity:Float?, pressure:Float?, acceleration:Float?) {
        self.date = date
        self.temperature = temperature
        self.humidity = humidity
        self.pressure = pressure
        self.acceleration = acceleration
    }
}
 
 public enum DataSample{
    case sensor(data:SensorDataSample)
    case event(data:EventDataSample)
 }
