/**
* Class Name  : FinalAppTriggerHandler
* Methods     : deleteContentDocuments 
* @author       Sourabh Singh
* @version      $Revision: 1.0 $, $Date: 10/Sep/2021
*/
public without sharing class FinalAppTriggerHandler 
{
    /**
* This method updates the owner of parent account id to the new final application owner
*/  
    public static void processUpdates(map<Id,contract> newAppsMap, map<Id,contract> oldAppsMap)
    {
        map<id,id> mapAccIdToOwnerId  =new map<id,id>(); 
        map<id,id> mapProvAppIdToOwnerId  =new map<id,id>(); 
        list<individualapplication> provAppList = new list<individualapplication>();
        try
        {
            for(contract newApp:newAppsMap.values())   
            {
                if(newApp.ownerId != oldAppsMap.get(newApp.id).ownerId)//if final app owner changed set new account owner  
                {
                    mapAccIdToOwnerId.put(newApp.accountId,newApp.ownerId); 
                    mapProvAppIdToOwnerId.put(newApp.IndividualApplicationId__c,newApp.ownerId);
                }
            }//end for loop
            
            map<id,user> mapIdToUser = new map<id,user>([select id,contactid from user where id in:mapAccIdToOwnerId.values()]);
            
            for(contract newApp:newAppsMap.values())   
            {
                if(newApp.ownerId != oldAppsMap.get(newApp.id).ownerId)//if final app owner changed set PF contact  
                    newApp.Panel_Finance_Officer__c = mapIdToUser.get(newApp.ownerId).contactid;
            }
            
            map<id,id> mapCaseIdToContactId = new map<id,id>();
            
            //update ownership of provisional apps
            map<id,individualapplication> mapIdToProvApp = new map<id,individualapplication>([select id,ownerid,ApplicationCaseId from individualapplication 
                                                                                              where id in:mapProvAppIdToOwnerId.keyset()]);
            for(individualapplication pa:mapIdToProvApp.values())
            {
                pa.ownerid = mapProvAppIdToOwnerId.get(pa.id);
                pa.Panel_Finance_Officer__c = mapIdToUser.get(pa.ownerId).contactid;
                provAppList.add(pa);
                mapCaseIdToContactId.put(pa.ApplicationCaseId,pa.Panel_Finance_Officer__c);
            }
            
            if(!provAppList.isEmpty())
                update provAppList;
            
            //update panel finance officer on case
            List<case> caseList = new List<case>();
            map<id,case> mapIdToCase = new map<id,case>([select id,ContactId from Case where id in:mapCaseIdToContactId.keyset()]);
            for(Case c:mapIdToCase.values())
            {
                c.ContactId = mapCaseIdToContactId.get(c.id);
                caseList.add(c);
            }
            
            if(!caseList.isEmpty())
                update caseList;
            
            List<Id> accsIds = new list<Id>();
            List<applicant__c> applList= [select id,Account__c,IndividualApplication__c from applicant__c where IndividualApplication__c in:mapIdToProvApp.keySet()];
            for(applicant__c appl:applList)
            {
                accsIds.add(appl.Account__c);
                mapAccIdToOwnerId.put(appl.Account__c,mapProvAppIdToOwnerId.get(appl.IndividualApplication__c));
            }
            
            List<account> accsInScope = [select id,ownerid from account where id in :accsIds and ispersonaccount=true];           
            for(account acc:accsInScope)  
            {
                acc.ownerId = mapAccIdToOwnerId.get(acc.Id);
                acc.Panel_Finance_Officer__c = mapIdToUser.get(acc.ownerId).contactid;
            }
            
            if(!accsInScope.isEmpty())
                update accsInScope;
        }
        catch(exception e)
        {
            system.debug('error in FinalAppTriggerHandler:'+e);
        }
    }//end of method
}