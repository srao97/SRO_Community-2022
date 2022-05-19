/*Created by Nayana Revanna.
 * Called from process builder - "VHF Final Application Flow"
 * Updates the Case with recent most active Final application with the scheduled date. 
 */
 /*******************************************************************************************/
/* MODIFICATION LOG
* Version           Modified by          Date               Description
*-------------------------------------------------------------------------------------------
*  1.1              Manish Jhingran      27/09/2021          Modification (Updating Case settlement status) & Bulkify the code 
*  VHF-2514         Sourabh Singh    	 11/10/2021			 	
*******************************************************************************************/

public class PopulateScheduledSettlementDateOnCase
{
@InvocableMethod
Public static void calculateSettlementDate(List < ID > caseID)
{
SYSTEM.DEBUG('METHOD ENTRY - calculateSettlementDate');
List < Contract > finalAppls = [SELECT ID,ApplicationCaseId__c, Status,Settlement_Date__c, ApplicationCaseId__r.Status,
ApplicationCaseId__r.Scheduled_Settlement_Date__c FROM CONTRACT WHERE ApplicationCaseId__c in : caseID
AND Status NOT IN('Cancelled', 'Rejected', 'Cancelled Settlement')
ORDER BY createdDate DESC];
//SYSTEM.DEBUG('***' + finalAppls[0].Settlement_Date__c); //VHF-2514:commented to avoid list index OOB exception
if (!finalAppls.isEmpty())
{
Map < Id, Case > mapCaseUpdate = new Map < Id, Case > ();
for (Contract objContract: finalAppls)
{
if (!mapCaseUpdate.containskey(objContract.ApplicationCaseId__c))
{
Case caseRec = new Case();
caseRec.ID = objContract.ApplicationCaseId__c;
caseRec.Status = objContract.ApplicationCaseId__r.Status;
caseRec.Scheduled_Settlement_Date__c = objContract.Settlement_Date__c;
SYSTEM.DEBUG('***caseRec.Status '+caseRec.Status);
SYSTEM.DEBUG('***^^^^caseRec.ID'+caseRec.ID);
SYSTEM.DEBUG('%%%%%%%%caseRec.Scheduled_Settlement_Date__c'+caseRec.Scheduled_Settlement_Date__c );
If(objContract.Settlement_Date__c >= System.Today()&& caseRec.status <> 'Closed' && objContract.Status <> 'Settled')
{
SYSTEM.DEBUG('*** Settlement_Date__c>=System.Today()');
caseRec.BypassValidation__c = True;
caseRec.Settlement_Status__c = 'Upcoming settlement';
}
else If(objContract.Settlement_Date__c <System.Today() && caseRec.Status == 'Settlement')
{
SYSTEM.DEBUG('@@@@@@@@@@Settlement_Date__c<System.Today()');
caseRec.BypassValidation__c = True;
caseRec.Settlement_Status__c = 'Overdue settlement';
}
else if (caseRec.status == 'Closed' && objContract.Status == 'Settled')
{
caseRec.BypassValidation__c = True;
SYSTEM.DEBUG('######caseRec.status==Closed');
caseRec.Settlement_Status__c = 'Settled';
}
mapCaseUpdate.put(caseRec.Id, caseRec);
}
}
update mapCaseUpdate.values();
}
}
}