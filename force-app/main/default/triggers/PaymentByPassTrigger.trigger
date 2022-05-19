/*
* Description: Trigger Payments for Payment Object 
** Version History ** 
Created: Manish Jhingran, 20/12/2021
*/
trigger PaymentByPassTrigger on Payment__c(
  before insert,
  before update,
  after insert,
  after update
) {
  if (Trigger.isAfter) {
    if (Trigger.isUpdate) {
      if (!CheckRecursive.firstcall) {
        CheckRecursive.firstcall = true;
        PaymentTriggerHelper.resetBypassAfterUpdate(Trigger.new);
      }
    } else if (Trigger.isInsert)
      PaymentTriggerHelper.resetBypassAfterUpdate(Trigger.new);
  }
}