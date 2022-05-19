Public class ShareContentDocumentTriggerHandler
{

public static boolean Executetriggeronce=true;

@Future
public static void ShareContentDocuments(list<string>listDocumentIds)
{

list < ContentWorkspace > lstworkspace = [SELECT Id, Name
        FROM ContentWorkspace
        WHERE Name = 'VHFContentLibrary'
    ];
    system.debug('lstworkspace@@@@'+lstworkspace);
    if (lstworkspace.size() > 0)
    
    {
        ContentWorkspace workspace = lstworkspace[0];
        List < ContentDocumentLink> LstCDL = new List < ContentDocumentLink > ();
        
        for (String recordId: listDocumentIds)
        {
            ContentDocumentLink objContentFolderMember = new ContentDocumentLink();
            objContentFolderMember.ContentDocumentId = recordId;
            objContentFolderMember.LinkedEntityId = workspace.id;
            
            LstCDL.add(objContentFolderMember);
        }
        insert LstCDL;
        system.debug(LstCDL);
    }
}


}