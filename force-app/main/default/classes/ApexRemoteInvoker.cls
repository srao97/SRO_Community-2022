global with sharing class ApexRemoteInvoker implements vlocity_ins.VlocityOpenInterface2 {

    global Object invokeMethod (
        String methodName, Map<String, Object> inputMap, Map<String, Object> outputMap, Map<String, Object> options
    ) {

        String className = String.valueOf(options.get('serviceClass'));
        String method = String.valueOf(options.get('serviceMethod'));
        
        
        Type OI2;
        Type OI;
        
        if(vlocity_ins.VlocityOpenInterface2.class.isAssignableFrom(Type.forName(className))) {
            OI2 = Type.forName(className);
        } else if(vlocity_ins.VlocityOpenInterface.class.isAssignableFrom(Type.forName(className))) {
            OI = Type.forName(className);
        } else {
            // return error class is not callable;
            outputMap.put('errorCode', 'INVOKECLASS-404');
            outputMap.put('error', 'Class not found: '+className);
            return null;
        }

        if('withoutSharing'.equals(methodName)) {
            WithoutSharingInvoker woInvoker = new WithoutSharingInvoker();
            if(OI == null) {
                return woInvoker.invokeMethod(
                    (vlocity_ins.VlocityOpenInterface2)OI2.newInstance(), method, inputMap, outputMap, options
                );
            } else {
                return woInvoker.invokeMethod(
                    (vlocity_ins.VlocityOpenInterface)OI.newInstance(), method, inputMap, outputMap, options
                );
            }
        } else {
            // default with sharing
            WithSharingInvoker wInvoker = new WithSharingInvoker();
            if(OI == null) {
                return wInvoker.invokeMethod(
                    (vlocity_ins.VlocityOpenInterface2)OI2.newInstance(), method, inputMap, outputMap, options
                );
            } else {
                return wInvoker.invokeMethod(
                    (vlocity_ins.VlocityOpenInterface)OI.newInstance(), method, inputMap, outputMap, options
                );
            }
        }
        
    }


    private with sharing class WithSharingInvoker {

        public Object invokeMethod(
            vlocity_ins.VlocityOpenInterface classInstance, String methodName, Map<String, Object> inputMap,
            Map<String, Object> outputMap,  Map<String, Object> optionsMap
        ) {

            return classInstance.invokeMethod(methodName, inputMap, outputMap, optionsMap);

        }

        public Object invokeMethod(
            vlocity_ins.VlocityOpenInterface2 classInstance, String methodName, Map<String, Object> inputMap,
            Map<String, Object> outputMap,  Map<String, Object> optionsMap
        ) {

            return classInstance.invokeMethod(methodName, inputMap, outputMap, optionsMap);

        }

    }

    private without sharing class WithoutSharingInvoker {

        public Object invokeMethod(
            vlocity_ins.VlocityOpenInterface classInstance, String methodName, Map<String, Object> inputMap,
            Map<String, Object> outputMap,  Map<String, Object> optionsMap
        ) {

            return classInstance.invokeMethod(methodName, inputMap, outputMap, optionsMap);

        }

        public Object invokeMethod(
            vlocity_ins.VlocityOpenInterface2 classInstance, String methodName, Map<String, Object> inputMap,
            Map<String, Object> outputMap,  Map<String, Object> optionsMap
        ) {

            return classInstance.invokeMethod(methodName, inputMap, outputMap, optionsMap);

        }

    }

}