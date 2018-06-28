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

public class SmarTagMainViewController : UIViewController,NFCNDEFReaderSessionDelegate{
    
    private static let NFC_READ_MESSAGE = {
        return  NSLocalizedString("You can scan NFC-tags by holding them behind the top of your iPhone.",
                                  tableName: nil,
                                  bundle: Bundle(for: SmarTagMainViewController.self),
                                  value: "You can scan NFC-tags by holding them behind the top of your iPhone.",
                                  comment: "You can scan NFC-tags by holding them behind the top of your iPhone.");
    }()

    private static let INVALID_NFC_TITLE = {
        return  NSLocalizedString("Error reading the tag",
                                  tableName: nil,
                                  bundle: Bundle(for: SmarTagMainViewController.self),
                                  value: "Error reading the tag",
                                  comment: "Error reading the tag");
    }()
    
    private static let INVALID_NFC_MESSAGE = {
        return  NSLocalizedString("SmarTag record not found",
                                  tableName: nil,
                                  bundle: Bundle(for: SmarTagMainViewController.self),
                                  value: "SmarTag record not found",
                                  comment: "SmarTag record not found");
    }()
    
    private static let SHOW_CONTENT_SEGUE = "SmarTag_showTagContent"
    
    private var readerSession:NFCNDEFReaderSession?
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden=true
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.isNavigationBarHidden=false
    }
    
    private func startReadNDef(){
        readerSession = NFCNDEFReaderSession(delegate: self,queue: nil,invalidateAfterFirstRead: true)
        readerSession?.alertMessage = SmarTagMainViewController.NFC_READ_MESSAGE
        readerSession?.begin()
    }
    
    @IBAction func onReadNfcButtonClicked(_ sender: UIButton) {
        #if targetEnvironment(simulator)
            let data = SmarTagNDefParserFake()
            self.performSegue(withIdentifier: SmarTagMainViewController.SHOW_CONTENT_SEGUE, sender: data)
        #else
            startReadNDef()
        #endif
    }
    
    public func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
        guard let readerError = error as? NFCReaderError else {
            return
        }
        switch readerError.code {
            case .readerSessionInvalidationErrorFirstNDEFTagRead, .readerSessionInvalidationErrorUserCanceled:
                break
            default:
                DispatchQueue.main.async {
                    self.showErrorMessage(title: SmarTagMainViewController.INVALID_NFC_TITLE,
                                          message: error.localizedDescription)
                }
            
        }
    
        print("Error Reading Tag",error.localizedDescription)
    }
    
    private func checkCorrectNdef(messages: [NFCNDEFMessage]) -> SmarTagNdefParserPotocol?{
        if let message = messages.first {
            let record = message.records.first{ rec in
                let type = String(data: rec.type, encoding: .utf8)
                return rec.typeNameFormat == .nfcExternal && type == "st.com:smartag"
            }
            if let rec = record{
                return try? SmarTagNDefParserV1(rawData: rec.payload);
            }
        }
        return nil
    }
    
    public func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
        let smarTagData = checkCorrectNdef(messages: messages)
        DispatchQueue.main.async {
            if let data = smarTagData{
                self.performSegue(withIdentifier: SmarTagMainViewController.SHOW_CONTENT_SEGUE, sender: data)
            }else{
                self.showErrorMessage(title: SmarTagMainViewController.INVALID_NFC_TITLE,
                                      message: SmarTagMainViewController.INVALID_NFC_MESSAGE)
            }//if-else
        }// main queue
    }
    
    public override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if var contentViewController = segue.destination as? SmarTagObjectWithTag,
            let data = sender as? SmarTagNdefParserPotocol{
            contentViewController.tagContent = data;
        }
    }
    
}
