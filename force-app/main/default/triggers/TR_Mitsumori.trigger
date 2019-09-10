trigger TR_Mitsumori on Mitsumori__c (before insert, before update, after update) {

    if(Trigger.isBefore){
        if(ApexTrgFuncEnable__c.getOrgDefaults().SalesStageAutoUpdateFlg__c || ApexTrgFuncEnable__c.getOrgDefaults().QuoteLinkFlgUpdateFlg__c){
            CL_UpdateOpportunityStage.updOppStg(Trigger.new);
        }
    }
    
    if(Trigger.isAfter){
        CL_IntUpdateRecord.trgNum++;    // トリガの起動数をインクリメント
        
        // メッセージ送信
        if(ApexTrgFuncEnable__c.getOrgDefaults().MsgSendTriggerFlgVSS__c && CL_IntUpdateRecord.trgNum == 1){
            List<CL_IntCreateMsg> msgList = new List<CL_IntCreateMsg>();
            msgList.add(new CL_IntCreateMsg_VSSMain(Trigger.oldMap, Trigger.newMap));
            
            CL_IntSendMsg.sendMsg(msgList);
            
            CL_IntUpdateRecord.updateMitsumori(Trigger.newMap);
        }
        
        CL_IntUpdateRecord.trgNum--;    // トリガの起動数をデクリメント
    }
}