global without sharing class BusinessDaysCalculation implements vlocity_ins.VlocityOpenInterface{
    public Boolean invokeMethod(String methodName,Map<String, Object> input,Map<String, Object> output,Map<String, Object> options){
        if(methodName == 'validateDays'){
          calculateWorkingDays(input, output, options);
        }
        if(methodName == 'getWorkingDayDateAfterNDays'){
            getWorkingDayDateAfterNDays(input, output, options);
          }
        return true;
    }
    public void getWorkingDayDateAfterNDays(Map<String, Object> input,Map<String, Object> output,Map<String, Object> options){
        try{
            if((Integer)input.get('NthWorkingDay') == null || (String)input.get('startDate') == ''){
                output.put('ErrorMsg','Both the input params "startDate" and "NthWorkingDay" are mandatory');
                return;
            }
            Integer iNthWorkingDay = (Integer)input.get('NthWorkingDay');
            String sStartDate = ((String)input.get('startDate')).split('T')[0];
            Set<Date> holidaysSet = new Set<Date>();
            for(Holiday currHoliday : [SELECT Id, ActivityDate FROM holiday]){
                holidaysSet.add(currHoliday.ActivityDate);  
            }
            Date NextWorkingDay_Date = Date.valueOf(sStartDate);
            for(integer i=0; i < iNthWorkingDay; i++){
                NextWorkingDay_Date = NextWorkingDay_Date + 1;
                DateTime NextWorkingDay_DateTime = DateTime.newInstance(NextWorkingDay_Date.year(), NextWorkingDay_Date.month(), NextWorkingDay_Date.day()); 
                String sNextWorkingDay_DayOfWeek = NextWorkingDay_DateTime.format('EEEE');
                if(sNextWorkingDay_DayOfWeek == 'Saturday' || sNextWorkingDay_DayOfWeek =='Sunday' || (holidaysSet.contains(NextWorkingDay_Date))){
                    i--;
                }
            }
            output.put('NthWorkingDay_Date',NextWorkingDay_Date);
        }
        catch(Exception oException){
            output.put('ErrorMsg',oException.getMessage());
        }
    }
    public void calculateWorkingDays(Map<String, Object> input,Map<String, Object> output,Map<String, Object> options){
        String scheduledDtStr = (String)input.get('scheduledDate');
        Date endDate;
        system.debug('scheduledDtStr ' +scheduledDtStr);
        if(scheduledDtStr !=null){
            endDate = Date.parse(scheduledDtStr);
        }
        Date startDate = System.today()+1;
        Date startDatePlusTwo = System.today().AddYears(2);

        if(endDate == null){
            output.put('ErrorMsg',false);
            output.put('ErrorMoreThan2yrs',false);
        }
        else if(startDatePlusTwo.daysBetween(endDate)>0){
            output.put('ErrorMoreThan2yrs',true);
            output.put('ErrorMsg',false);
        }
        else{
            Set<Date> holidaysSet = new Set<Date>();
            for(Holiday currHoliday : [SELECT Id, ActivityDate FROM holiday]){
                holidaysSet.add(currHoliday.ActivityDate);  
            }

            Integer workingDays = 0;  
            if(startDate.daysBetween(endDate)<0){
                output.put('ErrorMsg',false);
                output.put('ErrorMoreThan2yrs',false);
            } 
            else{
                for(integer i=0; i <= startDate.daysBetween(endDate); i++){  
                    Date dt = startDate + i;  
                    DateTime currDate = DateTime.newInstance(dt.year(), dt.month(), dt.day());  
                    String todayDay = currDate.format('EEEE');  
                    if(todayDay != 'Saturday' && todayDay !='Sunday' && (!holidaysSet.contains(dt))){
                        workingDays = workingDays + 1;
                    }   
                }     
                System.debug('--Working days'+workingDays);
                if(workingDays < 5){
                    output.put('ErrorMsg',true);
                    output.put('ErrorMoreThan2yrs',false);
                } 
                else{
                    output.put('ErrorMsg',false);
                    output.put('ErrorMoreThan2yrs',false);
                }
            }
        }
    } 
}