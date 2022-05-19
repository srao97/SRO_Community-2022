/*******************************************************************************************
* @Name         Property Sale Payout Document (VHF-2789, VHF-4935)
* @Author       Arjun Singh
* @Date         08/03/2022
* @Description  This class is used for Proporty Sale Payout Document generation pre validations and status update 
*******************************************************************************************/ 
/* MODIFICATION LOG
* Version          Developer          Date               Description
*-------------------------------------------------------------------------------------------
*  1.0              Arjun Singh       08/03/2022          Created  
*******************************************************************************************/
/**
 * @Description : Property Sale Payout document generation pre validations
 */
public with sharing class PropertySalePayoutDocumentPreChecks {
    public static String AWAITING_SETTLEMENT_STATUS = 'Awaiting Settlement';
    public static String CALCULATE_PIA_MSG = 'the results of the Proportional Interest Amount calculator have not been saved to the case';
    public static String AWAITIING_SETTLEMENT_MSG = 'the Payout Document has already been created';  
    public static String VHF_PROPERTYSALE_QUEUE_DEVELOPERNAME = 'Property_Sale_VGSO_queue';

    @AuraEnabled
    public static string validateRequest(String caseId){
        String validationMsg ;
        if(caseId != null){  
            validationMsg = 'GenerateDocument' ;          
            Case caseRecord = [SELECT Id, status, Proportionate_interest_amount__c FROM Case where Id =: caseId];
            if(String.isEmpty(String.valueOf(caseRecord.Proportionate_interest_amount__c))){
                validationMsg = CALCULATE_PIA_MSG;
            }else if(caseRecord.status == AWAITING_SETTLEMENT_STATUS){
                validationMsg = AWAITIING_SETTLEMENT_MSG;
            }
        }
        return validationMsg;
    }
    /**
     * @Description: Update Property Sale case status and owner for Payout document generation process to trigger.
     */
    @AuraEnabled
    public static String updatePropertySaleCase(String caseId){
       String updateSuccessMsg = 'false';
        try{
            Group propertySaleVGSOQueue = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperNAME =: VHF_PROPERTYSALE_QUEUE_DEVELOPERNAME];
            if(propertySaleVGSOQueue.Id != null){
                Case caseRecord = [SELECT Id, status, OwnerId, BypassValidation__c FROM Case where Id =: caseId];
                caseRecord.status = AWAITING_SETTLEMENT_STATUS;
                caseRecord.OwnerId = propertySaleVGSOQueue.Id;
                caseRecord.BypassValidation__c = true;
                update caseRecord ;
                updateSuccessMsg = 'true';
            }
        }catch(Exception e){
            updateSuccessMsg = e.getTypeName() + ' - ' + e.getMessage();
        }
        //updateSuccessMsg = 'Could not update Case status';
        return updateSuccessMsg;
    }
}