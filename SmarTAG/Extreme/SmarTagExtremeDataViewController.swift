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
import SmarTagLib

 class SmarTagExtremeDataViewController: UIViewController,SmarTagObjectWithTag {
    @IBOutlet weak var mExtremeCollectionView: UITableView!
    
    var tagContent: SmarTagData?
    fileprivate var mExtremeData:[SmarTagExtremeDataViewCell.Data] = []
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let extremes = tagContent?.dataExtreme{
            if let pressure = extremes.pressure{
                mExtremeData.append(
                    SmarTagExtremeDataViewCell.Data(
                        name: SmarTagSensorName.PRESSURE,
                            icon:#imageLiteral(resourceName: "pressure_icon"), dataFormat:SmarTagSensorName.PRESSURE_FORMAT, extremes:pressure))
            }
            if let humidity = extremes.humidity{
                mExtremeData.append(
                SmarTagExtremeDataViewCell.Data(
                    name: SmarTagSensorName.HUMIDITY,
                    icon:#imageLiteral(resourceName: "humidity_icon"),dataFormat:SmarTagSensorName.HUMIDITY_FORMAT,extremes: humidity))
            }
            if let temperature = extremes.temperature{
                mExtremeData.append(
                SmarTagExtremeDataViewCell.Data(
                    name: SmarTagSensorName.TEMPERATURE,
                    icon:#imageLiteral(resourceName: "temperature_icon"),dataFormat:SmarTagSensorName.TEMPERATURE_FORMAT,extremes: temperature))
            }
            if let acceleration = extremes.acceleration{
                mExtremeData.append(
                SmarTagExtremeDataViewCell.Data(
                    name: SmarTagSensorName.ACCELERATION,
                    icon:#imageLiteral(resourceName: "vibration_icon"),dataFormat:SmarTagSensorName.ACCELERATION_FORMAT,extremes: acceleration));
            }
            
        }
        mExtremeCollectionView.dataSource=self
    }
 }
 
 extension SmarTagExtremeDataViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mExtremeData.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:SmarTagExtremeDataViewController.CELL_ID, for: indexPath) as? SmarTagExtremeDataViewCell
        
        cell?.setData(mExtremeData[indexPath.row]);
        
        return cell!
    }
    
    private static let CELL_ID = "SmarTagExtremeDataCellID"
 }
 
