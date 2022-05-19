/*
* Description: Trigger Handler for Contract Object 
* Author: 
** Version History ** 
* Created Date: 
* Modified: Lavanya Kavuri, VHF-1900, Sep 28 2021
Sourabh Singh, 11/Oct/2021, VHF-2596 
Sourabh Singh, 20/Oct/2021, VHF-2584 
Sourabh Singh, 31/Oct/2021, VHF-2892 
*/
public with sharing class ContractTriggerHelper {
    
    public static final Pattern FOLIO_PATTERN = Pattern.compile('([0-9]{1,3})([ABCKLabckl ]{0,1})$');
    
    /*
* Validate Plan Lot Folio Volume
*/
    public static void ValidatePlanLotFolioVolume(List<Contract> contracts){
        for(Contract contract: contracts){         
            Map<String, Object> output =new Map<String, Object>();
            Map<String, Object> output1 =new Map<String, Object>();
            if(contract.Lot_Number__c != null && contract.Plan_Number__c!=null ){                    
                LandIdentifiersValidator.ValidateLotPlan(contract.Lot_Number__c,contract.Plan_Number__c, output);
                System.debug('@@@@Output1'+output);      
                if (string.valueof(output.get('validity'))!='Valid'){                   
                    contract.addError(string.valueof(output.get('errorCode'))+'\n'+string.valueof(output.get('errorMsgP')));
                }
            }
            if(contract.Volume__c != null && contract.Folio__c !=null ){      
                LandIdentifiersValidator.ValidateVolumeFolio(string.valueof(contract.Volume__c), contract.Folio__c, output1);
                System.debug('*******Output2'+output1);
                if (string.valueof(output1.get('validity'))!='Valid'){
                    contract.addError(string.valueof(output1.get('errorCode'))+'\n'+string.valueof(output1.get('errorMsgF')));
                }
            }
        }
    }
    
    /*
* Update Land Indentifiers to UpCase
*/ 
    
    public static void UpdateLandIdentifiersToUpcase(List<Contract> contracts) {
        updateFolioSuffixToUpperCase(contracts);
        updatePlanNumberToUpperCase(contracts);
    }
    
    /*
* Update Folio Suffix To UpperCase
*/
    public static void updateFolioSuffixToUpperCase(List<Contract> contracts){
        for(Contract contract: contracts){    
            if(contract.Folio__c != null){
                Matcher folioMatcher = FOLIO_PATTERN.matcher(contract.Folio__c);
                if(folioMatcher.matches()) {
                    String folioSuffix = folioMatcher.group(2);
                    System.debug('******* contract.Folio__c Before '+ contract.Folio__c);
                    if(folioSuffix != null && folioSuffix.isAllLowerCase()) {
                        contract.Folio__c = contract.Folio__c.ToUpperCase();
                    }
                    System.debug('******* contract.Folio__c After '+ contract.Folio__c);
                }
            }
        }
    }
    
    /*
* Update Plan number to UpperCase
*/ 
    public static void updatePlanNumberToUpperCase(List<Contract> contracts){
        for(Contract contract: contracts){    
            if(contract.Plan_Number__c != null){
                contract.Plan_Number__c = contract.Plan_Number__c.ToUpperCase();
              //  contract.BypassValidation__c = true; //VHF-2892
                System.debug('******* contract.Plan_Number__c After '+ contract.Plan_Number__c);   
            }
        }
    }
    

    /*
* VHF-2596:Error message on direct update of status to 'Settled'
*/     
    public static void validateStatusBeforeUpdate(List<Contract> contracts) {
        Id vgsoProfileId = [select id,name from profile where name = 'VHF VGSO Community Plus User' limit 1].Id;    
        Set<String> badStatusValuesSet = new Set<String>{'Settled','Cancelled','Rejected'};    
            for(contract con:contracts)
        {
            system.debug('con.status='+con.status+' , con.BypassValidation__c='+con.BypassValidation__c+' ,UserInfo.getProfileId()='+UserInfo.getProfileId()+' ,vgsoProfileId='+vgsoProfileId);
            if( badStatusValuesSet.contains(con.status) && !con.BypassValidation__c 
               && vgsoProfileId != null && UserInfo.getProfileId() == vgsoProfileId)
            {
                con.adderror('You can\'t select this status value!');  
            }
        }
    }
    /*
* VHF-2892:reset bypass flag to false
*/      
    public static void resetBypassAfterUpdate(List<Contract> contracts)
    {
        system.debug('contracts='+contracts);
        Set<Id> finalAppIds = new Set<Id>();
        for(contract con:contracts)
        {
            if(con.BypassValidation__c)                   
                  finalAppIds.add(con.Id);
        }
        
        List<contract> finalAppToUpdate = [select id,bypassvalidation__c from contract where id in:finalAppIds];
        system.debug('finalAppToUpdate='+finalAppToUpdate);
        if(!finalAppToUpdate.isEmpty())
        {
            for(contract con:finalAppToUpdate)
                con.BypassValidation__c = false;
            update finalAppToUpdate;
        }
    }
}