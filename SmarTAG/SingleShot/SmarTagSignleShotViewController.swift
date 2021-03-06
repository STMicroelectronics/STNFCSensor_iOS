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


@available(iOS 13, *)
class SmarTagSignleShotViewController: UIViewController {
    private var readerSession:NFCReaderSession?

    @IBOutlet weak var accelerationLabel: UILabel!
    @IBOutlet weak var pressureLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    
    override func viewDidLoad() {
        accelerationLabel.text = Self.DISABLED
        pressureLabel.text = Self.DISABLED
        temperatureLabel.text = Self.DISABLED
        humidityLabel.text = Self.DISABLED
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        startReadTag()
    }
    
    fileprivate func showValue(data:SensorDataSample){
    
        if let temp = data.temperature{
            temperatureLabel.text = String(format:SmarTagSensorName.TEMPERATURE_FORMAT,temp)
        }
        if let pres = data.pressure {
            pressureLabel.text = String(format:SmarTagSensorName.PRESSURE_FORMAT,pres)
        }
        if let humidity = data.humidity {
            humidityLabel.text = String(format:SmarTagSensorName.HUMIDITY_FORMAT,humidity)
        }
        if let acc = data.acceleration {
            accelerationLabel.text = String(format:SmarTagSensorName.ACCELERATION_FORMAT,acc)
        }
    }
    
    private static let DISABLED = {
        return  NSLocalizedString("Disabled",
                                  tableName: nil,
                                  bundle: Bundle(for: SmarTagMainViewController.self),
                                  value: "Disabled",
                                  comment: "Disabled");
    }()

    
    
}


@available(iOS 13, *)
extension SmarTagSignleShotViewController : NFCTagReaderSessionDelegate {
   
    private static let NFC_READ_MESSAGE = {
        return  NSLocalizedString("This is an “energy harvesting” feature.\nBe sure the battery has been removed from the SmarTag",
                                  tableName: nil,
                                  bundle: Bundle(for: SmarTagMainViewController.self),
                                  value: "This is an “energy harvesting” feature.\nBe sure the battery has been removed from the SmarTag",
                                  comment: "This is an “energy harvesting” feature.\nBe sure the battery has been removed from the SmarTag");
    }()

    private static let NFC_READ_FAIL = {
           return  NSLocalizedString("Previous read fail, please align better the NFC antenna",
                                     tableName: nil,
                                     bundle: Bundle(for: SmarTagMainViewController.self),
                                     value: "Previous read fail, please align better the NFC antenna",
                                     comment: "Previous read fail, please align better the NFC antenna");
       }()
    
    
   fileprivate func startReadTag(){
       readerSession = NFCTagReaderSession(pollingOption: .iso15693, delegate: self)
       readerSession?.alertMessage = SmarTagSignleShotViewController.NFC_READ_MESSAGE
       readerSession?.begin()
    }
   
   public func tagReaderSessionDidBecomeActive(_ session: NFCTagReaderSession) {
       NSLog("Session Activated")
   }
       
   public func tagReaderSession(_ session: NFCTagReaderSession, didInvalidateWithError error: Error) {
       print(error.localizedDescription)
       NSLog("Error")
       guard let readerError = error as? NFCReaderError else {
           return
       }
       switch readerError.code {
       case .readerSessionInvalidationErrorUserCanceled,
            .readerSessionInvalidationErrorSessionTimeout :
           break
       default:
        session.invalidate(errorMessage: error.localizedDescription)
       }
   }
   
   public func tagReaderSession(_ session: NFCTagReaderSession, didDetect tags: [NFCTag]) {
       guard let tag = tags.first, case let NFCTag.iso15693(type5Tag) = tag else{
           return
       }
   
       session.connect(to: tag){ error in
           guard error == nil else{
               session.invalidate(errorMessage: error!.localizedDescription)
               return
           }
           let parser = SmartTagIso15693Parser(tagIO: SmarTagIOISO15693(type5Tag))
           parser.readSingleShotContent{ singleShotValue in
               switch(singleShotValue){
                 case .failure(_):
                    session.invalidate(errorMessage: Self.NFC_READ_FAIL)
                 case .success( let data):
                    session.invalidate()
                    DispatchQueue.main.async {
                        self.showValue(data: data)
                    }
               }//switch
           }//readSingleShot
       }//on connect sesison
   }
    
}
