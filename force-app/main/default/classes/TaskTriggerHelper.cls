/*******************************************************************************************
* @Name         TaskTriggerHelper 
* @Author       Arjun Singh
* @Date         18/11/2021
* @Description  : Handler of task trigger event
*******************************************************************************************/
/* MODIFICATION LOG
* Version          Developer          Date               Description
*-------------------------------------------------------------------------------------------
*  1.0              Arjun            18/11/2021          Initial Creation                                 
*******************************************************************************************/
public with sharing class TaskTriggerHelper {
    /**
     * @Description : Reassign the Provisional approval extended task to related parent provisional application
     */
    public static void reAssignProvisionalApplicationExtensionTasks(list<task> newList){
        Set<Id> shadowApplicationSets = new Set<Id>();
        Map<Id,Id> shadowWithProvisionalApplicationMap = new Map<Id,Id>();
        for(task tsk : newList){
            if(tsk.subject != null && tsk.subject.contains('Provisional approval extended')){
                shadowApplicationSets.add(tsk.whatId);
            }
        }
        for(Individual_Application_Shadow__c shadowRecord : [Select Id, Individual_Application__c From Individual_Application_Shadow__c Where Id IN : shadowApplicationSets]){
            shadowWithProvisionalApplicationMap.put(shadowRecord.Id, shadowRecord.Individual_Application__c);
        }
        for(task tsk : newList){
            if(shadowWithProvisionalApplicationMap.containsKey(tsk.whatId)){
                tsk.whatId = shadowWithProvisionalApplicationMap.get(tsk.whatId); 
            }
        }

    }
}