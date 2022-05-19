global without sharing class DuplicateApplicationCheckService implements vlocity_ins.VlocityOpenInterface2 {
    
    global Object invokeMethod (
        String methodName, Map<String, Object> input, Map<String, object> output, Map<String, Object> options
    ) {
        try {
            Boolean status = false;
            if('checkDuplicateApplications'.equals(methodName)) {
                checkDuplicateApplications(input, output, options);
                status = true;
            }
             else if('CheckDuplicateApplicationCheck'.equals(methodName)) {
                CheckDuplicateApplicationCheck(input, output, options);
                status = true;
            }
            return status;
        } catch(TypeException te) {
            output.put('error', 'Bad Request');
            output.put('errorCode', 'INVOKE-400');
            return false;
        }
    }
    
    private void checkDuplicateApplications(Map<String, Object> input, Map<String, object> output, Map<String, Object> options) {
        
        Object dataObject = input.get('data');
        
        List<Object> data = new List<Object>();
        
        if(dataObject instanceof List<Object>) {
            data.addAll((List<Object>) dataObject);
        } else if(dataObject instanceof Map<String, Object>) {
            data.add((Map<String, Object>) dataObject);
        }
        
        if(data.isEmpty()) {
            output.put('error', 'Input(s) blank or missing');
            output.put('errorCode', 'INVOKE-500');
            return;
        }
        
        List<Account> accountList = new List<Account>();
        String medicares = '';
        String currentMedicare = '';
        String emailAddressList = '';
        Integer Medicarefound;
        Integer duplicateEmailFound;
        
        List<RecordType> personRecordType = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND IsPersonType = true LIMIT 1];
        
        for(Object datum: data) {
            Map<String, Object> eachApplicant = (Map<String, Object>) datum;
            Account newAccount = new Account();
            newAccount.RecordTypeId = personRecordType.get(0).Id;
            newAccount.FirstName = String.valueOf(eachApplicant.get('FirstName'));
            newAccount.LastName = String.valueOf(eachApplicant.get('LastName'));
            newAccount.MedicareNumber__pc  = Decimal.valueOf(String.valueOf(eachApplicant.get('MedicareNumber')));
            newAccount.Medicare_Card_Number__pc  = Decimal.valueOf(String.valueOf(eachApplicant.get('MedicareNumber')).substring(0,9));
            newAccount.Medicare_Reference_Number__pc = Decimal.valueOf(String.valueOf(eachApplicant.get('RefNumber')));
            newAccount.IsActiveApplicant__pc  = 'Yes';
            currentMedicare = String.valueOf(newAccount.MedicareNumber__pc) + String.valueOf(newAccount.Medicare_Reference_Number__pc);
            Medicarefound = medicares.indexOf(currentMedicare);
            duplicateEmailFound = emailAddressList.indexOf(String.valueOf(eachApplicant.get('EmailAddress')));
            if(Medicarefound != -1 || duplicateEmailFound != -1)
            {
                List<Map<String, Object>> duplicateList = new List<Map<String, Object>>();
                duplicateList.add(new Map<String, String> {'DuplicateReason' => 'INVOKE-422'});
                output.put('data', new Map<String, Object> {'FailureReason' => duplicateList});
                return;
            }
            medicares = medicares + currentMedicare + ' ';
            emailAddressList = emailAddressList + String.valueOf(eachApplicant.get('EmailAddress')) + ' ';
            accountList.add(newAccount);
        }
        
        List<Datacloud.FindDuplicatesResult> duplicateResults = Datacloud.FindDuplicates.findDuplicates(accountList);
        if(duplicateResults.size() == 0) return;
        
        List<Id> accountIds = new List<Id>();
        for(Datacloud.FindDuplicatesResult findduplicateResult: duplicateResults) {
            for(Datacloud.DuplicateResult duplicateResult: findduplicateResult.getDuplicateResults()) {
                for (Datacloud.MatchResult matchResult : duplicateResult.getMatchResults()) {
                    for (Datacloud.MatchRecord matchRecord : matchResult.getMatchRecords()) {
                        system.debug('*** Results: '+matchRecord.getRecord());
                        accountIds.add(matchRecord.getRecord().Id);
                    }
                }
            }
        }
        
        if(accountIds.size() == 0) return;
        
        List<Applicant__c> applicants = [SELECT Id,IndividualApplication__r.Name,IndividualApplication__r.Id, IndividualApplication__r.ApplicationCase.CaseNumber, IndividualApplication__r.ApplicationCaseId, Account__r.Name, Account__r.MedicareNumber__pc,Account__r.Medicare_Card_Number__pc, Account__r.Medicare_Reference_Number__pc, IndividualApplication__r.Status FROM Applicant__c WHERE Account__c in :(accountIds) AND IndividualApplication__r.Status in ('Provisional Application Submitted','Provisionally Approved','Settled')];
        
        if(applicants.isEmpty()) return;
        
        List<Map<String, Object>> duplicateList = new List<Map<String, Object>>();
        
        for(Applicant__c duplicateApplicants: applicants) {
            duplicateList.add( new Map<String, String> {'ApplicationNumber' => duplicateApplicants.IndividualApplication__r.Name,'ApplicantMedicareNumber' => String.valueOf(duplicateApplicants.Account__r.MedicareNumber__pc),'ApplicantMedicareCardNumber' => String.valueOf(duplicateApplicants.Account__r.Medicare_Card_Number__pc),'ApplicantMedicareRefNumber' => String.valueOf(duplicateApplicants.Account__r.Medicare_Reference_Number__pc),'Name' => duplicateApplicants.Account__r.Name,'CaseNumber' => duplicateApplicants.IndividualApplication__r.ApplicationCase.CaseNumber,'CaseId' => duplicateApplicants.IndividualApplication__r.ApplicationCaseId,'ApplicationSFId' => duplicateApplicants.IndividualApplication__r.Id,'ApplicantId' => duplicateApplicants.Id});
        }
        
        output.put('data', new Map<String, Object> {'existingApplications' => duplicateList}); 
    }
 

