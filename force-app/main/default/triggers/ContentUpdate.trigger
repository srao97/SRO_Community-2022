trigger ContentUpdate on ContentDocument(after insert)
{

If(ShareContentDocumentTriggerHandler.Executetriggeronce)
    {

   list<string>lstDocumentIds=new list<string>();
   for(ContentDocument cdoc:Trigger.new)
      {
       lstDocumentIds.add(cdoc.id);
      }
ShareContentDocumentTriggerHandler.Executetriggeronce=false;
ShareContentDocumentTriggerHandler.ShareContentDocuments(lstDocumentIds);
System.debug('lstDocumentIds@@@@'+lstDocumentIds);
    }

}