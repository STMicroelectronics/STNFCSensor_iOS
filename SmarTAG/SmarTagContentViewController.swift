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
import MessageUI
 
import UIKit

public class SmarTagContentViewController : UITabBarController,SmarTagObjectWithTag{
    
    public var tagContent:SmarTagNdefParserPotocol?=nil

    
    public override func viewDidLoad() {
        addSaveBarButton()
    }
    
    private func addSaveBarButton(){
        navigationItem.rightBarButtonItem  = UIBarButtonItem(barButtonSystemItem: .save,
                                                             target: self,
                                                             action: #selector(saveReadData))
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        //set the tag content for the sub view
        viewControllers?.forEach{ viewController in
            if var contentViewController = viewController as? SmarTagObjectWithTag,
                let data = tagContent{
                contentViewController.tagContent = data;
            }//if
        }//for each
        //display the subview
        super.viewWillAppear(animated)
    }
    
    @objc private func saveReadData(){
        tagContent?.exportToCSV{ data in
            self.sendMailWithAttachCSV(data)
        }
    }
}

 extension SmarTagContentViewController : MFMailComposeViewControllerDelegate{
    
    private static let FILE_DATE_FORMATTER:DateFormatter = {
        let dateForamtter = DateFormatter()
        dateForamtter.dateFormat = "dd-MMM-yy_HHmmss"
        return dateForamtter
    }()
    
    private static let MAIL_OBJECT = {
        return  NSLocalizedString("[ST SmarTag] Export data",
                                  tableName: nil,
                                  bundle: Bundle(for: SmarTagContentViewController.self),
                                  value: "[ST SmarTag] Export data",
                                  comment: "[ST SmarTag] Export data");
    }()
    
    private static let MAIL_CONTENT = {
        return  NSLocalizedString("SmarTag data",
                                  tableName: nil,
                                  bundle: Bundle(for: SmarTagContentViewController.self),
                                  value: "SmarTag data",
                                  comment: "SmarTag data");
    }()
    
    private static let MAIL_SENT_DIALOG_TITLE = {
        return  NSLocalizedString("Export Data",
                                  tableName: nil,
                                  bundle: Bundle(for: SmarTagContentViewController.self),
                                  value: "Export Data",
                                  comment: "Export Data");
    }()
    
    private static let MAIL_SENT_DIALOG_SUCCESS = {
        return  NSLocalizedString("Your message has been sent.",
                                  tableName: nil,
                                  bundle: Bundle(for: SmarTagContentViewController.self),
                                  value: "Your message has been sent.",
                                  comment: "Your message has been sent.");
    }()
    
    private static let MAIL_SENT_DIALOG_FAIL = {
        return  NSLocalizedString("Your email was not sent",
                                  tableName: nil,
                                  bundle: Bundle(for: SmarTagContentViewController.self),
                                  value: "Your email was not sent",
                                  comment: "Your email was not sent");
    }()
    
    private func getFileName()->String{
        return String(format:"SmarTag_%@.csv",
                      SmarTagContentViewController.FILE_DATE_FORMATTER.string(from: Date()))
    }
    
    func sendMailWithAttachCSV(_ data:Data){
        guard MFMailComposeViewController.canSendMail() else {
            return;
        }
        let mail = MFMailComposeViewController()
        mail.mailComposeDelegate = self;
        mail.setSubject(SmarTagContentViewController.MAIL_OBJECT)
        mail.setMessageBody(SmarTagContentViewController.MAIL_CONTENT, isHTML: false)
        mail.addAttachmentData(data, mimeType: "text/plain", fileName: getFileName())
        present(mail, animated: true, completion: nil)
    }
    
    public func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
        switch result {
            case .sent:
                showErrorMessage(title: SmarTagContentViewController.MAIL_SENT_DIALOG_TITLE, message: SmarTagContentViewController.MAIL_SENT_DIALOG_SUCCESS)
                break;
            case .failed:
                showErrorMessage(title: SmarTagContentViewController.MAIL_SENT_DIALOG_TITLE, message: SmarTagContentViewController.MAIL_SENT_DIALOG_FAIL)
                break;
            case .saved, .cancelled:
                break;
        }
        
    }
    
 }
 
