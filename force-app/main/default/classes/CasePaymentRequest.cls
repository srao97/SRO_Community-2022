/*******************************************************************************************
* @Name         Case Payment Request (VHF-3129, VHF-2002)
* @Author       Lavanya Kavuri
* @Date         17/12/2021
* @Description  This class is used for case payment request LWC.
*******************************************************************************************/ 
/* MODIFICATION LOG
* Version          Developer          Date               Description
*-------------------------------------------------------------------------------------------
*  1.0              Lavanya Kavuri     17/12/2021          Created  
*  1.1              Sourabh			   17/1/2022      Updated: Added 'Payment Received' as 
*													  inactive status
*  1.2              Lavanya Kavuri     28/1/2022      Added Final Payment Status - VHF-2002	
*  1.3              Lavanya Kavuri     23/03/2022     Added ITE Case Type - VHF-4312   	
*******************************************************************************************/
public with sharing class CasePaymentRequest {

    public static String ACTIVE_PAYMENT_ERROR = 'An active payment exists for the property';
    public static String PAYMENT_NOT_ELIGIBLE = 'The payment is not eligible. Please review calculation details';
    public static String NOT_IN_SYNC = 'The SEM and SEI not in sync with Property record. Please re-calculate and request payment';
    public static String NO_WINDFALL_CALCULATION = 'An updated SEI has not been calculated and the payment eligibility has not been determined';
    public static String NO_FINAL_CALCULATION = 'The final payment amount has not been calculated';
    public static String NO_REFINANCE = 'The loan refinance has not been approved';
    public static String WINDFALL_RECORD_TYPE_ID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Windfall_Gains').getRecordTypeId();
    public static String FINAL_PAYMENT_RECORD_TYPE_ID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Final_Payment').getRecordTypeId();
    public static String VOLUNTARY_PAYMENT_RECORD_TYPE_ID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Voluntary_Payments').getRecordTypeId();
    public static String ITE_CASE_TYPE_RECORD_TYPE_ID   = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Income_Threshold_Exceeded').getRecordTypeId();
    /*
    *Method: Validate Payment Regeneration Request 
    * @param: recordId
    * @output: Map<String,String> response
    */
    @AuraEnabled
    public static string validateRequest(String caseId){
        Map<String,String> responseMap = new Map<String,String>();
        List<String> errorMsgList = new List<String>();

        /*
            Step1: Check the below to allow 
            1. SEI has been calculated and results saved 
            2. 'Payment Eligible' field = yes 
            3. SEI(old) and SEM(old) values saved in the respective case are in sync with the property record. 
            4. No active payment records exist for the property
        */
        Case caseRecord = getCaseRecord(caseId); 

        //(VHF-3129 , AC1.1), (VHF-2002, AC2 )
        // Active payments exists for the property. Cannot proceed.
        List<Payment__c> paymentsList = [Select Id, Status__c 
                                                        from Payment__c 
                                                        where 
                                                        Property__c =: caseRecord.Property__c
                                                        and 
                                                        Status__c not in ('Cancelled', 'Request Expired', 'Payment Received')
                                                    ];
        
        
        /*
        * Common Scenario
        */ 

        if(!paymentsList.isEmpty())
        {
            System.debug('payment list exists');
            //String paymentError = ACTIVE_PAYMENT_ERROR;
            errorMsgList.add(ACTIVE_PAYMENT_ERROR);
        }

        //(VHF-3129, AC 1.3), (VHF-2002, AC3)
        //Not in Sync with Property 
        if(caseRecord.SEI_OLD__c != caseRecord.Property__r.Shared_Equity_Interest__c || caseRecord.SEM_OLD__c != caseRecord.Property__r.Shared_Equity_Money__c )
        {
            system.debug('sei sem not matching');
            //String notInSync = NOT_IN_SYNC;
            errorMsgList.add(NOT_IN_SYNC);
        }

        /*
        * Windfall Gains / Voluntary payments Scenario / ITE Type
        */ 

        if(caseRecord.RecordTypeId == WINDFALL_RECORD_TYPE_ID || caseRecord.RecordTypeId == VOLUNTARY_PAYMENT_RECORD_TYPE_ID || caseRecord.RecordTypeId == ITE_CASE_TYPE_RECORD_TYPE_ID)
        {
            system.debug('windfall gains / voluntary paymentrecord type / ITE record type');
            //(VHF-3129, AC 1.2) - Payment Ineligible 
            if(caseRecord.Payment_Eligible__c == 'No' || caseRecord.Payment_Eligible__c == null)
            {
                system.debug('payment not eligible');
                //String notEligibleError = PAYMENT_NOT_ELIGIBLE;
                errorMsgList.add(PAYMENT_NOT_ELIGIBLE);
            }

            //AC 1.4 - No Windfall Calulcation done 
            if(caseRecord.SEI_new__c == null || caseRecord.SEM_new__c == null)
            {
                system.debug('no windfall calculation');
                errorMsgList.add(NO_WINDFALL_CALCULATION);
            }
        }

        /*
        * Final Payment Scenario
        */ 
        if(caseRecord.RecordTypeId == FINAL_PAYMENT_RECORD_TYPE_ID)
        {
            system.debug('final payment record type');
            //(VHF-2002, AC4) - No Final Payment Calculation 
            if(caseRecord.Proportionate_interest_amount__c == null || caseRecord.Payment_Amount__c == null)
            {
                system.debug('no final payment calculation');
                errorMsgList.add(NO_FINAL_CALCULATION);
            }

        }

        /*
        * ITE Type Scenario
        */
        if(caseRecord.RecordTypeId == ITE_CASE_TYPE_RECORD_TYPE_ID)
        {
            system.debug('ITE payment record type');
            if(caseRecord.Refinance_Approved__c == 'No')
            {
                system.debug('refinanced not approved');
                errorMsgList.add(NO_REFINANCE);
            }
        }
        
        
        if(!errorMsgList.isEmpty())
        {
            responseMap.put('errors', JSON.serialize(errorMsgList));
        }
        else 
        {
            responseMap.put('errors', '');
        }
        
        return JSON.serialize(responseMap);
    }

    /*
    * Update the case with status = payment requested
    */

    @AuraEnabled
    public static Case updateCase(string caseId, String comments) 
    { 
        System.debug('coming into udpate case');
        System.debug('case Id=' + caseId);
        System.debug('case comments=' + comments);
        Case updateCase = getCaseRecord(caseId);
        updateCase.Payment_Comments__c = comments;
        updateCase.BypassValidation__c = true; 
        updateCase.Status = 'Payment Requested';
        System.debug('udpateCase=' + updateCase);
        update updateCase;

        System.debug('case after updated-' + updateCase);
        return updateCase;
    }


    public static Case getCaseRecord(String caseId)
    {
        Case caseRec = [Select 
                        Id, Payment_Eligible__c, SEI_new__c, SEI_OLD__c, SEM_new__c, SEM_OLD__c, Payment_Comments__c,
                        RecordTypeId, Property__c, BypassValidation__c, Property__r.Shared_Equity_Interest__c, 
                        Property__r.Shared_Equity_Money__c, Payment_Amount__c, Proportionate_interest_amount__c,
                        Refinance_Approved__c
                        from Case where Id =: caseId];

                        System.debug('case record =' + caseRec);
        return caseRec;
    }
}