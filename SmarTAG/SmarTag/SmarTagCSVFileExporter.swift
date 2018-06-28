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

 fileprivate let CVS_DATA_FORMAT:DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "dd/MM/yy HH:mm:ss"
    return dateFormatter;
 }()
 
 extension SmarTagNdefParserPotocol {
    
    private func writeConfiguration()->String{
        var conf = "Sampling Interval,\(configuration.samplingInterval_s),seconds\n"
        + "\(SmarTagSensorName.TEMPERATURE) Enabled:,\(configuration.temperatureConf.isEnable.yesOrNo())"
        + "\(SmarTagSensorName.HUMIDITY) Enabled:,\(configuration.humidityConf.isEnable.yesOrNo())"
        + "\(SmarTagSensorName.PRESSURE) Enabled:,\(configuration.pressureConf.isEnable.yesOrNo())"
        + "\(SmarTagSensorName.ACCELERATION) Enabled:,\(configuration.accelerometerConf.isEnable.yesOrNo())\n"

        if(configuration.mode == .SamplingWithThreshold){
            if(configuration.accelerometerConf.isEnable){
                conf += "\(SmarTagSensorName.ORIENTATION) Enabled:,\(configuration.orientationConf.isEnable.yesOrNo())\n"
                conf += "\(SmarTagSensorName.WAKE_UP) Enabled:,\(configuration.wakeUpConf.isEnable.yesOrNo())\n"
            }
            conf += writeSensorThreshold();
        }
        return conf+"\n\n"
    }
    
    private func writeSensorThreshold() -> String{
        var sensorThreshold = "Threshold\n,Min,Max\n"
        if(configuration.temperatureConf.isEnable){
            let th = configuration.temperatureConf.threshold
            sensorThreshold += "\(SmarTagSensorName.TEMPERATURE),\(th.min.valueOrNan()),\(th.max.valueOrNan())\n"
        }
        if(configuration.humidityConf.isEnable){
            let th = configuration.humidityConf.threshold
            sensorThreshold += "\(SmarTagSensorName.HUMIDITY),\(th.min.valueOrNan()),\(th.max.valueOrNan())\n"
        }
        if(configuration.pressureConf.isEnable){
            let th = configuration.pressureConf.threshold
            sensorThreshold += "\(SmarTagSensorName.PRESSURE),\(th.min.valueOrNan()),\(th.max.valueOrNan())\n"
        }
        if(configuration.accelerometerConf.isEnable){
            let th = configuration.accelerometerConf.threshold
            sensorThreshold += "\(SmarTagSensorName.ACCELERATION),\(th.min.valueOrNan()),\(th.max.valueOrNan())\n"
        }
        if(configuration.orientationConf.isEnable){
            let th = configuration.orientationConf.threshold
            sensorThreshold += "\(SmarTagSensorName.ORIENTATION),\(th.min.valueOrNan()),\(th.max.valueOrNan())\n"
        }
        if(configuration.wakeUpConf.isEnable){
            let th = configuration.wakeUpConf.threshold
            sensorThreshold += "\(SmarTagSensorName.WAKE_UP),\(th.min.valueOrNan()),\(th.max.valueOrNan())\n"
        }
        return sensorThreshold
    }
    
    private func writeSensorData()->String{
        return "Data Log\n" +
        "Date,\(SmarTagSensorName.PRESSURE) (\(SmarTagSensorName.PRESSURE_UNIT)),\(SmarTagSensorName.HUMIDITY)" +
        " (\(SmarTagSensorName.HUMIDITY_UNIT)),\(SmarTagSensorName.TEMPERATURE) (\(SmarTagSensorName.TEMPERATURE_UNIT))" +
        ",\(SmarTagSensorName.ACCELERATION) (\(SmarTagSensorName.ACCELERATION_UNIT))\n" +
        samples.compactMap{ sample in
            switch (sample){
            case .sensor(let data):
                return data.toCSV()
            case .event:
                return nil
            }
        }.joined(separator: "\n") +
        "\n\n"
    }
    
    private func writeEventData()->String{
        return "Events\n" +
            "Date,Event,\(SmarTagSensorName.ORIENTATION), \(SmarTagSensorName.ACCELERATION) (\(SmarTagSensorName.ACCELERATION_UNIT))\n" +
            samples.compactMap{ sample in
                switch (sample){
                case .sensor:
                    return nil
                case .event( let data):
                    return data.toCSV()
                }
                }.joined(separator: "\n")
    }
    
    private func writeExtreme()->String{
        return "Extreme measurements\n"
            + "Acquisition start:,\(CVS_DATA_FORMAT.string(from: dataExtreme.acquisitionStart))\n"
            + ",Value,Unit,Date\n"
            + dataExtreme.temperature.toCSV(sensorName: SmarTagSensorName.TEMPERATURE,sensorUnit: SmarTagSensorName.TEMPERATURE_UNIT)
            + dataExtreme.humidity.toCSV(sensorName: SmarTagSensorName.HUMIDITY,sensorUnit: SmarTagSensorName.HUMIDITY_UNIT)
            + dataExtreme.pressure.toCSV(sensorName: SmarTagSensorName.PRESSURE,sensorUnit: SmarTagSensorName.PRESSURE_UNIT)
            + dataExtreme.acceleration.toCSV(sensorName: SmarTagSensorName.ACCELERATION,sensorUnit: SmarTagSensorName.ACCELERATION_UNIT)
            + "\n\n"
    }
    
    public func exportToCSV( onComplete:@escaping (_ exportedData:Data)->Void){
        DispatchQueue.global(qos: .background).async {
            var data = self.writeConfiguration().data(using: .utf8)
            data?.append(self.writeExtreme().data(using: .utf8)!)
            data?.append(self.writeSensorData().data(using: .utf8)!)
            data?.append(self.writeEventData().data(using: .utf8)!)
            DispatchQueue.main.async {
                onComplete(data!)
            }
        }
    }
    
 }

