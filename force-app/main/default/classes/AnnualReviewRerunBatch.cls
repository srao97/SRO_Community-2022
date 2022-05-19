/*******************************************************************************************
* @Name         AnnualReviewRerunBatch
* @Author       Sebastian Anton <santon@salesforce.com>
* @Date         12/11/2021
* @Description  Invocable method to call Annual Review batch class with specified period
*******************************************************************************************/
/* MODIFICATION LOG
* Version          Developer          Date               Description
*-------------------------------------------------------------------------------------------
*  1.0              Sebastian      21/10/2021          Initial Creation
*******************************************************************************************/
public class AnnualReviewRerunBatch {
    @InvocableMethod(label='Rerun Annual Review Batch' description='Run Annual Review batch process for specified month'category='Annual Review')
    public static void AnnualReviewRerunBatch(list<list<Integer>> requestedDate) {
        System.debug('*** INVOCABLE METHOD CALL: Rerun Annual Review Batch for Month: ' + requestedDate[0][0] + ' Year: ' + requestedDate[0][1]);
        AnnualReviewBatch annualReviewBatch = new AnnualReviewBatch();
        annualReviewBatch.specifiedMonth = requestedDate[0][0];
        annualReviewBatch.specifiedYear = requestedDate[0][1];
        DataBase.executeBatch(annualReviewBatch, 30);
    }
}