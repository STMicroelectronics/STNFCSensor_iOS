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
import UIKit
import CoreNFC


 public class SmarTAGDebugViewController: UIViewController, SmarTagObjectWithTag{
    var tagContent: SmarTagNdefParserPotocol?
    
    @IBOutlet weak var mPayloadContentText: UITextView!
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let tag = tagContent{
            var tagStr = "Version: \(tag.version.majour).\(tag.version.minor).\(tag.version.patch)\n"
            tagStr += configurationDescription(tag.configuration)
            tagStr += extremeDescription(tag.dataExtreme)
            tagStr += sampleDescription(tag.samples)
            DispatchQueue.main.async {
                self.mPayloadContentText.text?=tagStr
            }//main thread
        }// if tag
    }//if record
    
    private func configurationDescription( _ conf:Configuration) -> String{
        //todo move in the conf struct
        return """
            Conf:\n\tsampling: \(conf.samplingInterval_s)
            \tmode: \(conf.mode)
            \tTemp: \(conf.temperatureConf.isEnable)
            \t\tMax: \(conf.temperatureConf.threshold.max!) Min: \(conf.temperatureConf.threshold.min!)
            \tHum: \(conf.humidityConf.isEnable)
            \t\tMax: \(conf.humidityConf.threshold.max!) Min: \(conf.humidityConf.threshold.min!)
            \tPres: \(conf.pressureConf.isEnable)
            \t\tMax: \(conf.pressureConf.threshold.max!) Min: \(conf.pressureConf.threshold.min!)
            \tAcc: \(conf.accelerometerConf.isEnable)
            \t\tMax: \(conf.accelerometerConf.threshold.max!)\n\n
        """
    }
    
    private let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yy HH:mm:ss"
        return dateFormatter;
    }()
    
    private func sampleDescription(_ data:[DataSample])->String{
        var str = "Samples: \(data.count)\n"
        data.forEach{ sample in
            switch(sample){
            case .sensor(let data):
                let dateStr = dateFormatter.string(from: data.date)
                str += """
                \t\(dateStr)
                \t\t\(data.pressure!)\t\(data.humidity!)\t\(data.temperature!)\t\(data.acceleration!)\n
                """
                break;
            case .event(let data):
                let dateStr = dateFormatter.string(from: data.date)
                str += """
                \t\(dateStr)
                \t\t\(data.acceleration ?? Float.nan)\t\(data.currentOrientation)\t\(data.accelerationEvents)\t
                """
                break;
            }
        }//for each sample
        return str
    }
    
    private func extremeDescription(_ extreme:TagExtreme)->String{
        /*
        return """
            Extreme:
            \tAcquisition Start:\(dateFormatter.string(from: extreme.acquisitionStart))
            \tTemp:
            \t\tMax: \(extreme.temperature.maxValue!) - \(dateFormatter.string(from: extreme.temperature.maxDate!))
            \t\tMin: \(extreme.temperature.minValue!) - \(dateFormatter.string(from: extreme.temperature.minDate!))
            \tHum:
            \t\tMax: \(extreme.humidity.maxValue!) - \(dateFormatter.string(from: extreme.humidity.maxDate!))
            \t\tMin: \(extreme.humidity.minValue!) - \(dateFormatter.string(from: extreme.humidity.minDate!))
            \tPress:
            \t\tMax: \(extreme.pressure.maxValue!) - \(dateFormatter.string(from: extreme.pressure.maxDate!))
            \t\tMin: \(extreme.pressure.minValue!) - \(dateFormatter.string(from: extreme.pressure.minDate!))
            \tAcc:
            \t\tMax: \(extreme.acceleration.maxValue!) - \(dateFormatter.string(from: extreme.acceleration.maxDate!))\n\n
        """
  */
        return ""
    }

}

