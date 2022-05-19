import omniscriptDate from "vlocity_ins/omniscriptDate";

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
    
export default class omniDateWithAgeValidator extends omniscriptDate{
    // your properties and methods here
    connectedCallback() {
        super.connectedCallback();

        // override default labels
        this.setLabelsFromPropMap();

        this.template.addEventListener('focus', this.inputFocussed);

    }

    inputFocussed = (e) => {
        console.log(e);
        //this.doCustomValidation();
        this.childInput.setCustomValidity("");
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

    doCustomValidation() {

        if(this.childInput && this.childInput.value) {

            let init = new Date(this.childInput.value);

            let today = new Date();

            let minAge = this.jsonDef.propSetMap && this.jsonDef.propSetMap.minAge && parseInt(this.jsonDef.propSetMap.minAge);

            if(minAge == null || isNaN(minAge)) {
                this.childInput.setCustomValidity(""); //invalid inputs, ignore custom validation
            }

            if(isNaN(init) || isNaN(today)) {
                this.childInput.setCustomValidity("Please enter a valid date"); // potentially use: messageWhenBadInput
            }

            let years = today.getFullYear() - init.getFullYear();

            let months = today.getMonth() - init.getMonth();

            if(months < 0 || (months === 0 && (today.getDate() < init.getDate()))) {
                years--;
            }

            if(years < minAge) {
                // ToDo: Move it propertyset
                this.childInput.setCustomValidity("Applicants should be at least 18 years of age as of the settlement date.");
            } else {
                this.childInput.setCustomValidity("");
            }


        } else {
            this.childInput.setCustomValidity("");
        }

    }
    
}