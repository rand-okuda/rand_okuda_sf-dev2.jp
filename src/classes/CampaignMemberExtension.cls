public with sharing class CampaignMemberExtension {

    public CampaignMember CMember{get;set;}

    public Lead currentLead{get;set;}
    public Account currentAccount{get;set;}
    public Contact currentContact{get;set;}

    public Id currentCampaignId{get;set;}
    public Id currentCMemberId{get;set;}
    public Id nextCMemberId{get;set;}
    public Id prevCMemberId{get;set;}

    public Boolean isContact{get;set;}
    public Boolean isLead{get;set;}

    public Id currentContactId{get;set;}
    public Id currentAccountId{get;set;}
    public Id currentLeadId{get;set;}

    public List<CampaignMember> cMemberHistorys{get;set;}

    //コンストラクタ
    public CampaignMemberExtension(ApexPages.StandardController controller) {

        CMember = (CampaignMember) controller.getRecord();
        currentCMemberId = CMember.id;

        //同一キャンペーンのメンバー取得
        List<CampaignMember> CMembers = [SELECT Id,CampaignId,ContactId,LeadId FROM CampaignMember WHERE Id = :currentCMemberId LIMIT 1];

        //検索用IDセット
        if(CMembers.size() > 0){
            currentCampaignId = CMembers[0].CampaignId;
            currentContactId = CMembers[0].ContactId;
            currentLeadId = CMembers[0].LeadId;
        }

        //リード判定
        isLead = false;
        if(currentLeadId != null){
            //リードレコード取得
            List<Lead> leads = [SELECT Id,LastName,FirstName,Title,Company,Street,City,State,PostalCode,Country,Phone,MobilePhone,Fax,Email,Website,Description,LeadSource,Status,Industry,Rating,AnnualRevenue,NumberOfEmployees FROM Lead WHERE Id = :currentLeadId LIMIT 1000];
            if(leads.size() > 0){
                isLead = true;
                currentLead = leads[0];
                //キャンペーン履歴取得
                cMemberHistorys =[SELECT Id,ContactId,LeadId,CreatedDate,CampaignId,Campaign.Id,Campaign.Name,Campaign.Type,FootprintsDateText__c,FootprintsDate__c FROM CampaignMember WHERE LeadId = :currentLeadId ORDER BY FootprintsDate__c DESC LIMIT 1000];
            }
        }

        //責任者判定
        isContact = false;
        if(currentContactId != null){
            //責任者レコード取得
            List<Contact> contacts = [SELECT Id,AccountId,LastName,FirstName,OtherStreet,OtherCity,OtherState,OtherPostalCode,OtherCountry,MailingStreet,MailingCity,MailingState,MailingPostalCode,MailingCountry,Phone,Fax,MobilePhone,HomePhone,OtherPhone,AssistantPhone,Email,Title,Department,AssistantName,LeadSource,Birthdate,Description FROM Contact WHERE Id = :currentContactId LIMIT 1000];
            if(contacts.size() > 0){
                currentContact = contacts[0];
                currentAccountId = contacts[0].AccountId;
                //取引先レコード取得
                List<Account> accounts = [SELECT Id,Name,Type,BillingStreet,BillingCity,BillingState,BillingPostalCode,BillingCountry,ShippingStreet,ShippingCity,ShippingState,ShippingPostalCode,ShippingCountry,Phone,Fax,AccountNumber,Website,Sic,Industry,AnnualRevenue,NumberOfEmployees,Ownership,TickerSymbol,Description,Rating,Site,DescriptionA__C,DescriptionB__C,DescriptionC__C FROM Account WHERE Id = :currentAccountId LIMIT 1000];
                if(accounts.size() > 0){
                    isContact = true;
                    isLead = false;
                    currentAccount = accounts[0];
                    //キャンペーン履歴取得
                    cMemberHistorys =[SELECT Id,ContactId,LeadId,CreatedDate,CampaignId,Campaign.Id,Campaign.Name,Campaign.Type,FootprintsDateText__c,FootprintsDate__c FROM CampaignMember WHERE ContactId = :currentContactId ORDER BY FootprintsDate__c DESC LIMIT 1000];
                }
            }
        }

    }

    /**
     * 次のIDを取得しプロパティ（Id）にセットする。
     * 次が存在しない場合は現在のIDを返す。
     */
    private void searchNextId() {
        //現在のIDをセット
        nextCMemberId = currentCampaignId;
        // 同のリストを取得
        List<CampaignMember> listCMembers = [SELECT Id,CampaignId FROM CampaignMember WHERE CampaignId = :currentCampaignId LIMIT 1000];
        if(listCMembers.size() > 0){
            // 最初のIDをセット
            nextCMemberId = listCMembers[0].Id;
        }
        Boolean existFlag = false;
        for (CampaignMember lcm : listCMembers) {
            if (existFlag) {
                nextCMemberId = lcm.Id;
                // ループ終了
                break;
            }
            if (lcm.Id == currentCMemberId) {
                existFlag = true;
            }
        }
    }

    /**
     * 前のIDを取得しプロパティ（Id）にセットする。
     * 前が存在しない場合は現在のIDを返す。
     */

    private void searchPrevId() {
        //現在のIDをセット
        prevCMemberId = currentCampaignId;
        // 同のリストを取得
        List<CampaignMember> listCMembers = [SELECT Id,CampaignId FROM CampaignMember WHERE CampaignId = :currentCampaignId LIMIT 1000];
        if(listCMembers.size() > 0){
            // 最初のIDをセット
            prevCMemberId = listCMembers[0].Id;
        }
        for (CampaignMember lcm : listCMembers) {
            if(lcm.Id == currentCMemberId){
                //ループ終了
                break;
            }
            prevCMemberId = lcm.Id;
        }
    }

    /**
     * 次のレコードへ遷移する。スキップ。
     */
    public PageReference viewNext() {
        try{
            //次を検索する
            searchNextId();
            // 次のIDをパラメータで渡す
            PageReference pageRef = new PageReference('/' + nextCMemberId);
            // リダイレクトしてページを読み直させる
            pageRef.setRedirect(true);
            return pageRef;
        }catch(DmlException e){ ApexPages.addMessages(e);return null;}
    }

    /**
     * 前のレコードへ遷移する。バック。
     */
    public PageReference viewPrev() {
        try{
            //前を検索する
            searchPrevId();
            // 前IDをパラメータで渡す
            PageReference pageRef = new PageReference('/' + prevCMemberId);
            // リダイレクトしてページを読み直させる
            pageRef.setRedirect(true);
            return pageRef;
        }catch(DmlException e){ ApexPages.addMessages(e);return null;}
    }

    /**
     * 保存し次のレコードへ遷移する。スキップ。
     *
    public PageReference saveNext() {
        try{
            //更新保存
            this.save();
            //次を検索する
            searchNextId();
            // 次のIDをパラメータで渡す
            PageReference pageRef = new PageReference('/' + nextCMemberId);
            // リダイレクトしてページを読み直させる
            pageRef.setRedirect(true);
            return pageRef;
        }catch(DmlException e){ ApexPages.addMessages(e);return null;}
    }
     */

    /**
     *保存し 前のレコードへ遷移する。バック。
     *
    public PageReference savePrev() {
        try{
            //更新保存
            this.save();
            //前を検索する
            searchPrevId();
            // 前のIDをパラメータで渡す
            PageReference pageRef = new PageReference('/' + prevCMemberId);
            // リダイレクトしてページを読み直させる
            pageRef.setRedirect(true);
            return pageRef;
        }catch(DmlException e){ ApexPages.addMessages(e);return null;}
    }
     */

    /**
     *保存のみ。
     */
    public PageReference updateThis() {
        try{
            //更新保存
            this.save();
            // 現在のIDをパラメータで渡す
            //PageReference pageRef = new PageReference('/' + currentCMemberId);
            // リダイレクトしてページを読み直させる
            //pageRef.setRedirect(true);
            //return pageRef;
            return null;
        }catch(DmlException e){ ApexPages.addMessages(e);return null;}
    }

    /**
     * レコードの更新。
     */
    private void save() {
        // 更新
        if(isLead){
            update currentLead;
        }
        if(isContact){
            update currentAccount;
            update currentContact;
        }

    }

}