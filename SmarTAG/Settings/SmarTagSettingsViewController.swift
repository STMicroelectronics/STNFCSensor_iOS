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
import SmarTagLib

class SmartagSettingViewController: UIViewController, SmarTagObjectWithTag {
    
    private static let NOT_DEFINED = {
        return  NSLocalizedString("Not defined",
                                  tableName: nil,
                                  bundle: Bundle(for: SmartagSettingViewController.self),
                                  value: "Not defined",
                                  comment: "Not defined");
    }()
            
    private static let DEFAULT_SAMPLING_INTERVAL_S = UInt16(5)
    @IBOutlet weak var tagIdLabel: UILabel!
    
    @IBOutlet weak var temperatureSettings: SmarTagSensorSettingsView!
    @IBOutlet weak var pressureSettings: SmarTagSensorSettingsView!
    @IBOutlet weak var humiditySettings: SmarTagSensorSettingsView!
    @IBOutlet weak var accelerometerSettings: SmarTagAccelerometerSettingsView!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var logNextSampleSwitch: UISwitch!
    @IBOutlet weak var useThresholdSwitch: UISwitch!
    @IBOutlet weak var samplingIntervalValue: UITextField!
    
    /// configuration to show in this view controller
    var tagContent: SmarTagData?
    
    //we store the nfc NFCTagReaderSessionDelegate as object to avoid compile problem with version ios 12, where
    // the class is not present
    private var settingsWriter:NSObject?
    
    private let mTextFieldDelegate = CloseKeyboardOnReturn()
        
    override func viewDidLoad() {
        samplingIntervalValue.delegate = mTextFieldDelegate
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addSaveButton()
        displayTagId()
        displaySamplingInterval()
        setThresholdView()
        setLogNextSampleView()
        if let conf = tagContent?.configuration{
            setupTemperatureConfiguration(conf.temperatureConf)
            setupHumidityConfiguration(conf.humidityConf)
            setupPressureConfiguration(conf.pressureConf)
            setupAcceleropmeterConfiguration(conf)
            onEnableThresholdChange(useThresholdSwitch)
        }
    }
    
    private func setupTemperatureConfiguration(_ conf:SensorConfiguration){
        temperatureSettings.title = SmarTagSensorName.TEMPERATURE
        temperatureSettings.image = UIImage(imageLiteralResourceName: "temperature_icon")
        temperatureSettings.thresholdUnit = SmarTagSensorName.TEMPERATURE_UNIT
        temperatureSettings.setConfiguration(conf: conf,valueFormat: SmarTagSensorName.TEMPERATURE_DATA_FORMAT)
        temperatureSettings.isEdiatable = tagCanBeWritten
    }
    
    private func setupPressureConfiguration(_ conf:SensorConfiguration){
        pressureSettings.title = SmarTagSensorName.PRESSURE
        pressureSettings.image = UIImage(imageLiteralResourceName: "pressure_icon")
        pressureSettings.thresholdUnit = SmarTagSensorName.PRESSURE_UNIT
        pressureSettings.setConfiguration(conf: conf,valueFormat: SmarTagSensorName.PRESSURE_DATA_FORMAT)
        pressureSettings.isEdiatable = tagCanBeWritten
    }
    
    private func setupHumidityConfiguration(_ conf:SensorConfiguration){
        humiditySettings.title = SmarTagSensorName.HUMIDITY
        humiditySettings.image = UIImage(imageLiteralResourceName: "humidity_icon")
        humiditySettings.thresholdUnit = SmarTagSensorName.HUMIDITY_UNIT
        humiditySettings.setConfiguration(conf: conf,valueFormat: SmarTagSensorName.HUMIDITY_DATA_FORMAT)
        humiditySettings.isEdiatable = tagCanBeWritten
    }
    
