global with sharing class ModifyFileName implements vlocity_ins.VlocityOpenInterface {
    public Boolean invokeMethod(String methodName, Map < String, Object > input, Map < String, Object > outMap,Map < String, Object > optionMap) {
        try{
			if (methodName.equals('updateName')) {
                updateName(input, outMap);
			}
			if (methodName.equals('updateNMFileName')) {
                updateNMFileName(input, outMap);
			}
			return true;
		} catch(Exception e){
			system.debug(e.getLineNumber());
            return false;
		}
    }
    public void updateName(Map < String, Object > input, Map < String, Object > outMap) {
        Map<String,Object> fileUpload = (Map<String,Object>)input.get('FileUpload');
        system.debug('@@fileUpload:' + json.serializePretty(fileUpload));
        Map<String,Object> participantUpload = new Map<String,Object>();
        Object last3Payslips;
        Object lastTaxReturn;
        String participantUploadName;
        // Participant1
		if(fileUpload.get('ParticipantUpload1') != null){
            participantUpload = (Map<String,Object>)fileUpload.get('ParticipantUpload1');
            participantUploadName = (String)participantUpload.get('ParticipantUploadName1');
		    last3Payslips = updateCommonFileName(participantUpload,'Last3Payslips1',participantUploadName+'_Evidence of Income_',0);
		    participantUpload.put('Last3Payslips1',last3Payslips);
            lastTaxReturn = updateCommonFileName(participantUpload,'LastTaxReturn1',participantUploadName+'_Previous Tax Assessment Notice_',0);
		    participantUpload.put('LastTaxReturn1',lastTaxReturn);
            fileUpload.put('ParticipantUpload1',participantUpload);
        }
        // Participant2
		if(fileUpload.get('ParticipantUpload2') != null){
            participantUpload = (Map<String,Object>)fileUpload.get('ParticipantUpload2');
            participantUploadName = (String)participantUpload.get('ParticipantUploadName2');
		    last3Payslips = updateCommonFileName(participantUpload,'Last3Payslips2',participantUploadName+ '_Evidence of Income_',0);
		    participantUpload.put('Last3Payslips2',last3Payslips);
            lastTaxReturn = updateCommonFileName(participantUpload,'LastTaxReturn2',participantUploadName+ '_Previous Tax Assessment Notice_',0);
		    participantUpload.put('LastTaxReturn2',lastTaxReturn);
            fileUpload.put('ParticipantUpload2',participantUpload);
        }
        // Participant3
		if(fileUpload.get('ParticipantUpload3') != null){
            participantUpload = (Map<String,Object>)fileUpload.get('ParticipantUpload3');
            participantUploadName = (String)participantUpload.get('ParticipantUploadName3');
		    last3Payslips = updateCommonFileName(participantUpload,'Last3Payslips3',participantUploadName+ '_Evidence of Income_',0);
		    participantUpload.put('Last3Payslips3',last3Payslips);
            lastTaxReturn = updateCommonFileName(participantUpload,'LastTaxReturn3',participantUploadName+ '_Previous Tax Assessment Notice_',0);
		    participantUpload.put('LastTaxReturn3',lastTaxReturn);
            fileUpload.put('ParticipantUpload3',participantUpload);
        }
        // Participant4
		if(fileUpload.get('ParticipantUpload4') != null){
            participantUpload = (Map<String,Object>)fileUpload.get('ParticipantUpload4');
            participantUploadName = (String)participantUpload.get('ParticipantUploadName4');
		    last3Payslips = updateCommonFileName(participantUpload,'Last3Payslips4',participantUploadName+ '_Evidence of Income_',0);
		    participantUpload.put('Last3Payslips4',last3Payslips);
            lastTaxReturn = updateCommonFileName(participantUpload,'LastTaxReturn4',participantUploadName+ '_Previous Tax Assessment Notice_',0);
		    participantUpload.put('LastTaxReturn4',lastTaxReturn);
            fileUpload.put('ParticipantUpload4',participantUpload);
        }
		
        // Home Loan Statement	
		Object homeLoanStatement = updateCommonFileName(fileUpload,'HomeLoanStatement','Home Loan Statement',1);
		fileUpload.put('HomeLoanStatement',homeLoanStatement);
		
		// certificate Of Currency
		Object certificateOfCurrency = updateCommonFileName(fileUpload,'CertificateOfCurrency','Certificate of Currency',1);
        fileUpload.put('CertificateOfCurrency',certificateOfCurrency);
		
		// Rates Notice
		Object ratesNotice = updateCommonFileName(fileUpload,'RatesNotice','Rates Notice',1);
		fileUpload.put('RatesNotice',ratesNotice);
		
		// Water Charges
        Object waterCharges = updateCommonFileName(fileUpload,'WaterCharges','Water Charges',1);
        fileUpload.put('WaterCharges',waterCharges);
		
		// GaseCharges
		Object gasCharges = updateCommonFileName(fileUpload,'GasCharges','Gas Charges',1);
        fileUpload.put('GasCharges',gasCharges);
        
        // ElectricityCharges
		Object ecCharges = updateCommonFileName(fileUpload,'ElectricityCharges','Electricity Charges',1);
        fileUpload.put('ElectricityCharges',ecCharges);
        
        outMap.put('FileUploadNew',fileUpload); 
        system.debug('@@outMap:' + json.serializePretty(outMap));
    }
	public void updateNMFileName(Map < String, Object > input, Map < String, Object > outMap) {
        Map<String,Object> fileUpload = (Map<String,Object>)input.get('FileUploadNonMandatory');
        System.debug('@@fileUpload:' + json.serializePretty(fileUpload));
        Map<String,Object> participantUpload = new Map<String,Object>();
        Object last3Payslips;
        Object lastTaxReturn;
        String participantUploadName;
        // Participant1
		if(fileUpload.get('ParticipantUploadNM1') != null){
            participantUpload = (Map<String,Object>)fileUpload.get('ParticipantUploadNM1');
            participantUploadName = (String)participantUpload.get('ParticipantUploadNameNM1');
		    if(participantUpload.get('Last3PayslipsNM1') != null){
				last3Payslips = updateCommonFileName(participantUpload,'Last3PayslipsNM1',participantUploadName+'_Evidence of Income_',0);
				participantUpload.put('Last3PayslipsNM1',last3Payslips);
			}
		    if(participantUpload.get('LastTaxReturnNM1') != null){
				lastTaxReturn = updateCommonFileName(participantUpload,'LastTaxReturnNM1',participantUploadName+'_Previous Tax Assessment Notice_',0);
				participantUpload.put('LastTaxReturnNM1',lastTaxReturn);
			}
            fileUpload.put('ParticipantUploadNM1',participantUpload);
        }
        // Participant2
		if(fileUpload.get('ParticipantUploadNM2') != null){
            participantUpload = (Map<String,Object>)fileUpload.get('ParticipantUploadNM2');
            participantUploadName = (String)participantUpload.get('ParticipantUploadNameNM2');
		    if(participantUpload.get('Last3PayslipsNM2') != null){
				last3Payslips = updateCommonFileName(participantUpload,'Last3PayslipsNM2',participantUploadName+ '_Evidence of Income_',0);
				participantUpload.put('Last3PayslipsNM2',last3Payslips);
			}
            if(participantUpload.get('LastTaxReturnNM2') != null){
				lastTaxReturn = updateCommonFileName(participantUpload,'LastTaxReturnNM2',participantUploadName+ '_Previous Tax Assessment Notice_',0);
				participantUpload.put('LastTaxReturnNM2',lastTaxReturn);
			}
            fileUpload.put('ParticipantUploadNM2',participantUpload);
        }
        // Participant3
		if(fileUpload.get('ParticipantUploadNM3') != null){
            participantUpload = (Map<String,Object>)fileUpload.get('ParticipantUploadNM3');
            participantUploadName = (String)participantUpload.get('ParticipantUploadNameNM3');
		    if(participantUpload.get('Last3PayslipsNM3') != null){
				last3Payslips = updateCommonFileName(participantUpload,'Last3PayslipsNM3',participantUploadName+ '_Evidence of Income_',0);
				participantUpload.put('Last3PayslipsNM3',last3Payslips);
			}
            if(participantUpload.get('LastTaxReturnNM3') != null){
				lastTaxReturn = updateCommonFileName(participantUpload,'LastTaxReturnNM3',participantUploadName+ '_Previous Tax Assessment Notice_',0);
				participantUpload.put('LastTaxReturnNM3',lastTaxReturn);
			}
            fileUpload.put('ParticipantUploadNM3',participantUpload);
        }
        // Participant4
		if(fileUpload.get('ParticipantUploadNM4') != null){
            participantUpload = (Map<String,Object>)fileUpload.get('ParticipantUploadNM4');
            participantUploadName = (String)participantUpload.get('ParticipantUploadNameNM4');
			if(participantUpload.get('Last3PayslipsNM4') != null){
				last3Payslips = updateCommonFileName(participantUpload,'Last3PayslipsNM4',participantUploadName+ '_Evidence of Income_',0);
				participantUpload.put('Last3PayslipsNM4',last3Payslips);
			}
			if(participantUpload.get('LastTaxReturnNM4') != null){
				lastTaxReturn = updateCommonFileName(participantUpload,'LastTaxReturnNM4',participantUploadName+ '_Previous Tax Assessment Notice_',0);
				participantUpload.put('LastTaxReturnNM4',lastTaxReturn);
			}
			fileUpload.put('ParticipantUploadNM4',participantUpload);
        }
		
        // Home Loan Statement	
		if(fileUpload.get('HomeLoanStatementNM') != null){
			Object homeLoanStatement = updateCommonFileName(fileUpload,'HomeLoanStatementNM','Home Loan Statement',1);
			fileUpload.put('HomeLoanStatementNM',homeLoanStatement);
		}
		
		// certificate Of Currency
		if(fileUpload.get('CertificateOfCurrencyNM') != null){
			Object certificateOfCurrency = updateCommonFileName(fileUpload,'CertificateOfCurrencyNM','Certificate of Currency',1);
			fileUpload.put('CertificateOfCurrencyNM',certificateOfCurrency);
		}
		
		// Rates Notice
		if(fileUpload.get('RatesNoticeNM') != null){
			Object ratesNotice = updateCommonFileName(fileUpload,'RatesNoticeNM','Rates Notice',1);
			fileUpload.put('RatesNoticeNM',ratesNotice);
		}
		
		// Water Charges
		if(fileUpload.get('WaterChargesNM') != null){	
			Object waterCharges = updateCommonFileName(fileUpload,'WaterChargesNM','Water Charges',1);
			fileUpload.put('WaterChargesNM',waterCharges);
		}
		// GaseCharges
		if(fileUpload.get('GasChargesNM') != null){
			Object gasCharges = updateCommonFileName(fileUpload,'GasChargesNM','Gas Charges',1);
			fileUpload.put('GasChargesNM',gasCharges);
        }
            
        // ElectricityCharges
        if(fileUpload.get('ElectricityChargesNM') != null){
			Object ecCharges = updateCommonFileName(fileUpload,'ElectricityChargesNM','Electricity Charges',1);
        	fileUpload.put('ElectricityChargesNM',ecCharges);
		}
        outMap.put('NMFileUploadNew',fileUpload); 
        System.debug('@@outMap:' + json.serializePretty(outMap));
    }
    public Object updateCommonFileName(Map < String, Object > fileUpload,String node,String newFileName, Integer flag){
        List<Object> commonFile = (List<Object>)fileUpload.get(node);
		System.debug('@@commonFile:' + json.serializePretty(commonFile));
        List<Object> updCommonFile = new List<Object>();
		if(commonFile == null) return updCommonFile;
        String fName;
		for(Object o : commonFile){
            Map<String,Object> file = (Map<String,Object>)o;
            fName = (String)file.get('filename');
            if(flag ==1){
                file.put('filename',newFileName  + '.' + fName.substringAfter('.'));
            }
            else{
                file.put('filename',newFileName  + fName);
            }
            updCommonFile.add(o);
		}
        System.debug('@@updCommonFile:' + json.serializePretty(updCommonFile));
        return updCommonFile;
    }
}