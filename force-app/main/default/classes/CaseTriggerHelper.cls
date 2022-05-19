/*
* Description: Trigger Handler for Case Object 
** Version History ** 
Created: Sourabh Singh, 10/12/2021
*******************************************************************************************/
/* MODIFICATION LOG
 * Version          Developer          Date               Description
 *-------------------------------------------------------------------------------------------
 *  1.1             Arjun Singh        20/01/2022          Added method for duration and validation duration calculation
 *  1.2             Sourabh            24/1/2022           VHF- 4270
 *  1.3             Arjun Singh        03/02/2022          VHF-3082
 *  1.4             Manish             21/03/2022          VHF-4306
 */

public class CaseTriggerHelper {
  public  static String STATUS_CREATED = 'Created';
  public  static String STATUS_PAYMENT_REGISTERED = 'Payment Registered';
  public  static String STATUS_PAYMENT_REQUESTED = 'Payment Requested';
  public  static String STATUS_PAYMENT_RECEIVED = 'Payment Received';
  public  static String Err_Msg = 'Active payment records exists. Cannot reject the case.';
  Public  static String Err_Msg_Cancellation = 'Active payment records exists. Cannot cancel the case.';
  /*
   * Reset bypass flag to false
   */
  public static void resetBypassAfterUpdate(List<Case> caseList) {
    Set<Id> caseIds = new Set<Id>();
    for (Case c : caseList) {
      if (c.BypassValidation__c)
        caseIds.add(c.Id);
    }

    List<Case> casesToUpdate = [
      SELECT id, bypassvalidation__c
      FROM Case
      WHERE id IN :caseIds
    ];

    if (!casesToUpdate.isEmpty()) {
      for (Case c : casesToUpdate)
        c.BypassValidation__c = false;
      update casesToUpdate;
    }
  }
  
  /**
   * @Description : Calculate valid Absence Duration in Months
   */
  public static void calculateValidAbsenceMonths(List<Case> caseList) {
    Id longTermAbsenceRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName()
      .get('Long_Term_Absence')
      .getRecordTypeId();
    List<Case> longTermAbsenceCases = new List<Case>();
    Map<Id, Case> casesMap = new Map<Id, Case>();
    //Map<Id,Order> propertyMap = new Map<Id,Order>();
    //Set<Id> propertyIds = New Set<Id>();
    Set<Id> annualReviewIds = new Set<Id>();
    Map<Id, Annual_Review__c> annualReviewMap = new Map<Id, Annual_Review__c>();

    for (Case caseRecord : caseList) {
      if (caseRecord.recordTypeId == longTermAbsenceRecordTypeId) {
        longTermAbsenceCases.add(caseRecord);
        annualReviewIds.add(caseRecord.Annual_Review__c);
      }
    }

    for (Annual_Review__c annualReviewRec : [
      SELECT Id, Annual_Review_Start_Date__c, Annual_Review_End_Date__c
      FROM Annual_Review__c
      WHERE Id IN :annualReviewIds
    ]) {
      annualReviewMap.put(annualReviewRec.Id, annualReviewRec);
    }

    for (Case caseRec : longTermAbsenceCases) {
      System.debug('caseRec1>>>>' + caseRec);
      if (caseRec.origin == 'Participant Portal') {
        caseRec.Valid_Absence_Duration_Months__c = 0.0;
      } else if (
        annualReviewMap.containsKey(caseRec.Annual_Review__c) &&
        caseRec.Absence_start_date__c != null &&
        caseRec.Absence_end_date__c != null
      ) {
        date settlementStartDate = annualReviewMap.get(caseRec.Annual_Review__c)
          .Annual_Review_Start_Date__c;
        date settlementEndDate = annualReviewMap.get(caseRec.Annual_Review__c)
          .Annual_Review_End_Date__c;
        decimal totalvalidMonth=0.0;
        if (
          caseRec.Absence_start_date__c < settlementStartDate &&
          caseRec.Absence_end_date__c < settlementStartDate
        ) {
          // Before the review period range
          totalvalidMonth = 0.0;
        } else if (
          caseRec.Absence_start_date__c >= settlementStartDate &&
          caseRec.Absence_end_date__c <= settlementEndDate
        ) {
          //In between the review period range
          Integer noOfDays =
            caseRec.Absence_start_date__c.daysBetween(
              caseRec.Absence_end_date__c
            ) + 1;
          totalvalidMonth = getDurationInMonth(noOfDays);
        } else if (
          caseRec.Absence_start_date__c <= settlementStartDate &&
          caseRec.Absence_end_date__c <= settlementEndDate
        ) {
          //In between the review period range
          Integer noOfDays =
            settlementStartDate.daysBetween(caseRec.Absence_end_date__c) + 1;
          totalvalidMonth = getDurationInMonth(noOfDays);
        } else if (
          caseRec.Absence_start_date__c > settlementStartDate &&
          caseRec.Absence_end_date__c > settlementEndDate &&
          caseRec.Absence_start_date__c < settlementEndDate
        ) {
          // between and outside the end period
          Integer noOfDays =
            caseRec.Absence_start_date__c.daysBetween(settlementEndDate) + 1;
          totalvalidMonth = getDurationInMonth(noOfDays);
        } else if (
          caseRec.Absence_start_date__c > settlementStartDate &&
          caseRec.Absence_end_date__c > settlementEndDate
        ) {
          //both outside of end range
          totalvalidMonth = 0.0;
        }
        caseRec.Valid_Absence_Duration_Months__c = totalvalidMonth;
      }
      if (
      //  annualReviewMap.containsKey(caseRec.Annual_Review__c) &&  //Sourabh:commented to include cases with origin = Participant Portal
        caseRec.Absence_start_date__c != null &&
        caseRec.Absence_end_date__c != null
      ) {
        Integer noOfDays =
          caseRec.Absence_start_date__c.daysBetween(
            caseRec.Absence_end_date__c
          ) + 1;
        decimal durationInMonthValue = getDurationInMonth(noOfDays);
        caseRec.Absence_Duration_Months__c = durationInMonthValue;
      }
      System.debug('caseRec2>>>>' + caseRec);
    }
  }

