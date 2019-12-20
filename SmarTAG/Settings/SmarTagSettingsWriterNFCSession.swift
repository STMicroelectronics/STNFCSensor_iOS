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

import SmarTagLib
import CoreNFC

@available(iOS 13, *)
class SmarTagSettingsWriter:NSObject, NFCTagReaderSessionDelegate{
    
    private var configuration:Configuration    
    private var writeSession:NFCTagReaderSession?
    
    private static let TAP_TO_WRITE = {
        return  NSLocalizedString("Tap on the tag where stave the configuration",
                                  tableName: nil,
                                  bundle: Bundle(for: SmarTagSettingsWriter.self),
                                  value: "Tap on the tag where stave the configuration",
                                  comment: "Tap on the tag where stave the configuration");
    }()
    
    private static let WRITE_COMPLETED = {
        return  NSLocalizedString("Settings written",
                                  tableName: nil,
                                  bundle: Bundle(for: SmarTagSettingsWriter.self),
                                  value: "Settings written",
                                  comment: "Settings written");
    }()
    
    private static let CONNECITON_ERROR = {
        return  NSLocalizedString("Impossible to connect with the tag",
                                  tableName: nil,
                                  bundle: Bundle(for: SmarTagSettingsWriter.self),
                                  value: "Impossible to connect with the tag",
                                  comment: "Impossible to connect with the tag");
    }()
    
    init(conf:Configuration){
        self.configuration = conf
        super.init()
        writeSession = NFCTagReaderSession(pollingOption: .iso15693, delegate: self)
        writeSession?.alertMessage = SmarTagSettingsWriter.TAP_TO_WRITE
        writeSession?.begin()
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
        stopSessionWithError(readerError.localizedDescription)
       }
   }
   
    private func stopSessionWithError(_ errorStr:String){
        writeSession?.invalidate(errorMessage: errorStr)
    }
    
   public func tagReaderSession(_ session: NFCTagReaderSession, didDetect tags: [NFCTag]) {
       guard let tag = tags.first, case let NFCTag.iso15693(type5Tag) = tag else{
           return
       }
   
       session.connect(to: tag){ error in
        guard error == nil else{
            session.invalidate(errorMessage: SmarTagSettingsWriter.CONNECITON_ERROR)
            return
        }//guard error 
        let parser = SmartTagIso15693Parser(tagIO: SmarTagIOISO15693(type5Tag))
        parser.writeConfiguration(self.configuration){ result in
            if let error = result{
                session.invalidate(errorMessage: error.localizedDescription)
            }else{
                session.alertMessage=SmarTagSettingsWriter.WRITE_COMPLETED
                session.invalidate()
            }//if error
        }//write config
       }//session connect
   }
}


