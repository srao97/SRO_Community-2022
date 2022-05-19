public class FinalAppBtnController 
{
   @AuraEnabled
    public static boolean getBtnVisibile(String appId) 
    { 
        boolean showFlag = false;
        
        List<IndividualApplication> finalAppls = [select id, status,
                                     (select id,status from Contracts_del__r where status not in ('Cancelled','Rejected','Cancelled Settlement')) 
                                     from Individualapplication 
                                     where status = 'Provisionally Approved'
                                     and Id=:appId];   
        
        if(finalAppls.size()>0 && finalAppls[0].Contracts_del__r.size()==0)
            showFlag = true;
        
        system.debug('recid='+appId);
        system.debug('showflag='+showFlag);
        
        return showflag;
    }
    
    //Added by N Rev for VHF 2236
    @AuraEnabled
    public static boolean displayButtonForExpiry(String appId) 
    {
    	SYSTEM.DEBUG('METHOD ENTRY - displayButtonForExpiry');
    	IndividualApplication provApp = [SELECT Id,
                                            Hard_Expiry_Date__c,
                                            Second_Extension_Requested__c,
                                     		status,
                                            Final_Application_In_Progress_c__c 
                                    FROM IndividualApplication 
                                    WHERE Id = :appId];
        if(provApp.Final_Application_In_Progress_c__c == false &&
           provApp.Hard_Expiry_Date__c >= System.today() 
           && provApp.Second_Extension_Requested__c == false
           && provApp.status == 'Provisionally Approved'){
            return true;
        }
       	else
            return false;
    }
    
}