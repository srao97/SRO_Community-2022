/*
* Case Trigger 
** Version History ** 
Created: Sourabh Singh, 10/12/2021
*******************************************************************************************/
/* MODIFICATION LOG
 * Version          Developer          Date               Description
 *-------------------------------------------------------------------------------------------
*  1.1             Arjun Singh        03/02/2022          VHF-3082
*  1.2             Manish             21/03/2022          VHF-4306
*/ 
trigger caseTrigger on Case (before insert, before update, after insert, after update) 
{
  if(trigger.isBefore){
    if(trigger.isInsert || trigger.isUpdate){
      CaseTriggerHelper.calculateValidAbsenceMonths(trigger.new);
    }
    if(trigger.isUpdate){
      CaseTriggerHelper.finalPaymentCaseValidation(trigger.new, trigger.oldMap);
      CaseTriggerHelper.finalPaymentCaseValidation_Cancellation(trigger.new, trigger.oldMap);
      CaseTriggerHelper.ITE_CaseValidation_Cancellation(trigger.new, trigger.oldMap);
    }
  }
      

  if(trigger.isAfter)
      {
        if(trigger.isUpdate)
        {    
          if(!CheckRecursive.firstcall) 
            {
             CheckRecursive.firstcall = true;
             CaseTriggerHelper.resetBypassAfterUpdate(Trigger.new);
            }
        }
        else if(trigger.isInsert)
            CaseTriggerHelper.resetBypassAfterUpdate(Trigger.new);
      }
}