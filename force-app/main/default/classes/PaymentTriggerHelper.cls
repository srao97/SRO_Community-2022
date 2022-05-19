/*
* Description: Trigger Handler for Case Object 
** Version History ** 
Created: Manish Jhingran, 20/12/2021
*/

public class PaymentTriggerHelper {
  /*
   * Reset bypass flag to false
   */
  public static void resetBypassAfterUpdate(List<Payment__c> PaymentList) {
    Set<Id> PaymentIds = new Set<Id>();
    for (Payment__c PL : PaymentList) {
      if (PL.BypassValidation__c)
        PaymentIds.add(PL.Id);
    }

    List<Payment__c> PaymentsToUpdate = [
      SELECT id, bypassvalidation__c
      FROM Payment__c
      WHERE id IN :PaymentIds
    ];

    if (!PaymentsToUpdate.isEmpty()) {
      for (Payment__c p : PaymentsToUpdate)
        p.BypassValidation__c = false;
      update PaymentsToUpdate;
    }
  }
}