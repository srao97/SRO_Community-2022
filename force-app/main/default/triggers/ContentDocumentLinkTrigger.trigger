/*******************************************************************************************
* @Name         ContentDocumentLinkTrigger 
* @Author       Sebastian Anton <santon@salesforce.com>
* @Date         31/08/2021
* @Description  Triggered on Content Document Link
*******************************************************************************************/
/* MODIFICATION LOG
* Version          Developer          Date               Description
*-------------------------------------------------------------------------------------------
*  1.0              Sebastian      31/08/2021          Initial Creations		 
*******************************************************************************************/
trigger ContentDocumentLinkTrigger on ContentDocumentLink (before insert,after insert,before delete) {
    
    if(trigger.isInsert){
        if(trigger.isBefore){
            for(ContentDocumentLink cdl : Trigger.new){ 
                cdl.Visibility = 'AllUsers'; 
            }
            ContentDocumentLink_TriggerHelper.verifyParticapantFileUploadAccess(Trigger.new);
        }
        if(trigger.isAfter){
            ContentDocumentLink_TriggerHelper.congaFileLinkToCase(Trigger.new);
            //Disabled for bug vhf-3423 which is blocking email sending with attachments
            ContentDocumentLink_TriggerHelper.restrictFileExtensionUpload(Trigger.new);
        }
    }
}