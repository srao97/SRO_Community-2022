/*******************************************************************************************
* @Name         updateAnnualReviewTaskTriggerHelper 
* @Author       Suresh Manukonda <suresh.manukonda@salesforce.com >
* @Date         17/09/2021
* @Description  
*******************************************************************************************/
/* MODIFICATION LOG
* Version          Developer          Date               Description
*-------------------------------------------------------------------------------------------
*  1.0              Suresh      17/09/2021          Initial Creation  
*  1.1              Sebastian   01/11/2021          Added logic to ensure bypassed records are
                                                    locked after use                                 
*******************************************************************************************/
public without sharing class updateAnnualReviewTaskTriggerHelper {
    public static List<Id> updateAnnualReview(list<task> newList){
        set<id> annualReviewRecsSet = new set<id>();
        set<id> notToUpdateSet = new set<id>();
        list<Annual_Review__c> annualReviewsList = new list<Annual_Review__c>();
        map<id, list<task>> ARRTaskMap = new map<id, list<task>>();
        Id recordTypeId = Schema.SObjectType.Annual_Review__C.getRecordTypeInfosByName().get('Annual Review ReadOnly').getRecordTypeId();
        
        for(task updatedTask: newList){
            if(updatedTask.status == 'Completed'){
                annualReviewRecsSet.add(updatedTask.whatId);
            }
        }
        
        list<task> taskList = [Select id, status, whatId from Task where whatId IN :annualReviewRecsSet];
    
        for(task tsk:taskList){
            if(ARRTaskMap.containsKey(tsk.whatId)){
                ARRTaskMap.get(tsk.whatId).add(tsk);
            } else {
                ARRTaskMap.put(tsk.whatId, new list<task>{tsk});
            }
        }
        
        for(Id id :ARRTaskMap.keyset()){
            for(task tsk:ARRTaskMap.get(id)){
                if(tsk.status == 'Open'){
                    notToUpdateSet.add(tsk.whatId);
                    Break;
                }
            }
        }
        
        if(!ARRTaskMap.isEmpty()){
            for(Annual_Review__c AR : [select id, status__c from Annual_Review__c where id IN :ARRTaskMap.keyset() AND id NOT IN :notToUpdateSet]){
                //VHF-2925 - updated by Lawrence Tang -  Check if status is currently cancelled
                if (AR.status__c != 'Cancelled'){
                    AR.BypassValidation__c = true;
                	AR.status__c = 'Submitted';
                	AR.RecordTypeId = recordTypeId;
                	annualReviewsList.add(AR);
                }
            }
        }

        List<Id> bypassedAnnualReviews = new list<Id>();
        
        if(!annualReviewsList.isEmpty()){
            update annualReviewsList;
            for(Annual_Review__c annualReview: annualReviewsList){
                bypassedAnnualReviews.add(annualReview.Id);
            }
        }

        return bypassedAnnualReviews;
    }

    /* VHF-2982: Reset bypass flag to false */
    public static void resetBypassAfterUpdate(List<Id> annualReviews){
        system.debug('Reset Bypassed Annual Reviews='+annualReviews);
        list<Annual_Review__c> annualReviewsToUpdate = [SELECT Id, bypassvalidation__c FROM Annual_Review__c WHERE Id IN :annualReviews AND BypassValidation__c = true];
        if(!annualReviewsToUpdate.isEmpty()){
            for(Annual_Review__c annualReview: annualReviewsToUpdate)
                annualReview.BypassValidation__c = false;
            update annualReviewsToUpdate;
        }
    }
}