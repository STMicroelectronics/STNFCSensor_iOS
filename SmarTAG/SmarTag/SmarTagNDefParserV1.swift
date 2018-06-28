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

public class SmarTagNDefParserV1 : SmarTagNdefParserPotocol {
    
    public lazy var version:Version = {
        return Version(majour: rawData[SmarTagNDefParserV1.VERSION_MAJ_OFFEST],
                       minor: rawData[SmarTagNDefParserV1.VERSION_MIN_OFFEST],
                       patch: rawData[SmarTagNDefParserV1.VERSION_PATH_OFFEST])
    }()

    public lazy var configuration: Configuration = {
        let mode = Configuration.SamplingMode(rawValue: rawData[SmarTagNDefParserV1.LOG_MODE_OFFEST])
        let samplingInterval = rawData.getLeUInt16(offset: SmarTagNDefParserV1.SAMPLING_INTERVAL_OFFEST)
        let temperatureConf = SmarTagNDefParserV1.getTemperatureConf(from: rawData);
        let humidityConf = SmarTagNDefParserV1.getHumidityConf(from: rawData);
        let pressureConf = SmarTagNDefParserV1.getPressureConf(from: rawData);
        let accelerometerConf = SmarTagNDefParserV1.getAccelerometerConf(from: rawData)
        let orientationConf = SmarTagNDefParserV1.getOrientationConf(from: rawData)
        let wakeUpConf = SmarTagNDefParserV1.getWakeUpConf(from: rawData)
        return Configuration(samplingInteval: samplingInterval,
                             mode: mode!,
                             temperatureConf:temperatureConf,
                             humidityConf:humidityConf,
                             pressureConf:pressureConf,
                             accelerometerConf:accelerometerConf,
                             orientationConf:orientationConf,
                             wakeUpConf: wakeUpConf)
    }()
    
    
    private func parseExtremeOrNil(enable:Bool,parse:((Data)->DataExtreme))->DataExtreme?{
        if(enable){
            return parse(rawData)
        }else{
            return nil
        }
    }
    
    public lazy var dataExtreme:TagExtreme = {
       let temperature = parseExtremeOrNil(enable: configuration.temperatureConf.isEnable, parse:SmarTagNDefParserV1.getTemperatureExtreme )
       let pressure = parseExtremeOrNil(enable: configuration.pressureConf.isEnable, parse: SmarTagNDefParserV1.getPressureExtreme)
       let humidity = parseExtremeOrNil(enable: configuration.humidityConf.isEnable, parse: SmarTagNDefParserV1.getHumidityExtreme)
       let acceleration = parseExtremeOrNil(enable: configuration.accelerometerConf.isEnable, parse: SmarTagNDefParserV1.getAccelerometerExtreme)
       return TagExtreme(acquisitionStart: SmarTagNDefParserV1.getDate(from: rawData, offset: 8),
                         temperature: temperature,
                         pressure: pressure,
                         humidity: humidity,
                         acceleration: acceleration)
    }()
    private static let SAMPLE_N_SAMPLE_OFFSET = 60
    private static let NEXT_SAMPLE_PTR_OFFSET = 62
    
    private static func getMaxNumOfSample(memory:TagMemoryLayout)->UInt16{
        return (memory.availableSpace-UInt16(SmarTagNDefParserV1.SAMPLE_FIRST_DATA_OFFSET))/8
    }
    
    public lazy var samples: [DataSample] = {
        let nSample = rawData.getLeUInt16(offset: SmarTagNDefParserV1.SAMPLE_N_SAMPLE_OFFSET)
        guard nSample != 0 else{
            return []
        }
        let memoryLayout = SmarTagNDefParserV1.getTagMemoryLayout(ndefSize: rawData.count)
        let maxNSample = SmarTagNDefParserV1.getMaxNumOfSample(memory: memoryLayout)
        let nextSamplePtr = rawData.getLeUInt16(offset: SmarTagNDefParserV1.NEXT_SAMPLE_PTR_OFFSET)
        // /8 since eache sample needs 8 bytes ( 4 byte timestamp + 4 byte data)
        // -1 since we want the last sample and we have the next sample
        let lastSampleIndex = (nextSamplePtr - UInt16(SmarTagNDefParserV1.SAMPLE_FIRST_DATA_OFFSET) - memoryLayout.headerSize)/8 - 1
        var fistSampleIndex =  nSample >= maxNSample ? lastSampleIndex + 1 : 0
        var tempSamples:[DataSample] = []
        for i in 0...Int(nSample)-1{
            tempSamples.append(SmarTagNDefParserV1.getDataSample(from: rawData,sampleIndex: Int(fistSampleIndex)))
            fistSampleIndex = ( fistSampleIndex + 1 ) % maxNSample
        }
        return tempSamples
    }()
    