Public static void CheckDuplicateApplicationCheck(Map<String, Object> input, Map<String, object> output, Map<String, Object> options)
{
   string CaseSubject=string.valueof(input.get('CaseSubject'));
   string CaseComents=string.valueof(input.get('CaseComents'));
   string LenderAccountId=string.valueof(input.get('LenderAccountId'));
   string LenderContactId=string.valueof(input.get('LenderContactId'));
   string jsonStr=json.serialize(input);
   RecordType RT = [select Id,name from RecordType where Name ='Duplicate Application Check' and SobjectType = 'Case'];   
   System.debug('RecordTypr&&&--'+RT.ID);
   QueueSobject Queue1=[select id,QueueId,Queue.Name from QueueSObject where Queue.Name='Duplicate VHF Application'];
   Case objcase = new Case();
   objCase.Subject= CaseSubject;
   objCase.AccountId= LenderAccountId;
   objCase.ContactId= LenderContactId;
   objCase.Description = CaseComents;
   objCase.Duplicate_Check_Details__c=jsonStr;
   objCase.RecordTypeId=RT.id; 
   objCase.ownerId=Queue1.QueueId;
   objCase.BypassValidation__c = true;
   DuplicateApplicationsCreation(objcase);
   System.debug('BeforeInsert@@@'+objCase);
   insert objcase;
   System.debug('AfterInsert--'+objCase);
   case objcase2= [Select id,CaseNumber from case where id=:objCase.id];
   System.debug('ReturnCASENUMBER--'+objcase2.CaseNumber);
   output.put('CaseNumber',objcase2.CaseNumber);
}

@AuraEnabled
Public static list<CaseListWrapper>getDuplicateRecordId(Id Caseid)
{
   list<CaseListWrapper> lstCaseWrapper= new list<CaseListWrapper>();
   case objcase= [Select id,Duplicate_Check_Details__c from case where id=:CaseId];
   string inputJson=objcase.Duplicate_Check_Details__c;
   if(string.isNotBlank(inputJson))
     {
       list<case>lstCase=checkDuplicate(inputJson);
       for(case objTempcase :lstCase)
         {
            CaseListWrapper InstCLW = new CaseListWrapper();
            InstCLW.caseNum=objTempcase.CaseNumber;
            InstCLW.caseApplicationNum=objTempcase.Individual_Application__r.NAME;
            InstCLW.caseId=objTempcase.Id;
            InstCLW.LenderAccount=objTempcase.Individual_Application__r.Lender_Account__c;
            InstCLW.LenderContact=objTempcase.Individual_Application__r.Panel_Finance_Officer__c;
            lstCaseWrapper.add(InstCLW);
         }

    }
return lstCaseWrapper;

}

