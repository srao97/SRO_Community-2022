@IsTest
public class BusinessDaysCalculationTest {    
    @IsTest
    private static void testBusinessDaysMoreThanFive() {
        Test.startTest();
        BusinessDaysCalculation calculator = new BusinessDaysCalculation();
        Date dToday = Date.today()+20;
        String scheduledDate = String.valueOf(dToday.day()).leftPad(2,'0') + '/' + String.valueOf(dToday.month()).leftPad(2,'0') + '/' + dToday.year();
        
        Map<String, Object> inputMap = new Map<String, Object>{'scheduledDate' => scheduledDate};
        Map<String, Object> outputMap = new Map<String, Object> ();
        Map<String, Object> options = new Map<String, Object> ();
        
        calculator.invokeMethod(
            'validateDays', inputMap, outputMap, options
        );
        
        System.assertEquals('false', String.valueOf(outputMap.get('ErrorMsg')));
        Test.stopTest();
    }
    
    @IsTest
    private static void testBusinessDaysLessThanFive() {
        Test.startTest();
        BusinessDaysCalculation calculator = new BusinessDaysCalculation();
        Date dToday = Date.today()+2;
        String scheduledDate = String.valueOf(dToday.day()).leftPad(2,'0') + '/' + String.valueOf(dToday.month()).leftPad(2,'0') + '/' + dToday.year();
        
        Map<String, Object> inputMap = new Map<String, Object>{'scheduledDate' => scheduledDate};
        Map<String, Object> outputMap = new Map<String, Object> ();
        Map<String, Object> options = new Map<String, Object> ();
        
        calculator.invokeMethod(
            'validateDays', inputMap, outputMap, options
        );
        
        System.assertEquals('true', String.valueOf(outputMap.get('ErrorMsg')));
        
        Test.stopTest();
    }
    
    @IsTest
    private static void testBusinessDaysWithPastDate() {
        Test.startTest();
        BusinessDaysCalculation calculator = new BusinessDaysCalculation();
        Date dToday = Date.today()-2;
        String scheduledDate = String.valueOf(dToday.day()).leftPad(2,'0') + '/' + String.valueOf(dToday.month()).leftPad(2,'0') + '/' + dToday.year();
        
        Map<String, Object> inputMap = new Map<String, Object>{'scheduledDate' => scheduledDate};
        Map<String, Object> outputMap = new Map<String, Object> ();
        Map<String, Object> options = new Map<String, Object> ();
        
        calculator.invokeMethod(
            'validateDays', inputMap, outputMap, options
        );
        
        System.assertEquals('false', String.valueOf(outputMap.get('ErrorMsg')));
	}

    @isTest
    private static void testGetWorkingDayDateAfterNDays_Test(){
        Test.startTest();
        String sMethodName = 'getWorkingDayDateAfterNDays';
        Map<String, Object> inputMap = new Map<String, Object>{'NthWorkingDay'=>5,'startDate'=>'2021-08-13T14:00:00.000Z'};
        Map<String, Object> outputMap = new Map<String, Object>();
        Map<String, Object> options = new Map<String, Object>();
        new BusinessDaysCalculation().invokeMethod(sMethodName, inputMap, outputMap, options);
        system.assertEquals('2021-08-20', String.valueOf((Date)outputMap.get('NthWorkingDay_Date')));
        Test.stopTest();
    }
}