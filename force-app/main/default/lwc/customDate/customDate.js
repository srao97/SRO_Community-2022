import { OmniscriptBaseMixin } from "vlocity_ins/omniscriptBaseMixin";
import omniscriptDate from "vlocity_ins/omniscriptDate";
//import template from "./customDate.html";
import { get, set } from "vlocity_ins/lodash";
import { getDataHandler } from "vlocity_ins/utility";
import { api, track } from "lwc";

export default class CustomDate extends OmniscriptBaseMixin(omniscriptDate) {

  @track inputValue;

  handleChange(event) {
      this.checkDateValidity(event);
      super.handleChange(event);
  }
  handleBlur(event) {
    super.handleBlur(event);
    // let localJsonData = JSON.parse(JSON.stringify(this.jsonData));
    // let enteredDateJson = JSON.parse(
    //   JSON.stringify(localJsonData.OmniScriptFmtData)
    // );
    // this.inputValue = event.target.value;
    // console.log(this.inputValue, "hello");
    // let key = "StepContractDetails:SettlementDate";

    // let enteredDate = get(enteredDateJson, key);
    // console.log(enteredDate, "enteredDate");
    // let datasource = JSON.stringify({
    //   type: "apexremote",
    //   value: {
    //     className: "BusinessDaysCalculation",
    //     methodName: "validateDays",
    //     inputMap: { scheduledDate: enteredDate },
    //     optionsMap: {},
    //   },
    // });

    // getDataHandler(datasource)
    //   .then((data) => {
    //     var responseObj = JSON.parse(data);
    //     this.errorMessage = responseObj.ErrorMsg;
    //     let myData = { FmlErrSettleDateTooCloseSV: this.errorMessage };
    //     this.omniApplyCallResp(myData);
    //   })
    //   .catch((error) => {
    //     console.log(`Error calling ApexRemote ${error}`);
    //   });
  }
  checkDateValidity(event){
    let localJsonData = JSON.parse(JSON.stringify(this.jsonData));
    let enteredDateJson = JSON.parse(
      JSON.stringify(localJsonData.OmniScriptFmtData)
    );
    this.inputValue = event.target.value;
    console.log(this.inputValue, "hello");
    let dateArray = this.inputValue.split('-');

    let enteredDate = dateArray[2]+'/'+dateArray[1]+'/'+dateArray[0];
    console.log(enteredDate, "enteredDate");
    let datasource = JSON.stringify({
      type: "apexremote",
      value: {
        className: "BusinessDaysCalculation",
        methodName: "validateDays",
        inputMap: { scheduledDate: enteredDate },
        optionsMap: {},
      },
    });

    getDataHandler(datasource)
      .then((data) => {
        console.log("hello");
        var responseObj = JSON.parse(data);
        this.errorMessage = responseObj.ErrorMsg;
        let myData = { FmlErrSettleDateTooCloseSV: this.errorMessage };
        this.omniApplyCallResp(myData);
      })
      .catch((error) => {
        console.log(`Error calling ApexRemote ${error}`);
      });
  }
  connectedCallback() {
    super.connectedCallback();
  }
}