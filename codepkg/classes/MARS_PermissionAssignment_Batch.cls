public with sharing class MARS_PermissionAssignment_Batch implements Database.Batchable<string>{

    public Iterable<string> start(Database.BatchableContext BC){
        return new List<String> { 'MARS_OES_Fire_Administrator', 'MARS_OES_Reimbursement_Primary', 
                                    'MARS_OES_Reimbursement_Secondary','MARS_OES_Field_Operations', 
                                    'MARS_OES_Read_Only_Secondary', 'MARS_OES_Equipment' };
    
    }
    public void execute(Database.BatchableContext BC, List<string> scope){
        string pSetName = scope[0];
 

        map<string,set<string>> persettoUserIdsMap = new map<string,set<string>>();
        map<string,set<string>> persettoPublicgroupMap = new map <string, set<string>>();
        map<string,set<string>> persettoQueueMap = new map <string, set<string>>();

        set<string> allQueues = new set<string>();
        set<string> allGroups = new set<string>();

        //Public groups that each permission set users should be part of
        set<string> level1groups = new set<string>{'MARS_OES_Fire_Administrator'};
        set<string> level2groups = new set<string>{'MARS_OES_Reimbursement_Primary'};
        set<string> level3groups = new set<string>{'MARS_OES_Reimbursement_Secondary'};
        set<string> level4groups = new set<string>{'MARS_OES_Field_Operations'};
        set<string> level5groups = new set<string>{'MARS_OES_Read_Only_Secondary'};
        set<string> level6groups = new set<string>{'MARS_OES_Equipment'};
    
        persettoPublicgroupMap.put('Level1', level1groups);
        persettoPublicgroupMap.put('Level2', level2groups);
        persettoPublicgroupMap.put('Level3', level3groups);
        persettoPublicgroupMap.put('Level4', level4groups);
        persettoPublicgroupMap.put('Level5', level5groups);
        persettoPublicgroupMap.put('Level6', level6groups);

        //Queues that each user should be part of
        set<string> level1Queues = new set<string>{'MARS_F_42_APPROVAL_QUEUE'};
        set<string> level2Queues = new set<string>{'MARS_F_42_APPROVAL_QUEUE'};
        set<string> level3Queues = new set<string>{'MARS_F_42_APPROVAL_QUEUE'};
        set<string> level4Queues = new set<string>{''};
        set<string> level5Queues = new set<string>{''};
        set<string> level6Queues = new set<string>{''};
    
        persettoQueueMap.put('Level1', level1Queues);
        persettoQueueMap.put('Level2', level2Queues);
        persettoQueueMap.put('Level3', level3Queues);
        persettoQueueMap.put('Level4', level4Queues);
        persettoQueueMap.put('Level5', level5Queues);
        persettoQueueMap.put('Level6', level6Queues);

        string currentContext = '';
        for(PermissionSetAssignment pa: [SELECT Id, AssigneeId, Permissionset.Description FROM PermissionSetAssignment
                                         WHERE PermissionSet.Name =  :pSetName]){
                                            
            if(pa.PermissionSet.description.contains('Level1')){
                currentContext = 'Level1';
                set<string> level1Users = new set<string>();
                level1Users = persettoUserIdsMap.get('Level1');
                level1Users.add(pa.AssigneeId);
                persettoUserIdsMap.put('Level1',level1Users);
            }
            if(pa.PermissionSet.description.contains('Level2')){
                currentContext = 'Level2';
                set<string> Level2Users = new set<string>();
                Level2Users = persettoUserIdsMap.get('Level2');
                Level2Users.add(pa.AssigneeId);
                persettoUserIdsMap.put('Level2',Level2Users);
            }
            if(pa.PermissionSet.description.contains('Level3')){
                currentContext = 'Level3';
                set<string> Level3Users = new set<string>();
                Level3Users = persettoUserIdsMap.get('Level3');
                Level3Users.add(pa.AssigneeId);
                persettoUserIdsMap.put('Level3',Level3Users);
            }
            if(pa.PermissionSet.description.contains('Level4')){
                currentContext = 'Level4';
                set<string> level4Users = new set<string>();
                level4Users = persettoUserIdsMap.get('Level4');
                level4Users.add(pa.AssigneeId);
                persettoUserIdsMap.put('Level4',level4Users);
            }
            if(pa.PermissionSet.description.contains('Level5')){
                currentContext = 'Level5';
                set<string> level5Users = new set<string>();
                level5Users = persettoUserIdsMap.get('Level5');
                level5Users.add(pa.AssigneeId);
                persettoUserIdsMap.put('Level5',level5Users);
            }
            if(pa.PermissionSet.description.contains('Level6')){
                currentContext = 'Level6';
                set<string> level6Users = new set<string>();
                level6Users = persettoUserIdsMap.get('Level6');
                level6Users.add(pa.AssigneeId);
                persettoUserIdsMap.put('Level6',level6Users);
            }
        }

        list<GroupMember> memberstoInsert = new list<GroupMember>();
        list<GroupMember> memberstoRemove = new list<GroupMember>();
        set<string> publicGroupKeys = new set<string>();
        map<string,string> groupNametoIdMap = new map<string,string>();
        for(Group g: [SELECT Id, DeveloperName FROM Group 
                        WHERE DeveloperName IN: persettoPublicgroupMap.get(currentContext)]){
            groupNametoIdMap.put(g.DeveloperName, g.Id);
        }
        for(string pg: persettoPublicgroupMap.get(currentContext)){
            for(string u: persettoUserIdsMap.get(currentContext)){
                publicGroupKeys.add(u+'~'+groupNametoIdMap.get(pg));
            }
        }

        for(GroupMember gm: [SELECT Id, GroupId, userorGroupId FROM GroupMember WHERE 
                                userorGroupId IN: groupNametoIdMap.values()]){
            string key = gm.userorGroupId+'~'+gm.GroupId;
            if(publicGroupKeys.contains(key)){
                publicGroupKeys.remove(key);
            }else{
                memberstoRemove.add(gm);
            }
        }

        GroupMember gmtoAdd;
        for(string gmA: publicGroupKeys){
            gmtoAdd = new GroupMember();
            gmtoAdd.userorGroupId = gma.SubstringBefore('~');
            gmtoAdd.GroupId = gma.SubstringAfter('~');
            memberstoInsert.add(gmtoAdd);
        }

        delete memberstoRemove;
        insert memberstoInsert;
        
    }
    public void finish(Database.BatchableContext BC){
    }

}