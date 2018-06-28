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


class SmartagSettingViewController: UIViewController, SmarTagObjectWithTag {
    
    private static let NOT_DEFINED = {
        return  NSLocalizedString("Not defined",
                                  tableName: nil,
                                  bundle: Bundle(for: SmartagSettingViewController.self),
                                  value: "Not defined",
                                  comment: "Not defined");
    }()
    
    @IBOutlet weak var mSensorConfTable: UITableView!
    @IBOutlet weak var mLogNextSampleSwitch: UISwitch!
    @IBOutlet weak var mUseThresholdSwitch: UISwitch!
    @IBOutlet weak var mSamplingInterval: UITextField!
    
    private enum CellRowType{
        case generic(SmarTagSensorSettingCell.Data)
        case accelerometer(SmarTagAccelerationSettingCell.Data)
    }
    
    private var mSensorCellConfiguration: [CellRowType] = []
    
    var tagContent: SmarTagNdefParserPotocol?
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        displaySamplingInterval()
        setThresholdView()
        setLogNextSampleView()
        
        if let conf = tagContent?.configuration{
            mSensorCellConfiguration = [
                .generic(SmarTagSensorSettingCell.Data(name:SmarTagSensorName.PRESSURE,
                                                       unit:SmarTagSensorName.PRESSURE_UNIT,
                                                       dataFormat: SmarTagSensorName.PRESSURE_DATA_FORMAT,
                                              image:#imageLiteral(resourceName: "pressure_icon"),
                                              sensorConf:conf.pressureConf)),
                .generic(SmarTagSensorSettingCell.Data(name:SmarTagSensorName.HUMIDITY,
                                              unit:SmarTagSensorName.HUMIDITY_UNIT,
                                              dataFormat: SmarTagSensorName.HUMIDITY_DATA_FORMAT,
                                              image:#imageLiteral(resourceName: "humidity_icon"),
                                              sensorConf:conf.humidityConf)),
                .generic(SmarTagSensorSettingCell.Data(name:SmarTagSensorName.TEMPERATURE,
                                              unit:SmarTagSensorName.TEMPERATURE_UNIT,
                                              dataFormat: SmarTagSensorName.TEMPERATURE_DATA_FORMAT,
                                              image:#imageLiteral(resourceName: "temperature_icon"),
                                              sensorConf:conf.temperatureConf)),
                .accelerometer(SmarTagAccelerationSettingCell.Data(name:SmarTagSensorName.ACCELERATION,
                                              unit:SmarTagSensorName.ACCELERATION_UNIT,
                                              dataFormat: SmarTagSensorName.ACCELERATION_DATA_FORMAT,
                                              image:#imageLiteral(resourceName: "vibration_icon"),
                                              sensorConf:conf.accelerometerConf,
                                              orientationEnabled: conf.orientationConf.isEnable,
                                              wakeUpEnabled: conf.wakeUpConf.isEnable))
            ]
        }
        
        mSensorConfTable.dataSource = self;
        
    }
    
    
    private func displaySamplingInterval(){
        if let interval = tagContent?.configuration.samplingInterval_s {
            mSamplingInterval.text = "\(interval)"
        }else{
            mSamplingInterval.text = SmartagSettingViewController.NOT_DEFINED
        }
    }
    
    private func setThresholdView(){
        mUseThresholdSwitch.isOn = tagContent?.configuration.mode == Configuration.SamplingMode.SamplingWithThreshold
    }
    
    private func setLogNextSampleView(){
        mLogNextSampleSwitch.isOn = tagContent?.configuration.mode == Configuration.SamplingMode.StoreNextSample
    }
    
    @IBAction func onEnableThresholdChange(_ sender: UISwitch) {
        mSensorConfTable.reloadData()
    }
 }

extension SmartagSettingViewController:UITableViewDataSource{
    private static let GENERIC_CELL_ID = "SmarTagSensorSettingCellID"
    private static let ACC_CELL_ID = "SmarTagAccelerationSettingCellID"
        
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mSensorCellConfiguration.count
    }
    
    private func setupGenericCellContent(cell:SmarTagSensorSettingCell, content:SmarTagSensorSettingCell.Data){
        cell.showThresholdDelegate = { self.mUseThresholdSwitch.isOn }
        cell.setData(data:content)
    }
    
    private func setupGenericCellContent(cell:SmarTagAccelerationSettingCell, content:SmarTagAccelerationSettingCell.Data){
        cell.showThresholdDelegate = { self.mUseThresholdSwitch.isOn }
        cell.setData(data:content)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch mSensorCellConfiguration[indexPath.row] {
        case .generic(let data):
            let cell = tableView.dequeueReusableCell(withIdentifier: SmartagSettingViewController.GENERIC_CELL_ID, for: indexPath) as! SmarTagSensorSettingCell;
            setupGenericCellContent(cell: cell, content: data)
            return cell
        case .accelerometer(let data):
            let cell = tableView.dequeueReusableCell(withIdentifier: SmartagSettingViewController.ACC_CELL_ID, for: indexPath) as! SmarTagAccelerationSettingCell;
            setupGenericCellContent(cell: cell, content: data)
            return cell
        }
        
    }
    
    
 }
 
