/**
 * Class Name  : FinalAppTrigger
 * @author       Sourabh Singh
 * @version      $Revision: 1.0 $, $Date: 9/Sep/2021
 */
trigger FinalAppTrigger on Contract (before update) 
{
   if(trigger.isbefore && trigger.isupdate)
         {
           FinalAppTriggerHandler.processUpdates(trigger.newmap, trigger.oldmap);
         }
}