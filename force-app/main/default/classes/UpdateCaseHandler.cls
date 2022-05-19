public without sharing class UpdateCaseHandler {
    public static void UpdateNewPanelFinancier(Map<String, Object> input,Map<String, Object> output,Map<String, Object> options){
        Id caseId = (Id)input.get('CaseId');
        String sPanelFinancier = (String)input.get('NewPanelFinancier');
        output.put('success', false);
        if (caseId != null && String.isNotEmpty(sPanelFinancier)) {
            List<Account> listAccounts = [Select Id from Account where RecordType.Name = 'Business' and Name = :sPanelFinancier Limit 1];
            if(!listAccounts.isEmpty()){
                Case oCase = new Case(Id=caseId, New_Panel_Financier__c=listAccounts[0].Id);
                update oCase;
                List<Confirmation__c> CList = [Select Id, New_PF__c From Confirmation__c Where Refinance_Case_ID__c =: caseId order by createdDate desc];
                if(!CList.isEmpty()){
                    CList[0].New_PF__c = oCase.New_Panel_Financier__c ;
                    update CList[0];
                }
                
                output.put('success', true);
            }
        }
    }
}