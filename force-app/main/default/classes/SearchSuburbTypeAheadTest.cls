@isTest
public class SearchSuburbTypeAheadTest {
    @testSetup
    static void setupTestData(){
    }
    @isTest
    static void testSearchSuburbTypeAhead_Success() {
        Test.startTest();
        TypeAheadSuburb__mdt oTypeAheadSuburb = new TypeAheadSuburb__mdt(
            SuburbSet__c = 'TEST Estate,Addington,Airly,Alfredton,Ashbourne,Athlone,Avenel, Bacchus Marsh, Bairnsdale, Bald Hills, Carlsruhe, Cashmore, Castle Creek, Castlemaine, Chewton'
        );
        SearchSuburbTypeAhead.listTypeAheadSuburbs.add(oTypeAheadSuburb);
        SearchSuburbTypeAhead oSearchSuburbTypeAhead = new SearchSuburbTypeAhead();
        Map<String, List<Object>> mapInputs= new Map<String, List<Object>>{'arguments'=>new List<Object>{'TEST'}};
        Map<String,Object> mapOutput = new Map<String, Object>();
        oSearchSuburbTypeAhead.invokeMethod('SearchSuburb', mapInputs, mapOutput, new Map<String, Object>{});
        List<Object> listOutput = new List<Object>();
        listOutput = (List<Object>)mapOutput.get('result');
        system.assertEquals(1, listOutput.size());
        Test.stopTest();
    }

    @isTest
    static void testSearchSuburbTypeAhead_NoResults() {
        Test.startTest();
        TypeAheadSuburb__mdt oTypeAheadSuburb = new TypeAheadSuburb__mdt(
            SuburbSet__c = 'Addington,Airly,Alfredton,Ashbourne,Athlone,Avenel, Bacchus Marsh, Bairnsdale, Bald Hills, Carlsruhe, Cashmore, Castle Creek, Castlemaine, Chewton'
        );
        SearchSuburbTypeAhead.listTypeAheadSuburbs.add(oTypeAheadSuburb);
        SearchSuburbTypeAhead oSearchSuburbTypeAhead = new SearchSuburbTypeAhead();
        Map<String, List<Object>> mapInputs= new Map<String, List<Object>>{'arguments'=>new List<Object>{'TEST'}};
        Map<String,Object> mapOutput = new Map<String, Object>();
        oSearchSuburbTypeAhead.invokeMethod('SearchSuburb', mapInputs, mapOutput, new Map<String, Object>{});
        system.assertEquals(null, mapOutput.get('result'));
        Test.stopTest();
    }
}