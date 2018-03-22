@isTest
private class CampaignMemberExtensionTest {

    static testMethod void myUnitTest() {
       // テストデータ作成

        Lead ld1 = new Lead(LastName = 'AAA',Company ='XXX');
        Lead ld2 = new Lead(LastName = 'AAA',Company ='XXX');
        Account ac1 = new Account(Name = 'BBBB');
        Contact cn1 = new Contact(LastName = 'CCC', AccountId = ac1.Id );
        Account ac2 = new Account(Name = 'BBBB');
        Contact cn2 = new Contact(LastName = 'CCC', AccountId = ac2.Id );
        insert ld1;
        insert ld2;
        insert ac1;
        insert cn1;
        insert ac2;
        insert cn2;

        Campaign cp1 = new Campaign(Name = 'キャンペーン');
        insert cp1;

        CampaignMember cpm1 = new CampaignMember(CampaignId = cp1.Id, LeadId = ld1.Id, Status = 'Sent');
        CampaignMember cpm2 = new CampaignMember(CampaignId = cp1.Id, ContactId = cn1.Id, Status = 'Sent');
        CampaignMember cpm3 = new CampaignMember(CampaignId = cp1.Id, LeadId = ld2.Id, Status = 'Sent');
        CampaignMember cpm4 = new CampaignMember(CampaignId = cp1.Id, ContactId = cn2.Id, Status = 'Sent');
        insert cpm1;
        insert cpm2;
        insert cpm3;
        insert cpm4;

        // ページ初期化

        PageReference pageRef2 = new PageReference('/' + cpm2.Id);
        Test.setCurrentPage(pageRef2);
        ApexPages.Standardcontroller stdController2 =  new ApexPages.Standardcontroller(cpm2);
        CampaignMemberExtension controller2 = new CampaignMemberExtension(stdController2);

        pageRef2 = controller2.viewNext();
        pageRef2 = controller2.viewPrev();
        //pageRef2 = controller2.saveNext();
        //pageRef2 = controller2.savePrev();
        pageRef2 = controller2.updateThis();

        PageReference pageRef1 = new PageReference('/' + cpm1.Id);
        Test.setCurrentPage(pageRef1);
        ApexPages.Standardcontroller stdController1 =  new ApexPages.Standardcontroller(cpm1);
        CampaignMemberExtension controller1 = new CampaignMemberExtension(stdController1);

        pageRef1 = controller1.viewNext();
        pageRef1 = controller1.viewPrev();
        //pageRef2 = controller1.saveNext();
        //pageRef2 = controller1.savePrev();
        pageRef2 = controller1.updateThis();

    }
}