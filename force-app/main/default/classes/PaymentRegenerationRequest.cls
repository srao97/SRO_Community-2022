/*******************************************************************************************
* @Name         Payment Regeneration Request (VHF-2979)
* @Author       Lavanya Kavuri
* @Date         09/12/2021
* @Description  This class is used for Payment Regeneration Request Lightning web component
*******************************************************************************************/ 
/* MODIFICATION LOG
* Version          Developer          Date               Description
*-------------------------------------------------------------------------------------------
*  1.0              Lavanya Kavuri     09/12/2021          Created      
*  1.1              Lavanya Kavuri      01/02/2022          Updated. AC9 Updated, VHF-4154 
*  1.2              Lavanya Kavuri      11/02/2022          Bugs: VHF-4652, VHF-4653, VHF-4655, VHF-4656                                           
*******************************************************************************************/
public with sharing class PaymentRegenerationRequest {
    
    public static String PAYMENT_ERROR = 'Active payment exists for the property. Cannot create a new payment request.';
    //public static String PAYMENT_ERROR = 'Active payment exists for the property. Cannot create a new payment request';
    public static String SET_NOT_MATCHED_ERROR = 'SEI and SEM has been updated. Create a new case and request payment.';
    public static String VALUATION_ERROR = 'Property valuation is not valid. Create a new case and request payment.';
   
    /*
    *Method: Validate Payment Regeneration Request 
    * @param: recordId
    * @output: Map<String,String> response
    */
    @AuraEnabled
    public static string validateRequest(String paymentRecId){

        Profile sysAdminProfile = [Select Id, Name from Profile where Name = 'System Administrator'];
        Id currentUserProfileId = UserInfo.getProfileId();

        system.debug('record Id coming=' + paymentRecId);
        Map<String,String> responseMap = new Map<String,String>();
        List<String> errorList = new List<String>();

            Payment__c paymentRecord = getPaymentRecord(paymentRecId);

            System.debug('payment record=' + paymentRecord);
            if(paymentRecord != null)
            {

                //is it System admin regenerating the payment record? 
                if(sysAdminProfile.Id == currentUserProfileId)
                {
                    //There is an error in the Payment Processing
                    if(paymentRecord.GatewayResultCode__c != null || paymentRecord.GatewayResultCodeDescription__c != null)
                    {
                        if(paymentRecord.Status__c == 'Created' || paymentRecord.Status__c == 'Payment Registered')
                        {
                            errorList.addAll(doValidations(paymentRecord));
                        }
                        else 
                        {
                            errorList.add('Invalid Request');
                        }
                    }
                    else 
                    {
                        errorList.add('Invalid Request');
                    }
                }
                else 
                {
                    errorList.addAll(doValidations(paymentRecord));
                }
                
            }
            else {
                //Something went wrong in getting the related payment record context. Log an error
                AuraHandledException e = new AuraHandledException('Something went wrong. Please try again later.');
                e.setMessage('Something went wrong. Please try again later.');
                throw e;
            }

            //We have some validation errors. append to response Map
            if(!errorList.isEmpty())
            {
                responseMap.put('errors', JSON.serialize(errorList));
            }
            //No validation errors, send an empty errorlist.
            else 
            {
                responseMap.put('errors', '');
            }  

        return JSON.serialize(responseMap);
    }



    /*
    *Method: Create Payment Regeneration Request 
    * @param: recordId
    * @output: Map<String,String> response
    */
    @AuraEnabled
    public static Payment__c createPaymentRequest(String paymentRecId, String comments) {
        String paymentNumber;
        Payment__c newPaymentRec = new Payment__c();
        Payment__c existingPaymentRecord = getPaymentRecord(paymentRecId);

        newPaymentRec.Case__c = existingPaymentRecord.Case__c;
        newPaymentRec.Property__c = existingPaymentRecord.Property__c;
        newPaymentRec.Primary_Participant__c = existingPaymentRecord.Primary_Participant__c;
        //newPaymentRec.Status__c = 'Payment Registered';
        newPaymentRec.Status__c = 'Created';// Changed to Created status as discussed
        newPaymentRec.Comments__c = existingPaymentRecord.Comments__c;
        newPaymentRec.OwnerId = existingPaymentRecord.OwnerId;
        newPaymentRec.Parent_Payment__c = existingPaymentRecord.Id;
        newPaymentRec.Requested_Date__c=System.today();
        newPaymentRec.Amount__c = existingPaymentRecord.Amount__c;
        newPaymentRec.ByPassValidation__c = true;
        newPaymentRec.Flag_Current_Payment_Regenerated_Record__c=true;
        insert newPaymentRec;

        //Need to get the inserted Payment record again, for the Payment Number 
        Payment__c newPayment = getPaymentRecord(newPaymentRec.Id);

        existingPaymentRecord.ByPassValidation__c = true;
        existingPaymentRecord.Payment_Regenerated__c = true;

        update existingPaymentRecord;

        return newPayment;
    }

    public static Payment__c getPaymentRecord(String paymentRecId) 
    {
        Payment__c paymentRecord = [Select 
                                        Id, Status__c, Payment_Regenerated__c, OwnerId, Comments__c, Name, Case__r.Property_Valuation_Date__c, 
                                        Case__r.SEI_OLD__c,Case__r.SEM_OLD__c, Case__r.SEM_new__c, Property__c, 
                                        GatewayResultCode__c, GatewayResultCodeDescription__c,
                                        Primary_Participant__c,Amount__c,
                                        Property__r.Shared_Equity_Interest__c, 
                                        Property__r.Shared_Equity_Money__c, 
                                        Property__r.Actual_Settlement_Date__c
                                        from Payment__c 
                                        where Id=: paymentRecId
                                        ];
        
        return paymentRecord;
    }

    public static List<String> doValidations(Payment__c paymentRecord)
    {

        List<String> errorMsgList = new List<String>();

        //Check one -> Is Payment regenerated once ? 
        if(paymentRecord.Payment_Regenerated__c) 
        {
            AuraHandledException e = new AuraHandledException('Payment has already been regenerated for this Payment Record.');
            e.setMessage('Payment has already been regenerated for this Payment Record.');
            throw e;
        }
        //No regenerated payment request, proceed to check validations.
        else 
        {
            //Get the list of all Payment Records to check for any active payments in progress.
            List<Payment__c> paymentsList = [Select Id, Status__c 
                                                from Payment__c 
                                                where 
                                                Property__c =: paymentRecord.Property__c
                                                and 
                                                Status__c not in ('Cancelled', 'Request Expired', 'Payment Received')
                                            ];

            //AC1 - Payment Not in Cancelled or Request Expired Status, throw an error
            if(!paymentsList.isEmpty())
            {
                String paymentError;
                for(Payment__c payment: paymentsList)
                {
                    System.debug('Payment Id=' + payment.Id);
                    System.debug('Payment status=' + payment.Status__c);
                    
                    System.debug('why is it coming here?');
                    //If any active payments found, validation failed, add the error message to validation errors.
                    paymentError = PAYMENT_ERROR;
                    
                }
                if(paymentError.length() > 0)
                {
                    errorMsgList.add(paymentError);
                }
                
            }

            //AC2 - Compare SEI SEM Values 
            if(paymentRecord.Case__r.SEI_OLD__c != paymentRecord.Property__r.Shared_Equity_Interest__c || paymentRecord.Case__r.SEM_OLD__c != paymentRecord.Property__r.Shared_Equity_Money__c)
            {
                //SEI and SEM values are not matched from case and property, add the error message to validation errors.
                String paymentError = SET_NOT_MATCHED_ERROR;
                errorMsgList.add(paymentError);
            }

            //AC9 - Valuation not more than 90 days 
            // If Valuation date is null, then check if the Actual Settlement Date on Property is not more than 90 days
            Integer daysBetween;
            if(paymentRecord.Case__r.Property_Valuation_Date__c != null)
            {
                Date valuationDate = paymentRecord.Case__r.Property_Valuation_Date__c;
                Date todaysDate = System.today();
                daysBetween = valuationDate.daysBetween(todaysDate);
                system.debug('days between=' + daysBetween);
            }

            if(paymentRecord.Case__r.Property_Valuation_Date__c == null && paymentRecord.Property__r.Actual_Settlement_Date__c != null)
            {
                Date settlementDate = paymentRecord.Property__r.Actual_Settlement_Date__c;
                Date todaysDate = System.today();
                daysBetween = settlementDate.daysBetween(todaysDate);
                system.debug('days between=' + daysBetween);
            }

            if(daysBetween > 90)
            {
                //Valution out of date, add the error message to validation errors.
                String paymentError = VALUATION_ERROR;
                errorMsgList.add(paymentError);
            }
        }

        return errorMsgList;
    }
}