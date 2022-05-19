/*******************************************************************************************
* @Name         PopulateEndPaymentDateOnProperty 
* @Author       Pradeep Selvaraj
* @Date         13/04/2022
* @Description  : Called from flow - "Case Post Settlement Logic". Updates the Property record's 'End Payment Date' based on changes to the Refinance Case record 
*******************************************************************************************/
/* MODIFICATION LOG
* Version          Developer          Date               Description
*-------------------------------------------------------------------------------------------
*  1.0             Pradeep            13/04/2022          Initial Creation                                 
*******************************************************************************************/


public class PopulateEndPaymentDateOnProperty {
    
    
    @InvocableMethod(label='Set End Payment Date' description='Updates the Property record\'s \'End Payment Date\' based on changes to the Refinance Case record ')
    public static void createEnrolments(List<EndPaymentDateActionRequest> actionRequests){
        
        //construct a map of property id & End Payment date 
        Map<ID,date> propertyIdEndDateMap= new map<ID,date>();
        for(EndPaymentDateActionRequest actionRequest : actionRequests){
            if(actionRequest.isLoanMaturityExtendedDueToHardship){
                propertyIdEndDateMap.put(actionRequest.propertyId, actionRequest.refinancedLoanMaturityDate.addDays(60));
            }else {
                Date endDate = getEarlierDate(actionRequest.actualSettlementDate, actionRequest.refinancedLoanMaturityDate);
                propertyIdEndDateMap.put(actionRequest.propertyId, endDate);
            }
            
        }
        
        set<ID> propertyIds = propertyIdEndDateMap.keyset();
        List<Order> properties = [select id, End_Payment_Date_Override__c  from order where id IN :propertyIds];
        for(Order property : properties){
            property.End_Payment_Date_Override__c = propertyIdEndDateMap.get(property.id);
            system.debug('End_Payment_Date__c = ' + property.End_Payment_Date_Override__c);
        }
        if(properties.size()>0)
        {
            update properties;
            
        }
            
        
    }
    
    
    public class EndPaymentDateActionRequest {
        
        @InvocableVariable(required=true)
        public ID propertyId; 
        
        @InvocableVariable(required=true)
        public boolean isCurrentLoanMaturityChanged;
        
        @InvocableVariable(required=true)
        public boolean isLoanMaturityExtendedDueToHardship;
        
        @InvocableVariable(required=false)
        public date actualSettlementDate ;
        
        @InvocableVariable(required=false)
        public date refinancedLoanMaturityDate;
        
        
    
    }
    /*
     * When provided Actual Settlement date & Refinanced Loan maturity date this method returns the 
     * lesser of (Actual settlement date + 30 yrs) OR (Refinanced loan maturity date + 60 days)
     */
    private static Date getEarlierDate(Date actualSettlementDate , Date refinancedLoanMaturityDate){
        Date date1 = actualSettlementDate.addYears(30);
        Date date2 = refinancedLoanMaturityDate.addDays(60);
        if(date1<date2)
            return date1;
        return date2;
    }
}