    private let rawData:Data
    
    public init(rawData:Data) throws{
        guard rawData[0]==1 else{
            throw SmarTagError.InvalidVersion
        }
        self.rawData = rawData
    }
    
    private static let MIN_TEMPERATURE = Float(-40.0)
    private static let MIN_HUMIDITY = Float(0.0)
    private static let MIN_PRESSURE = Float(810.0)
    private static let ACC_SCALE = Float(256)
    
    private static let VERSION_MAJ_OFFEST = 1
    private static let VERSION_MIN_OFFEST = 2
    private static let VERSION_PATH_OFFEST = 3
    private static let SAMPLING_INTERVAL_OFFEST = 4
    private static let LOG_MODE_OFFEST = 6
    private static let LOG_SEMSOR_OFFSET = 7
    private static let LOG_TEMPERATURE_MASK = UInt8(0x01)
    private static let LOG_HUMIDITY_MASK = UInt8(0x02)
    private static let LOG_PRESSURE_MASK = UInt8(0x04)
    private static let LOG_ACCELEROMETER_MASK = UInt8(0x08)
    private static let LOG_ORIENTATION_MASK = UInt8(0x10)
    private static let LOG_WAKEUP_MASK = UInt8(0x20)
    private static let LOG_TEMP_MAX_TH_OFFSET = 12
    private static let LOG_TEMP_MIN_TH_OFFSET = 13
    private static let LOG_HUM_MAX_TH_OFFSET = 14
    private static let LOG_HUM_MIN_TH_OFFSET = 15
    private static let LOG_PRES_ACC_TH_OFFSET = 16
    private static let EXTREME_TEMP_MAX_OFFSET = 40
    private static let EXTREME_TEMP_MAX_DATE_OFFSET = 24
    private static let EXTREME_TEMP_MIN_OFFSET = 41
    private static let EXTREME_TEMP_MIN_DATE_OFFSET = 28
    private static let EXTREME_HUM_MAX_OFFSET = 42
    private static let EXTREME_HUM_MAX_DATE_OFFSET = 32
    private static let EXTREME_HUM_MIN_OFFSET = 43
    private static let EXTREME_HUM_MIN_DATE_OFFSET = 36
    private static let EXTREME_PRES_MAX_MIN_OFFSET = 56
    private static let EXTREME_PRES_MAX_DATE_OFFSET = 44
    private static let EXTREME_PRES_MIN_DATE_OFFSET = 48
    private static let EXTREME_ACC_MAX_OFFSET = 56
    private static let EXTREME_ACC_MAX_DATE_OFFSET = 52
    private static let INVALID_TEMP = 0x007F
    private static let INVALID_PRESSURE = 0x0FFF
    private static let INVALID_HUM = 0x007F
    private static let INVALID_ACC = 0x003F
    private static let SAMPLE_FIRST_DATA_OFFSET = 64
    private static let YEAR_OFFSET = 2018
    
    private static func getTemperatureConf(from rawData:Data) ->SensorConfiguration{
        let isEnabled = (rawData[LOG_SEMSOR_OFFSET] & LOG_TEMPERATURE_MASK) != 0
        let threshold = Threshold(max: Float(rawData[LOG_TEMP_MAX_TH_OFFSET])+MIN_TEMPERATURE,
                                  min: Float(rawData[LOG_TEMP_MIN_TH_OFFSET])+MIN_TEMPERATURE)
        return SensorConfiguration(isEnable: isEnabled, threshold: threshold)
    }
    
    private static func getHumidityConf(from rawData:Data) ->SensorConfiguration{
        
        let isEnabled = (rawData[LOG_SEMSOR_OFFSET] & LOG_HUMIDITY_MASK) != 0
        let threshold = Threshold(max: Float(rawData[LOG_HUM_MAX_TH_OFFSET])+MIN_HUMIDITY,
                                  min: Float(rawData[LOG_HUM_MIN_TH_OFFSET])+MIN_HUMIDITY)
        return SensorConfiguration(isEnable: isEnabled, threshold: threshold)
    }
    
