/*******************************************************************************************
* @Name         ProvisionalApplicationExpiryBatch
* @Author       Manish Jhingran<manish.jhingran@salesforce.com>
* @Date         07/09/2021
* @Description  This class when executed via scheduled job updates Provisional Application Status (to Expiry) and Expiry date fields
*******************************************************************************************/
/* MODIFICATION LOG
* Version          Developer          Date               Description
*-------------------------------------------------------------------------------------------
*  1.0              Manish Jhingran      06/09/2021          Initial Creation 
*. 1.1              Manish Jhingran.     09/12/2021          Updated the Case Id in the Email ntfy                                                     
*  1.2              Aashish Sajwan       20/04/2022          Updated Email notification period from 14 to 28 Days for all Lenders -VHF-6086                                               
*******************************************************************************************/
global class ProvisionalApplicationExpiryBatch extends batchjobsch.BatchJobBase implements Database.Batchable<sObject>{

    // Method: start
    public Database.QueryLocator start(Database.BatchableContext bc){
    Date currentDate = System.today(); 
    String CD = DateTime.newInstance(currentDate.year(),currentDate.month(),currentDate.day()).format('YYYY-MM-dd'); 
    Date dt2 = Date.valueOf(CD);
    //VHF-6086 : Update Days from 14 to 28
    Date dt3=dt2.addDays(28);
    //VHF-6086- End
    Date dtm4=dt2.addMonths(1);

 //collect the batches of records or objects to be passed to execute
        //String query = 'SELECT Id FROM IndividualApplication where Status=\'Provisionally Approved\' AND Hard_Expiry_Date__c <=:dt3 AND Final_Application_In_Progress_c__c=false' ;
        String query = 'SELECT Id,Hard_Expiry_Date__c,Expiry_Date1__c,Status,Final_Application_In_Progress_c__c,ApplicantNames__c,Application_Case_Autonumber__c,AppliedDate,Name,LastModifiedDate FROM IndividualApplication where Status=\'Provisionally Approved\' AND (((Expiry_Date1__c=:dt3) AND (Hard_Expiry_Date__c>:dtm4))OR (Hard_Expiry_Date__c <=:dt2)) AND Final_Application_In_Progress_c__c=false';
        Database.QueryLocator queryLocator = Database.getQueryLocator(query);
        return queryLocator;
    //System.debug('@@@@ Query: ' + query);
    }

    // Method: execute
    public void execute(Database.BatchableContext BC, List<IndividualApplication> PAList){
        // Update Provisional Application Records
        System.debug('*** ProvisionalApplicationExpiryBatch- Execute ***');
        System.debug('Provisional Application Recotrds: ' + PAList);
          
           List<IndividualApplication> PAList1=new List<IndividualApplication>();
           List<IndividualApplication> PAList2=new List<IndividualApplication>();
        for(IndividualApplication InstPA : PAList)
        {        
          if(InstPA.Hard_Expiry_Date__c<=System.Today())
          {
          
            IndividualApplication InstPA1 = new IndividualApplication();
            InstPA1=InstPA;
            InstPA1.BypassValidation__c=True;
            InstPA1.Status = 'Expired';
            InstPA1.Expiry_Date1__c = ProvisionalApplication.adjustForHolidays(System.Today());
            PAList1.add(InstPA1);
            System.debug('#####PAList1: ' + PAList1); 
            }
           else
           {
          IndividualApplication InstPA2 = new IndividualApplication();
          InstPA2=InstPA;
          InstPA2.Id=InstPA.Id;
          InstPA2.Expiry_Date1__c=InstPA.Expiry_Date1__c;
          InstPA2.ApplicantNames__c =InstPA.ApplicantNames__c;
          InstPA2.AppliedDate =Date.valueOf(InstPA.AppliedDate);
          //InstPA2.Name =InstPA.Name;
          PAList2.add(InstPA2);
          System.debug('#####PAList2: ' + PAList2);  
          }
            
        }
        try {
            System.debug('#####PAList2: ' + PAList2); 
            System.debug('#####PAList1: ' + PAList1); 
             update PAList1;
             update PAList2;
             if(PAList2.size()>0){
             Map<String,List<IndividualApplication>> PAMap = new Map<String, List<IndividualApplication>>();
             PAMap.put('GetProvAppRecordsCollectionApex', PAList2);
             Flow.Interview.ProvAppExpiryReminder flow1 = new Flow.Interview.ProvAppExpiryReminder(PAMap);
             flow1.start();
             
             String outputValue = (String)flow1.getVariableValue('SingleVaribleProAppRecords');
             System.debug('#####outputValue: ' + outputValue); 
            }
        
        } catch(Exception e) {
            System.debug(e);
        }

        
    }

    // Method: finish
    public void finish(Database.BatchableContext BC){
        System.debug('*** ProvisionalApplicationExpiry- Finish ***');
       super.finishBatch(BC);
    }
}