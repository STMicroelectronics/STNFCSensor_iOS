/*
* Copyright (c) 2019  STMicroelectronics – All rights reserved
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
import SmarTagLib

@IBDesignable
class SmarTagAccelerometerSettingsView : UIView{
    @IBOutlet var contentView: UIView!
    
    @IBOutlet weak var sensorName: UILabel!
    @IBOutlet weak var sensorImage: UIImageView!
    @IBOutlet weak var isEnableSwitch: UISwitch!
    @IBOutlet weak var maxThresholdValue: UITextField!
    @IBOutlet weak var maxThresholdView: UIStackView!
    @IBOutlet weak var maxThresholdUnitLabel: UILabel!
    @IBOutlet weak var orientationEventSwitch: UISwitch!
    @IBOutlet weak var wakeUpEventSwitch: UISwitch!

    @IBOutlet weak var orientationEventView: UIStackView!
    @IBOutlet weak var wakeUpEventView: UIStackView!
    
    private let mTextFieldDelegate = CloseKeyboardOnReturn()
    
    var title:String?{
        get{
            return sensorName.text
        }
        set(value){
            sensorName.text = value
        }
    }
    
    var image:UIImage?{
        get{
            return sensorImage.image
        }
        set(image){
            return sensorImage.image = image
        }
    }
    
    var thresholdUnit:String?{
           get{
               return maxThresholdUnitLabel.text
           }
           set(value){
               maxThresholdUnitLabel.text = value
           }
       }
       
       var isEdiatable:Bool{
           get{
               return isEnableSwitch.isEnabled
           }
           set(value){
               isEnableSwitch.isEnabled = value
               maxThresholdValue.isEnabled = value
               orientationEventSwitch.isEnabled = value
               wakeUpEventSwitch.isEnabled = value
           }
       }
       
       var showThreshold:Bool{
           get{
               return !maxThresholdView.isHidden
           }
           set(value){
               maxThresholdView.isHidden = !value
               orientationEventView.isHidden = !value
               wakeUpEventView.isHidden = !value
           }
       }
       
    @IBAction func onEnableAccelerometerChange(_ sender: UISwitch) {
        if(sender.isOn==false){
            orientationEventSwitch.isOn=false
            wakeUpEventSwitch.isOn=false
        }
    }
    
   func setAccelerometerConfiguration(_ conf:SensorConfiguration, valueFormat:String){
       isEnableSwitch.isOn = conf.isEnable
       if let max = conf.threshold.max{
           maxThresholdValue.text = String(format:valueFormat,max)
       }
       return
   }
    
    func setOrientationEventConfiguration(_ conf:SensorConfiguration){
        orientationEventSwitch.isOn = conf.isEnable
    }
    
    func setWakeupEventConfiguraiton(_ conf:SensorConfiguration){
        wakeUpEventSwitch.isOn = conf.isEnable
    }
       
    func getAccelerometerConfiguration()->SensorConfiguration{
        let maxTh = maxThresholdValue.text.floatOrNil
        return SensorConfiguration(isEnable: isEnableSwitch.isOn, threshold: Threshold(max:maxTh))
    }
    
    func getWakeUpConfiguration()->SensorConfiguration{
        let maxTh = maxThresholdValue.text.floatOrNil
        return SensorConfiguration(isEnable: wakeUpEventSwitch.isOn, threshold: Threshold(max:maxTh))
    }
    
    func getOrientationEventConfiguration()->SensorConfiguration{
        let maxTh = maxThresholdValue.text.floatOrNil
        return SensorConfiguration(isEnable: orientationEventSwitch.isOn, threshold: Threshold(max:maxTh))
    }
    override func prepareForInterfaceBuilder() {
           super.prepareForInterfaceBuilder()
           xibSetup()
           contentView.prepareForInterfaceBuilder()
       }
       
   override func awakeFromNib() {
       super.awakeFromNib()
       xibSetup()
        maxThresholdValue.delegate = mTextFieldDelegate
   }

   private func xibSetup() {
       let view = loadViewFromNib()
       view.frame = bounds
       view.autoresizingMask =
                   [.flexibleWidth, .flexibleHeight]
       addSubview(view)
       contentView = view
   }
   
   private func loadViewFromNib() -> UIView {
       return Bundle(for: SmarTagAccelerometerSettingsView.self)
           .loadNibNamed("SmarTagAccelerometerSettingsView", owner: self, options: nil)?.first as! UIView
   }
}