    private static func getPressureConf(from rawData:Data) ->SensorConfiguration{
        
        let isEnabled = (rawData[LOG_SEMSOR_OFFSET] & LOG_PRESSURE_MASK) != 0
        let thValue = rawData.getLeUInt32(offset: LOG_PRES_ACC_TH_OFFSET)
        let max = Float(thValue & 0xFFF)/10.0 + MIN_PRESSURE
        let min = Float((thValue >> 12) & 0xFFF)/10.0 +  MIN_PRESSURE
        let threshold = Threshold(max: max, min: min)
        return SensorConfiguration(isEnable: isEnabled, threshold: threshold)
    }
    
    private static func getAccelerometerConf(from rawData:Data) ->SensorConfiguration{
        
        let isEnabled = (rawData[LOG_SEMSOR_OFFSET] & LOG_ACCELEROMETER_MASK) != 0
        let thValue = rawData.getLeUInt32(offset: LOG_PRES_ACC_TH_OFFSET)
        
        let max = Float(((thValue >> 24) & 0x3F))*ACC_SCALE
        
        let threshold = Threshold(max: max, min: nil)
        return SensorConfiguration(isEnable: isEnabled, threshold: threshold)
    }
    
    private static func getOrientationConf(from rawData:Data) ->SensorConfiguration{
        
        let isEnabled = (rawData[LOG_SEMSOR_OFFSET] & LOG_ORIENTATION_MASK) != 0
        
        let threshold = Threshold(max: nil, min: nil)
        return SensorConfiguration(isEnable: isEnabled, threshold: threshold)
    }
    
    private static func getWakeUpConf(from rawData:Data) ->SensorConfiguration{
        
        let isEnabled = (rawData[LOG_SEMSOR_OFFSET] & LOG_WAKEUP_MASK) != 0
        let thValue = rawData.getLeUInt32(offset: LOG_PRES_ACC_TH_OFFSET)
        
        let max = Float(((thValue >> 24) & 0x3F))*ACC_SCALE
        
        let threshold = Threshold(max: max, min: nil)
        return SensorConfiguration(isEnable: isEnabled, threshold: threshold)
    }

    
    private static func getTemperatureExtreme(from rawData:Data) ->DataExtreme{
        let max = Float(rawData[EXTREME_TEMP_MAX_OFFSET])+MIN_TEMPERATURE
        let dataMax = getDate(from: rawData, offset: EXTREME_TEMP_MAX_DATE_OFFSET)
        let min = Float(rawData[EXTREME_TEMP_MIN_OFFSET])+MIN_TEMPERATURE
        let dataMin = getDate(from: rawData, offset: EXTREME_TEMP_MIN_DATE_OFFSET)
        return DataExtreme(maxDate: dataMax, maxValue: max, minDate: dataMin, minValue: min)
    }
    
    private static func getHumidityExtreme(from rawData:Data) ->DataExtreme{
        let max = Float(rawData[EXTREME_HUM_MAX_OFFSET])+MIN_HUMIDITY
        let dataMax = getDate(from: rawData, offset: EXTREME_HUM_MAX_DATE_OFFSET)
        let min = Float(rawData[EXTREME_HUM_MIN_OFFSET])+MIN_HUMIDITY
        let dataMin = getDate(from: rawData, offset: EXTREME_HUM_MIN_DATE_OFFSET)
        return DataExtreme(maxDate: dataMax, maxValue: max, minDate: dataMin, minValue: min)
    }
    
    
    private static func getPressureExtreme(from rawData:Data) ->DataExtreme{
        
        let pressureValue = rawData.getLeUInt32(offset: EXTREME_PRES_MAX_MIN_OFFSET)
        let max = Float(pressureValue & 0xFFF)/10.0 + MIN_PRESSURE
        let dataMax = getDate(from: rawData, offset: EXTREME_PRES_MAX_DATE_OFFSET)
        let min = Float((pressureValue >> 12) & 0xFFF)/10.0 + MIN_PRESSURE
        let dataMin = getDate(from: rawData, offset: EXTREME_PRES_MIN_DATE_OFFSET)
        return DataExtreme(maxDate: dataMax, maxValue: max, minDate: dataMin, minValue: min)
    }
    
    
    
    private static func getAccelerometerExtreme(from rawData:Data) ->DataExtreme{
        
        let thValue = rawData.getLeUInt32(offset: EXTREME_ACC_MAX_OFFSET)
        
        let max = Float(((thValue >> 24) & 0x3F))*ACC_SCALE
        let dataMax = getDate(from: rawData, offset: EXTREME_ACC_MAX_DATE_OFFSET)

        return DataExtreme(maxDate: dataMax, maxValue: max, minDate: nil, minValue: nil)
        
    }
    
