/***********************************************************************************************************************************
* Class Name   : PHOS_Constants
* Description  : This class for declare the constants for PHOS app
* Author       : Pankaj
* Created On   : 07/30/2020
* Modification Log:  
* --------------------------------------------------------------------------------------------------------------------------------------
* Developer             Date             Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
* Pankaj              07/30/2020      Initial Implementation
**************************************************************************************************************************************/

public with sharing class PHOS_Constants {
    public static final String ORDER_STATUS_DRAFT = 'Draft';
    public static final String ORDER_STATUS_CDPH_RESOURCE_REQUEST_SUPERVISOR_REVIEW = 'CDPH Resource Request Supervisor Review';
    public static final String ORDER_STATUS_RDMHS_REVIEW = 'RDMHS Review';
    public static final String ORDER_STATUS_MHOAC_REVIEW = 'MHOAC Review';
    public static final String ORDER_APPROVAL_RDMHS_REVIEW_PROCESS = 'RDMHS_Review_Process';
    public static final String ORDER_APPROVAL_MHOAC_REVIEW_PROCESS = 'MHOAC_Review_Process';
    public static final String ORDER_PROFILE_PHOS_CUSTOMER_COMMUNITY_PLUS_LOGIN_USER = 'PHOS Customer Community Plus Login User';

    public static final String SHIPMENT_ORDER_STATUS_READY = 'Ready';
    public static final String SHIPMENT_ORDER_STATUS_SENT = 'Sent';
    public static final String ORDER_PRODUCT_STATUS_SENT = 'Sent';
    //public static final String ORDER_PRODUCT_STATUS_FAILED = 'Failed';
    public static final String ORDER_PRODUCT_STATUS_REJECTED = 'Rejected';
    public static final String ORDER_PRODUCT_STATUS_FULLFILLEDANDCLOSED = 'Fulfilled - Closed';

    public static final String SHIPMENT_LINE_ORDER_STATUS_READY = 'Ready';
    public static final String SHIPMENT_LINE_ORDER_STATUS_Rejected = 'Rejected';
    public static final String APPROVAL_STATUS_APP_REQUESTED = 'App Requested';
    public static final String COMMUNITY_NAME_CALOES_PUBLIC_HEALTH_ORDERING_SYSTEM = 'Cal OES - Public Health Ordering System';

    public static final String FILLED_REGIONALLY_STATUS = 'Filled Locally/Regionally';
    public static final String ORDER_SOURCE_REDDINET = 'Reddinet';
    public static final String ORDER_SOURCE_DYNAMICS = 'Dynamics';

    public static final String ORDER_PRIORITY_EMERGENCY = 'Emergency';

    public static final String FULFILMENT_ENTITY_WAREHOUSE_COLOR = 'Color';
}