@IsTest
public class LandIdentifiersValidatorTest {
    
    @IsTest
    private static void testVolFolValidInputs() {
        
        Test.startTest();
        
        LandIdentifiersValidator validator = new LandIdentifiersValidator();
        
        Map<String, Object> inputMap = new Map<String, Object>();
        Map<String, Object> outputMap = new Map<String, Object> ();
        Map<String, Object> options = new Map<String, Object> ();
        
        validator.invokeMethod(
            'ValidateVolumeFolio', inputMap, outputMap, options
        );
        
        System.assertEquals('Volume is required', String.valueOf(outputMap.get('errorMsgF')));
        
        Map<String, Object> volFol = new Map<String, Object> {
            'Volume' => '8789',
                'Folio' => '900'
                };
                    //inputMap.put('data', volFol);
                    outputMap.clear();
        validator.invokeMethod(
            'ValidateVolumeFolio', volFol, outputMap, options
        );
        
        System.assertEquals('Valid', String.valueOf(outputMap.get('validity')));
        volFol.clear();
        
        // 9549 - 99999
        LandIdentifiersValidator.validateVolumeFolio('9549', '0', outputMap);
        System.assertEquals('Valid', String.valueOf(outputMap.get('validity')));
        outputMap.clear();
        
        LandIdentifiersValidator.validateVolumeFolio('9549', '555', outputMap);
        System.assertEquals('Valid', String.valueOf(outputMap.get('validity')));
        outputMap.clear();
        
        LandIdentifiersValidator.validateVolumeFolio('9549', '999', outputMap);
        System.assertEquals('Valid', String.valueOf(outputMap.get('validity')));
        outputMap.clear();
        
        LandIdentifiersValidator.validateVolumeFolio('25000', '0', outputMap);
        System.assertEquals('Valid', String.valueOf(outputMap.get('validity')));
        outputMap.clear();
        
        LandIdentifiersValidator.validateVolumeFolio('25000', '555', outputMap);
        System.assertEquals('Valid', String.valueOf(outputMap.get('validity')));
        outputMap.clear();
        
        LandIdentifiersValidator.validateVolumeFolio('25000', '999', outputMap);
        System.assertEquals('Valid', String.valueOf(outputMap.get('validity')));
        outputMap.clear();
        
        LandIdentifiersValidator.validateVolumeFolio('99999', '0', outputMap);
        System.assertEquals('Valid', String.valueOf(outputMap.get('validity')));
        outputMap.clear();
        
        LandIdentifiersValidator.validateVolumeFolio('99999', '555', outputMap);
        System.assertEquals('Valid', String.valueOf(outputMap.get('validity')));
        outputMap.clear();
        
        LandIdentifiersValidator.validateVolumeFolio('99999', '999', outputMap);
        System.assertEquals('Valid', String.valueOf(outputMap.get('validity')));
        outputMap.clear();
        
        LandIdentifiersValidator.validateVolumeFolio('99999', '555A', outputMap);
        System.assertEquals('Valid', String.valueOf(outputMap.get('validity')));
        outputMap.clear();
        
        LandIdentifiersValidator.validateVolumeFolio('99999', '999B', outputMap);
        System.assertEquals('Valid', String.valueOf(outputMap.get('validity')));
        outputMap.clear();
        
        // 8030 - 9548
        LandIdentifiersValidator.validateVolumeFolio('8030', '1', outputMap);
        System.assertEquals('Valid', String.valueOf(outputMap.get('validity')));
        outputMap.clear();
        
        LandIdentifiersValidator.validateVolumeFolio('8030', '555', outputMap);
        System.assertEquals('Valid', String.valueOf(outputMap.get('validity')));
        outputMap.clear();
        
        LandIdentifiersValidator.validateVolumeFolio('8030', '999', outputMap);
        System.assertEquals('Valid', String.valueOf(outputMap.get('validity')));
        outputMap.clear();
        
        LandIdentifiersValidator.validateVolumeFolio('9150', '001', outputMap);
        System.assertEquals('Valid', String.valueOf(outputMap.get('validity')));
        outputMap.clear();
        
        LandIdentifiersValidator.validateVolumeFolio('9150', '555', outputMap);
        System.assertEquals('Valid', String.valueOf(outputMap.get('validity')));
        outputMap.clear();
        
        LandIdentifiersValidator.validateVolumeFolio('9150', '999', outputMap);
        System.assertEquals('Valid', String.valueOf(outputMap.get('validity')));
        outputMap.clear();
        
        LandIdentifiersValidator.validateVolumeFolio('9548', '001', outputMap);
        System.assertEquals('Valid', String.valueOf(outputMap.get('validity')));
        outputMap.clear();
        
        LandIdentifiersValidator.validateVolumeFolio('9548', '555', outputMap);
        System.assertEquals('Valid', String.valueOf(outputMap.get('validity')));
        outputMap.clear();
        
        LandIdentifiersValidator.validateVolumeFolio('9548', '999', outputMap);
        System.assertEquals('Valid', String.valueOf(outputMap.get('validity')));
        outputMap.clear();
        
        // 7451 - 8029
        LandIdentifiersValidator.validateVolumeFolio('7451', '1', outputMap);
        System.assertEquals('Valid', String.valueOf(outputMap.get('validity')));
        outputMap.clear();
        
        LandIdentifiersValidator.validateVolumeFolio('7451', '200', outputMap);
        System.assertEquals('Valid', String.valueOf(outputMap.get('validity')));
        outputMap.clear();
        
        LandIdentifiersValidator.validateVolumeFolio('7451', '150', outputMap);
        System.assertEquals('Valid', String.valueOf(outputMap.get('validity')));
        outputMap.clear();
        
        LandIdentifiersValidator.validateVolumeFolio('8100', '1', outputMap);
        System.assertEquals('Valid', String.valueOf(outputMap.get('validity')));
        outputMap.clear();
        
        LandIdentifiersValidator.validateVolumeFolio('8100', '200', outputMap);
        System.assertEquals('Valid', String.valueOf(outputMap.get('validity')));
        outputMap.clear();
        
        LandIdentifiersValidator.validateVolumeFolio('8100', '150', outputMap);
        System.assertEquals('Valid', String.valueOf(outputMap.get('validity')));
        outputMap.clear();
        
        LandIdentifiersValidator.validateVolumeFolio('8029', '1', outputMap);
        System.assertEquals('Valid', String.valueOf(outputMap.get('validity')));
        outputMap.clear();
        
        LandIdentifiersValidator.validateVolumeFolio('8029', '200', outputMap);
        System.assertEquals('Valid', String.valueOf(outputMap.get('validity')));
        outputMap.clear();
        
        LandIdentifiersValidator.validateVolumeFolio('8029', '150', outputMap);
        System.assertEquals('Valid', String.valueOf(outputMap.get('validity')));
        outputMap.clear();
        
        // 0001 - 7450 (1,6)
        LandIdentifiersValidator.validateVolumeFolio('1', '1', outputMap);
        System.assertEquals('Valid', String.valueOf(outputMap.get('validity')));
        outputMap.clear();
        
        LandIdentifiersValidator.validateVolumeFolio('6', '200', outputMap);
        System.assertEquals('Valid', String.valueOf(outputMap.get('validity')));
        outputMap.clear();
        
        LandIdentifiersValidator.validateVolumeFolio('2511', '150', outputMap);
        System.assertEquals('Valid', String.valueOf(outputMap.get('validity')));
        outputMap.clear();
        
        
        // 0001 - 7450 (2,7)
        LandIdentifiersValidator.validateVolumeFolio('2', '201', outputMap);
        System.assertEquals('Valid', String.valueOf(outputMap.get('validity')));
        outputMap.clear();
        
        LandIdentifiersValidator.validateVolumeFolio('7', '400', outputMap);
        System.assertEquals('Valid', String.valueOf(outputMap.get('validity')));
        outputMap.clear();
        
        LandIdentifiersValidator.validateVolumeFolio('2512', '300', outputMap);
        System.assertEquals('Valid', String.valueOf(outputMap.get('validity')));
        outputMap.clear();
        
        
        // 0001 - 7450 (3,8)
        LandIdentifiersValidator.validateVolumeFolio('3', '401', outputMap);
        System.assertEquals('Valid', String.valueOf(outputMap.get('validity')));
        outputMap.clear();
        
        LandIdentifiersValidator.validateVolumeFolio('8', '500', outputMap);
        System.assertEquals('Valid', String.valueOf(outputMap.get('validity')));
        outputMap.clear();
        
        LandIdentifiersValidator.validateVolumeFolio('2513', '600', outputMap);
        System.assertEquals('Valid', String.valueOf(outputMap.get('validity')));
        outputMap.clear();
        
        // 0001 - 7450 (4,9)
        LandIdentifiersValidator.validateVolumeFolio('4', '601', outputMap);
        System.assertEquals('Valid', String.valueOf(outputMap.get('validity')));
        outputMap.clear();
        
        LandIdentifiersValidator.validateVolumeFolio('9', '700', outputMap);
        System.assertEquals('Valid', String.valueOf(outputMap.get('validity')));
        outputMap.clear();
        
        LandIdentifiersValidator.validateVolumeFolio('2514', '800', outputMap);
        System.assertEquals('Valid', String.valueOf(outputMap.get('validity')));
        outputMap.clear();
              
        // 0001 - 7450 (5,0)
        LandIdentifiersValidator.validateVolumeFolio('5', '801', outputMap);
        System.assertEquals('Valid', String.valueOf(outputMap.get('validity')));
        outputMap.clear();
        
        LandIdentifiersValidator.validateVolumeFolio('2510', '999', outputMap);
        System.assertEquals('Valid', String.valueOf(outputMap.get('validity')));
        outputMap.clear();
        
        LandIdentifiersValidator.validateVolumeFolio('2510', '0', outputMap);
        System.assertEquals('Valid', String.valueOf(outputMap.get('validity')));
        outputMap.clear();
                
        // Check Folios alpha
        LandIdentifiersValidator.validateVolumeFolio('1', '1A', outputMap);
        System.assertEquals('Valid', String.valueOf(outputMap.get('validity')));
        outputMap.clear();
        
        LandIdentifiersValidator.validateVolumeFolio('1', '1A', outputMap);
        System.assertEquals('Valid', String.valueOf(outputMap.get('validity')));
        outputMap.clear();
        
        LandIdentifiersValidator.validateVolumeFolio('1', '1B', outputMap);
        System.assertEquals('Valid', String.valueOf(outputMap.get('validity')));
        outputMap.clear();
        
        LandIdentifiersValidator.validateVolumeFolio('1', '1C', outputMap);
        System.assertEquals('Valid', String.valueOf(outputMap.get('validity')));
        outputMap.clear();
        
        LandIdentifiersValidator.validateVolumeFolio('1', '1a', outputMap);
        System.assertEquals('Valid', String.valueOf(outputMap.get('validity')));
        outputMap.clear();
        
        LandIdentifiersValidator.validateVolumeFolio('1', '1b', outputMap);
        System.assertEquals('Valid', String.valueOf(outputMap.get('validity')));
        outputMap.clear();
        
        LandIdentifiersValidator.validateVolumeFolio('1', '1c', outputMap);
        System.assertEquals('Valid', String.valueOf(outputMap.get('validity')));
        outputMap.clear();
        
        LandIdentifiersValidator.validateVolumeFolio('1', '001 ', outputMap);
        System.assertEquals('Valid', String.valueOf(outputMap.get('validity')));
        outputMap.clear();
        
        LandIdentifiersValidator.validateVolumeFolio('1', '001', outputMap);
        System.assertEquals('Valid', String.valueOf(outputMap.get('validity')));
        outputMap.clear();
        
        LandIdentifiersValidator.validateVolumeFolio('1', '1', outputMap);
        System.assertEquals('Valid', String.valueOf(outputMap.get('validity')));
        outputMap.clear();
        
        LandIdentifiersValidator.validateVolumeFolio('1', '1 ', outputMap);
        System.assertEquals('Valid', String.valueOf(outputMap.get('validity')));
        outputMap.clear();
                
        // Alpha Indicator of K or L has no range checking
        LandIdentifiersValidator.validateVolumeFolio('1111', '300K', outputMap);
        System.assertEquals('Valid', String.valueOf(outputMap.get('validity')));
        outputMap.clear();
        
        LandIdentifiersValidator.validateVolumeFolio('1112', '500k', outputMap);
        System.assertEquals('Valid', String.valueOf(outputMap.get('validity')));
        outputMap.clear();
        
        LandIdentifiersValidator.validateVolumeFolio('1113', '700L', outputMap);
        System.assertEquals('Valid', String.valueOf(outputMap.get('validity')));
        outputMap.clear();
        
        LandIdentifiersValidator.validateVolumeFolio('1114', '100l', outputMap);
        System.assertEquals('Valid', String.valueOf(outputMap.get('validity')));
        outputMap.clear();
        
        LandIdentifiersValidator.validateVolumeFolio('1115', '0K', outputMap);
        System.assertEquals('Valid', String.valueOf(outputMap.get('validity')));
        outputMap.clear();
        
        LandIdentifiersValidator.validateVolumeFolio('1116', '300k', outputMap);
        System.assertEquals('Valid', String.valueOf(outputMap.get('validity')));
        outputMap.clear();
        
        LandIdentifiersValidator.validateVolumeFolio('1117', '500L', outputMap);
        System.assertEquals('Valid', String.valueOf(outputMap.get('validity')));
        outputMap.clear();
        
        LandIdentifiersValidator.validateVolumeFolio('1118', '700l', outputMap);
        System.assertEquals('Valid', String.valueOf(outputMap.get('validity')));
        outputMap.clear();
        
        LandIdentifiersValidator.validateVolumeFolio('1119', '100l', outputMap);
        System.assertEquals('Valid', String.valueOf(outputMap.get('validity')));
        outputMap.clear();
        
        LandIdentifiersValidator.validateVolumeFolio('1110', '0l', outputMap);
        System.assertEquals('Valid', String.valueOf(outputMap.get('validity')));
        outputMap.clear();
        
        Test.stopTest();
        
    }
    
