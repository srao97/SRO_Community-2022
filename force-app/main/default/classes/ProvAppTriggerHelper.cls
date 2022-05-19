/*
* Description: Trigger Handler for IndividualApplication Object 
** Version History ** 
Created: Sourabh Singh, 19/11/2021
*/ 

public class ProvAppTriggerHelper 
{
/*
* Reset bypass flag to false
*/      
    public static void resetBypassAfterUpdate(List<IndividualApplication> provApps)
    {
        system.debug('prov apps='+provApps);
        Set<Id> provAppIds = new Set<Id>();
        for(IndividualApplication papp:provApps)
        {
            if(papp.BypassValidation__c)                   
                provAppIds.add(papp.Id);
        }
        
        List<IndividualApplication> provAppToUpdate = [select id,bypassvalidation__c from IndividualApplication where id in:provAppIds];
        system.debug('provAppToUpdate='+provAppToUpdate);
        if(!provAppToUpdate.isEmpty())
        {
            for(IndividualApplication papp:provAppToUpdate)
                papp.BypassValidation__c = false;
            update provAppToUpdate;
        }
    }
}