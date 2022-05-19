/*
* Contract Trigger 
* Author: Lavanya Kavuri (lkavuri@salesforce.com)
** Version History ** 
Create Date:
Modified: Lavanya Kavuri, 28 Sep 2021, VHF-1900
Sourabh Singh, 11/Oct/2021, VHF-2596  
Sourabh Singh, 31/Oct/2021, VHF-2892 
*/ 
trigger ContractTrigger on Contract (after undelete, before delete, after insert, before update,before insert, after update) {
    
    if((Trigger.isUpdate || Trigger.isInsert) && Trigger.isBefore){   
        if(!CheckRecursive.firstcall) {
            CheckRecursive.firstcall = true;
            ContractTriggerHelper.ValidatePlanLotFolioVolume(Trigger.new);
            ContractTriggerHelper.UpdateLandIdentifiersToUpcase(Trigger.new);
            ContractTriggerHelper.validateStatusBeforeUpdate(Trigger.new);//VHF-2596
        }
    }
    
    if(trigger.isAfter)
    {
        ContractTriggerHelper.resetBypassAfterUpdate(Trigger.new);//VHF-2892
    }
    
}