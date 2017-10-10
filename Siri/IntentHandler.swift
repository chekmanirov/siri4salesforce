//
//  IntentHandler.swift
//  Siri
//
//  Created by Kevin Me on 2017-09-25.
//  Copyright © 2017 Salesforce. All rights reserved.
//

import Intents
import ApiAI

class IntentHandler: INExtension {
    
    override func handler(for intent: INIntent) -> Any {
        return self
    }
    
    
    
}

extension IntentHandler : INAddTasksIntentHandling {
    
    public func handle(intent: INAddTasksIntent,
                       completion: @escaping (INAddTasksIntentResponse) -> Swift.Void) {
        
        print("Create task: ", intent)
        
        let configuration: AIConfiguration = AIDefaultConfiguration()
        configuration.clientAccessToken = "7d60e385ee7d4e089a9986368a59b2a8"
        let apiai = ApiAI.shared()
        apiai?.configuration = configuration
        
        var addedTasks:[INTask] = []
         for title in intent.taskTitles!{
         let newTask = INTask(
                title: title,
                status: .notCompleted,
                taskType: .completable,
                spatialEventTrigger: nil,
                temporalEventTrigger: nil,
                createdDateComponents: nil,
                modifiedDateComponents: nil,
                identifier: nil)
            
            let taskQuery = title.spokenPhrase
            print(taskQuery)
            
            let request = ApiAI.shared().textRequest()
             request?.query = [taskQuery]
            

            request?.setCompletionBlockSuccess({ (request, response) in
                let response = response as! AnyObject?
                print("resp2: ", response)
            },
                                     failure: {(request, error)
                                        in print(error)
            })
            
            ApiAI.shared().enqueue(request)
         
         addedTasks.append(newTask)
         }
        
        
        let response = INAddTasksIntentResponse(code: .success, userActivity: nil)
        completion(response)
    }
    
}
