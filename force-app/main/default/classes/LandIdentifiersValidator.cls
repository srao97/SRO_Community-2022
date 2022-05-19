global without sharing class LandIdentifiersValidator implements vlocity_ins.VlocityOpenInterface2 {
    global Object invokeMethod (
        String methodName, Map<String, Object> input, Map<String, object> output, Map<String, Object> options
    ){
        try {
            Boolean status = false;
            if('ValidateLotPlan'.equals(methodName)) {
                ValidateLotPlan(input, output, options);
                status = true;
            } else if('ValidateVolumeFolio'.equals(methodName)) {
                ValidateVolumeFolio(input, output, options);
                status = true;
            }
            return status;
        } catch(TypeException te) {
            output.put('errorMsg', 'Bad Request');
            output.put('errorCode', 'INVOKE-400');
            output.put('validity', 'Invalid');
            return false;
        }
    }
    public static final Pattern VOLUME_PATTERN = Pattern.compile('[0-9]{1,5}$');
    public static final Pattern FOLIO_PATTERN = Pattern.compile('([0-9]{1,3})([ABCKLabckl ]{0,1})$');
    private static final Pattern PATTERN_FOLIOS_ALPHA_INDICATOR_REQUIRING_RANGE_CHECK = Pattern.compile(
            '^([A-Ca-c ]{0,1})$');
        
    public static void ValidateLotPlan(Map<String, Object> input, Map<String, object> output, Map<String, Object> options) {
        output.clear();
        string lot = string.valueof(input.get('Lot'));
        //string lot = string.valueof(input.get('Lot_Number__c'));
        System.debug('---Plan original ---'+ string.valueof(input.get('Plan')));
        string plan = string.valueof(input.get('Plan'));
        //string plan = string.valueof(input.get('Plan_Number__c'));
        System.debug('@@@lot'+string.valueof(input.get('Lot_Number__c')));
        System.debug('@@@plan'+string.valueof(input.get('Plan_Number__c')));
         if(!String.isBlank(plan) || !String.isBlank(lot)) {
            validateLotPlan(lot, plan, output);
         } else {
              output.put('validity', 'Valid');
         }
    }
    public static void ValidateVolumeFolio(Map<String, Object> input, Map<String, object> output, Map<String, Object> options) {
        string Volume = string.valueof(input.get('Volume'));
         //string Volume = string.valueof(input.get('Volume__c'));
       
        string Folio = string.valueof(input.get('Folio'));
         //string Folio = string.valueof(input.get('Folio__c'));
       
        validateVolumeFolio(volume, folio, output);
    }
    
    public static void validateVolumeFolio(String volume, String folio, Map<String, object> output) {
        if(isValidVolume(volume,output)) {
            if(isValidFolio(folio,output)) {
                if(!isValidVolumeFolio(volume,folio)) {
                    output.put('errorMsgF', 'Invalid Volume/Folio: Please check the title, land transfer or contract of sale and re-enter the correct land identifiers');
                    output.put('errorCode', 'INVOKE-422');
                    output.put('validity', 'Invalid');
                }else {
                   output.put('validity', 'Valid');
                }
            }
        }
    }
    private static boolean isValidVolume(String volume, Map<String, object> output) {
        if(isBlankVolume(volume,output) || !isValidPatternVolume(volume,output) ) {
            return false;
        } else {
            return true;
        }
    }
    private static boolean isValidPatternVolume(String volume, Map<String, object> output) {
        boolean validVolume = VOLUME_PATTERN.matcher(volume).matches();
        if(!validVolume) {
            output.put('errorMsgF', 'Invalid Volume: Please check the title, land transfer or contract of sale and re-enter the correct land identifiers');
            output.put('errorCode', 'INVOKE-422');
            output.put('validity', 'Invalid');
            return false;
        }
        return true;
    }
    private static boolean isBlankVolume(String volume, Map<String, object> output) {
        if(String.isBlank(volume)) {
            output.put('errorMsgF', 'Volume is required');
            output.put('errorCode', 'INVOKE-422');
            output.put('validity', 'Invalid');
            return true;
        }
        return false;
    }
    private static boolean isValidFolio(String folio, Map<String, object> output) {
        if(String.isBlank(folio)) {
            output.put('errorMsgF', 'Folio is required');
            output.put('errorCode', 'INVOKE-422');
            output.put('validity', 'Invalid');
            return false;
        } else {
            boolean validFolio = FOLIO_PATTERN.matcher(folio).matches();
            if(!validFolio) { 
                output.put('errorMsgF', 'Invalid Folio: Please check the title, land transfer or contract of sale and re-enter the correct land identifiers');
                output.put('errorCode', 'INVOKE-422');
                output.put('validity', 'Invalid');
                return false;
            }
        }
        return true;
    }
    
    private static boolean isValidVolumeFolio(String volume, String folio) {
        boolean valid = false;
        Matcher folioMatcher = FOLIO_PATTERN.matcher(folio);
        if (folioMatcher.matches()) {
            valid = validateFoliosRange(volume, folioMatcher.group(1), folioMatcher.group(2));
        }
        return valid;
    }
    
    private static boolean validateFoliosRange(String volume, String folioNoSuffix, String folioSuffix) {
        boolean valid = false;
        Integer volumeInt = Integer.valueOf(volume);
        Integer folioInt = Integer.valueOf(folioNoSuffix);
        
        if (PATTERN_FOLIOS_ALPHA_INDICATOR_REQUIRING_RANGE_CHECK.matcher(folioSuffix).matches()) {
            
            If( volumeInt >= 9549 && volumeInt <= 99999){ 
                if( folioInt >= 0 && folioInt <= 999) {
                    valid = true;
                }
            } else if (volumeInt >= 8030 && volumeInt <= 9548) {
                if( folioInt >= 1 && folioInt <= 999) {
                    valid = true;
                }
            } else if (volumeInt >= 7451 && volumeInt <= 8029) {
                if( folioInt >= 1 && folioInt <= 200) {
                    valid = true;
                }
            } else if (volumeInt >= 1 && volumeInt <= 7450) {
                String volumeLastDigit = volume.substring(volume.length() - 1, volume.length());
                if ('1'.equals(volumeLastDigit) || '6'.equals(volumeLastDigit)) {
                    if( folioInt >= 1 && folioInt <= 200) {
                        valid = true;
                    }
                } else if ('2'.equals(volumeLastDigit) || '7'.equals(volumeLastDigit)) {
                    if( folioInt >= 201 && folioInt <= 400) {
                        valid = true;
                    }
                } else if ('3'.equals(volumeLastDigit) || '8'.equals(volumeLastDigit)) {
                    if( folioInt >= 401 && folioInt <= 600) {
                        valid = true;
                    }
                } else if ('4'.equals(volumeLastDigit) || '9'.equals(volumeLastDigit)) {
                    if( folioInt >= 601 && folioInt <= 800) {
                        valid = true;
                    }
                } else if ('5'.equals(volumeLastDigit) || '0'.equals(volumeLastDigit)) {
                    if( folioInt == 0 || folioInt >= 801 && folioInt <= 999) {
                        valid = true;
                    }
                }
            }
        } else {
            valid = true;
        }
        return valid;
    }
    
    
    public static final Pattern LOT_PATTERN = Pattern.compile('^[a-zA-Z0-9 ]{1,10}$');
    public static final Pattern PLAN_PATTERN = Pattern.compile('([A-Z]{2})([0-9]{6})([A-Z]{0,1})$');
    
    private static final Set<String> VALID_PLAN_PREFIXES = new Set<String>{'LP', 'PS', 'CP', 'PC','SP', 'CS', 'TP', 'RP'};
        
    private enum Alphabet {
            A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U, V, W, X, Y, Z
                }
    private enum ReverseAlphabetCheckSum {
        Y, X, W, V, U, T, S, R, Q ,P, N, M, L, K, J, H, G, F, E, D, C, B, A
            }
    
    public static void validateLotPlan(String lot, String planInput, Map<String, object> output) {
        String plan = (planInput != null ? planInput.toUpperCase() : planInput);
        if(!String.isBlank(plan) || !String.isBlank(lot)) {
            System.debug('@@@static void validateLotPlan-'+plan);
            if(isValidLot(lot,output)) {
            	if(isValidPlan(plan,output)) {
                    if(!isValidLotPlan(plan)) {
                        output.put('errorMsgP', 'Invalid Plan number: Please check the title, land transfer or contract of sale and re-enter the correct land identifiers');
                        output.put('errorCode', 'INVOKE-422');
                        output.put('validity', 'Invalid');
                    }else {                
                        output.put('validity', 'Valid');
                    }
                }
        	}
        } else {
             output.put('validity', 'Valid');
        }
        
    }
    private static boolean isValidLot(String lot, Map<String, object> output) {
        if(isBlankLot(lot,output) || !isValidPatternLot(lot,output)) {
            return false;
        } else {
            return true;
        }
    }
    
    private static boolean isBlankLot(String lot, Map<String, object> output) {
        if(String.isBlank(lot)) {
            output.put('errorMsgP', 'Lot is required');
            output.put('errorCode', 'INVOKE-422');
            output.put('validity', 'Invalid');
            return true;
        }
        return false;
    }
    private static boolean isValidPatternLot(String lot, Map<String, object> output) {
        System.debug('@@@lot number-- '+ lot);
        String lotNoSpace = lot.replaceAll(' ', '');
        System.debug('@@@lotNoSpace number-- '+ lotNoSpace);
        boolean validLot = LOT_PATTERN.matcher(lotNoSpace).matches();
          System.debug('@@@validLot'+validLot);
        if(!validLot) {
            output.put('errorMsgP', 'Invalid Lot number: Please check the title, land transfer or contract of sale and re-enter the correct land identifiers');
            output.put('errorCode', 'INVOKE-422');
            output.put('validity', 'Invalid');
            return false;
        }
        return true;
    }
    
    private static boolean isValidPlan(String plan, Map<String, object> output) {
        if(isBlankPlan(plan,output) || !isValidPatternPlan(plan,output)) {
            return false;
        } else {
            return true;
        }
    }
    
    private static boolean isBlankPlan(String plan, Map<String, object> output) {
        if(String.isBlank(plan)) {
            output.put('errorMsgP', 'Plan is required');
            output.put('errorCode', 'INVOKE-422');
            output.put('validity', 'Invalid');
            return true;
        }
        return false;
    }
    private static boolean isValidPatternPlan(String plan, Map<String, object> output) {
         System.debug('--isValidPatternPlan-- '+ plan);
        boolean validPlan = PLAN_PATTERN.matcher(plan).matches();
         System.debug('@@@validPlan'+validPlan);
        if(!validPlan) {
            output.put('errorMsgP', 'Invalid Plan number: Please check the title, land transfer or contract of sale and re-enter the correct land identifiers');
            output.put('errorCode', 'INVOKE-422');
            output.put('validity', 'Invalid');
            return false;
        }
        return true;
    }
    
    private static boolean isValidLotPlan(String plan) {
        boolean valid = false;
        Matcher planMatcher = PLAN_PATTERN.matcher(plan);
         System.debug('@@@planMatcher'+planMatcher);
        if (planMatcher.matches()) {
            valid = validateLotPlanFormat(planMatcher.group(1), planMatcher.group(2), planMatcher.group(3));
        }
        return valid;
    }
    private static boolean validateLotPlanFormat(String planPrefix, String planNumber, String checkDigit) {
        return validatePlanType(planPrefix) && validatePlanRanges(planPrefix, planNumber)
            && validatePlanCheckDigit(planPrefix, planNumber, checkDigit);
    }
    
    private static boolean validatePlanType(String planPrefix) {
        return VALID_PLAN_PREFIXES.contains(planPrefix);
    }
    
    private static boolean validatePlanRanges(String planPrefix, String planNumber) {
        boolean valid = false;
        Integer planNumberInt = Integer.valueOf(planNumber);
        
        if ('LP'.equals(planPrefix)) {
            If( (planNumberInt >= 1 && planNumberInt <= 99999) || 
               (planNumberInt >= 110000 && planNumberInt <= 149999) ||
               (planNumberInt >= 200000 && planNumberInt <= 299999) ){
                   valid = true;
               }
        } else if ('PS'.equals(planPrefix)) {
            If( (planNumberInt >= 1 && planNumberInt <= 350000) || 
               (planNumberInt >= 400001 && planNumberInt <= 450000) ||
               (planNumberInt >= 500001 && planNumberInt <= 550000) ||
               (planNumberInt >= 600001 && planNumberInt <= 650000) ||
               (planNumberInt >= 700001 && planNumberInt <= 750000) ||
               (planNumberInt >= 800001 && planNumberInt <= 850000) ||
               (planNumberInt >= 900001 && planNumberInt <= 950000)) {
                   valid = true;
               }
        } else if ('CP'.equals(planPrefix)) {
            if ((planNumberInt >= 100000 && planNumberInt <= 109999) ||
                (planNumberInt >= 150000 && planNumberInt <= 199999)) {
                    valid = true;
                }
        } else if ('PC'.equals(planPrefix)) {
            if ((planNumberInt >= 350001 && planNumberInt <= 400000) ||
                (planNumberInt >= 450001 && planNumberInt <= 500000) ||
                (planNumberInt >= 550001 && planNumberInt <= 600000) ||
                (planNumberInt >= 650001 && planNumberInt <= 700000) ||
                (planNumberInt >= 750001 && planNumberInt <= 800000) ||
                (planNumberInt >= 850001 && planNumberInt <= 900000) ||
                (planNumberInt >= 950001 && planNumberInt <= 999999)) {
                    valid = true; 
                }   
        } else if ('SP'.equals(planPrefix)) {
            if (planNumberInt >= 19926 && planNumberInt <= 999999) {
                valid = true;
            }
        } else if ('CS'.equals(planPrefix)) {
            If( planNumberInt >= 1000 && planNumberInt <= 999999) {
                valid = true;
            }
        } else if ('TP'.equals(planPrefix)) {
            If( planNumberInt >= 1 && planNumberInt <= 999999) {
                valid = true;
            }
        } else if ('RP'.equals(planPrefix)) {
            If( planNumberInt >= 1 && planNumberInt <= 19925) {
                valid = true;
            }
        }
        return valid;
    }
    
    private static Integer getAlphabetOrdinal(String planPrefixPos) {
        Alphabet planPrefixAlhpa;
        for (Alphabet alpha: Alphabet.values()) {
            if (alpha.name() == planPrefixPos) {
                planPrefixAlhpa = alpha;
                return alpha.ordinal();
            }
        }
        return null;
    }
    
    private static boolean validatePlanCheckDigit(String planPrefix, String planNumber, String checkDigit) {
        boolean valid = false;
        String expectedCheckCharacter = '';
        if (isCheckDigitRequired(planPrefix, planNumber)) {
            Integer planPrefixPart1Ordinal = getAlphabetOrdinal(planPrefix.substring(0, 1));
            Integer planPrefixPart2Ordinal = getAlphabetOrdinal(planPrefix.substring(1, 2));
            
            if(planPrefixPart1Ordinal == null || planPrefixPart2Ordinal == null) {
                return false;
            }
            Integer totalCheckDigit =
                (9 * ( planPrefixPart1Ordinal + 1))
                + (8 * (planPrefixPart2Ordinal + 1))
                + (7 * Integer.valueOf(planNumber.substring(0, 1)))
                + (6 * Integer.valueOf(planNumber.substring(1, 2)))
                + (5 * Integer.valueOf(planNumber.substring(2, 3)))
                + (4 * Integer.valueOf(planNumber.substring(3, 4)))
                + (3 * Integer.valueOf(planNumber.substring(4, 5)))
                + (2 * Integer.valueOf(planNumber.substring(5, 6)));
            
            Integer expectedCheckDigitOrdinal = Math.mod(totalCheckDigit,23) + 1;
            System.debug('@@@expectedCheckDigitOrdinal'+expectedCheckDigitOrdinal);
            expectedCheckCharacter = ReverseAlphabetCheckSum.values()[expectedCheckDigitOrdinal - 1].name();
             System.debug('@@@expectedCheckCharacter'+expectedCheckCharacter);
        }
        valid = expectedCheckCharacter.equals(checkDigit);
        return valid;
    }
    
    private static boolean isCheckDigitRequired(String planPrefix, String planNumber) {
        boolean required = true;
        Integer planNumberInt = Integer.valueOf(planNumber);
        
        if ('LP'.equals(planPrefix))  {
            If( (planNumberInt >= 1 && planNumberInt <= 99999) || (planNumberInt >= 110000 && planNumberInt <= 145851)) {
                required = false;
            }
        } else if ('SP'.equals(planPrefix)) {
            If( (planNumberInt >= 1 && planNumberInt <= 20335)) {
                required = false;
            }
        } else if ('CS'.equals(planPrefix)) {
            If( (planNumberInt >= 1000 && planNumberInt <= 1386)) {
                required = false;
            }
        } else if ('CP'.equals(planPrefix)) {
            If( (planNumberInt >= 100000 && planNumberInt <= 109999) || (planNumberInt >= 150000 && planNumberInt <= 157284)) {
                required = false;
            }
        }
        return required;
    }
    
}