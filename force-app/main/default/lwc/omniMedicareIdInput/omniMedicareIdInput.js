import omniscriptText from "vlocity_ins/omniscriptText";

const listOfValidationKeys = [
    "messageWhenValueMissing",
    "messageWhenPatternMismatch",
    "messageWhenPatternMismatch",
    "messageWhenTooShort",
    "messageWhenTooLong",
    "messageWhenBadInput",
    "messageWhenRangeOverflow",
    "messageWhenRangeUnderflow"
];
    
export default class omniMedicareIdInput extends omniscriptText{

    connectedCallback() {
        super.connectedCallback();

        // override default labels
        this.setLabelsFromPropMap();
    }

    setLabelsFromPropMap() {

        if(this.jsonDef && this.jsonDef.propSetMap) {
            let propSetMap = this.jsonDef.propSetMap;
            listOfValidationKeys.forEach( messageKey => {
                if(propSetMap[messageKey] && typeof propSetMap[messageKey] === "string") {
                    this[`_${messageKey}`] = propSetMap[messageKey];
                }
            });
        }

    }

    // your properties and methods here
    doCustomValidation() {

        if(this.childInput && this.childInput.value) {

            let val = this.childInput.value;

            if(typeof val === "number") {
                val = val.toString();
            }

            let arr = val.split("");

            let isValid = true;
            
            isValid = isValid && arr[0] >= 2 && arr[0] <= 6 ;

            let count = parseInt(arr[0])
                + (parseInt(arr[1]) * 3)
                + (parseInt(arr[2]) * 7)
                + (parseInt(arr[3]) * 9)
                + parseInt(arr[4])
                + (parseInt(arr[5]) * 3)
                + (parseInt(arr[6]) * 7)
                + (parseInt(arr[7]) * 9);

            isValid = isValid && parseInt(arr[8]) === count%10;

            if(isValid === true) {
                this.childInput.setCustomValidity('');
            } else {
                this.childInput.setCustomValidity('Enter a valid Medicare number');
            }

        }

    }
        
}