    private static func getDate(from rawData:Data, offset:Data.Index)->Date{
        let compactValue = rawData.getLeUInt32(offset: offset) & 0x7FFFFFFF; //set to 0 the msb
        var dateComponents = DateComponents()
        
        dateComponents.year = Int((compactValue >> 26) & 0x3F) + YEAR_OFFSET //6bit
        dateComponents.month = Int((compactValue >> 17) & 0x0F) //4bit
        dateComponents.day = Int((compactValue >> 21)  & 0x1F) //5bit
        
        dateComponents.hour = Int((compactValue >> 12) & 0x1F) //5bit
        dateComponents.minute = Int((compactValue >> 6) & 0x3F)  //6bit
        dateComponents.second = Int(compactValue & 0x3F)  //6bit
        return  Calendar.current.date(from: dateComponents)!
    }
    

    private static func getSensorSampleSample(from rawData:Data, sampleAdrr: Int)->SensorDataSample{
        let sampleDate = getDate(from: rawData, offset: sampleAdrr)
        let data = rawData.getLeUInt32(offset: sampleAdrr+4)
        var intValue = (data >> 20) & 0xFFF
        let pressure = (intValue != INVALID_PRESSURE) ? Float(intValue)/10.0 + MIN_PRESSURE : nil
        intValue = (data >> 13) & 0x7F
        let temperature = (intValue != INVALID_TEMP) ? Float(intValue)+MIN_TEMPERATURE : nil
        intValue = (data >> 6) & 0x7F
        let humidity = (intValue != INVALID_HUM) ? Float(intValue) + MIN_HUMIDITY: nil
        intValue = data & 0x3F
        let acc = (intValue != INVALID_ACC) ? Float(intValue)*ACC_SCALE : nil
        return SensorDataSample(date: sampleDate, temperature: temperature,
                                humidity: humidity, pressure: pressure,
                                acceleration: acc)
    }
    
    private static func getEventSampleSample(from rawData:Data, sampleAdrr: Int)->EventDataSample{
        let sampleDate = getDate(from: rawData, offset: sampleAdrr)
        let data = rawData.getLeUInt32(offset: sampleAdrr+4)
        
        // orientation = 3 bit
        let orientation = UInt8(data & 0x07).toOrientation()
        let events = UInt8((data >> 3) & 0x3F).toAccelerationEvents()
        let intValue = (data >> 9) & 0x3F
        let acc = (intValue != INVALID_ACC) ? Float(intValue)*ACC_SCALE : nil
        return EventDataSample(date: sampleDate,
                               acceleration: acc,
                               accelerationEvents: events,
                               currentOrientation: orientation)
    }
    
    private static func getDataSample(from rawData:Data, sampleIndex: Int)->DataSample{
        let sampleAddr = SAMPLE_FIRST_DATA_OFFSET + 8*sampleIndex;
        let isAsyncSample = (rawData.getLeUInt32(offset: sampleAddr) & 0x80000000) != 0
        if( isAsyncSample){
            return DataSample.event(data: getEventSampleSample(from: rawData, sampleAdrr: sampleAddr))
        }else{
            return DataSample.sensor(data: getSensorSampleSample(from: rawData, sampleAdrr: sampleAddr))
        }
        
    }
    
    private static let NFCTAG_4K = TagMemoryLayout(totalSize: 0x200)
    private static let NFCTAG_64K = TagMemoryLayout(totalSize: 0x2000)
    
    private static func getTagMemoryLayout(ndefSize:Int)->TagMemoryLayout{
        if(ndefSize<=NFCTAG_4K.availableSpace){
            return NFCTAG_4K
        }else{
            return NFCTAG_64K
        }
    }
    
}

extension Data{
    
    public func getLeUInt16(offset:Index)->UInt16{
        var value = UInt16(0)
        value = UInt16(self[offset]) | UInt16(self[offset+1])<<8
        return value
    }
        
    public func getLeUInt32(offset:Index)->UInt32{
        return  UInt32(self[offset])       | (UInt32(self[offset+1])<<8) |
                (UInt32(self[offset+2])<<16) | (UInt32(self[offset+3])<<24)
    }
}
 
fileprivate struct TagMemoryLayout{
    let headerSize:UInt16
    let totalSize:UInt16
    let availableSpace:UInt16
    
    init(totalSize:UInt16){
        self.totalSize = totalSize;
        var ccSize = UInt16(4)
        let tlvSize = UInt16(4)
        if(totalSize>512){
            //8 = start extended CC size
            ccSize = 8
        }
        let ndefHeaderSize = UInt16(20)
        headerSize = ccSize + tlvSize + ndefHeaderSize
        // -4 for the end tlv
        availableSpace = totalSize - headerSize - 4
    }
}
