/**
* Class Name  : VGSODataShare
* Methods     : shareRecords 
* @author       Sourabh Singh
* @version      $Revision: 1.0 $, $Date: 28/Sep/2021
*/
public class VGSODataShare 
{
    @InvocableMethod
    public static void shareRecords (List<Id> finalAppIds)
    {
        Map<Id,String> provAppIdtoFinalStatus = new Map<Id,String>();
        Map<Id,String> mapAccIdtoFinalAppStatus = new Map<Id,String>();
        List<id> provAppIds = new List<Id>();
        system.debug('finalAppIds='+finalAppIds);
        try
        {
            for(contract finalApp : [select Id,IndividualApplicationId__c,Status 
                                     FROM Contract where id in:finalAppIds])
            {
                provAppIds.add(finalApp.IndividualApplicationId__c);
                provAppIdtoFinalStatus.put(finalApp.IndividualApplicationId__c,finalApp.Status);
            }
            for(Applicant__c a:[select Account__c, IndividualApplication__c 
                                from Applicant__c 
                                where IndividualApplication__c in :provAppIds])
            {
                mapAccIdtoFinalAppStatus.put(a.Account__c,provAppIdtoFinalStatus.get(a.IndividualApplication__c));
            }
            
            //update person accounts for VGSO sharing rule 
            List<Account> accList = [select Id, Final_Application_Status__c from Account 
                                     where id in:mapAccIdtoFinalAppStatus.keySet()];
            for (Account a : accList) 
            {
                a.Final_Application_Status__c = mapAccIdtoFinalAppStatus.get(a.id);
            } 
            if(!accList.isEmpty())
                update accList;
        }catch(Exception e)
        {
            System.debug('Error in VGSODataShare:'+ e);
        }
        
    }
}