/*
* Provisional Application Trigger 
** Version History ** 
Created: Sourabh Singh, 19/11/2021

*/ 
trigger provAppTrigger on IndividualApplication (after insert, after update) 
{
  if(trigger.isAfter)
    {
       if(!CheckRecursive.firstcall) 
       {
         CheckRecursive.firstcall = true;
         ProvAppTriggerHelper.resetBypassAfterUpdate(Trigger.new);
       }
    }
}