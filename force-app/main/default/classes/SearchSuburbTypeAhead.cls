global with sharing class SearchSuburbTypeAhead implements vlocity_ins.VlocityOpenInterface{
    private static final String SUBURB = 'Suburb';
    global Boolean invokeMethod(String methodName, Map<String, Object> inputs, Map<String, Object> output, Map<String, Object> options)
    {
        if (methodName == 'SearchSuburb')
        {
            List<Object> arguments = (List<Object>)inputs.get('arguments');
            output.put('result', searchSuburb(arguments));
        }
        
        return true;
    }
    List<Object> searchSuburb(List<Object> arguments)
    {
        List<Object> result = new List<Object>();
        List<String> subList = new List<String>();
        List<String> finalList = new List<String>();
        String key = (String)arguments[0];
        for(TypeAheadSuburb__mdt sub : listTypeAheadSuburbs){
            subList = sub.SuburbSet__c.split(',');
            finalList.addAll(subList);
        }

        for(String str : finalList){
            if(str.startsWithIgnoreCase(key) || str.startsWithIgnoreCase(' '+key)){
                result.add(new Map<String, String>{SUBURB=>str});
            }
        }
        if(result.size() !=0){
            return result;
        }
        else{
            return null;
        }
    }

    @testVisible private static List<TypeAheadSuburb__mdt> listTypeAheadSuburbs {
        get {
            if (listTypeAheadSuburbs == null) {
                listTypeAheadSuburbs = [SELECT SuburbSet__c FROM TypeAheadSuburb__mdt];
            }
            return listTypeAheadSuburbs;
        }
        set;
    }
}