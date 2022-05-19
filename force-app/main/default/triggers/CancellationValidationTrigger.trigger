/*
 * Cancellation Validation Trigger 
 * Author: Lawrence Tang (lawrence.tang@salesforce.com)
 ** Version History ** 
 Create Date: 18 Oct 2021, VHF-2598
*/ 
trigger CancellationValidationTrigger on Annual_Review__c (before update, after update) { 
    
    //if(!CheckRecursive.firstcall){
        //CheckRecursive.firstCall = true;

    if (Trigger.isBefore){
        List<Annual_Review__c> arWithActiveCases =
            [SELECT Id FROM Annual_Review__c WHERE Id IN (
                SELECT Annual_Review__c FROM Case WHERE isClosed = False AND
                    Annual_Review__c IN :Trigger.New)];

        for (Annual_Review__c ar : arWithActiveCases) {
            Annual_Review__c newRecord = Trigger.newMap.get(ar.Id);
            if (newRecord.Status__c == 'Cancelled') {
                newRecord.addError('Annual Review cannot be cancelled as there are active related cases');
            }
        }
    }
    else if(Trigger.isAfter){
            list<Annual_Review__c> annualReviewsToUpdate = [SELECT Id, bypassvalidation__c FROM Annual_Review__c WHERE Id IN :Trigger.new AND BypassValidation__c = true];
            if(!annualReviewsToUpdate.isEmpty()){
                for(Annual_Review__c annualReview: annualReviewsToUpdate)
                   annualReview.BypassValidation__c = false;
                update annualReviewsToUpdate;
            }
        }
    //}
}