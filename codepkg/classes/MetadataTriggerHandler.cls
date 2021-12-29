public with sharing class MetadataTriggerHandler extends TriggerBase implements TriggerAction.BeforeInsert, TriggerAction.AfterInsert {
    public MetadataTriggerHandler() {

    }

    private static Set<String> bypassedActions;
    static Map<String, Boolean> permissionMap;
    static Map<String, Map<String, List<Trigger_Action__mdt>>> sObjectToContextToActions;

    static {
        bypassedActions = new Set<String>();
        permissionMap = new Map<String, Boolean>();
        sObjectToContextToActions = new Map<String, Map<String, List<Trigger_Action__mdt>>>();
    }

    public void beforeInsert(List<SObject> newList) {
        for(TriggerAction.BeforeInsert action : beforeInsertActions) {
            action.beforeInsert(newList);
        }
    }

    public void afterInsert(List<SObject> newList) {
        for(TriggerAction.AfterInsert action : afterInsertActions) {
            action.afterInsert(newList);
        }
    }

    private List<Trigger_Action__mdt> getActionMetadata(String relationshipName) {
        if(!sObjectToContextToActions.containsKey(this.sObjectName)) {
            sObjectToContextToActions.put(this.sObjectName, new Map<String, List<Trigger_Action__mdt>>());
        }

        if(!sObjectToContextToActions.get(this.sObjectName).containsKey(relationshipName)) {
            List<Trigger_Action__mdt> result = new List<Trigger_Action__mdt>();
            Set<String> bypassedActions = MetadataTriggerHandler.bypassedActions;
            Set<String> byPassedObjects = TriggerBase.byPassedObjects;
            String sObjectLocalName = this.sObjectName;
            System.debug('sobjectLocalName---'+sObjectLocalName);
            System.debug('sobjectName---'+sObjectName);
            List<String> split = sObjectName.split('__');
            System.debug('split---'+split);
            String namespace;
            if(split.size() > 2) {
                namespace = split[0];
                sObjectLocalName = sObjectLocalName.replaceFirst(namespace+'__', '');
            }
            System.debug('Namespace---'+namespace);
            System.debug('sobjectLocalName---'+sObjectLocalName);
            List<String> queryArray = new List<String>{
                'SELECT Apex_Class_Name__c,',
                'Order__c,',
                'Flow_Name__c,',
                'Bypass_Permission__c,',
                'Required_Permission__c,',
                '{0}__r.Bypass_Permission__c,',
                '{0}__r.Required_Permission__c',
                'FROM Trigger_Action__mdt',
                'WHERE',
                'Apex_Class_Name__c NOT IN :bypassedActions',
                'AND {0}__c != NULL',
                'AND {0}__r.Object_API_Name__c = :sObjectLocalName',
				'AND {0}__r.Object_Namespace__c = :namespace',
				'AND {0}__r.Bypass_Execution__c = FALSE',
				'AND Bypass_Execution__c = FALSE',
				'ORDER BY Order__c ASC'
            };
            String queryString = String.format(String.join(queryArray, ' '), new List<Object>{relationshipName});
            System.debug('query---'+queryString);
            for(Trigger_Action__mdt actionMetadata : (List<Trigger_Action__mdt>) Database.query(queryString)) {
                if(shouldExecute(actionMetadata, relationshipName) && !TriggerBase.isBypassed(this.sObjectName)) {
                    result.add(actionMetadata);
                }
            }
            sObjectToContextToActions.get(this.sObjectName).put(relationshipName, result);
        }
        return sObjectToContextToActions.get(this.sObjectName).get(relationshipName);
    }

    private Boolean shouldExecute(Trigger_Action__mdt actionMetadata, String relationshipName) {
        String sObjectBypassPermissionName = (String) ((sObject_Trigger_Setting__mdt) actionMetadata.getSobject(relationshipName+'__r')).get('Bypass_Permission__c');
        String sObjectRequiredPermissionName = (String) ((sObject_Trigger_Setting__mdt) actionMetadata.getSobject(relationshipName+'__r')).get('Required_Permission__c');
        for(String permissionName : new List<String> {actionMetadata.Bypass_Permission__c, actionMetadata.Required_Permission__c, sObjectBypassPermissionName, sObjectRequiredPermissionName}) {
            if(permissionName != null && !permissionMap.containsKey(permissionName)) {
                permissionMap.put(permissionName, FeatureManagement.checkPermission(permissionName));
            }
        }
        Boolean actionShouldExecute = !((actionMetadata.Bypass_Permission__c != null && permissionMap.get(actionMetadata.Bypass_Permission__c)) || (actionMetadata.Required_Permission__c != null && permissionMap.get(actionMetadata.Required_Permission__c)));
        Boolean sObjectShouldExecute = !((sObjectBypassPermissionName != null && permissionMap.get(sObjectBypassPermissionName)) || (sObjectRequiredPermissionName != null && permissionMap.get(sObjectRequiredPermissionName)));
        return actionShouldExecute && sObjectShouldExecute;
    }

    private List<Trigger_Action__mdt> beforeInsertActionMetadata {
        get {
            if(beforeInsertActionMetadata == null) {
                beforeInsertActionMetadata = getActionMetadata(System.TriggerOperation.BEFORE_INSERT.name());
            }
            return beforeInsertActionMetadata;
        } 
        set;
    }

    private List<TriggerAction.BeforeInsert> beforeInsertActions {
        get {
            List<TriggerAction.BeforeInsert> returnValue = new List<TriggerAction.BeforeInsert>();
            for(Trigger_Action__mdt triggerMetadata : this.beforeInsertActionMetadata) {
                try {
                    TriggerAction.BeforeInsert triggerAction = (TriggerAction.BeforeInsert) Type.forName(triggerMetadata.Apex_Class_Name__c).newInstance();
                    // if(triggerMetadata.Flow_Name__c != null) {
                    //     ((TriggerActionFlow) triggerAction).flowName = triggerMetadata.Flow_Name__c;
                    // }
                    returnValue.add(triggerAction);
                } catch(System.TypeException e) {
                    handleException(INVALID_TYPE_ERROR, triggerMetadata.Apex_Class_Name__c, System.TriggerOperation.BEFORE_INSERT);
                } catch(System.NullPointerException e) {
                    handleException(INVALID_CLASS_ERROR, triggerMetadata.Apex_Class_Name__c, System.TriggerOperation.BEFORE_INSERT);
                }
            }
            System.debug('return trigger Action--'+returnValue);
            return returnValue;
        }
    }

    private List<Trigger_Action__mdt> afterInsertActionMetadata {
		get {
			if (afterInsertActionMetadata == null) {
				afterInsertActionMetadata = getActionMetadata(System.TriggerOperation.AFTER_INSERT.name());
			}
			return afterInsertActionMetadata;
		}
		set;
	}

	private List<TriggerAction.AfterInsert> afterInsertActions {
		get {
			List<TriggerAction.AfterInsert> returnValue = new List<TriggerAction.AfterInsert>();
			for (Trigger_Action__mdt triggerMetadata : afterInsertActionMetadata) {
				try {
					TriggerAction.AfterInsert triggerAction = (TriggerAction.AfterInsert) Type.forName(triggerMetadata.Apex_Class_Name__c).newInstance();
					// if (triggerMetadata.Flow_Name__c != null) {
					// 	((TriggerActionFlow) triggerAction).flowName = triggerMetadata.Flow_Name__c;
					// }
					returnValue.add(triggerAction);
				} catch (System.TypeException e) {
					handleException(INVALID_TYPE_ERROR,triggerMetadata.Apex_Class_Name__c,System.TriggerOperation.AFTER_INSERT);
				} catch (System.NullPointerException e) {
					handleException(INVALID_CLASS_ERROR,triggerMetadata.Apex_Class_Name__c,System.TriggerOperation.AFTER_INSERT);
				}
			}
			return returnValue;
		}
	}

    private void handleException(String error, String className, System.TriggerOperation triggerOperation) {
		throw new MetadataTriggerHandlerException(
			String.format(error,new List<String>{
                className,
                String.valueOf(triggerOperation),
                this.sObjectName
			})
		);
	}

	public static void bypass(String actionName) {
		MetadataTriggerHandler.bypassedActions.add(actionName);
	}

	public static void clearBypass(String actionName) {
		MetadataTriggerHandler.bypassedActions.remove(actionName);
	}

	public static Boolean isBypassed(String actionName) {
		return MetadataTriggerHandler.bypassedActions.contains(actionName);
	}

	public static void clearAllBypasses() {
		MetadataTriggerHandler.bypassedActions.clear();
	}

	@TestVisible
	private static final String INVALID_TYPE_ERROR = 'Please check the Trigger Action Custom Metadata for the {1} context on the {2} sObject. The {0} class does not implement the Trigger Action interface specified for the {1} context.';

	@TestVisible
	private static final String INVALID_CLASS_ERROR = 'Please check the Trigger Action Custom Metadata for the {1} context on the {2} sObject. The {0} class does not exist.';

	class MetadataTriggerHandlerException extends Exception {
	}
}