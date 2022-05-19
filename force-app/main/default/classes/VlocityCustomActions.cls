global with sharing class VlocityCustomActions implements vlocity_ins.VlocityOpenInterface{
    global Boolean invokeMethod(String methodName,Map<String, Object> input,Map<String, Object> output,Map<String, Object> options){
        try{
            if(methodName == 'UpdateNewPanelFinancier'){
                UpdateCaseHandler.UpdateNewPanelFinancier(input, output, options);
            }
            if(methodName == 'TransformListtoObject'){
                List<Object> list2Return = TransformListtoObject(input, output, options);
                output.put('result', list2Return);
            }
        }
        catch(Exception oException){ system.debug(oException.getStackTraceString()); output.put('result', oException.getStackTraceString());}
        return true;
    }

    public List<Object> TransformListtoObject(Map<String, Object> input,Map<String, Object> output,Map<String, Object> options){
        system.debug('arguments'+input.get('arguments'));
        List<Object> listObjects = new List<Object>();
        if(input.get('arguments') instanceOf List<Object>){
            listObjects = (List<Object>)input.get('arguments');
        }
        else{
            listObjects.add(input.get('arguments'));
        }
        Map<String, Object> mapResult = new Map<String, Object>();
        List<Object> list2Return = new List<Object>();
        String sTempString = '';
        for(Object oObject : listObjects){
            sTempString = (String)oObject;
            list2Return.add(new Map<String,Object>{'name'=>sTempString.normalizeSpace()});
        }
        return list2Return;
    }
}