    @IsTest
    private static void testVolumeFolioInvalidInputs() {
        
        Test.startTest();
        Map<String, Object> outputMap = new Map<String, Object> ();
        
        LandIdentifiersValidator.validateVolumeFolio('', '', outputMap);
        System.assertEquals('Volume is required', String.valueOf(outputMap.get('errorMsgF')));
        outputMap.clear();
        
        LandIdentifiersValidator.validateVolumeFolio('1', '', outputMap);
        System.assertEquals('Folio is required', String.valueOf(outputMap.get('errorMsgF')));
        outputMap.clear();
        
        LandIdentifiersValidator.validateVolumeFolio('', '1', outputMap);
        System.assertEquals('Volume is required', String.valueOf(outputMap.get('errorMsgF')));
        outputMap.clear();
        
        //Volume pattern check
        LandIdentifiersValidator.validateVolumeFolio('A', '123Z', outputMap);
        System.assertEquals('Invalid Volume: Please check the title, land transfer or contract of sale and re-enter the correct land identifiers', String.valueOf(outputMap.get('errorMsgF')));
        outputMap.clear();
        
        //Folio pattern check
        LandIdentifiersValidator.validateVolumeFolio('123', '1234Z', outputMap);
        System.assertEquals('Invalid Folio: Please check the title, land transfer or contract of sale and re-enter the correct land identifiers', String.valueOf(outputMap.get('errorMsgF')));
        outputMap.clear();
        
        // Alpha out of range checks
        LandIdentifiersValidator.validateVolumeFolio('1', '001D', outputMap);
        System.assertEquals('Invalid Folio: Please check the title, land transfer or contract of sale and re-enter the correct land identifiers', String.valueOf(outputMap.get('errorMsgF')));
        outputMap.clear();
        
        LandIdentifiersValidator.validateVolumeFolio('1', '1D', outputMap);
        System.assertEquals('Invalid Folio: Please check the title, land transfer or contract of sale and re-enter the correct land identifiers', String.valueOf(outputMap.get('errorMsgF')));
        outputMap.clear();
        
        LandIdentifiersValidator.validateVolumeFolio('1', '01D', outputMap);
        System.assertEquals('Invalid Folio: Please check the title, land transfer or contract of sale and re-enter the correct land identifiers', String.valueOf(outputMap.get('errorMsgF')));
        outputMap.clear();
        
        LandIdentifiersValidator.validateVolumeFolio('1', '001+', outputMap);
        System.assertEquals('Invalid Folio: Please check the title, land transfer or contract of sale and re-enter the correct land identifiers', String.valueOf(outputMap.get('errorMsgF')));
        outputMap.clear();
        
        LandIdentifiersValidator.validateVolumeFolio('0', '900', outputMap);
        System.assertEquals('Invalid Volume/Folio: Please check the title, land transfer or contract of sale and re-enter the correct land identifiers', String.valueOf(outputMap.get('errorMsgF')));
        outputMap.clear();
        
        LandIdentifiersValidator.validateVolumeFolio('7150', '77A', outputMap);
        System.assertEquals('Invalid Volume/Folio: Please check the title, land transfer or contract of sale and re-enter the correct land identifiers', String.valueOf(outputMap.get('errorMsgF')));
        outputMap.clear();
        
        LandIdentifiersValidator.validateVolumeFolio('7155', '77B', outputMap);
        System.assertEquals('Invalid Volume/Folio: Please check the title, land transfer or contract of sale and re-enter the correct land identifiers', String.valueOf(outputMap.get('errorMsgF')));
        outputMap.clear();
        
        LandIdentifiersValidator.validateVolumeFolio('7251', '201C', outputMap);
        System.assertEquals('Invalid Volume/Folio: Please check the title, land transfer or contract of sale and re-enter the correct land identifiers', String.valueOf(outputMap.get('errorMsgF')));
        outputMap.clear();
        
        LandIdentifiersValidator.validateVolumeFolio('7256', '201 ', outputMap);
        System.assertEquals('Invalid Volume/Folio: Please check the title, land transfer or contract of sale and re-enter the correct land identifiers', String.valueOf(outputMap.get('errorMsgF')));
        outputMap.clear();
        
        LandIdentifiersValidator.validateVolumeFolio('6252', '200a', outputMap);
        System.assertEquals('Invalid Volume/Folio: Please check the title, land transfer or contract of sale and re-enter the correct land identifiers', String.valueOf(outputMap.get('errorMsgF')));
        outputMap.clear();
        
        LandIdentifiersValidator.validateVolumeFolio('6257', '200b', outputMap);
        System.assertEquals('Invalid Volume/Folio: Please check the title, land transfer or contract of sale and re-enter the correct land identifiers', String.valueOf(outputMap.get('errorMsgF')));
        outputMap.clear();
        
        LandIdentifiersValidator.validateVolumeFolio('5288', '400B', outputMap);
        System.assertEquals('Invalid Volume/Folio: Please check the title, land transfer or contract of sale and re-enter the correct land identifiers', String.valueOf(outputMap.get('errorMsgF')));
        outputMap.clear();
        
        LandIdentifiersValidator.validateVolumeFolio('4254', '600a', outputMap);
        System.assertEquals('Invalid Volume/Folio: Please check the title, land transfer or contract of sale and re-enter the correct land identifiers', String.valueOf(outputMap.get('errorMsgF')));
        outputMap.clear();
        
        LandIdentifiersValidator.validateVolumeFolio('4289', '600B', outputMap);
        System.assertEquals('Invalid Volume/Folio: Please check the title, land transfer or contract of sale and re-enter the correct land identifiers', String.valueOf(outputMap.get('errorMsgF')));
        outputMap.clear();
        Test.stopTest();
    }
    
