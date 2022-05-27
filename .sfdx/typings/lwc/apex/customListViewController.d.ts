declare module "@salesforce/apex/customListViewController.fetchObjectRecords" {
  export default function fetchObjectRecords(param: {objectName: any, fields: any, filter: any, recordLimit: any, pageSize: any, pageNumber: any, pagenationEnabled: any, sortBy: any, sortDirection: any}): Promise<any>;
}
declare module "@salesforce/apex/customListViewController.fetchFileRecords" {
  export default function fetchFileRecords(param: {relatedId: any}): Promise<any>;
}
declare module "@salesforce/apex/customListViewController.isPrimaryParticipant" {
  export default function isPrimaryParticipant(): Promise<any>;
}