    private func setupAcceleropmeterConfiguration(_ conf:Configuration){
        accelerometerSettings.title = SmarTagSensorName.ACCELERATION
        accelerometerSettings.image = UIImage(imageLiteralResourceName: "vibration_icon")
        accelerometerSettings.thresholdUnit = SmarTagSensorName.ACCELERATION_UNIT
        accelerometerSettings.setAccelerometerConfiguration(conf.accelerometerConf, valueFormat: SmarTagSensorName.ACCELERATION_DATA_FORMAT)
        accelerometerSettings.setWakeupEventConfiguraiton(conf.wakeUpConf)
        accelerometerSettings.setOrientationEventConfiguration(conf.orientationConf)
        accelerometerSettings.isEdiatable = tagCanBeWritten
        
    }
    
    private func displayTagId(){
        let id = tagContent?.idStr ?? "Unknown"
        self.tagIdLabel.text = "Id: \(id)"
    }
    
    private func addSaveButton(){
        if(tagCanBeWritten){
            if (parent?.navigationItem.rightBarButtonItem) != nil {
                parent?.navigationItem.rightBarButtonItems?.append(saveButton)
            }else{
                parent?.navigationItem.rightBarButtonItem = saveButton
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeSaveButton()
    }
    
    private func removeSaveButton(){
        if(tagCanBeWritten){
            parent?.navigationItem.rightBarButtonItems?.removeLast()
        }
    }
    
    private func displaySamplingInterval(){
        if let interval = tagContent?.configuration.samplingInterval_s {
            samplingIntervalValue.text = "\(interval)"
        }else{
            samplingIntervalValue.text = SmartagSettingViewController.NOT_DEFINED
        }
    }
    
    private func setThresholdView(){
        useThresholdSwitch.isOn = tagContent?.configuration.mode == Configuration.SamplingMode.SamplingWithThreshold
        useThresholdSwitch.isEnabled = tagCanBeWritten
    }
    
    private func setLogNextSampleView(){
        logNextSampleSwitch.isOn = tagContent?.configuration.mode == Configuration.SamplingMode.StoreNextSample
        logNextSampleSwitch.isEnabled = tagCanBeWritten
    }
    
    @IBAction func onEnableThresholdChange(_ sender: UISwitch) {
        temperatureSettings.showThreshold = sender.isOn
        pressureSettings.showThreshold = sender.isOn
        humiditySettings.showThreshold = sender.isOn
        accelerometerSettings.showThreshold = sender.isOn
    }
    
    private func getSamplingMode()->Configuration.SamplingMode{
        if useThresholdSwitch.isOn {
            return .SamplingWithThreshold
        }else if logNextSampleSwitch.isOn{
            return .StoreNextSample
        }else{
            return .Sampling
        }
    }
    
    private func getSamplingInterval()->UInt16 {
        guard let value = samplingIntervalValue.text  else {
            return SmartagSettingViewController.DEFAULT_SAMPLING_INTERVAL_S
        }
        return UInt16(value) ?? SmartagSettingViewController.DEFAULT_SAMPLING_INTERVAL_S
    }
    
    @IBAction func onSaveClieked(_ sender: UIBarButtonItem) {
        guard #available(iOS 13, *) else {
            return
        }
        
        let newConf = Configuration(samplingInteval: getSamplingInterval(),
                                    mode: getSamplingMode(),
                                    temperatureConf: temperatureSettings.getConfiguration(),
                                    humidityConf: humiditySettings.getConfiguration(),
                                    pressureConf: pressureSettings.getConfiguration(),
                                    accelerometerConf: accelerometerSettings.getAccelerometerConfiguration(),
                                    orientationConf: accelerometerSettings.getOrientationEventConfiguration(), wakeUpConf:  accelerometerSettings.getWakeUpConfiguration())
        settingsWriter = SmarTagSettingsWriter(conf: newConf)
    }
    
    /// true if the app is running on ios13 or above where the tag can be written
    private lazy var tagCanBeWritten: Bool = {
        if #available(iOS 13, *){
            return true
        }else{
            return false
        }
    }()
    
 }
