/*Modified by
 * N Rev - 6 Sep - Added logic for Hard Exp Date
 * N Rev - 5 OCT - 2251
 */
global class ProvisionalApplication {
     
    @InvocableMethod (label='Set Expiry Date' description='Set the Expiry date of a provisionally approved application')
    public static void setExpiry(List<Id> provAppIds){
        //Being called by Process Builder: "VHF Application process Status Cancelled"
        //set Expiry date1 to 6 months from today using an estimate where
        //number of days in a month is calculated by dividing 365 days a year into 12 equal months
        // (note: 1 even though each month has slightly different number of days this is ignored
        //        2 both leap and non leap year equates to 183 days after calculation and rounding)
        //Also sets Provisional approval Date to today's date as well
        //        
        Id provAppId = provAppIds[0];
        IndividualApplication provApp = [SELECT Id FROM IndividualApplication where id = :provAppId];
        provApp.Provisional_Approval_Date__c = System.today();
        
        //Add months
        Date origExpiryDate = System.today().addmonths(6);
        Date hardExpiryDate = System.today().addmonths(12); //Calculate Hard Exp Date

        provapp.Expiry_Date1__c = adjustForHolidays(origExpiryDate);
        provapp.Hard_Expiry_Date__c = adjustForHolidays(hardExpiryDate);
        try {
         update provApp;
        }  catch (DmlException e) {
            System.debug('Failed to update Expiry Date on Provisional Application.  Exception:' + e.getMessage());
        }
        
    }
    
    public static date adjustForHolidays(date originalExpiry){
        Integer d = originalExpiry.day();
        Integer m = originalExpiry.month();
        Integer y = originalExpiry.year();
        // Get the default business hours
		BusinessHours bh = [SELECT Id FROM BusinessHours WHERE IsDefault=true];
        
        DateTime targetTime = DateTime.newInstance(y, m, d);
        Datetime nextStart = BusinessHours.nextStartdate(bh.id, targetTime);
        Date adjustedDate = nextStart.date();
      
        return adjustedDate;
    }
}