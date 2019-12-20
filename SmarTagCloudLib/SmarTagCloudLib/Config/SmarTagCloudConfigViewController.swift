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
import SmarTagCloudLibMqtt
 
fileprivate struct CloudProvider{
    let name:String
    let buildConfig: ()->UIViewController?
}

fileprivate let CLOUD_PROVIDER = [
    CloudProvider(name: MqttProvider.NAME,
                  buildConfig: MqttProvider.buildSettingsViewController)
]

public class SmarTagCloudConfigViewController : UIViewController{
    
    private static let ERROR_TITLE = "Error"
    private static let MISSING_PROVIDER_MESSAGE = "Select a cloud provider"
    
    @IBOutlet weak var providerTableView: UITableView!
    @IBOutlet weak var enableLoggingSwitch: UISwitch!
    
    private var config = SmarTagCloudConfigUtil.defaultInstance
    
    public override func viewDidLoad() {
        providerTableView.dataSource = self
        providerTableView.delegate = self
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        enableLoggingSwitch.isOn = config.isEnabled
    }
    
    @IBAction func onCloudEnableChanged(_ sender: UISwitch) {
        config.isEnabled = sender.isOn
    }
    
    @IBAction func onConfigureButtonPressed(_ sender: UIButton) {
        if let selectedName = config.provider,
            let selectedProvider = CLOUD_PROVIDER.getByName(selectedName){
            
            if let configVC = selectedProvider.buildConfig() {
                self.navigationController?.pushViewController(configVC, animated: true)
                //self.present(configVC, animated: true, completion: nil)
            }
        }else{
            let noSelected = UIAlertController(title: SmarTagCloudConfigViewController.ERROR_TITLE,
                                               message: SmarTagCloudConfigViewController.MISSING_PROVIDER_MESSAGE, preferredStyle: .alert)
            noSelected.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(noSelected, animated: true, completion: nil)
        }
    }
}

extension SmarTagCloudConfigViewController:UITableViewDataSource{
    
    private static let CELL_ID = "CloudConfigTableCell"
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return CLOUD_PROVIDER.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SmarTagCloudConfigViewController.CELL_ID)
        
        let name = CLOUD_PROVIDER[indexPath.row].name
        
        cell?.textLabel?.text = name
        if(name == config.provider){
            cell?.accessoryType = .checkmark
        }else {
            cell?.accessoryType = .none
        }
        return cell!
    }
}


extension SmarTagCloudConfigViewController: UITableViewDelegate{
    public func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath?{
    
        let selectedCell = tableView.cellForRow(at: indexPath)
        
        //change the selected provider and reload the table
        config.provider = selectedCell?.textLabel?.text
        tableView.reloadData()
        
        return indexPath
    }
}

extension Array where Element == CloudProvider{
    
    func getByName(_ name:String) -> CloudProvider?{
        return first{$0.name == name}
    }
    
}