  public static decimal getDurationInMonth(Integer days) {
    decimal durationDivider = decimal.valueOf(label.LTA_Duration_Divider);
    String totalDuration = String.valueOf(days / durationDivider);
    Integer trimmedTotalDuration = totalDuration.indexOf('.') + 2;
    decimal durationInMonthValue;
    if (totalDuration.indexOf('.') == -1) {
      durationInMonthValue = decimal.valueOf(totalDuration);
    } else {
      durationInMonthValue = decimal.valueOf(
        totalDuration.subString(0, trimmedTotalDuration)
      );
    }
    System.debug('durationInMonthValue>>>' + durationInMonthValue);
    return durationInMonthValue;
  }

  public static void finalPaymentCaseValidation(List<Case> newCaseList, Map<Id,Case>oldCaseMap){
    Set<Id> rejectedCaseIds = new Set<Id>();
    Set<String> statusToInclude = new Set<String>{STATUS_CREATED, STATUS_PAYMENT_REGISTERED, STATUS_PAYMENT_REQUESTED, STATUS_PAYMENT_RECEIVED};
    Id fullPaymentRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Final_Payment').getRecordTypeId();
    Map<Id,Payment__c> caseWithLatestPayment = new Map<Id, Payment__c>();

    for (Case cRecord : newCaseList) {
      if (oldCaseMap.get(cRecord.id).Status != cRecord.Status && cRecord.Status =='Rejected' && cRecord.RecordTypeId == fullPaymentRecordTypeId){
        rejectedCaseIds.add(cRecord.Id);
      }
    }
    for(Payment__c paymentRecord : [Select Id, Case__c, Status__c From Payment__c Where Case__c IN : rejectedCaseIds AND Status__c IN : statusToInclude order by createddate desc]){
      if(!caseWithLatestPayment.containsKey(paymentRecord.Case__c)){
        caseWithLatestPayment.put(paymentRecord.Case__c, paymentRecord);
      }
    }

    for(Case cRecord : newCaseList){
      if(caseWithLatestPayment.containsKey(cRecord.Id)){
        cRecord.addError(Err_Msg);
      }
    }
  }
  
   public static void finalPaymentCaseValidation_Cancellation(List<Case> newCaseList, Map<Id,Case>oldCaseMap){
    Set<Id> CancelledCaseIds = new Set<Id>();
    Set<String> statusToInclude = new Set<String>{STATUS_CREATED, STATUS_PAYMENT_REGISTERED, STATUS_PAYMENT_REQUESTED,STATUS_PAYMENT_RECEIVED};
    Id fullPaymentRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Final_Payment').getRecordTypeId();
    Map<Id,Payment__c> caseWithLatestPayment = new Map<Id, Payment__c>();

    for (Case cRecord : newCaseList) {
      
         if (oldCaseMap.get(cRecord.id).Status != cRecord.Status && cRecord.Status =='Cancelled' && cRecord.RecordTypeId == fullPaymentRecordTypeId){
        CancelledCaseIds.add(cRecord.Id);
      }
    }
    
    for(Payment__c paymentRecord : [Select Id, Case__c, Status__c From Payment__c Where Case__c IN : CancelledCaseIds AND Status__c IN : statusToInclude order by createddate desc]){
      if(!caseWithLatestPayment.containsKey(paymentRecord.Case__c)){
        caseWithLatestPayment.put(paymentRecord.Case__c, paymentRecord);
      }
    }

    for(Case cRecord : newCaseList){
      if(caseWithLatestPayment.containsKey(cRecord.Id)){
      //if (cRecord.Status =='Cancelled')
      //{
       cRecord.addError(Err_Msg_Cancellation);
      //  }
        
      //  if (cRecord.Status =='Rejected')
     //  {
      //  cRecord.addError(Err_Msg);
        //}
      }
    }
  
  }
  public static void ITE_CaseValidation_Cancellation(List<Case> newCaseList, Map<Id,Case>oldCaseMap){
    Set<Id> CancelledCaseIds = new Set<Id>();
    Set<String> statusToInclude = new Set<String>{STATUS_CREATED, STATUS_PAYMENT_REGISTERED, STATUS_PAYMENT_REQUESTED};
    Id ITERecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Income_Threshold_Exceeded').getRecordTypeId();
    Profile p = [select id,Name from Profile where id=:Userinfo.getProfileid()];
    Map<Id,Payment__c> caseWithLatestPayment = new Map<Id, Payment__c>();

    for (Case cRecord : newCaseList) {
         if (oldCaseMap.get(cRecord.id).Status != cRecord.Status && cRecord.Status =='Cancelled' && cRecord.RecordTypeId == ITERecordTypeId){
        CancelledCaseIds.add(cRecord.Id);
      }
    }
    for(Payment__c paymentRecord : [Select Id, Case__c, Status__c From Payment__c Where Case__c IN : CancelledCaseIds AND Status__c IN : statusToInclude order by createddate desc]){
      if(!caseWithLatestPayment.containsKey(paymentRecord.Case__c)){
        caseWithLatestPayment.put(paymentRecord.Case__c, paymentRecord);
      }
    }

    for(Case cRecord : newCaseList){
      if(caseWithLatestPayment.containsKey(cRecord.Id)&&(p.Name =='Operations')){
      
       cRecord.addError(Err_Msg_Cancellation);
     
      }
    }
    }
  }