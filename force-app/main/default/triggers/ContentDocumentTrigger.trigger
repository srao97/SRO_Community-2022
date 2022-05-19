/**
 * Class Name  : ContentDocumentTrigger
 * @author       Sourabh Singh
 * @version      $Revision: 1.0 $, $Date: 9/Sep/2021
 */

trigger ContentDocumentTrigger on ContentDocument (before delete) 
{
    if(trigger.isDelete)
         {
           ContentDocumentTriggerHandler.deleteContentDocuments(trigger.old);
        }
}