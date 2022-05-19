import { LightningElement } from "lwc";

const columns = [
  { label: "Application", fieldName: "applicationId", type: "text" },
  {
    label: "Student",
    fieldName: "studentName",
    type: "text"
  },
  {
    label: "Type",
    fieldName: "studentType",
    type: "text"
  },
  {
    label: "Status",
    fieldName: "studentStatus",
    type: "text"
  },
  { label: "School", fieldName: "schoolName", type: "text" },
  { label: "Last Modified", fieldName: "lastModifiedDate", type: "text" }
];

export default class NgApplications extends LightningElement {
  data = [];
  columns = columns;

  // eslint-disable-next-line @lwc/lwc/no-async-await
  async connectedCallback() {
    const data = [{
        applicationId: '120102910',
        studentName: 'Aesha Jackson',
        studentType: 'Transition',
        studentStatus: 'Place Offered',
        schoolName: 'Collingwood College',
        lastModifiedDate: '14:23 26/10/2020'
    },
    {
        applicationId: '120102910',
        studentName: 'Aesha Jackson',
        studentType: 'Transition',
        studentStatus: 'Place Offered',
        schoolName: 'Collingwood College',
        lastModifiedDate: '14:23 26/10/2020'
    }];
    this.data = data;
  }
}