Public static void DuplicateApplicationsCreation(case objcase)
   {
    string inputJSON=objCase.Duplicate_Check_Details__c;
     string duplicatestring='';
     duplicatestring= duplicatestring+'<P>Please review the following Applications and their related duplicate Applicants:<p><br/>';
       list<string>lstApplicantNames= New list<string>();
       list<string>lstApplicationIdNames= New list<string>();
       
    if(string.isNotBlank(inputJSON))

       {

      Map<String, Object>MapInst=(Map<String,object>)JSON.deserializeUntyped(inputJSON);
      
       if(MapInst.get('data')!=null)
       {
       list<object>listData=(list<Object>)MapInst.get('data');
       if(listData!=null && listData.isEmpty()!=true)
       {
       
       for(object objData:listData)

           {
            Map<String,Object>MapData=(Map<String, Object>)objData;
            string Name=string.valueof(MapData.get('Name'));
            string ApplicationName= string.valueof(MapData.get('ApplicationName'));
            string MedicareNumber= string.valueof(MapData.get('MedicareNumber'));
            string CaseId=string.valueof(MapData.get('CaseId'));
            string CaseNumber=string.valueof(MapData.get('CaseNumber'));
            string ApplicantId =string.valueof(MapData.get('ApplicantId'));
             System.debug('ApplicantId****'+ApplicantId);
            string ApplicationId=string.valueof(MapData.get('ApplicationId'));   
             System.debug('ApplicationId****'+ApplicationId);      
            duplicatestring= duplicatestring+'<p style="color: #2e6c80;font-size:15px;margin:-1px 0px 0px 0px;">CaseID:<a href="/lightning/r/Case/'+CaseId+'/view" target="_blank">'+CaseNumber+'</a> for Application Id:<a href="/lightning/r/IndividualApplication/'+ApplicationId+'/view" target="_blank">'+ApplicationName+'</a></a> Applicant Name:<a href="/lightning/r/Account/'+ApplicantId+'/view" target="_blank">'+Name+'</a></p>';
            /*'<p><a href="'+URL.getSalesforceBaseUrl().toExternalForm()+'/'+recordid+'">'+displayname+'</a></p>';*/
            lstApplicantNames.add(Name);
            lstApplicationIdNames.add(ApplicationName);
           }
           
           }
           }
           
           objCase.DuplicateApplications__c=duplicatestring;
           System.debug('duplicatestring--'+duplicatestring);
           if(lstApplicantNames.isEmpty()!=true) objcase.Duplicate_Case_Applicant_Names__c=string.join(lstApplicantNames,',');
           if(lstApplicationIdNames.isEmpty()!=true) objcase.Duplicate_Case_Application_Id_s__c=string.join(lstApplicationIdNames,',');
       }

   }


public static list<case>CheckDuplicate(string Inputjson){
    list<case> lstCase= new list<case>();
    if(String.isNotBlank(inputjson)){
        InputWrapper objinputWrapper = (inputWrapper)System.JSON.deserialize(inputjson,inputWrapper.class);
        if(objinputWrapper!=null){
            set<string>SetApplicationId= new set<string>();
            if(objinputWrapper.data!=null){
                if(objinputWrapper.data.isEmpty()!=true){
                    system.debug('Results:objinputWrapper::'+objinputWrapper);
                    for(dataWrapper objdataWrapper: objinputWrapper.data){
                        system.debug('Results:objdataWrapper.ApplicationId::'+objdataWrapper.ApplicationId);
                        SetApplicationId.add(objdataWrapper.ApplicationId);
                    }
                }
            }
            System.debug('Results:SetApplicationId::'+SetApplicationId);
            if(SetApplicationId.isEmpty()!=true){
                List<IndividualApplication> listIndividualApplications = [Select Id, Name from IndividualApplication];
                system.debug('Results:listIndividualApplications::'+listIndividualApplications);
                lstCase=[SELECT AccountId,CaseNumber,Id,Individual_Application__c, Individual_Application__r.NAME,Individual_Application__r.Lender_Account__c, Individual_Application__r.Panel_Finance_Officer__c FROM Case where Individual_Application__r.NAME in: SetApplicationId];
                System.debug('Results:lstCase::'+lstCase);
            }
        }
    }
    return LstCase;
}

Public class CaseListWrapper{
   @AuraEnabled
   Public String caseNum{get;set;}
   @AuraEnabled public String caseApplicationNum{get;set;}
   @AuraEnabled public String caseId{get;set;}
   @AuraEnabled public String LenderAccount{get;set;}
   @AuraEnabled public String LenderContact{get;set;}
   }
   
   

Public class InputWrapper{
   Public String CaseSubject;
   Public string CaseComents;
   Public dataWrapper[] data;
}

Public class dataWrapper{
   public String Name;
   public String ApplicationId;
   public long MedicareNumber;
}


}