    @IsTest
    private static void testLotPlanValidInputs() {
        
        Test.startTest();
        
        LandIdentifiersValidator validator = new LandIdentifiersValidator();
        
        Map<String, Object> inputMap = new Map<String, Object>();
        Map<String, Object> outputMap = new Map<String, Object> ();
        Map<String, Object> options = new Map<String, Object> ();
        
        validator.invokeMethod(
            'ValidateLotPlan', inputMap, outputMap, options
        );
        
       // System.assertEquals('Lot is required', String.valueOf(outputMap.get('errorMsgP')));
        
        Map<String, Object> lotPlan = new Map<String, Object> {
            'Lot' => '832324',
                'Plan' => 'PS832324H'
                };
                    
                    outputMap.clear();
        validator.invokeMethod(
            'ValidateLotPlan', lotPlan, outputMap, options
        );
        
        lotPlan.clear();
        LandIdentifiersValidator.validateLotPlan('1', 'LP145852b', outputMap);
        System.assertEquals('Valid', String.valueOf(outputMap.get('validity')));
        outputMap.clear();
        
        LandIdentifiersValidator.validateLotPlan('13G', 'PS406543x', outputMap);
        System.assertEquals('Valid', String.valueOf(outputMap.get('validity')));
        outputMap.clear();
        
        LandIdentifiersValidator.validateLotPlan('RES1', 'CP157285G', outputMap);
        System.assertEquals('Valid', String.valueOf(outputMap.get('validity')));
        outputMap.clear();
        
        LandIdentifiersValidator.validateLotPlan('R1', 'PC358851P', outputMap);
        System.assertEquals('Valid', String.valueOf(outputMap.get('validity')));
        outputMap.clear();
        
        LandIdentifiersValidator.validateLotPlan('RD', 'SP020373T', outputMap);
        System.assertEquals('Valid', String.valueOf(outputMap.get('validity')));
        outputMap.clear();
        
        LandIdentifiersValidator.validateLotPlan('CM2', 'CS001747Q', outputMap);
        System.assertEquals('Valid', String.valueOf(outputMap.get('validity')));
        outputMap.clear();
        
        //Plan variations
        LandIdentifiersValidator.validateLotPlan('1', 'CP164023Y', outputMap);
        System.assertEquals('Valid', String.valueOf(outputMap.get('validity')));
        outputMap.clear();
        
        LandIdentifiersValidator.validateLotPlan('1', 'LP221609N', outputMap);
        System.assertEquals('Valid', String.valueOf(outputMap.get('validity')));
        outputMap.clear();
        
        LandIdentifiersValidator.validateLotPlan('1', 'PC378020X', outputMap);
        System.assertEquals('Valid', String.valueOf(outputMap.get('validity')));
        outputMap.clear();
        
        LandIdentifiersValidator.validateLotPlan('1', 'TP000919C', outputMap);
        System.assertEquals('Valid', String.valueOf(outputMap.get('validity')));
        outputMap.clear();
        
        LandIdentifiersValidator.validateLotPlan('1', 'CP170009H', outputMap);
        System.assertEquals('Valid', String.valueOf(outputMap.get('validity')));
        outputMap.clear();
        
        LandIdentifiersValidator.validateLotPlan('1', 'TP818298X', outputMap);
        System.assertEquals('Valid', String.valueOf(outputMap.get('validity')));
        outputMap.clear();
        
        LandIdentifiersValidator.validateLotPlan('1', 'RP006970P', outputMap);
        System.assertEquals('Valid', String.valueOf(outputMap.get('validity')));
        outputMap.clear();
        
        LandIdentifiersValidator.validateLotPlan('4', 'PS406543X', outputMap);
        System.assertEquals('Valid', String.valueOf(outputMap.get('validity')));
        outputMap.clear();
        
        LandIdentifiersValidator.validateLotPlan('13G', 'LP074245', outputMap);
        System.assertEquals('Valid', String.valueOf(outputMap.get('validity')));
        outputMap.clear();
        
        LandIdentifiersValidator.validateLotPlan('RES1', 'LP052642', outputMap);
        System.assertEquals('Valid', String.valueOf(outputMap.get('validity')));
        outputMap.clear();
        
        LandIdentifiersValidator.validateLotPlan('R1', 'LP022352', outputMap);
        System.assertEquals('Valid', String.valueOf(outputMap.get('validity')));
        outputMap.clear();
        
        LandIdentifiersValidator.validateLotPlan('RD', 'LP074298', outputMap);
        System.assertEquals('Valid', String.valueOf(outputMap.get('validity')));
        outputMap.clear();
        
        LandIdentifiersValidator.validateLotPlan('CM2', 'PS308129F', outputMap);
        System.assertEquals('Valid', String.valueOf(outputMap.get('validity')));
        outputMap.clear();
        
        LandIdentifiersValidator.validateLotPlan('24 Lot 1 A b', 'PS308129F', outputMap);
        System.assertEquals('Valid', String.valueOf(outputMap.get('validity')));
        outputMap.clear();
        
        Test.stopTest();
        
    }
    @IsTest
    private static void testLotPlanInputsInvalidData() {
        
        Test.startTest();
        Map<String, Object> outputMap = new Map<String, Object> ();
        
        LandIdentifiersValidator.validateLotPlan('', '', outputMap);
        //System.assertEquals('Lot is required', String.valueOf(outputMap.get('errorMsgP')));
        outputMap.clear();
        
        LandIdentifiersValidator.validateLotPlan('1', '', outputMap);
        System.assertEquals('Plan is required', String.valueOf(outputMap.get('errorMsgP')));
        outputMap.clear();
        
        LandIdentifiersValidator.validateLotPlan('', '1', outputMap);
        System.assertEquals('Lot is required', String.valueOf(outputMap.get('errorMsgP')));
        outputMap.clear();
        
        LandIdentifiersValidator.validateLotPlan('', 'A', outputMap);
        System.assertEquals('Lot is required', String.valueOf(outputMap.get('errorMsgP')));
        outputMap.clear();
        
        //Lot pattern check error
        LandIdentifiersValidator.validateLotPlan('12345678901', 'CP157285A', outputMap);
        System.assertEquals('Invalid Lot number: Please check the title, land transfer or contract of sale and re-enter the correct land identifiers', String.valueOf(outputMap.get('errorMsgP')));
        outputMap.clear();
        
        //Plan pattern check error
        LandIdentifiersValidator.validateLotPlan('1', 'C157285A', outputMap);
        System.assertEquals('Invalid Plan number: Please check the title, land transfer or contract of sale and re-enter the correct land identifiers', String.valueOf(outputMap.get('errorMsgP')));
        outputMap.clear();
        
        LandIdentifiersValidator.validateLotPlan('1', 'CP157285A', outputMap);
        System.assertEquals('Invalid Plan number: Please check the title, land transfer or contract of sale and re-enter the correct land identifiers', String.valueOf(outputMap.get('errorMsgP')));
        outputMap.clear();
        
        LandIdentifiersValidator.validateLotPlan('1', 'CP109999X', outputMap);
        System.assertEquals('Invalid Plan number: Please check the title, land transfer or contract of sale and re-enter the correct land identifiers', String.valueOf(outputMap.get('errorMsgP')));
        outputMap.clear();
        
        LandIdentifiersValidator.validateLotPlan('1', 'LP100001', outputMap);
        System.assertEquals('Invalid Plan number: Please check the title, land transfer or contract of sale and re-enter the correct land identifiers', String.valueOf(outputMap.get('errorMsgP')));
        outputMap.clear();
        
        LandIdentifiersValidator.validateLotPlan('1', 'PS200000', outputMap);
        System.assertEquals('Invalid Plan number: Please check the title, land transfer or contract of sale and re-enter the correct land identifiers', String.valueOf(outputMap.get('errorMsgP')));
        outputMap.clear();
        
        LandIdentifiersValidator.validateLotPlan('1', 'CP110000', outputMap);
        System.assertEquals('Invalid Plan number: Please check the title, land transfer or contract of sale and re-enter the correct land identifiers', String.valueOf(outputMap.get('errorMsgP')));
        outputMap.clear();
        
        LandIdentifiersValidator.validateLotPlan('1', 'PC100000', outputMap);
        System.assertEquals('Invalid Plan number: Please check the title, land transfer or contract of sale and re-enter the correct land identifiers', String.valueOf(outputMap.get('errorMsgP')));
        outputMap.clear();
        
        LandIdentifiersValidator.validateLotPlan('1', 'SP010000', outputMap);
        System.assertEquals('Invalid Plan number: Please check the title, land transfer or contract of sale and re-enter the correct land identifiers', String.valueOf(outputMap.get('errorMsgP')));
        outputMap.clear();
        
        LandIdentifiersValidator.validateLotPlan('1', 'CS000999', outputMap);
        System.assertEquals('Invalid Plan number: Please check the title, land transfer or contract of sale and re-enter the correct land identifiers', String.valueOf(outputMap.get('errorMsgP')));
        outputMap.clear();
        
        LandIdentifiersValidator.validateLotPlan('1', 'RP555555', outputMap);
        System.assertEquals('Invalid Plan number: Please check the title, land transfer or contract of sale and re-enter the correct land identifiers', String.valueOf(outputMap.get('errorMsgP')));
        outputMap.clear();
        
        Test.stopTest();
    }
}