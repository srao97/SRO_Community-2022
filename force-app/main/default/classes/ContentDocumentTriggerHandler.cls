/**
 * Class Name  : ContentDocumentTriggerHandler
 * Methods     : deleteContentDocuments 
 * @author       Sourabh Singh
 * @version      $Revision: 1.0 $, $Date: 9/Sep/2021
 * @Update       $Revision: 1.1 $, Aashish Singh Sajwan 16/Feb/2022- VHF-4627
 */

public class ContentDocumentTriggerHandler {
  private static final string PROFILE_SYSADMIN = 'System Administrator';
  private static final string PROFILE_VHFPARTICIPANTCOMMUNITYPLUSUSER = 'VHF Participant Community Plus User';
  private static final string ERRORMESSAGE_CANNOTDELETEFILE = 'You do not have permission to delete this file!';
  public static void deleteContentDocuments(list < ContentDocument > listCDs) {
    Boolean hasPermission = FeatureManagement.checkPermission('DeleteFilePermission');
    String roleId = System.userInfo.getUserRoleId();
    //Change User Role to string and added safe navigation operator - AS-VHF-4627
    string urole = [SELECT Id, Name FROM UserRole WHERE Id =: roleId]?.Name;
    system.debug(urole);
    Id SYS_ADMIN_PROFILE_ID; //= [select ProfileId from User where Profile.Name = 'System Administrator' limit 1].ProfileId;
    Id VHFPARTICIPANTCOMMUNITYPLUSUSER_PROFILE_ID;
    for (Profile oProfile: [select Id, Name from Profile where Name IN(: PROFILE_SYSADMIN,: PROFILE_VHFPARTICIPANTCOMMUNITYPLUSUSER)]) {
      if (oProfile.Name == PROFILE_SYSADMIN) {
        SYS_ADMIN_PROFILE_ID = oProfile.Id;
      }
      if (oProfile.Name == PROFILE_VHFPARTICIPANTCOMMUNITYPLUSUSER) {
        VHFPARTICIPANTCOMMUNITYPLUSUSER_PROFILE_ID = oProfile.Id;
      }
    }

    List < ID > cidList = new List < ID > ();
    Set < Id > setDocumentssCreatedByCurrentUser = new Set < Id > ();
    for (ContentDocument d: listCDs) {
      if (d.createdById == UserInfo.getUserId()) {
        setDocumentssCreatedByCurrentUser.add(d.Id);
      }
      cidList.add(d.id);
    }

    if (UserInfo.getProfileId() == VHFPARTICIPANTCOMMUNITYPLUSUSER_PROFILE_ID) {
      Set < Id > setContentDocumentLinkIds = new Set < Id > ();
      for (ContentDocumentLink oContentDocumentLink: [Select Id, ContentDocumentId, LinkedEntityId, ContentDocument.CreatedById from ContentDocumentLink Where ContentDocumentId in: setDocumentssCreatedByCurrentUser]) {
        if (oContentDocumentLink.LinkedEntityId != oContentDocumentLink.ContentDocument.CreatedById) {
          setContentDocumentLinkIds.add(oContentDocumentLink.ContentDocumentId);
        }
      }
      for (ContentDocument oContentDocument: listCDs) {
        if (!setDocumentssCreatedByCurrentUser.contains(oContentDocument.Id) || setContentDocumentLinkIds.contains(oContentDocument.Id)) {
          oContentDocument.adderror(ERRORMESSAGE_CANNOTDELETEFILE);
        }
      }
    } else {
      map < id, ContentDocument > documentMap = new map < id, ContentDocument > ([SELECT id, (SELECT Id, FileType, PublishStatus from ContentVersions) from ContentDocument where id IN: cidList]);
      for (ContentDocument con: listCDs) {
        List < ContentVersion > versionList = documentMap.get(con.Id).ContentVersions;
        if (versionList.size() > 0) {
          for (contentVersion cv: versionList) {
            if (
              (cv.PublishStatus == 'P') &&
              !((UserInfo.getProfileId() == SYS_ADMIN_PROFILE_ID) ||
                hasPermission ||
                'Branch Manager'.equals(urole))
            )
              con.adderror(ERRORMESSAGE_CANNOTDELETEFILE);
          }
        }
      }
    }
  }
}