fileprivate extension Optional where Wrapped == DataExtreme{
    
    func toCSV(sensorName:String,sensorUnit:String) -> String {
        switch self {
        case .none:
            return ""
        case .some(let extreme):
            var extremeStr = "";
            if let value = extreme.maxValue , let date = extreme.maxDate{
                extremeStr += "Maximum \(sensorName), \(value), \(sensorUnit),\(CVS_DATA_FORMAT.string(from:date))\n"
            }
            if let value = extreme.minValue , let date = extreme.minDate{
                extremeStr += "Minimum \(sensorName), \(value), \(sensorUnit),\(CVS_DATA_FORMAT.string(from:date))\n"
            }
            return extremeStr
        }
    }
    
 }
 
 fileprivate extension SensorDataSample {
    
    func toCSV()->String{
        return "\(CVS_DATA_FORMAT.string(from: date)), \(pressure.valueOrNan()), \(humidity.valueOrNan())," +
            " \(temperature.valueOrNan()), \(acceleration.valueOrNan())"
    }
    
 }
 
 fileprivate extension EventDataSample {
    
    private static let WAKE_UP = {
        return  NSLocalizedString("Wake Up", comment: "Wake Up");
    }()
    
    private static let ORIENTATION = {
        return  NSLocalizedString("Orientation", comment: "Orientation");
    }()
    
    private static let SINGLE_TAP = {
        return  NSLocalizedString("Single Tap", comment: "Single Tap");
    }()
    
    private static let DOUBLE_TAP = {
        return  NSLocalizedString("Double Tap", comment: "Double Tap");
    }()
    
    private static let FREE_FALL = {
        return  NSLocalizedString("Free Fall", comment: "Free Fall");
    }()
    
    private static let TILT = {
        return  NSLocalizedString("Tilt", comment: "Tilt");
    }()
    
    private func accEventToString(_ event: AccelerationEvent)->String{
        switch event {
        case .wakeUp:
            return EventDataSample.WAKE_UP
        case .orientation:
            return EventDataSample.ORIENTATION
        case .singleTap:
            return EventDataSample.SINGLE_TAP
        case .doubleTap:
            return EventDataSample.DOUBLE_TAP
        case .freeFall:
            return EventDataSample.FREE_FALL
        case .tilt:
            return EventDataSample.TILT
        }
    }
    
    private static let UNKNOWN = {
        return  NSLocalizedString("Unknown", comment: "Unknown");
    }()
    
    private static let UP_RIGHT = {
        return  NSLocalizedString("Up Right", comment: "Up Right");
    }()
    
    private static let TOP = {
        return  NSLocalizedString("Top", comment: "Top");
    }()
    
    private static let BOTTOM = {
        return  NSLocalizedString("Bottom", comment: "Bottom");
    }()
    
    private static let DOWN_LEFT = {
        return  NSLocalizedString("Down Left", comment: "Down Left");
    }()
    
    private static let UP_LEFT = {
        return  NSLocalizedString("Up Left", comment: "Up Left");
    }()
    
    private static let DOWN_RIGHT = {
        return  NSLocalizedString("Down Right", comment: "Down Right");
    }()
    
    private func orientationToString(_ orientation: Orientation) -> String{
        switch orientation {
        case .unknown:
            return EventDataSample.UNKNOWN
        case .up_right:
            return EventDataSample.UP_RIGHT
        case .top:
            return EventDataSample.TOP
        case .down_left:
            return EventDataSample.DOWN_LEFT
        case .bottom:
            return EventDataSample.BOTTOM
        case .up_left:
            return EventDataSample.UP_LEFT
        case .down_right:
            return EventDataSample.DOWN_RIGHT
        }
    }

    func toCSV()->String{
        let events = accelerationEvents.map(accEventToString).joined(separator: " ")
        return "\(CVS_DATA_FORMAT.string(from: date)), \(events), \(orientationToString(currentOrientation))" +
            ", \(acceleration.valueOrNan())"
    }
    
 }
 
fileprivate extension Bool{
    func yesOrNo() -> String {
        if(self){
            return "Yes"
        }else{
            return "No"
        }
    }
}
 
 fileprivate extension Optional where Wrapped == Float{
    func valueOrNan()->Float{
        if let value = self{
            return value;
        }else{
            return Float.nan
        }
    }
 }
