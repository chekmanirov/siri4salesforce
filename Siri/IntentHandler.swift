//
//  IntentHandler.swift
//  Siri
//
//  Created by Kevin Me on 2017-09-25.
//  Copyright © 2017 Salesforce. All rights reserved.
//

import Intents
import SalesforceSDKCore
import ApiAI

let RemoteAccessConsumerKey = "3MVG9g9rbsTkKnAXwcNp__EJ6cU.lil4mXOXF9Y7up2YqLqojSyaOHIQ_GyFZNAzo_qt9VKdA.E2GOhc.Djrq";
let OAuthRedirectURI        = "salesforce://auth/success";

class IntentHandler: INExtension {
    
    override func handler(for intent: INIntent) -> Any {
        return self
    }
    
    
    
}

extension IntentHandler : INAddTasksIntentHandling, SFRestDelegate {
    
    public func handle(intent: INAddTasksIntent,
                       completion: @escaping (INAddTasksIntentResponse) -> Swift.Void) {
        
        SFSDKDatasharingHelper.sharedInstance().appGroupName = "group.com.kevinme.Salesforce"
        SFSDKDatasharingHelper.sharedInstance().appGroupEnabled = true;
        
        SalesforceSDKManager.shared().connectedAppId = RemoteAccessConsumerKey
        SalesforceSDKManager.shared().connectedAppCallbackUri = OAuthRedirectURI
        SalesforceSDKManager.shared().authScopes = ["web", "api"];
        
        let defaults = UserDefaults(suiteName: "group.com.kevinme.Salesforce")
        defaults?.synchronize()

        
        print("Create task: ", intent)
        
        let configuration: AIConfiguration = AIDefaultConfiguration()
        configuration.clientAccessToken = "7d60e385ee7d4e089a9986368a59b2a8"
        let apiai = ApiAI.shared()
        apiai?.configuration = configuration
        
        var addedTasks:[INTask] = []
         for title in intent.taskTitles!{
            
            let taskQuery = title.spokenPhrase
            print(taskQuery)
            
            let ApiAIRequest = ApiAI.shared().textRequest()
             ApiAIRequest?.query = [taskQuery]
            

            ApiAIRequest?.setCompletionBlockSuccess({ (request, response) in
                let response = response as AnyObject?
                print("resp2: ", response)
                
                
                let targetRecord = "Lauren Boyle"
                let subject = "discuss a new project"
                let taskDate = "2017-11-11"
                let sfQuery = "{\"targetRecord\":\"" + targetRecord + "\","
                    + "\"subject\":\"" + subject + "\","
                    + "\"dueDate\":\"" + taskDate + "\","
                    + "\"status\":\"incomplete\"}"
                
                
                let sfRequest = SFRestRequest(method: .POST,
                                              path:"/services/apexrest/Siri/",
                                              queryParams: nil)
                sfRequest.endpoint = ""
                sfRequest.setCustomRequestBodyData(sfQuery.data(using: .utf8)!, contentType: "application/json")
                
                print("before salesforce request")
                SFRestAPI.sharedInstance().send(sfRequest, delegate: sfDelegate());
                print("after salesforce request")
                
                
            },
                                     failure: {(request, error)
                                        in print(error)
            })
            
            ApiAI.shared().enqueue(ApiAIRequest)
            
            let newTask = INTask(
                title: title,
                status: .notCompleted,
                taskType: .completable,
                spatialEventTrigger: nil,
                temporalEventTrigger: nil,
                createdDateComponents: nil,
                modifiedDateComponents: nil,
                identifier: nil)
            
         addedTasks.append(newTask)
         }
        
        
        let response = INAddTasksIntentResponse(code: .success, userActivity: nil)
        response.addedTasks = addedTasks
        completion(response)
    }
    
    class sfDelegate: NSObject, SFRestDelegate {
        
        func request(_ request: SFRestRequest, didLoadResponse jsonResponse: Any)
        {
            print(jsonResponse)
        }
        
        func request(_ request: SFRestRequest, didFailLoadWithError error: Error)
        {
            SFSDKLogger.sharedDefaultInstance().log(type(of:self), level:.debug, message:"didFailLoadWithError: \(error)")
            // Add your failed error handling here
        }
        
        func requestDidCancelLoad(_ request: SFRestRequest)
        {
            SFSDKLogger.sharedDefaultInstance().log(type(of:self), level:.debug, message:"requestDidCancelLoad: \(request)")
            // Add your failed error handling here
        }
        
        func requestDidTimeout(_ request: SFRestRequest)
        {
            SFSDKLogger.sharedDefaultInstance().log(type(of:self), level:.debug, message:"requestDidTimeout: \(request)")
            // Add your failed error handling here
        }
        
    }
}
