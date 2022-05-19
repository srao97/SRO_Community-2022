/*******************************************************************************************
* @Name         taskTrigger 
* @Author       Suresh Manukonda <suresh.manukonda@salesforce.com >
* @Date         17/09/2021
* @Description  
*******************************************************************************************/
/* MODIFICATION LOG
* Version          Developer          Date               Description
*-------------------------------------------------------------------------------------------
*  1.0              Suresh      17/09/2021          Initial Creation
*  1.1              Sebastian   01/11/2021          VHF-2982 Logic to remove validation bypass granted
                                                    by this class     
*  1.2              Arjun       18/11/2021          VHF-3072 Reassign Provisional approval extended task to Provisional Application                                                                                              
*******************************************************************************************/
trigger taskTrigger on Task (before insert, after update) {

    List<Id> bypassedAnnualReviews = new List<Id>();
    
    if(trigger.isAfter && trigger.isUpdate){
        if(!CheckRecursive.firstcall){
            CheckRecursive.firstCall = true;
            bypassedAnnualReviews = updateAnnualReviewTaskTriggerHelper.updateAnnualReview(trigger.new);


            if(!bypassedAnnualReviews.isEmpty()){
                updateAnnualReviewTaskTriggerHelper.resetBypassAfterUpdate(bypassedAnnualReviews); // VHF-2982
            }
        }
    }
    if(trigger.isBefore && trigger.isInsert){
        taskTriggerHelper.reAssignProvisionalApplicationExtensionTasks(trigger.new);
    }
}