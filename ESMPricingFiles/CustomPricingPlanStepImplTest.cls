@isTest(SeeAllData=false)
public class CustomPricingPlanStepImplTest {

    private static String namespace = 'vlocity_cmt__';

    // Intitialized in Setup, used throughout
    public static vlocity_cmt__CalculationMatrixVersion__c version;
    public static SObject versionSobj;
    public static vlocity_cmt__CalculationMatrix__c parent;
    public static SObject parentSobj;
    public static List<vlocity_cmt__CalculationMatrixRow__c> lineItems;
    public static List<SObject> lineItemsSobj;
    private static Id orderId;
    private static boolean flag;  //used to upload matrix row data for test1 or test2
    private static Map<String, vlocity_cmt__PricingVariable__c> pricingVariableByCodeMap;


    //Testing Price a target using attribute value
    /*
    Input : "Consumer Landline" order Item which has "Provider" Attribute having "Verizon"
    Output : MRC 300 and NRC 125 and Target Product Name : Path3 (HD TV)
    */
    static private testmethod void attributeValueBasedTargetPricing(){

        Map<String, Object> output = new Map<String, Object>();
        Map<String, Object> options = new Map<String,Object>();
        Map<String, Object> input = new Map<String, Object>();
        flag = false;

        Test.startTest();
        testProductSetup();
        testMatrixSetup();

        sObject targetProduct = [SELECT Id, Name FROM Product2 WHERE Name = 'HD TV'];
        sObject orderSObject = [SELECT Id, RecordTypeId FROM Order WHERE Id = :orderId];
        List<SObject> orderItemList = [SELECT   Id, PricebookEntryId, PricebookEntry.Product2.Name, PricebookEntry.Product2.ProductCode, Quantity,
                vlocity_cmt__PricingLogData__c, vlocity_cmt__ProvisioningStatus__c, vlocity_cmt__RecurringCharge__c, vlocity_cmt__OneTimeCharge__c,
                vlocity_cmt__JSONAttribute__c,vlocity_cmt__LineNumber__c, vlocity_cmt__Action__c, vlocity_cmt__SupplementalAction__c
                FROM OrderItem WHERE OrderId = :orderId];

        vlocity_cmt.PricingPlanService.putInPricingContext('Parent', orderSObject);
        vlocity_cmt.PricingPlanService.putInPricingContext('LineItemList', orderItemList);
        vlocity_cmt.PricingPlanService.putInPricingContext('PricingVariableDefinitionsMap', pricingVariableByCodeMap);        

        input.put('ProcedureName','TargetPathRangePricingDemoProcedureTest');
        input.put('MatrixName','TargetPathRangePricingMatrixTest');
        //input.put('Path1','Triple Play Bundle Small<Consumer Landline');
        //input.put('Path2','Triple Play Bundle Small<Broadband Internet Small');
        input.put('Path3','Triple Play Bundle Small<TV Small<HD TV');
        input.put('RangeFields','Quantity');
        input.put('IncludeAttrInfoInRangeKeys','true');
        input.put('SourceTargetABP','True');

        CustomPricingPlanStepImpl testing = new CustomPricingPlanStepImpl();
        testing.invokeMethod('GetMatrixPrice',input,output,options);

        Boolean assertExecuted = false;
        for(SObject orderItem : orderItemList){
            if(orderItem.get('vlocity_cmt__RecurringCharge__c')!=null)
            {
                System.assert(orderItem.get('vlocity_cmt__RecurringCharge__c') == 300.00 );
                System.assert(orderItem.get('vlocity_cmt__OneTimeCharge__c') == 125.00 );
                assertExecuted = true;
                break;
            }
        }
        System.assert(assertExecuted);

        Test.stopTest();
    }
    
    //Testing Price a target using attribute value
    /*
    Input : "Consumer Landline" order Item which has "Provider" Attribute having "Verizon" with V2AttributeModel feature enabled
    Output : MRC 300 and NRC 125 and Target Product Name : Path3 (HD TV)
    */
    static private testmethod void v2AttributeValueBasedTargetPricing(){

	Map<String, Object> output = new Map<String, Object>();
        Map<String, Object> options = new Map<String,Object>();
        Map<String, Object> input = new Map<String, Object>();
        flag = false;

        Test.startTest();
        vlocity_cmt.VlocityFeatureService.SetFeatureValue('EnableV2AttributeModel', 'true');
        testProductSetup();
        testMatrixSetup();

        sObject targetProduct = [SELECT Id, Name FROM Product2 WHERE Name = 'HD TV'];
        sObject orderSObject = [SELECT Id FROM Order WHERE Id = :orderId];
        List<SObject> orderItemList = [SELECT   Id, PricebookEntryId, PricebookEntry.Product2.Name, PricebookEntry.Product2.ProductCode, PricebookEntry.Product2.vlocity_cmt__AttributeMetadata__c,
                Quantity,vlocity_cmt__PricingLogData__c, vlocity_cmt__ProvisioningStatus__c, vlocity_cmt__RecurringCharge__c,
                vlocity_cmt__OneTimeCharge__c, vlocity_cmt__AttributeSelectedValues__c,vlocity_cmt__LineNumber__c,vlocity_cmt__Action__c, vlocity_cmt__SupplementalAction__c
                FROM OrderItem WHERE OrderId = :orderId];

        vlocity_cmt.PricingPlanService.putInPricingContext('Parent', orderSObject);
        vlocity_cmt.PricingPlanService.putInPricingContext('LineItemList', orderItemList);
        vlocity_cmt.PricingPlanService.putInPricingContext('PricingVariableDefinitionsMap', pricingVariableByCodeMap);

        input.put('ProcedureName','TargetPathRangePricingDemoProcedureTest');
        input.put('MatrixName','TargetPathRangePricingMatrixTest');
        //input.put('Path1','Triple Play Bundle Small<Consumer Landline');
        //input.put('Path2','Triple Play Bundle Small<Broadband Internet Small');
        input.put('Path3','Triple Play Bundle Small<TV Small<HD TV');
        input.put('RangeFields','Quantity');
        input.put('IncludeAttrInfoInRangeKeys','true');
        //input.put('RangeAttributes','TV Boxes Required');
        input.put('SourceTargetABP','True');
        input.put('InputVariableMap','value1');
       	input.put('FieldAttributes','value1');
        
        input.put('OutputAttributeMap','value2');
       	input.put('OutputVariableMap','value2');
        


        CustomPricingPlanStepImpl testing = new CustomPricingPlanStepImpl();
        testing.invokeMethod('GetMatrixPrice',input,output,options);

        Boolean assertExecuted = false;
        for(SObject orderItem : orderItemList){
            if(orderItem.get('vlocity_cmt__RecurringCharge__c')!=null)
            {
                System.assert(orderItem.get('vlocity_cmt__RecurringCharge__c') == 300.00 );
                System.assert(orderItem.get('vlocity_cmt__OneTimeCharge__c') == 125.00 );
                assertExecuted = true;
                break;
            }
        }
        System.assert(assertExecuted);

        Test.stopTest();
    }

    //Testing Price a target using attribute value
    /*
    Input : "Consumer Landline" order Item which has "Provider" Attribute having "Verizon" later changed to "Xfinity" (UOWMode=TRUE)
    Output : MRC 105 and NRC 50 and Target Product Name : Path3 (HD TV)
    */
    static private testmethod void attributeValueBasedTargetPricing_UOW(){

        Map<String, Object> output = new Map<String, Object>();
        Map<String, Object> options = new Map<String,Object>();
        Map<String, Object> input = new Map<String, Object>();
        flag = false;

        Test.startTest();
        testProductSetup();
        testMatrixSetup();

        sObject targetProduct = [SELECT Id, Name FROM Product2 WHERE Name = 'HD TV'];
        sObject orderSObject = [SELECT Id FROM Order WHERE Id = :orderId];
        List<SObject> orderItemList = [SELECT   Id, PricebookEntryId, PricebookEntry.Product2.Name, PricebookEntry.Product2.ProductCode, Quantity,
                vlocity_cmt__PricingLogData__c, vlocity_cmt__ProvisioningStatus__c, vlocity_cmt__RecurringCharge__c,
                vlocity_cmt__OneTimeCharge__c, vlocity_cmt__JSONAttribute__c,vlocity_cmt__LineNumber__c,vlocity_cmt__Action__c, vlocity_cmt__SupplementalAction__c
                FROM OrderItem WHERE OrderId = :orderId];

        for(SObject orderItem: orderItemList)
        {
                if(orderItem.getSObject('PricebookEntry').getSObject('Product2').get('Name') == 'Consumer Landline')
                {
                        orderItem.put('vlocity_cmt__JSONAttribute__c', '{\"VLO-PRO-0015\":[{\"$$AttributeDefinitionStart$$\":null,\"objectid__c\":\"01t46000003GrteAAC\",\"attributeid__c\":\"a1S46000000NqHeEAK\",\"attributecategoryid__c\":\"a1R46000000S2KWEA0\",\"categorycode__c\":\"VLO-PRO-0015\",\"categoryname__c\":\"Logistics\",\"attributeuniquecode__c\":\"ATTRIBUTE-124\",\"attributeconfigurable__c\":true,\"attributedisplaysequence__c\":\"4\",\"attributefilterable__c\":true,\"attributecloneable__c\":false,\"isactive__c\":true,\"attributedisplayname__c\":\"Provider\",\"displaysequence__c\":\"null\",\"categorydisplaysequence__c\":23,\"customconfiguitemplate__c\":null,\"formatmask__c\":null,\"hasrule__c\":false,\"isconfigurable__c\":true,\"ishidden__c\":false,\"valueinnumber__c\":null,\"objecttype__c\":\"Product2\",\"querycode__c\":null,\"isreadonly__c\":false,\"isquerydriven__c\":false,\"querylabel__c\":null,\"id\":\"a1Q46000000RhxAEAS\",\"isrequired__c\":false,\"rulemessage__c\":null,\"uidisplaytype__c\":\"Radiobutton\",\"value__c\":\"Xfinity\",\"valuedatatype__c\":\"Picklist\",\"valuedescription__c\":null,\"attributeRunTimeInfo\":{\"dataType\":\"Picklist\",\"uiDisplayType\":\"Radiobutton\",\"default\":[{\"value\":\"Verizon\",\"id\":2,\"displayText\":\"Verizon\"}],\"values\":[{\"value\":\"ATT\",\"id\":1,\"displayText\":\"AT&T\"},{\"value\":\"Verizon\",\"id\":2,\"displayText\":\"Verizon\"},{\"value\":\"Xfinity\",\"id\":3,\"displayText\":\"Xfinity\"}],\"selectedItem\":{\"value\":\"Xfinity\",\"id\":3,\"displayText\":\"Xfinity\"}},\"$$AttributeDefinitionEnd$$\":null}]}');
                        break;
                }
        }
        vlocity_cmt.PricingPlanService.putInPricingContext('Parent', orderSObject);
        vlocity_cmt.PricingPlanService.putInPricingContext('LineItemList', orderItemList);
        vlocity_cmt.PricingPlanService.putInPricingContext('PricingVariableDefinitionsMap', pricingVariableByCodeMap);

        input.put('ProcedureName','TargetPathRangePricingDemoProcedureTest');
        input.put('MatrixName','TargetPathRangePricingMatrixTest');
        //input.put('Path1','Triple Play Bundle Small<Consumer Landline');
        //input.put('Path2','Triple Play Bundle Small<Broadband Internet Small');
        input.put('IncludeAttrInfoInRangeKeys','true');
        input.put('Path3','Triple Play Bundle Small<TV Small<HD TV');
        input.put('RangeFields','Quantity');
        input.put('SourceTargetABP','True');

        CustomPricingPlanStepImpl testing = new CustomPricingPlanStepImpl();
        testing.invokeMethod('GetMatrixPrice',input,output,options);

        Boolean assertExecuted = false;
        for(SObject orderItem : orderItemList){
            if(orderItem.get('vlocity_cmt__RecurringCharge__c')!=null)
            {
                System.assert(orderItem.get('vlocity_cmt__RecurringCharge__c') == 50.00 );
                System.assert(orderItem.get('vlocity_cmt__OneTimeCharge__c') == 105.00 );
                assertExecuted = true;
                break;
            }
        }
        System.assert(assertExecuted);

        Test.stopTest();
    }

    //Testing Price a target using attribute value range
    /*
    Input : "HD TV" order Item which has "TV Content;TV Boxes Required"  ......  Default : "HD;4"
    Output : MRC 300 and NRC 125 and Target Product Name : Path1 (Consumer Landline)
    */
    static private testmethod void attributeRangeBasedTargetPricing(){

        Map<String, Object> output = new Map<String, Object>();
        Map<String, Object> options = new Map<String,Object>();
        Map<String, Object> input = new Map<String, Object>();
        flag = true;

        Test.startTest();
        testProductSetup();
        attributeRangeBasedTargetPricingMatrixSetup();

        sObject targetProduct = [ SELECT Id, Name FROM Product2 WHERE Name = 'Consumer Landline'];
        sObject orderSObject = [SELECT Id FROM Order WHERE Id = :orderId];
        List<SObject> orderItemList = [SELECT   Id, PricebookEntryId, PricebookEntry.Product2.Name, PricebookEntry.Product2.ProductCode, Quantity,
                vlocity_cmt__PricingLogData__c, vlocity_cmt__ProvisioningStatus__c, vlocity_cmt__RecurringCharge__c,
                vlocity_cmt__OneTimeCharge__c, vlocity_cmt__JSONAttribute__c,vlocity_cmt__LineNumber__c,vlocity_cmt__Action__c, vlocity_cmt__SupplementalAction__c
                FROM OrderItem WHERE OrderId = :orderId];

        vlocity_cmt.PricingPlanService.putInPricingContext('Parent', orderSObject);
        vlocity_cmt.PricingPlanService.putInPricingContext('LineItemList', orderItemList);
        vlocity_cmt.PricingPlanService.putInPricingContext('PricingVariableDefinitionsMap', pricingVariableByCodeMap);

        input.put('ProcedureName','TargetPathRangePricingDemoProcedureTest');
        input.put('MatrixName','TargetPathRangePricingMatrixTest');
        input.put('Path1','Triple Play Bundle Small<Consumer Landline');
        input.put('RangeAttributes','TV Boxes Required');
        input.put('RangeFields','Quantity');
        input.put('SourceTargetABP','True');
        input.put('IncludeAttrInfoInRangeKeys','True');

        CustomPricingPlanStepImpl testing = new CustomPricingPlanStepImpl();
        testing.invokeMethod('GetMatrixPrice',input,output,options);

        Boolean assertExecuted = false;
        for(SObject orderItem : orderItemList)
        {
            if(orderItem.get('vlocity_cmt__RecurringCharge__c')!=null)
            {
                System.assert(orderItem.get('vlocity_cmt__RecurringCharge__c') == 300.00 );
                System.assert(orderItem.get('vlocity_cmt__OneTimeCharge__c') == 125.00 );
                assertExecuted = true;
                break;
            }
        }
        System.assert(assertExecuted);

        Test.stopTest();
    }
    
    //Testing Price a target using multiple attribute values
    /*
    Input : "Broadband Internet Small" order Item which has "Internet Upload Speed;Internet Download Speed"  ......  Default : "80Mbps;16Mbps"
    Output : MRC 25 and NRC 0 and Target Product Name : Path1 (Consumer Product)
    */
    static private testmethod void attributeValuesBasedTargetPricing(){

        Map<String, Object> output = new Map<String, Object>();
        Map<String, Object> options = new Map<String,Object>();
        Map<String, Object> input = new Map<String, Object>();
        flag = true;

        Test.startTest();
        testProductSetup();
        testMatrixSetup();

        sObject targetProduct = [ SELECT Id, Name FROM Product2 WHERE Name = 'Consumer Landline'];
        sObject orderSObject = [SELECT Id FROM Order WHERE Id = :orderId];
        List<SObject> orderItemList = [SELECT   Id, PricebookEntryId, PricebookEntry.Product2.Name, PricebookEntry.Product2.ProductCode, Quantity,
                vlocity_cmt__PricingLogData__c, vlocity_cmt__ProvisioningStatus__c, vlocity_cmt__RecurringCharge__c,
                vlocity_cmt__OneTimeCharge__c, vlocity_cmt__JSONAttribute__c,vlocity_cmt__LineNumber__c,vlocity_cmt__Action__c, vlocity_cmt__SupplementalAction__c
                FROM OrderItem WHERE OrderId = :orderId];

        vlocity_cmt.PricingPlanService.putInPricingContext('Parent', orderSObject);
        vlocity_cmt.PricingPlanService.putInPricingContext('LineItemList', orderItemList);
        vlocity_cmt.PricingPlanService.putInPricingContext('PricingVariableDefinitionsMap', pricingVariableByCodeMap);

        input.put('ProcedureName','TargetPathRangePricingDemoProcedureTest');
        input.put('MatrixName','TargetPathRangePricingMatrixTest');
        input.put('Path1','Triple Play Bundle Small<Consumer Landline');
        //input.put('Path2','Triple Play Bundle Small<Broadband Internet Small');
        //input.put('Path3','Triple Play Bundle Small<TV Small<HD TV');
        input.put('IncludeAttrInfoInRangeKeys','true');
        input.put('RangeFields','Quantity');
        input.put('SourceTargetABP','True');

        CustomPricingPlanStepImpl testing = new CustomPricingPlanStepImpl();
        testing.invokeMethod('GetMatrixPrice',input,output,options);

        Boolean assertExecuted = false;
        for(SObject orderItem : orderItemList)
        {
            if(orderItem.get('vlocity_cmt__RecurringCharge__c')!=null)
            {
                System.assert(orderItem.get('vlocity_cmt__RecurringCharge__c') == 15.00 );
                System.assert(orderItem.get('vlocity_cmt__OneTimeCharge__c') == 0 );
                assertExecuted = true;
                break;
            }
        }
        System.assert(assertExecuted);

        Test.stopTest();
    }

    //Testing Price a product using attribute value range
    /*
    Input : "Broadband Internet Small" order Item which has "Internet Upload Speed;Internet Download Speed"  ......
    Output : MRC 30 and NRC 0 for Internet Upload Speed:0-10 and Internet Download Speed:100Mbps
    */
    static private testmethod void testRangeAttributeOverlapping(){

        Map<String, Object> output = new Map<String, Object>();
        Map<String, Object> options = new Map<String,Object>();
        Map<String, Object> input = new Map<String, Object>();

        testProductSetup();
        testOverlappingAttributeRangeMatrixSetup();

        sObject targetProduct = [ SELECT Id, Name FROM Product2 WHERE Name = 'Consumer Landline'];
        sObject orderSObject = [SELECT Id FROM Order WHERE Id = :orderId];
        List<SObject> orderItemList = [SELECT   Id, PricebookEntryId, PricebookEntry.Product2.Name, PricebookEntry.Product2.ProductCode, Quantity,
                vlocity_cmt__PricingLogData__c, vlocity_cmt__ProvisioningStatus__c, vlocity_cmt__RecurringCharge__c,
                vlocity_cmt__OneTimeCharge__c, vlocity_cmt__JSONAttribute__c,vlocity_cmt__LineNumber__c, vlocity_cmt__Action__c, vlocity_cmt__SupplementalAction__c
                FROM OrderItem WHERE OrderId = :orderId];

        vlocity_cmt.PricingPlanService.putInPricingContext('Parent', orderSObject);

        for(SObject orderItem: orderItemList)
        {
            if((String)orderItem.get('vlocity_cmt__LineNumber__c') == '0001.0002')
            {
                orderItem.put('vlocity_cmt__JSONAttribute__c','{\"INTERNET-CAT1\":[{\"$$AttributeDefinitionStart$$\":null,\"objectid__c\":\"01t46000003GrttAAC\",\"attributeid__c\":\"a1S46000000O2fqEAC\",\"attributecategoryid__c\":\"a1R46000000ths0EAA\",\"categorycode__c\":\"INTERNET-CAT1\",\"categoryname__c\":\"Internet\",\"attributeuniquecode__c\":\"ATTRIBUTE-1200\",\"attributeconfigurable__c\":true,\"attributedisplaysequence__c\":\"1\",\"attributefilterable__c\":true,\"attributecloneable__c\":true,\"isactive__c\":true,\"attributedisplayname__c\":\"Internet Download Speed\",\"displaysequence__c\":\"null\",\"categorydisplaysequence__c\":1,\"customconfiguitemplate__c\":null,\"formatmask__c\":null,\"hasrule__c\":false,\"isconfigurable__c\":true,\"ishidden__c\":false,\"valueinnumber__c\":null,\"objecttype__c\":\"Product2\",\"querycode__c\":null,\"isreadonly__c\":false,\"isquerydriven__c\":false,\"querylabel__c\":null,\"id\":\"a1Q46000000RhwvEAC\",\"isrequired__c\":false,\"rulemessage__c\":null,\"uidisplaytype__c\":\"Text\",\"value__c\":\"100Mbps\",\"valuedatatype__c\":\"Text\",\"valuedescription__c\":null,\"attributeRunTimeInfo\":{\"dataType\":\"Text\",\"uiDisplayType\":\"Text\",\"value\":\"100Mbps\"},\"$$AttributeDefinitionEnd$$\":null},{\"$$AttributeDefinitionStart$$\":null,\"objectid__c\":\"01t46000003GrttAAC\",\"attributeid__c\":\"a1S46000000O2g0EAC\",\"attributecategoryid__c\":\"a1R46000000ths0EAA\",\"categorycode__c\":\"INTERNET-CAT1\",\"categoryname__c\":\"Internet\",\"attributeuniquecode__c\":\"ATTRIBUTE-1270\",\"attributeconfigurable__c\":true,\"attributedisplaysequence__c\":\"1\",\"attributefilterable__c\":true,\"attributecloneable__c\":true,\"isactive__c\":true,\"attributedisplayname__c\":\"Internet Upload Speed\",\"displaysequence__c\":\"null\",\"categorydisplaysequence__c\":1,\"customconfiguitemplate__c\":null,\"formatmask__c\":null,\"hasrule__c\":false,\"isconfigurable__c\":true,\"ishidden__c\":false,\"valueinnumber__c\":null,\"objecttype__c\":\"Product2\",\"querycode__c\":null,\"isreadonly__c\":false,\"isquerydriven__c\":false,\"querylabel__c\":null,\"id\":\"a1Q46000000RhwwEAC\",\"isrequired__c\":false,\"rulemessage__c\":null,\"uidisplaytype__c\":\"null\",\"value__c\":\"8\",\"valuedatatype__c\":\"Number\",\"valuedescription__c\":null,\"attributeRunTimeInfo\":{\"dataType\":\"Number\",\"uiDisplayType\":\"null\",\"value\":\"8\"},\"$$AttributeDefinitionEnd$$\":null}]}');
                update orderItem;
                break;
            }
        }
        vlocity_cmt.PricingPlanService.putInPricingContext('LineItemList', orderItemList);
        vlocity_cmt.PricingPlanService.putInPricingContext('PricingVariableDefinitionsMap', pricingVariableByCodeMap);

        input.put('ProcedureName','AttributeRangePricingDemoProcedureTest');
        input.put('MatrixName','AttributeRangePricingMatrixTest');
        input.put('OverlappingRanges','True');
        input.put('RangeAttributes','Internet Upload Speed');

        Test.startTest();
        CustomPricingPlanStepImpl testing = new CustomPricingPlanStepImpl();
        testing.invokeMethod('GetMatrixPrice',input,output,options);

        for(SObject orderItem : orderItemList)
        {
            if(orderItem.get('vlocity_cmt__RecurringCharge__c')!=null)
            {
                System.assert(orderItem.get('vlocity_cmt__OneTimeCharge__c') == 0 );
                System.assert(orderItem.get('vlocity_cmt__RecurringCharge__c') == 30.00 );
            }
        }
        Test.stopTest();
    }

    static private testmethod void attributeBasedUsagePricing()
    {
        Map<String, Object> output = new Map<String, Object>();
        Map<String, Object> options = new Map<String,Object>();
        Map<String, Object> input = new Map<String, Object>();
        
        insert new vlocity_cmt__ChargeMeasurement__c(Name = 'p/day');
        insert new vlocity_cmt__ChargeMeasurement__c(Name = 'kwh');


        Test.startTest();
        vlocity_cmt.VlocityFeatureService.enableUsageFeature();
        testProductSetup();
        testMatrix2Setup();

        sObject targetProduct = [ SELECT Id, Name FROM Product2 WHERE Name = 'Consumer Landline'];
        sObject orderSObject = [SELECT Id FROM Order WHERE Id = :orderId];
        List<SObject> orderItemList = [SELECT   Id, PricebookEntryId, PricebookEntry.Product2.Name, PricebookEntry.Product2.ProductCode, Quantity,
                vlocity_cmt__PricingLogData__c, vlocity_cmt__ProvisioningStatus__c, vlocity_cmt__RecurringCharge__c,
                vlocity_cmt__OneTimeCharge__c, vlocity_cmt__JSONAttribute__c,vlocity_cmt__LineNumber__c,vlocity_cmt__Action__c, vlocity_cmt__SupplementalAction__c
                FROM OrderItem WHERE OrderId = :orderId];

        vlocity_cmt.PricingPlanService.putInPricingContext('Parent', orderSObject);
        vlocity_cmt.PricingPlanService.putInPricingContext('LineItemList', orderItemList);
        vlocity_cmt.PricingPlanService.putInPricingContext('PricingVariableDefinitionsMap', pricingVariableByCodeMap);

        input.put('ProcedureName','TargetPathRangePricingDemoProcedureTest');
        input.put('MatrixName','TargetPathRangePricingMatrixTest');
        //input.put('Path1','Triple Play Bundle Small<Consumer Landline');
        //input.put('Path2','Triple Play Bundle Small<Broadband Internet Small');
        //input.put('Path3','Triple Play Bundle Small<TV Small<HD TV');
        input.put('SourceTargetABP','True');

        CustomPricingPlanStepImpl testing = new CustomPricingPlanStepImpl();
        testing.invokeMethod('GetMatrixPrice',input,output,options);

        Boolean assertExecuted = false;
        for(SObject orderItem : orderItemList)
        {
            if(orderItem.get('vlocity_cmt__RecurringCharge__c')!=null)
            {
                System.assert(orderItem.get('vlocity_cmt__RecurringCharge__c') == 0 );
                System.assert(orderItem.get('vlocity_cmt__OneTimeCharge__c') == 0 );
                System.assert(orderItem.get('vlocity_cmt__UsageUnitPrice__c') == 0.234 );
                assertExecuted = true;
                break;
            }
        }
        System.assert(assertExecuted);

        Test.stopTest();  
    }

    //Testing Volume Based Attribute Pricing + TimePlanPolicy
    /*
    Input : Quantity (5)
    Output : MRC 25 and NRC 0
    */
    static private testmethod void testTimePlanPolicyVolumeABP(){

        Map<String, Object> output = new Map<String, Object>();
        Map<String, Object> options = new Map<String,Object>();
        Map<String, Object> input = new Map<String, Object>();

        testProductSetup();
        timePlanPolicyVolumeMatrixSetup();

        sObject orderSObject = [SELECT Id FROM Order WHERE Id = :orderId];
        List<SObject> orderItemList = [SELECT   Id, PricebookEntryId, PricebookEntry.Product2.Name, PricebookEntry.Product2.ProductCode, Quantity,
                vlocity_cmt__PricingLogData__c, vlocity_cmt__ProvisioningStatus__c, vlocity_cmt__RecurringCharge__c,
                vlocity_cmt__OneTimeCharge__c, vlocity_cmt__JSONAttribute__c,vlocity_cmt__LineNumber__c,vlocity_cmt__Action__c, vlocity_cmt__SupplementalAction__c
                FROM OrderItem WHERE OrderId = :orderId];

        vlocity_cmt.PricingPlanService.putInPricingContext('Parent', orderSObject);
        vlocity_cmt.PricingPlanService.putInPricingContext('LineItemList', orderItemList);
        vlocity_cmt.PricingPlanService.putInPricingContext('PricingVariableDefinitionsMap', pricingVariableByCodeMap);

        input.put('ProcedureName','VolumeTimePlanPolicyPricingProcedure');
        input.put('MatrixName','VolumeTimePlanPolicyPricingMatrix');
        input.put('RangeFields','Quantity');
        input.put('CreateAdjustment','True');

        Test.startTest();
        CustomPricingPlanStepImpl testing = new CustomPricingPlanStepImpl();
        testing.invokeMethod('GetMatrixPrice',input,output,options);

        Boolean assertExecuted = false;
        for(SObject orderItem : orderItemList){
            if(orderItem.get('vlocity_cmt__RecurringCharge__c')!=null)
            {
                System.assert(orderItem.get('vlocity_cmt__RecurringCharge__c') == 6.00 );
                System.assert(orderItem.get('vlocity_cmt__OneTimeCharge__c') == 5.00 );

                List<vlocity_cmt__OrderPriceAdjustment__c> orderAdjustments = [Select Id,vlocity_cmt__PricingVariableCode__c,vlocity_cmt__Amount__c,vlocity_cmt__TimePlanId__c,vlocity_cmt__TimePlanId__r.Name,vlocity_cmt__TimePolicyId__c,vlocity_cmt__TimePolicyId__r.Name From vlocity_cmt__OrderPriceAdjustment__c Where vlocity_cmt__OrderItemId__c=:orderItem.Id];
                System.assert(orderAdjustments.size()==2);

                for(vlocity_cmt__OrderPriceAdjustment__c orderAdjustment: orderAdjustments){
                    if((String)orderAdjustment.get('vlocity_cmt__PricingVariableCode__c')=='REC_MNTH_STD_PRC')
                    {
                        System.assert((Decimal)orderAdjustment.get('vlocity_cmt__Amount__c')==6.00);
                        System.assert((String) orderAdjustment.getSObject('vlocity_cmt__TimePlanId__r').get('Name')=='6 Month Time Plan');
                        System.assert((String) orderAdjustment.getSObject('vlocity_cmt__TimePolicyId__r').get('Name')=='Start Now End by Plan Duration');
                    }
                    else
                    {
                        System.assert((Decimal)orderAdjustment.get('vlocity_cmt__Amount__c')==5.00);
                    }
                }
                assertExecuted = true;
                break;
            }
        }
        System.assert(assertExecuted);

        Test.stopTest();
    }

    static private void timePlanPolicyVolumeMatrixSetup() {
        insert new vlocity_cmt__TriggerSetup__c(Name = 'AllTriggers', vlocity_cmt__IsTriggerOn__c = true);
        parent = new vlocity_cmt__CalculationMatrix__c(Name = 'VolumeTimePlanPolicyPricingMatrix');
        insert parent;

        version = new vlocity_cmt__CalculationMatrixVersion__c(Name = 'VolumeTimePlanPolicyPricingMatrix v2', vlocity_cmt__VersionNumber__c = 2,
                vlocity_cmt__IsEnabled__c = false, vlocity_cmt__CalculationMatrixId__c = parent.Id,
                vlocity_cmt__StartDateTime__c = DateTime.now().addDays(-10), vlocity_cmt__EndDateTime__c = DateTime.now().addDays(10),vlocity_cmt__Priority__c = 1);
        insert version;

        //Populating Headers
        lineItems = new List<vlocity_cmt__CalculationMatrixRow__c>();
        lineItems.add(new vlocity_cmt__CalculationMatrixRow__c(vlocity_cmt__CalculationMatrixVersionId__c = version.Id, Name = 'Header',
                vlocity_cmt__InputData__c ='{\"listValues\":null,\"name":\"Source Product Name\",\"label\":null,\"headerType\":\"Input\",\"displayOrder\":1,\"dataType\":\"Text\"}'
        ));
        lineItems.add(new vlocity_cmt__CalculationMatrixRow__c(vlocity_cmt__CalculationMatrixVersionId__c = version.Id, Name = 'Header',
                vlocity_cmt__InputData__c ='{\"listValues\":null,\"name":\"Source Product Code\",\"label\":null,\"headerType\":\"Input\",\"displayOrder\":2,\"dataType\":\"Text\"}'
        ));
        lineItems.add(new vlocity_cmt__CalculationMatrixRow__c(vlocity_cmt__CalculationMatrixVersionId__c = version.Id, Name = 'Header',
                vlocity_cmt__InputData__c ='{\"listValues\":null,\"name":\"Quantity\",\"label\":null,\"headerType\":\"Input\",\"displayOrder\":3,\"dataType\":\"Text\"}'
        ));
        lineItems.add(new vlocity_cmt__CalculationMatrixRow__c(vlocity_cmt__CalculationMatrixVersionId__c = version.Id, Name = 'Header',
                vlocity_cmt__InputData__c ='{\"listValues\":null,\"name":\"MRC\",\"label\":null,\"headerType\":\"Output\",\"displayOrder\":4,\"dataType\":\"Text\"}'
        ));
        lineItems.add(new vlocity_cmt__CalculationMatrixRow__c(vlocity_cmt__CalculationMatrixVersionId__c = version.Id, Name = 'Header',
                vlocity_cmt__InputData__c ='{\"listValues\":null,\"name":\"NRC\",\"label\":null,\"headerType\":\"Output\",\"displayOrder\":5,\"dataType\":\"Text\"}'
        ));
        lineItems.add(new vlocity_cmt__CalculationMatrixRow__c(vlocity_cmt__CalculationMatrixVersionId__c = version.Id, Name = 'Header',
                vlocity_cmt__InputData__c ='{\"listValues\":null,\"name":\"Time Plan\",\"label\":null,\"headerType\":\"Output\",\"displayOrder\":6,\"dataType\":\"Text\"}'
        ));
        lineItems.add(new vlocity_cmt__CalculationMatrixRow__c(vlocity_cmt__CalculationMatrixVersionId__c = version.Id, Name = 'Header',
                vlocity_cmt__InputData__c ='{\"listValues\":null,\"name":\"Time Policy\",\"label\":null,\"headerType\":\"Output\",\"displayOrder\":7,\"dataType\":\"Text\"}'
        ));
        insert lineItems;

        //Populating Row Data
        lineItems = new List<vlocity_cmt__CalculationMatrixRow__c>();
        lineItems.add(new vlocity_cmt__CalculationMatrixRow__c(vlocity_cmt__CalculationMatrixVersionId__c = version.Id,
                vlocity_cmt__InputData__c ='{\"Quantity\":\"1-2\",\"Source Product Code\":\"VLO-INT-0001\",\"Source Product Name\":\"Broadband Internet Small\"}',
                vlocity_cmt__OutputData__c = '{\"NRC\":\"1\",\"MRC\":\"2\",\"Time Plan\":\"1 Year Time Plan\",\"Time Policy\":\"Start Now End by Plan Duration\"}'
        ));
        lineItems.add(new vlocity_cmt__CalculationMatrixRow__c(vlocity_cmt__CalculationMatrixVersionId__c = version.Id,
                vlocity_cmt__InputData__c ='{\"Quantity\":\"3-4\",\"Source Product Code\":\"VLO-INT-0001\",\"Source Product Name\":\"Broadband Internet Small\"}',
                vlocity_cmt__OutputData__c = '{\"NRC\":\"3\",\"MRC\":\"4\",\"Time Plan\":\"1 Year Time Plan\",\"Time Policy\":\"Start Now End by Plan Duration\"}'
        ));
        lineItems.add(new vlocity_cmt__CalculationMatrixRow__c(vlocity_cmt__CalculationMatrixVersionId__c = version.Id,
                vlocity_cmt__InputData__c ='{\"Quantity\":\"5-6\",\"Source Product Code\":\"VLO-INT-0001\",\"Source Product Name\":\"Broadband Internet Small\"}',
                vlocity_cmt__OutputData__c = '{\"NRC\":\"5\",\"MRC\":\"6\",\"Time Plan\":\"6 Month Time Plan\",\"Time Policy\":\"Start Now End by Plan Duration\"}'
        ));
        lineItems.add(new vlocity_cmt__CalculationMatrixRow__c(vlocity_cmt__CalculationMatrixVersionId__c = version.Id,
                vlocity_cmt__InputData__c ='{\"Quantity\":\"7-8\",\"Source Product Code\":\"VLO-INT-0001\",\"Source Product Name\":\"Broadband Internet Small\"}',
                vlocity_cmt__OutputData__c = '{\"NRC\":\"7\",\"MRC\":\"8\",\"Time Plan\":\"6 Month Time Plan\",\"Time Policy\":\"Start Now End by Plan Duration\"}'
        ));
        insert lineItems;

        lineItems = [SELECT Name, vlocity_cmt__InputData__c, vlocity_cmt__OutputData__c FROM vlocity_cmt__CalculationMatrixRow__c WHERE Name != 'Header'];
        update new vlocity_cmt__CalculationMatrixVersion__c(Id = version.Id, vlocity_cmt__IsEnabled__c = true);

        //service
        vlocity_cmt__CalculationProcedure__c calcProcedure = new vlocity_cmt__CalculationProcedure__c(Name='VolumeTimePlanPolicyPricingProcedure');
        insert calcProcedure;

        //Making isEnabled = false due to ERROR="Please add steps before enabling this procedure configuration."
        vlocity_cmt__CalculationProcedureVersion__c procVersion = new vlocity_cmt__CalculationProcedureVersion__c(Name='VolumeTimePlanPolicyPricingProcedure v2', vlocity_cmt__VersionNumber__c=2, vlocity_cmt__IsEnabled__c=false,
                vlocity_cmt__CalculationProcedureId__c=calcProcedure.Id, vlocity_cmt__StartDateTime__c = DateTime.now().addDays(-5), vlocity_cmt__EndDateTime__c = DateTime.now().addDays(5), vlocity_cmt__Priority__c=1);
        insert procVersion;

        List<vlocity_cmt__CalculationProcedureStep__c> steps = new List<vlocity_cmt__CalculationProcedureStep__c> ();
        vlocity_cmt__CalculationProcedureStep__c step1 = new vlocity_cmt__CalculationProcedureStep__c (Name='a1L46000001ASQm', vlocity_cmt__Sequence__c=1,vlocity_cmt__Function__c='Matrix Lookup', vlocity_cmt__CalculationMatrixId__c=parent.Id, vlocity_cmt__IsIncludedInResult__c=true, vlocity_cmt__CalculationProcedureVersionId__c= procVersion.Id,
                vlocity_cmt__Input__c='[{\"name\":\"Source Product Name\",\"listValues\":null,\"label\":null,\"dataType\":\"Text\",\"columnKey\":\"3ce730\"},{\"name\":\"Source Product Code\",\"listValues\":null,\"label\":null,\"dataType\":\"Text\",\"columnKey\":\"b7ef4b\"},{\"name\":\"Quantity\",\"listValues\":null,\"label\":null,\"dataType\":\"Text\",\"columnKey\":\"1a5a15\"}]',
                vlocity_cmt__OutputJSON__c='[{\"name\":\"MRC\",\"listValues\":null,\"label\":null,\"dataType\":\"Text\",\"columnKey\":\"405688\"},{\"name\":\"NRC\",\"listValues\":null,\"label\":null,\"dataType\":\"Text\",\"columnKey\":\"31190\"},{\"name\":\"Time Plan\",\"listValues\":null,\"label\":null,\"dataType\":\"Text\",\"columnKey\":\"933787\"},{\"name\":\"Time Policy\",\"listValues\":null,\"label\":null,\"dataType\":\"Text\",\"columnKey\":\"6d6a3d\"}]',
                vlocity_cmt__OutputMappingJSON__c ='{\"MRC\":\"TimePlanAttributeBasedMatrix__MRC\",\"NRC\":\"TimePlanAttributeBasedMatrix__NRC\",\"Time Plan\":\"TimePlanAttributeBasedMatrix__TimePlan\",\"Time Policy\":\"TimePlanAttributeBasedMatrix__TimePolicy\"}');
        vlocity_cmt__CalculationProcedureStep__c step2 = new vlocity_cmt__CalculationProcedureStep__c (Name='a1L46000001ASQn', vlocity_cmt__Sequence__c=2,vlocity_cmt__Function__c='Calculation', vlocity_cmt__IsIncludedInResult__c=true, vlocity_cmt__CalculationProcedureVersionId__c= procVersion.Id,
                vlocity_cmt__CalculationFormulaLong__c='TimePlanAttributeBasedMatrix__MRC', vlocity_cmt__OutputJSON__c='{\"name\":\"REC_MNTH_STD_PRC\",\"dataType\":\"Currency\",\"alias\":\"REC_MNTH_STD_PRC\"}',
                vlocity_cmt__OutputMappingJSON__c = '{\"REC_MNTH_STD_PRC\":\"REC_MNTH_STD_PRC\"}', vlocity_cmt__CalculationFormulaTags__c='[{\"text\":\"MRC ( VolumeRangeAttributePricingMatrix )\",\"alias\":\"VolumeRangeAttributePricingMatrix__MRC\",\"userDefined\":false,\"dataType\":\"Text\"}]');
        vlocity_cmt__CalculationProcedureStep__c step3 = new vlocity_cmt__CalculationProcedureStep__c (Name='a1L46000001ASQo', vlocity_cmt__Sequence__c=3,vlocity_cmt__Function__c='Calculation', vlocity_cmt__IsIncludedInResult__c=true, vlocity_cmt__CalculationProcedureVersionId__c= procVersion.Id,
                vlocity_cmt__CalculationFormulaLong__c='TimePlanAttributeBasedMatrix__NRC',vlocity_cmt__OutputJSON__c='{\"name\":\"OT_STD_PRC\",\"dataType\":\"Currency\",\"alias\":\"OT_STD_PRC\"}',
                vlocity_cmt__OutputMappingJSON__c = '{\"OT_STD_PRC\":\"OT_STD_PRC\"}', vlocity_cmt__CalculationFormulaTags__c='[{\"text\":\"MRC ( TimePlanAttributeBasedMatrix )\",\"alias\":\"TimePlanAttributeBasedMatrix__NRC\",\"userDefined\":false,\"dataType\":\"Text\"}]' );
        steps.add(step1);
        steps.add(step2);
        steps.add(step3);
        insert steps;

        List<vlocity_cmt__CalculationProcedureVariable__c> calcProcVariableList = new List<vlocity_cmt__CalculationProcedureVariable__c>{
                new vlocity_cmt__CalculationProcedureVariable__c(name='REC_MNTH_STD_PRC',vlocity_cmt__alias__c='REC_MNTH_STD_PRC',vlocity_cmt__datatype__c='Currency',vlocity_cmt__CalculationProcedureVersionId__c=procVersion.Id),
                new vlocity_cmt__CalculationProcedureVariable__c(name='OT_STD_PRC',vlocity_cmt__alias__c='OT_STD_PRC',vlocity_cmt__datatype__c='Currency',vlocity_cmt__CalculationProcedureVersionId__c=procVersion.Id),
                new vlocity_cmt__CalculationProcedureVariable__c(name='Source Product Name',vlocity_cmt__alias__c='SourceProductName',vlocity_cmt__datatype__c='Text',vlocity_cmt__CalculationProcedureVersionId__c=procVersion.Id),
                new vlocity_cmt__CalculationProcedureVariable__c(name='Source Product Code',vlocity_cmt__alias__c='SourceProductCode',vlocity_cmt__datatype__c='Text',vlocity_cmt__CalculationProcedureVersionId__c=procVersion.Id),
                new vlocity_cmt__CalculationProcedureVariable__c(name='Quantity',vlocity_cmt__alias__c='Quantity',vlocity_cmt__datatype__c='Text',vlocity_cmt__CalculationProcedureVersionId__c=procVersion.Id),
                new vlocity_cmt__CalculationProcedureVariable__c(name='MRC',vlocity_cmt__alias__c='TimePlanAttributeBasedMatrix__MRC',vlocity_cmt__datatype__c='Text',vlocity_cmt__CalculationProcedureVersionId__c=procVersion.Id),
                new vlocity_cmt__CalculationProcedureVariable__c(name='NRC',vlocity_cmt__alias__c='TimePlanAttributeBasedMatrix__NRC',vlocity_cmt__datatype__c='Text',vlocity_cmt__CalculationProcedureVersionId__c=procVersion.Id),
                new vlocity_cmt__CalculationProcedureVariable__c(name='Time Plan',vlocity_cmt__alias__c='TimePlanAttributeBasedMatrix__TimePlan',vlocity_cmt__datatype__c='Text',vlocity_cmt__CalculationProcedureVersionId__c=procVersion.Id),
                new vlocity_cmt__CalculationProcedureVariable__c(name='Time Policy',vlocity_cmt__alias__c='TimePlanAttributeBasedMatrix__TimePolicy',vlocity_cmt__datatype__c='Text',vlocity_cmt__CalculationProcedureVersionId__c=procVersion.Id)
                };
        insert calcProcVariableList;

        //Creating and enabling CalculationProcedureVersion
        update new vlocity_cmt__CalculationProcedureVersion__c(Id = procVersion.Id, vlocity_cmt__IsEnabled__c = true);

    }

    static private void testMatrixSetup() {
        insert new vlocity_cmt__TriggerSetup__c(Name = 'AllTriggers', vlocity_cmt__IsTriggerOn__c = true);
        parent = new vlocity_cmt__CalculationMatrix__c(Name = 'TargetPathRangePricingMatrixTest');
        insert parent;

        version = new vlocity_cmt__CalculationMatrixVersion__c(Name = 'TargetPathRangePricingMatrixTest Version', vlocity_cmt__VersionNumber__c = 5,
                vlocity_cmt__IsEnabled__c = false, vlocity_cmt__CalculationMatrixId__c = parent.Id,
                vlocity_cmt__StartDateTime__c = DateTime.now().addDays(-10), vlocity_cmt__EndDateTime__c = DateTime.now().addDays(10),vlocity_cmt__Priority__c = 5);
        insert version;

        //Populating Headers
        lineItems = new List<vlocity_cmt__CalculationMatrixRow__c>();
        lineItems.add(new vlocity_cmt__CalculationMatrixRow__c(vlocity_cmt__CalculationMatrixVersionId__c = version.Id, Name = 'Header',
                vlocity_cmt__InputData__c ='{\"listValues\":null,\"name":\"Characteristic Name\",\"label\":null,\"headerType\":\"Input\",\"displayOrder\":1,\"dataType\":\"Text\"}'
        ));
        lineItems.add(new vlocity_cmt__CalculationMatrixRow__c(vlocity_cmt__CalculationMatrixVersionId__c = version.Id, Name = 'Header',
                vlocity_cmt__InputData__c ='{\"listValues\":null,\"name":\"Source Product Code\",\"label\":null,\"headerType\":\"Input\",\"displayOrder\":2,\"dataType\":\"Text\"}'
        ));
        lineItems.add(new vlocity_cmt__CalculationMatrixRow__c(vlocity_cmt__CalculationMatrixVersionId__c = version.Id, Name = 'Header',
                vlocity_cmt__InputData__c ='{\"listValues\":null,\"name":\"Source Product Name\",\"label\":null,\"headerType\":\"Input\",\"displayOrder\":3,\"dataType\":\"Text\"}'
        ));
        lineItems.add(new vlocity_cmt__CalculationMatrixRow__c(vlocity_cmt__CalculationMatrixVersionId__c = version.Id, Name = 'Header',
                vlocity_cmt__InputData__c ='{\"listValues\":null,\"name":\"Characteristic Value\",\"label\":null,\"headerType\":\"Input\",\"displayOrder\":4,\"dataType\":\"Text\"}'
        ));
        lineItems.add(new vlocity_cmt__CalculationMatrixRow__c(vlocity_cmt__CalculationMatrixVersionId__c = version.Id, Name = 'Header',
                vlocity_cmt__InputData__c ='{\"listValues\":null,\"name":\"Quantity\",\"label\":null,\"headerType\":\"Input\",\"displayOrder\":5,\"dataType\":\"Text\"}'
        ));
        lineItems.add(new vlocity_cmt__CalculationMatrixRow__c(vlocity_cmt__CalculationMatrixVersionId__c = version.Id, Name = 'Header',
                vlocity_cmt__InputData__c ='{\"listValues\":null,\"name":\"Target Product Name\",\"label\":null,\"headerType\":\"Output\",\"displayOrder\":6,\"dataType\":\"Text\"}'
        ));
        lineItems.add(new vlocity_cmt__CalculationMatrixRow__c(vlocity_cmt__CalculationMatrixVersionId__c = version.Id, Name = 'Header',
                vlocity_cmt__InputData__c ='{\"listValues\":null,\"name":\"MRC\",\"label\":null,\"headerType\":\"Output\",\"displayOrder\":7,\"dataType\":\"Text\"}'
        ));
        lineItems.add(new vlocity_cmt__CalculationMatrixRow__c(vlocity_cmt__CalculationMatrixVersionId__c = version.Id, Name = 'Header',
                vlocity_cmt__InputData__c ='{\"listValues\":null,\"name":\"NRC\",\"label\":null,\"headerType\":\"Output\",\"displayOrder\":8,\"dataType\":\"Text\"}'
        ));
        insert lineItems;

        //Populating Row Data
        lineItems = new List<vlocity_cmt__CalculationMatrixRow__c>();

        if(flag)  //running test2
        {
            lineItems.add(new vlocity_cmt__CalculationMatrixRow__c(vlocity_cmt__CalculationMatrixVersionId__c = version.Id,
                    vlocity_cmt__InputData__c ='{\"Quantity\":\"1-10\",\"Characteristic Value\":\"16Mbps;80Mbps\",\"Characteristic Name\":"Internet Upload Speed;Internet Download Speed\",\"Source Product Code\":\"VLO-INT-0001\",\"Source Product Name\":\"Broadband Internet Small\"}',
                    vlocity_cmt__OutputData__c = '{\"NRC\":\"0\",\"MRC\":\"15\",\"Target Product Name\":\"Path1\"}'
            ));
            lineItems.add(new vlocity_cmt__CalculationMatrixRow__c(vlocity_cmt__CalculationMatrixVersionId__c = version.Id,
                    vlocity_cmt__InputData__c ='{\"Quantity\":\"11-20\",\"Characteristic Value\":\"16Mbps;80Mbps\",\"Characteristic Name\":"Internet Upload Speed;Internet Download Speed\",\"Source Product Code\":\"VLO-INT-0001\",\"Source Product Name\":\"Broadband Internet Small\"}',
                    vlocity_cmt__OutputData__c = '{\"NRC\":\"0\",\"MRC\":\"25\",\"Target Product Name\":\"Path1\"}'
            ));
            lineItems.add(new vlocity_cmt__CalculationMatrixRow__c(vlocity_cmt__CalculationMatrixVersionId__c = version.Id,
                    vlocity_cmt__InputData__c ='{\"Quantity\":\"1-10\",\"Characteristic Value\":\"18Mbps;90Mbps\",\"Characteristic Name\":"Internet Upload Speed;Internet Download Speed\",\"Source Product Code\":\"VLO-INT-0001\",\"Source Product Name\":\"Broadband Internet Small\"}',
                    vlocity_cmt__OutputData__c = '{\"NRC\":\"0\",\"MRC\":\"30\",\"Target Product Name\":\"Path1\"}'
            ));
            lineItems.add(new vlocity_cmt__CalculationMatrixRow__c(vlocity_cmt__CalculationMatrixVersionId__c = version.Id,
                    vlocity_cmt__InputData__c ='{\"Quantity\":\"1-10\",\"Characteristic Value\":\"20Mbps;100Mbps\",\"Characteristic Name\":"Internet Upload Speed;Internet Download Speed\",\"Source Product Code\":\"VLO-INT-0001\",\"Source Product Name\":\"Broadband Internet Small\"}',
                    vlocity_cmt__OutputData__c = '{\"NRC\":\"0\",\"MRC\":\"35\",\"Target Product Name\":\"Path1\"}'
            ));
        }
        else   //running test1
        {
            lineItems.add(new vlocity_cmt__CalculationMatrixRow__c(vlocity_cmt__CalculationMatrixVersionId__c = version.Id,
                    vlocity_cmt__InputData__c ='{\"Quantity\":\"1-10\",\"Characteristic Value\":\"Xfinity\",\"Characteristic Name\":"Provider\",\"Source Product Code\":\"VLO-PHN-0005\",\"Source Product Name\":\"Consumer Landline\"}',
                    vlocity_cmt__OutputData__c = '{\"NRC\":\"105\",\"MRC\":\"50\",\"Target Product Name\":\"Path3\"}'
            ));
            lineItems.add(new vlocity_cmt__CalculationMatrixRow__c(vlocity_cmt__CalculationMatrixVersionId__c = version.Id,
                    vlocity_cmt__InputData__c ='{\"Quantity\":\"11-20\",\"Characteristic Value\":\"Xfinity\",\"Characteristic Name\":"Provider\",\"Source Product Code\":\"VLO-PHN-0005\",\"Source Product Name\":\"Consumer Landline\"}',
                    vlocity_cmt__OutputData__c = '{\"NRC\":\"115\",\"MRC\":\"100\",\"Target Product Name\":\"Path3\"}'
            ));
            lineItems.add(new vlocity_cmt__CalculationMatrixRow__c(vlocity_cmt__CalculationMatrixVersionId__c = version.Id,
                    vlocity_cmt__InputData__c ='{\"Quantity\":\"1-10\",\"Characteristic Value\":\"Verizon\",\"Characteristic Name\":"Provider\",\"Source Product Code\":\"VLO-PHN-0005\",\"Source Product Name\":\"Consumer Landline\"}',
                    vlocity_cmt__OutputData__c = '{\"NRC\":\"125\",\"MRC\":\"300\",\"Target Product Name\":\"Path3\"}'
            ));
            lineItems.add(new vlocity_cmt__CalculationMatrixRow__c(vlocity_cmt__CalculationMatrixVersionId__c = version.Id,
                    vlocity_cmt__InputData__c ='{\"Quantity\":\"11-20\",\"Characteristic Value\":\"Verizon\",\"Characteristic Name\":"Provider\",\"Source Product Code\":\"VLO-PHN-0005\",\"Source Product Name\":\"Consumer Landline\"}',
                    vlocity_cmt__OutputData__c = '{\"NRC\":\"135\",\"MRC\":\"600\",\"Target Product Name\":\"Path3\"}'
            ));
        }
        insert lineItems;

        lineItems = [SELECT Name, vlocity_cmt__InputData__c, vlocity_cmt__OutputData__c FROM vlocity_cmt__CalculationMatrixRow__c WHERE Name != 'Header'];
        update new vlocity_cmt__CalculationMatrixVersion__c(Id = version.Id, vlocity_cmt__IsEnabled__c = true);

        //service
        vlocity_cmt__CalculationProcedure__c calcProcedure = new vlocity_cmt__CalculationProcedure__c(Name='TargetPathRangePricingDemoProcedureTest');
        insert calcProcedure;

        //Making isEnabled = false due to ERROR="Please add steps before enabling this procedure configuration."
        vlocity_cmt__CalculationProcedureVersion__c procVersion = new vlocity_cmt__CalculationProcedureVersion__c(Name='TargetPathRangePricingDemo V3', vlocity_cmt__VersionNumber__c=5, vlocity_cmt__IsEnabled__c=false,
                vlocity_cmt__CalculationProcedureId__c=calcProcedure.Id, vlocity_cmt__StartDateTime__c = DateTime.now().addDays(-5), vlocity_cmt__EndDateTime__c = DateTime.now().addDays(5), vlocity_cmt__Priority__c=5);
        insert procVersion;

        List<vlocity_cmt__CalculationProcedureStep__c> steps = new List<vlocity_cmt__CalculationProcedureStep__c> ();
        vlocity_cmt__CalculationProcedureStep__c step1 = new vlocity_cmt__CalculationProcedureStep__c (Name='a1L46000001ASQm', vlocity_cmt__Sequence__c=1,vlocity_cmt__Function__c='Matrix Lookup', vlocity_cmt__CalculationMatrixId__c=parent.Id, vlocity_cmt__IsIncludedInResult__c=true, vlocity_cmt__CalculationProcedureVersionId__c= procVersion.Id,
                vlocity_cmt__Input__c='[{\"name\":\"Source Product Name\",\"listValues\":null,\"label\":null,\"dataType\":\"Text\",\"columnKey\":\"dea1b0\"},{\"name\":\"Source Product Code\",\"listValues\":null,\"label\":null,\"dataType\":\"Text\",\"columnKey\":\"15e771\"},{\"name\":\"Characteristic Name\",\"listValues\":null,\"label\":null,\"dataType\":\"Text\",\"columnKey\":\"a81456\"},{\"name\":\"Characteristic Value\",\"listValues\":null,\"label\":null,\"dataType\":\"Text\",\"columnKey\":\"880c2d\"},{\"name\":\"Quantity\",\"listValues\":null,\"label\":null,\"dataType\":\"Text\",\"columnKey\":\"94bbbe\"}]',
                vlocity_cmt__OutputMappingJSON__c ='{\"Target Product Name\":\"TargetPathRangePricing__TargetProductName\",\"MRC\":\"TargetPathRangePricing__MRC\",\"NRC\":\"TargetPathRangePricing__NRC\"}',
                vlocity_cmt__OutputJSON__c='[{\"name\":\"Target Product Name\",\"listValues\":null,\"label\":null,\"dataType\":\"Text\",\"columnKey\":\"fea7df\"},{\"name\":\"MRC\",\"listValues\":null,\"label\":null,\"dataType\":\"Text\",\"columnKey\":\"7776f5\"},{\"name\":\"NRC\",\"listValues\":null,\"label\":null,\"dataType\":\"Text\",\"columnKey\":\"ac5769\"}]');
        vlocity_cmt__CalculationProcedureStep__c step2 = new vlocity_cmt__CalculationProcedureStep__c (Name='a1L46000001ASQn', vlocity_cmt__Sequence__c=2,vlocity_cmt__Function__c='Calculation', vlocity_cmt__IsIncludedInResult__c=true, vlocity_cmt__CalculationProcedureVersionId__c= procVersion.Id,
                vlocity_cmt__CalculationFormulaLong__c='TargetPathRangePricing__MRC', vlocity_cmt__OutputJSON__c='{\"name\":\"REC_MNTH_STD_PRC\",\"dataType\":\"Currency\",\"alias\":\"REC_MNTH_STD_PRC\"}',
                vlocity_cmt__OutputMappingJSON__c = '{\"REC_MNTH_STD_PRC\":\"REC_MNTH_STD_PRC\"}', vlocity_cmt__CalculationFormulaTags__c='[{\"text\":\"MRC ( TargetPathRangePricing )\",\"alias\":\"TargetPathRangePricing__MRC\",\"userDefined\":false,\"dataType\":\"Text\"}]');
        vlocity_cmt__CalculationProcedureStep__c step3 = new vlocity_cmt__CalculationProcedureStep__c (Name='a1L46000001ASQo', vlocity_cmt__Sequence__c=3,vlocity_cmt__Function__c='Calculation', vlocity_cmt__IsIncludedInResult__c=true, vlocity_cmt__CalculationProcedureVersionId__c= procVersion.Id,
                vlocity_cmt__CalculationFormulaLong__c='TargetPathRangePricing__NRC',vlocity_cmt__OutputMappingJSON__c = '{\"OT_STD_PRC\":\"OT_STD_PRC\"}',
                vlocity_cmt__OutputJSON__c='{\"name\":\"OT_STD_PRC\",\"dataType\":\"Currency\",\"alias\":\"OT_STD_PRC\"}',vlocity_cmt__CalculationFormulaTags__c='[{\"text\":\"MRC ( TargetPathRangePricing )\",\"alias\":\"TargetPathRangePricing__NRC\",\"userDefined\":false,\"dataType\":\"Text\"}]' );
        steps.add(step1);
        steps.add(step2);
        steps.add(step3);
        insert steps;

        List<vlocity_cmt__CalculationProcedureVariable__c> calcProcVariableList = new List<vlocity_cmt__CalculationProcedureVariable__c>{
                new vlocity_cmt__CalculationProcedureVariable__c(name='REC_MNTH_STD_PRC',vlocity_cmt__alias__c='REC_MNTH_STD_PRC',vlocity_cmt__datatype__c='Currency',vlocity_cmt__CalculationProcedureVersionId__c=procVersion.Id),
                new vlocity_cmt__CalculationProcedureVariable__c(name='OT_STD_PRC',vlocity_cmt__alias__c='OT_STD_PRC',vlocity_cmt__datatype__c='Currency',vlocity_cmt__defaultValue__c='27',vlocity_cmt__CalculationProcedureVersionId__c=procVersion.Id),
                new vlocity_cmt__CalculationProcedureVariable__c(name='Source Product Name',vlocity_cmt__alias__c='SourceProductName',vlocity_cmt__datatype__c='Text',vlocity_cmt__defaultValue__c='false',vlocity_cmt__CalculationProcedureVersionId__c=procVersion.Id),
                new vlocity_cmt__CalculationProcedureVariable__c(name='Source Product Code',vlocity_cmt__alias__c='SourceProductCode',vlocity_cmt__datatype__c='Text',vlocity_cmt__defaultValue__c='false',vlocity_cmt__CalculationProcedureVersionId__c=procVersion.Id),
                new vlocity_cmt__CalculationProcedureVariable__c(name='Characteristic Name',vlocity_cmt__alias__c='CharacteristicName',vlocity_cmt__datatype__c='Text',vlocity_cmt__defaultValue__c='false',vlocity_cmt__CalculationProcedureVersionId__c=procVersion.Id),
                new vlocity_cmt__CalculationProcedureVariable__c(name='Characteristic Value',vlocity_cmt__alias__c='CharacteristicValue',vlocity_cmt__datatype__c='Text',vlocity_cmt__defaultValue__c='false',vlocity_cmt__CalculationProcedureVersionId__c=procVersion.Id),
                new vlocity_cmt__CalculationProcedureVariable__c(name='Quantity',vlocity_cmt__alias__c='Quantity',vlocity_cmt__datatype__c='Text',vlocity_cmt__defaultValue__c='false',vlocity_cmt__CalculationProcedureVersionId__c=procVersion.Id),
                new vlocity_cmt__CalculationProcedureVariable__c(name='Target Product Name',vlocity_cmt__alias__c='TargetPathRangePricing__TargetProductName',vlocity_cmt__datatype__c='Text',vlocity_cmt__defaultValue__c='false',vlocity_cmt__CalculationProcedureVersionId__c=procVersion.Id),
                new vlocity_cmt__CalculationProcedureVariable__c(name='MRC',vlocity_cmt__alias__c='TargetPathRangePricing__MRC',vlocity_cmt__datatype__c='Text',vlocity_cmt__defaultValue__c='false',vlocity_cmt__CalculationProcedureVersionId__c=procVersion.Id),
                new vlocity_cmt__CalculationProcedureVariable__c(name='NRC',vlocity_cmt__alias__c='TargetPathRangePricing__NRC',vlocity_cmt__datatype__c='Text',vlocity_cmt__defaultValue__c='false',vlocity_cmt__CalculationProcedureVersionId__c=procVersion.Id)
                };
        insert calcProcVariableList;

        //Creating and enabling CalculationProcedureVersion
        update new vlocity_cmt__CalculationProcedureVersion__c(Id = procVersion.Id, vlocity_cmt__IsEnabled__c = true);

    }

    static private void testMatrix2Setup()
    {
        insert new vlocity_cmt__TriggerSetup__c(Name = 'AllTriggers', vlocity_cmt__IsTriggerOn__c = true);
        parent = new vlocity_cmt__CalculationMatrix__c(Name = 'TargetPathRangePricingMatrixTest');
        insert parent;

        version = new vlocity_cmt__CalculationMatrixVersion__c(Name = 'TargetPathRangePricing Version', vlocity_cmt__VersionNumber__c = 5,
                vlocity_cmt__IsEnabled__c = false, vlocity_cmt__CalculationMatrixId__c = parent.Id,
                vlocity_cmt__StartDateTime__c = DateTime.now().addDays(-10), vlocity_cmt__EndDateTime__c = DateTime.now().addDays(10),vlocity_cmt__Priority__c = 5);
        insert version;

        //Populating Headers
        lineItems = new List<vlocity_cmt__CalculationMatrixRow__c>();
        lineItems.add(new vlocity_cmt__CalculationMatrixRow__c(vlocity_cmt__CalculationMatrixVersionId__c = version.Id, Name = 'Header',
                vlocity_cmt__InputData__c ='{\"listValues\":null,\"name":\"Characteristic Name\",\"label\":null,\"headerType\":\"Input\",\"displayOrder\":1,\"dataType\":\"Text\"}'
        ));
        lineItems.add(new vlocity_cmt__CalculationMatrixRow__c(vlocity_cmt__CalculationMatrixVersionId__c = version.Id, Name = 'Header',
                vlocity_cmt__InputData__c ='{\"listValues\":null,\"name":\"Source Product Code\",\"label\":null,\"headerType\":\"Input\",\"displayOrder\":2,\"dataType\":\"Text\"}'
        ));
        lineItems.add(new vlocity_cmt__CalculationMatrixRow__c(vlocity_cmt__CalculationMatrixVersionId__c = version.Id, Name = 'Header',
                vlocity_cmt__InputData__c ='{\"listValues\":null,\"name":\"Source Product Name\",\"label\":null,\"headerType\":\"Input\",\"displayOrder\":3,\"dataType\":\"Text\"}'
        ));
        lineItems.add(new vlocity_cmt__CalculationMatrixRow__c(vlocity_cmt__CalculationMatrixVersionId__c = version.Id, Name = 'Header',
                vlocity_cmt__InputData__c ='{\"listValues\":null,\"name":\"Characteristic Value\",\"label\":null,\"headerType\":\"Input\",\"displayOrder\":4,\"dataType\":\"Text\"}'
        ));
        lineItems.add(new vlocity_cmt__CalculationMatrixRow__c(vlocity_cmt__CalculationMatrixVersionId__c = version.Id, Name = 'Header',
                vlocity_cmt__InputData__c ='{\"listValues\":null,\"name":\"MRC\",\"label\":null,\"headerType\":\"Output\",\"displayOrder\":5,\"dataType\":\"Number\"}'
        ));
        lineItems.add(new vlocity_cmt__CalculationMatrixRow__c(vlocity_cmt__CalculationMatrixVersionId__c = version.Id, Name = 'Header',
                vlocity_cmt__InputData__c ='{\"listValues\":null,\"name":\"NRC\",\"label\":null,\"headerType\":\"Output\",\"displayOrder\":6,\"dataType\":\"Number\"}'
        ));
        lineItems.add(new vlocity_cmt__CalculationMatrixRow__c(vlocity_cmt__CalculationMatrixVersionId__c = version.Id, Name = 'Header',
                vlocity_cmt__InputData__c ='{\"listValues\":null,\"name":\"UP\",\"label\":null,\"headerType\":\"Output\",\"displayOrder\":7,\"dataType\":\"Number\"}'
        ));
        lineItems.add(new vlocity_cmt__CalculationMatrixRow__c(vlocity_cmt__CalculationMatrixVersionId__c = version.Id, Name = 'Header',
                vlocity_cmt__InputData__c ='{\"listValues\":null,\"name":\"UOM\",\"label\":null,\"headerType\":\"Output\",\"displayOrder\":8,\"dataType\":\"Text\"}'
        ));
        insert lineItems;

        //Populating Row Data
        lineItems = new List<vlocity_cmt__CalculationMatrixRow__c>();
        
        lineItems.add(new vlocity_cmt__CalculationMatrixRow__c(vlocity_cmt__CalculationMatrixVersionId__c = version.Id,
                vlocity_cmt__InputData__c ='{\"Characteristic Value\":\"Verizon\",\"Characteristic Name\":"Provider\",\"Source Product Code\":\"VLO-PHN-0005\",\"Source Product Name\":\"Consumer Landline\"}',
                vlocity_cmt__OutputData__c = '{\"NRC\":\"0\",\"MRC\":\"0\",\"UOM\":\"p/day\",\"UP\":\"0.234\"}'
        ));
        lineItems.add(new vlocity_cmt__CalculationMatrixRow__c(vlocity_cmt__CalculationMatrixVersionId__c = version.Id,
                vlocity_cmt__InputData__c ='{\"Characteristic Value\":\"Xfinity\",\"Characteristic Name\":"Provider\",\"Source Product Code\":\"VLO-PHN-0005\",\"Source Product Name\":\"Consumer Landline\"}',
                vlocity_cmt__OutputData__c = '{\"NRC\":\"0\",\"MRC\":\"0\",\"UOM\":\"kwh\",\"UP\":\"0.124\"}'
        ));
        
        insert lineItems;

        lineItems = [SELECT Name, vlocity_cmt__InputData__c, vlocity_cmt__OutputData__c FROM vlocity_cmt__CalculationMatrixRow__c WHERE Name != 'Header'];
        update new vlocity_cmt__CalculationMatrixVersion__c(Id = version.Id, vlocity_cmt__IsEnabled__c = true);

        //service
        vlocity_cmt__CalculationProcedure__c calcProcedure = new vlocity_cmt__CalculationProcedure__c(Name='TargetPathRangePricingDemoProcedureTest');
        insert calcProcedure;

        //Making isEnabled = false due to ERROR="Please add steps before enabling this procedure configuration."
        vlocity_cmt__CalculationProcedureVersion__c procVersion = new vlocity_cmt__CalculationProcedureVersion__c(Name='TargetPathRangePricingDemo V3', vlocity_cmt__VersionNumber__c=5, vlocity_cmt__IsEnabled__c=false,
                vlocity_cmt__CalculationProcedureId__c=calcProcedure.Id, vlocity_cmt__StartDateTime__c = DateTime.now().addDays(-5), vlocity_cmt__EndDateTime__c = DateTime.now().addDays(5), vlocity_cmt__Priority__c=5);
        insert procVersion;

        List<vlocity_cmt__CalculationProcedureStep__c> steps = new List<vlocity_cmt__CalculationProcedureStep__c> ();
        vlocity_cmt__CalculationProcedureStep__c step1 = new vlocity_cmt__CalculationProcedureStep__c (Name='a1L46000001ASQm', vlocity_cmt__Sequence__c=1,vlocity_cmt__Function__c='Matrix Lookup', vlocity_cmt__CalculationMatrixId__c=parent.Id, vlocity_cmt__IsIncludedInResult__c=true, vlocity_cmt__CalculationProcedureVersionId__c= procVersion.Id,
                vlocity_cmt__Input__c='[{\"name\":\"Source Product Name\",\"listValues\":null,\"label\":null,\"dataType\":\"Text\",\"columnKey\":\"dea1b0\"},{\"name\":\"Source Product Code\",\"listValues\":null,\"label\":null,\"dataType\":\"Text\",\"columnKey\":\"15e771\"},{\"name\":\"Characteristic Name\",\"listValues\":null,\"label\":null,\"dataType\":\"Text\",\"columnKey\":\"a81456\"},{\"name\":\"Characteristic Value\",\"listValues\":null,\"label\":null,\"dataType\":\"Text\",\"columnKey\":\"880c2d\"},{\"name\":\"Quantity\",\"listValues\":null,\"label\":null,\"dataType\":\"Text\",\"columnKey\":\"94bbbe\"}]',
                vlocity_cmt__OutputMappingJSON__c ='{\"MRC\":\"TargetPathRangePricing__MRC\",\"NRC\":\"TargetPathRangePricing__NRC\",\"UP\":\"TargetPathRangePricing__UP\",\"UOM\":\"TargetPathRangePricing__UOM\"}',
                vlocity_cmt__OutputJSON__c='[{\"name\":\"MRC\",\"listValues\":null,\"label\":null,\"dataType\":\"Text\",\"columnKey\":\"7776f5\"},{\"name\":\"NRC\",\"listValues\":null,\"label\":null,\"dataType\":\"Text\",\"columnKey\":\"ac5769\"},{\"name\":\"UP\",\"listValues\":null,\"label\":null,\"dataType\":\"Text\",\"columnKey\":\"933787\"},{\"name\":\"UOM\",\"listValues\":null,\"label\":null,\"dataType\":\"Text\",\"columnKey\":\"6d6a3d\"}]');
        vlocity_cmt__CalculationProcedureStep__c step2 = new vlocity_cmt__CalculationProcedureStep__c (Name='a1L46000001ASQn', vlocity_cmt__Sequence__c=2,vlocity_cmt__Function__c='Calculation', vlocity_cmt__IsIncludedInResult__c=true, vlocity_cmt__CalculationProcedureVersionId__c= procVersion.Id,
                vlocity_cmt__CalculationFormulaLong__c='TargetPathRangePricing__MRC', vlocity_cmt__OutputJSON__c='{\"name\":\"REC_MNTH_STD_PRC\",\"dataType\":\"Currency\",\"alias\":\"REC_MNTH_STD_PRC\"}',
                vlocity_cmt__OutputMappingJSON__c = '{\"REC_MNTH_STD_PRC\":\"REC_MNTH_STD_PRC\"}', vlocity_cmt__CalculationFormulaTags__c='[{\"text\":\"MRC ( TargetPathRangePricing )\",\"alias\":\"TargetPathRangePricing__MRC\",\"userDefined\":false,\"dataType\":\"Text\"}]');
        vlocity_cmt__CalculationProcedureStep__c step3 = new vlocity_cmt__CalculationProcedureStep__c (Name='a1L46000001ASQo', vlocity_cmt__Sequence__c=3,vlocity_cmt__Function__c='Calculation', vlocity_cmt__IsIncludedInResult__c=true, vlocity_cmt__CalculationProcedureVersionId__c= procVersion.Id,
                vlocity_cmt__CalculationFormulaLong__c='TargetPathRangePricing__NRC',vlocity_cmt__OutputMappingJSON__c = '{\"OT_STD_PRC\":\"OT_STD_PRC\"}',
                vlocity_cmt__OutputJSON__c='{\"name\":\"OT_STD_PRC\",\"dataType\":\"Currency\",\"alias\":\"OT_STD_PRC\"}',vlocity_cmt__CalculationFormulaTags__c='[{\"text\":\"MRC ( TargetPathRangePricing )\",\"alias\":\"TargetPathRangePricing__NRC\",\"userDefined\":false,\"dataType\":\"Text\"}]' );
        
        vlocity_cmt__CalculationProcedureStep__c step4 = new vlocity_cmt__CalculationProcedureStep__c (Name='a1L46000001ASQp', vlocity_cmt__Sequence__c=4,vlocity_cmt__Function__c='Calculation', vlocity_cmt__IsIncludedInResult__c=true, vlocity_cmt__CalculationProcedureVersionId__c= procVersion.Id,
                vlocity_cmt__CalculationFormulaLong__c='TargetPathRangePricing__UP',vlocity_cmt__OutputMappingJSON__c = '{\"USAGE_STD_PRC\":\"USAGE_STD_PRC\"}',
                vlocity_cmt__OutputJSON__c='{\"name\":\"USAGE_STD_PRC\",\"dataType\":\"Currency\",\"alias\":\"USAGE_STD_PRC\"}',vlocity_cmt__CalculationFormulaTags__c='[{\"text\":\"UP ( TargetPathRangePricing )\",\"alias\":\"TargetPathRangePricing__UP\",\"userDefined\":false,\"dataType\":\"Text\"}]' );
        vlocity_cmt__CalculationProcedureStep__c step5 = new vlocity_cmt__CalculationProcedureStep__c (Name='a1L46000001ASQq', vlocity_cmt__Sequence__c=5,vlocity_cmt__Function__c='Calculation', vlocity_cmt__IsIncludedInResult__c=true, vlocity_cmt__CalculationProcedureVersionId__c= procVersion.Id,
                vlocity_cmt__CalculationFormulaLong__c='TargetPathRangePricing__UOM',vlocity_cmt__OutputMappingJSON__c = '{\"UOM\":\"UOM\"}',
                vlocity_cmt__OutputJSON__c='{\"name\":\"UOM\",\"dataType\":\"Text\",\"alias\":\"UOM\"}',vlocity_cmt__CalculationFormulaTags__c='[{\"text\":\"UOM ( TargetPathRangePricing )\",\"alias\":\"TargetPathRangePricing__UOM\",\"userDefined\":false,\"dataType\":\"Text\"}]' );
        steps.add(step1);
        steps.add(step2);
        steps.add(step3);
        steps.add(step4);
        steps.add(step5);
        insert steps;

        List<vlocity_cmt__CalculationProcedureVariable__c> calcProcVariableList = new List<vlocity_cmt__CalculationProcedureVariable__c>{
                new vlocity_cmt__CalculationProcedureVariable__c(name='REC_MNTH_STD_PRC',vlocity_cmt__alias__c='REC_MNTH_STD_PRC',vlocity_cmt__datatype__c='Currency',vlocity_cmt__CalculationProcedureVersionId__c=procVersion.Id),
                new vlocity_cmt__CalculationProcedureVariable__c(name='OT_STD_PRC',vlocity_cmt__alias__c='OT_STD_PRC',vlocity_cmt__datatype__c='Currency',vlocity_cmt__defaultValue__c='27',vlocity_cmt__CalculationProcedureVersionId__c=procVersion.Id),
                new vlocity_cmt__CalculationProcedureVariable__c(name='USAGE_STD_PRC',vlocity_cmt__alias__c='USAGE_STD_PRC',vlocity_cmt__datatype__c='Currency',vlocity_cmt__defaultValue__c='27',vlocity_cmt__precision__c=3,vlocity_cmt__CalculationProcedureVersionId__c=procVersion.Id),
                new vlocity_cmt__CalculationProcedureVariable__c(name='Source Product Name',vlocity_cmt__alias__c='SourceProductName',vlocity_cmt__datatype__c='Text',vlocity_cmt__defaultValue__c='false',vlocity_cmt__CalculationProcedureVersionId__c=procVersion.Id),
                new vlocity_cmt__CalculationProcedureVariable__c(name='Source Product Code',vlocity_cmt__alias__c='SourceProductCode',vlocity_cmt__datatype__c='Text',vlocity_cmt__defaultValue__c='false',vlocity_cmt__CalculationProcedureVersionId__c=procVersion.Id),
                new vlocity_cmt__CalculationProcedureVariable__c(name='Characteristic Name',vlocity_cmt__alias__c='CharacteristicName',vlocity_cmt__datatype__c='Text',vlocity_cmt__defaultValue__c='false',vlocity_cmt__CalculationProcedureVersionId__c=procVersion.Id),
                new vlocity_cmt__CalculationProcedureVariable__c(name='Characteristic Value',vlocity_cmt__alias__c='CharacteristicValue',vlocity_cmt__datatype__c='Text',vlocity_cmt__defaultValue__c='false',vlocity_cmt__CalculationProcedureVersionId__c=procVersion.Id),
                new vlocity_cmt__CalculationProcedureVariable__c(name='UOM',vlocity_cmt__alias__c='UOM',vlocity_cmt__datatype__c='Text',vlocity_cmt__defaultValue__c='false',vlocity_cmt__CalculationProcedureVersionId__c=procVersion.Id),
                new vlocity_cmt__CalculationProcedureVariable__c(name='UP',vlocity_cmt__alias__c='UP',vlocity_cmt__datatype__c='Text',vlocity_cmt__defaultValue__c='false',vlocity_cmt__CalculationProcedureVersionId__c=procVersion.Id),
                new vlocity_cmt__CalculationProcedureVariable__c(name='Target Product Name',vlocity_cmt__alias__c='TargetPathRangePricing__TargetProductName',vlocity_cmt__datatype__c='Text',vlocity_cmt__defaultValue__c='false',vlocity_cmt__CalculationProcedureVersionId__c=procVersion.Id),
                new vlocity_cmt__CalculationProcedureVariable__c(name='MRC',vlocity_cmt__alias__c='TargetPathRangePricing__MRC',vlocity_cmt__datatype__c='Text',vlocity_cmt__defaultValue__c='false',vlocity_cmt__CalculationProcedureVersionId__c=procVersion.Id),
                new vlocity_cmt__CalculationProcedureVariable__c(name='NRC',vlocity_cmt__alias__c='TargetPathRangePricing__NRC',vlocity_cmt__datatype__c='Text',vlocity_cmt__defaultValue__c='false',vlocity_cmt__CalculationProcedureVersionId__c=procVersion.Id),
                new vlocity_cmt__CalculationProcedureVariable__c(name='NRC',vlocity_cmt__alias__c='TargetPathRangePricing__UOM',vlocity_cmt__datatype__c='Text',vlocity_cmt__defaultValue__c='false',vlocity_cmt__CalculationProcedureVersionId__c=procVersion.Id),
                new vlocity_cmt__CalculationProcedureVariable__c(name='NRC',vlocity_cmt__alias__c='TargetPathRangePricing__UP',vlocity_cmt__datatype__c='Text',vlocity_cmt__defaultValue__c='false',vlocity_cmt__CalculationProcedureVersionId__c=procVersion.Id)
                };
        insert calcProcVariableList;

        //Creating and enabling CalculationProcedureVersion
        update new vlocity_cmt__CalculationProcedureVersion__c(Id = procVersion.Id, vlocity_cmt__IsEnabled__c = true);
    
    }

    // Initialize Matrix and Procedure data for Attribute Range based pricing
    static private void attributeRangeBasedTargetPricingMatrixSetup() {
        insert new vlocity_cmt__TriggerSetup__c(Name = 'AllTriggers', vlocity_cmt__IsTriggerOn__c = true);
        parent = new vlocity_cmt__CalculationMatrix__c(Name = 'TargetPathRangePricingMatrixTest');
        insert parent;

        version = new vlocity_cmt__CalculationMatrixVersion__c(Name = 'TargetPathRangePricing Version', vlocity_cmt__VersionNumber__c = 5,
                vlocity_cmt__IsEnabled__c = false, vlocity_cmt__CalculationMatrixId__c = parent.Id,
                vlocity_cmt__StartDateTime__c = DateTime.now().addDays(-10), vlocity_cmt__EndDateTime__c = DateTime.now().addDays(10),vlocity_cmt__Priority__c = 5);
        insert version;

        //Populating Headers
        lineItems = new List<vlocity_cmt__CalculationMatrixRow__c>();
        lineItems.add(new vlocity_cmt__CalculationMatrixRow__c(vlocity_cmt__CalculationMatrixVersionId__c = version.Id, Name = 'Header',
                vlocity_cmt__InputData__c ='{\"listValues\":null,\"name":\"Characteristic Name\",\"label\":null,\"headerType\":\"Input\",\"displayOrder\":1,\"dataType\":\"Text\"}'
        ));
        lineItems.add(new vlocity_cmt__CalculationMatrixRow__c(vlocity_cmt__CalculationMatrixVersionId__c = version.Id, Name = 'Header',
                vlocity_cmt__InputData__c ='{\"listValues\":null,\"name":\"Source Product Code\",\"label\":null,\"headerType\":\"Input\",\"displayOrder\":2,\"dataType\":\"Text\"}'
        ));
        lineItems.add(new vlocity_cmt__CalculationMatrixRow__c(vlocity_cmt__CalculationMatrixVersionId__c = version.Id, Name = 'Header',
                vlocity_cmt__InputData__c ='{\"listValues\":null,\"name":\"Source Product Name\",\"label\":null,\"headerType\":\"Input\",\"displayOrder\":3,\"dataType\":\"Text\"}'
        ));
        lineItems.add(new vlocity_cmt__CalculationMatrixRow__c(vlocity_cmt__CalculationMatrixVersionId__c = version.Id, Name = 'Header',
                vlocity_cmt__InputData__c ='{\"listValues\":null,\"name":\"Characteristic Value\",\"label\":null,\"headerType\":\"Input\",\"displayOrder\":4,\"dataType\":\"Text\"}'
        ));
        lineItems.add(new vlocity_cmt__CalculationMatrixRow__c(vlocity_cmt__CalculationMatrixVersionId__c = version.Id, Name = 'Header',
                vlocity_cmt__InputData__c ='{\"listValues\":null,\"name":\"Quantity\",\"label\":null,\"headerType\":\"Input\",\"displayOrder\":5,\"dataType\":\"Text\"}'
        ));
        lineItems.add(new vlocity_cmt__CalculationMatrixRow__c(vlocity_cmt__CalculationMatrixVersionId__c = version.Id, Name = 'Header',
                vlocity_cmt__InputData__c ='{\"listValues\":null,\"name":\"Target Product Name\",\"label\":null,\"headerType\":\"Output\",\"displayOrder\":6,\"dataType\":\"Text\"}'
        ));
        lineItems.add(new vlocity_cmt__CalculationMatrixRow__c(vlocity_cmt__CalculationMatrixVersionId__c = version.Id, Name = 'Header',
                vlocity_cmt__InputData__c ='{\"listValues\":null,\"name":\"MRC\",\"label\":null,\"headerType\":\"Output\",\"displayOrder\":7,\"dataType\":\"Text\"}'
        ));
        lineItems.add(new vlocity_cmt__CalculationMatrixRow__c(vlocity_cmt__CalculationMatrixVersionId__c = version.Id, Name = 'Header',
                vlocity_cmt__InputData__c ='{\"listValues\":null,\"name":\"NRC\",\"label\":null,\"headerType\":\"Output\",\"displayOrder\":8,\"dataType\":\"Text\"}'
        ));
        insert lineItems;

        //Populating Row Data
        lineItems = new List<vlocity_cmt__CalculationMatrixRow__c>();

        // Quantity:1-10, TV Content: SD, TV Boxes Required: 1-5
        lineItems.add(new vlocity_cmt__CalculationMatrixRow__c(vlocity_cmt__CalculationMatrixVersionId__c = version.Id,
                                                               vlocity_cmt__InputData__c ='{\"Quantity\":\"1-10\",\"Characteristic Value\":\"SD;1-5\",\"Characteristic Name\":"TV Content;TV Boxes Required\",\"Source Product Code\":\"VLO-TV-0008\",\"Source Product Name\":\"HD TV\"}',
                                                               vlocity_cmt__OutputData__c = '{\"NRC\":\"105\",\"MRC\":\"50\",\"Target Product Name\":\"Path1\"}'
                                                              ));
        // Quantity:1-10, TV Content: SD, TV Boxes Required: 6-10
        lineItems.add(new vlocity_cmt__CalculationMatrixRow__c(vlocity_cmt__CalculationMatrixVersionId__c = version.Id,
                                                               vlocity_cmt__InputData__c ='{\"Quantity\":\"1-10\",\"Characteristic Value\":\"SD;6-10\",\"Characteristic Name\":"TV Content;TV Boxes Required\",\"Source Product Code\":\"VLO-TV-0008\",\"Source Product Name\":\"HD TV\"}',
                                                               vlocity_cmt__OutputData__c = '{\"NRC\":\"115\",\"MRC\":\"100\",\"Target Product Name\":\"Path1\"}'
                                                              ));
        // Quantity:1-10, TV Content: HD, TV Boxes Required: 1-5
        lineItems.add(new vlocity_cmt__CalculationMatrixRow__c(vlocity_cmt__CalculationMatrixVersionId__c = version.Id,
                                                               vlocity_cmt__InputData__c ='{\"Quantity\":\"1-10\",\"Characteristic Value\":\"HD;1-5\",\"Characteristic Name\":"TV Content;TV Boxes Required\",\"Source Product Code\":\"VLO-TV-0008\",\"Source Product Name\":\"HD TV\"}',
                                                               vlocity_cmt__OutputData__c = '{\"NRC\":\"125\",\"MRC\":\"300\",\"Target Product Name\":\"Path1\"}'
                                                              ));
        // Quantity:1-10, TV Content: HD, TV Boxes Required: 6-10
        lineItems.add(new vlocity_cmt__CalculationMatrixRow__c(vlocity_cmt__CalculationMatrixVersionId__c = version.Id,
                                                               vlocity_cmt__InputData__c ='{\"Quantity\":\"1-10\",\"Characteristic Value\":\"HD;6-10\",\"Characteristic Name\":"TV Content;TV Boxes Required\",\"Source Product Code\":\"VLO-TV-0008\",\"Source Product Name\":\"HD TV\"}',
                                                               vlocity_cmt__OutputData__c = '{\"NRC\":\"135\",\"MRC\":\"400\",\"Target Product Name\":\"Path1\"}'
                                                              ));
        // Quantity:11-20, TV Content: SD, TV Boxes Required: 1-5
        lineItems.add(new vlocity_cmt__CalculationMatrixRow__c(vlocity_cmt__CalculationMatrixVersionId__c = version.Id,
                                                               vlocity_cmt__InputData__c ='{\"Quantity\":\"11-20\",\"Characteristic Value\":\"SD;1-5\",\"Characteristic Name\":"TV Content;TV Boxes Required\",\"Source Product Code\":\"VLO-TV-0008\",\"Source Product Name\":\"HD TV\"}',
                                                               vlocity_cmt__OutputData__c = '{\"NRC\":\"115\",\"MRC\":\"175\",\"Target Product Name\":\"Path1\"}'
                                                              ));
        // Quantity:11-20, TV Content: SD, TV Boxes Required: 6-10
        lineItems.add(new vlocity_cmt__CalculationMatrixRow__c(vlocity_cmt__CalculationMatrixVersionId__c = version.Id,
                                                               vlocity_cmt__InputData__c ='{\"Quantity\":\"11-20\",\"Characteristic Value\":\"SD;6-10\",\"Characteristic Name\":"TV Content;TV Boxes Required\",\"Source Product Code\":\"VLO-TV-0008\",\"Source Product Name\":\"HD TV\"}',
                                                               vlocity_cmt__OutputData__c = '{\"NRC\":\"125\",\"MRC\":\"225\",\"Target Product Name\":\"Path3\"}'
                                                              ));
        // Quantity:11-20, TV Content: HD, TV Boxes Required: 1-5
        lineItems.add(new vlocity_cmt__CalculationMatrixRow__c(vlocity_cmt__CalculationMatrixVersionId__c = version.Id,
                                                               vlocity_cmt__InputData__c ='{\"Quantity\":\"11-20\",\"Characteristic Value\":\"HD;1-5\",\"Characteristic Name\":"TV Content;TV Boxes Required\",\"Source Product Code\":\"VLO-TV-0008\",\"Source Product Name\":\"HD TV\"}',
                                                               vlocity_cmt__OutputData__c = '{\"NRC\":\"130\",\"MRC\":\"350\",\"Target Product Name\":\"Path3\"}'
                                                              ));
        // Quantity:11-20, TV Content: SD, TV Box Required: 6-10
        lineItems.add(new vlocity_cmt__CalculationMatrixRow__c(vlocity_cmt__CalculationMatrixVersionId__c = version.Id,
                                                               vlocity_cmt__InputData__c ='{\"Quantity\":\"11-20\",\"Characteristic Value\":\"HD;6-10\",\"Characteristic Name\":"TV Content;TV Boxes Required\",\"Source Product Code\":\"VLO-TV-0008\",\"Source Product Name\":\"HD TV\"}',
                                                               vlocity_cmt__OutputData__c = '{\"NRC\":\"150\",\"MRC\":\"600\",\"Target Product Name\":\"Path3\"}'
                                                              ));
        insert lineItems;

        lineItems = [SELECT Name, vlocity_cmt__InputData__c, vlocity_cmt__OutputData__c FROM vlocity_cmt__CalculationMatrixRow__c WHERE Name != 'Header'];
        update new vlocity_cmt__CalculationMatrixVersion__c(Id = version.Id, vlocity_cmt__IsEnabled__c = true);

        List<vlocity_cmt__CalculationMatrixRow__c> rows = [SELECT Id, Name, vlocity_cmt__CalculationMatrixVersionId__c FROM vlocity_cmt__CalculationMatrixRow__c];

        //service
        vlocity_cmt__CalculationProcedure__c calcProcedure = new vlocity_cmt__CalculationProcedure__c(Name='TargetPathRangePricingDemoProcedureTest');
        insert calcProcedure;

        //Making isEnabled = false due to ERROR="Please add steps before enabling this procedure configuration."
        vlocity_cmt__CalculationProcedureVersion__c procVersion = new vlocity_cmt__CalculationProcedureVersion__c(Name='TargetPathRangePricingDemo V3', vlocity_cmt__VersionNumber__c=5, vlocity_cmt__IsEnabled__c=false,
                vlocity_cmt__CalculationProcedureId__c=calcProcedure.Id, vlocity_cmt__StartDateTime__c = DateTime.now().addDays(-5), vlocity_cmt__EndDateTime__c = DateTime.now().addDays(5), vlocity_cmt__Priority__c=5);
        insert procVersion;

        List<vlocity_cmt__CalculationProcedureStep__c> steps = new List<vlocity_cmt__CalculationProcedureStep__c> ();
        vlocity_cmt__CalculationProcedureStep__c step1 = new vlocity_cmt__CalculationProcedureStep__c (Name='a1L46000001ASQm', vlocity_cmt__Sequence__c=1,vlocity_cmt__Function__c='Matrix Lookup', vlocity_cmt__CalculationMatrixId__c=parent.Id, vlocity_cmt__IsIncludedInResult__c=true, vlocity_cmt__CalculationProcedureVersionId__c= procVersion.Id,
                vlocity_cmt__Input__c='[{\"name\":\"Source Product Name\",\"listValues\":null,\"label\":null,\"dataType\":\"Text\",\"columnKey\":\"dea1b0\"},{\"name\":\"Source Product Code\",\"listValues\":null,\"label\":null,\"dataType\":\"Text\",\"columnKey\":\"15e771\"},{\"name\":\"Characteristic Name\",\"listValues\":null,\"label\":null,\"dataType\":\"Text\",\"columnKey\":\"a81456\"},{\"name\":\"Characteristic Value\",\"listValues\":null,\"label\":null,\"dataType\":\"Text\",\"columnKey\":\"880c2d\"},{\"name\":\"Quantity\",\"listValues\":null,\"label\":null,\"dataType\":\"Text\",\"columnKey\":\"94bbbe\"}]',
                vlocity_cmt__OutputMappingJSON__c ='{\"Target Product Name\":\"TargetPathRangePricing__TargetProductName\",\"MRC\":\"TargetPathRangePricing__MRC\",\"NRC\":\"TargetPathRangePricing__NRC\"}',
                vlocity_cmt__OutputJSON__c='[{\"name\":\"Target Product Name\",\"listValues\":null,\"label\":null,\"dataType\":\"Text\",\"columnKey\":\"fea7df\"},{\"name\":\"MRC\",\"listValues\":null,\"label\":null,\"dataType\":\"Text\",\"columnKey\":\"7776f5\"},{\"name\":\"NRC\",\"listValues\":null,\"label\":null,\"dataType\":\"Text\",\"columnKey\":\"ac5769\"}]');
        vlocity_cmt__CalculationProcedureStep__c step2 = new vlocity_cmt__CalculationProcedureStep__c (Name='a1L46000001ASQn', vlocity_cmt__Sequence__c=2,vlocity_cmt__Function__c='Calculation', vlocity_cmt__IsIncludedInResult__c=true, vlocity_cmt__CalculationProcedureVersionId__c= procVersion.Id,
                vlocity_cmt__CalculationFormulaLong__c='TargetPathRangePricing__MRC', vlocity_cmt__OutputJSON__c='{\"name\":\"REC_MNTH_STD_PRC\",\"dataType\":\"Currency\",\"alias\":\"REC_MNTH_STD_PRC\"}',
                vlocity_cmt__OutputMappingJSON__c = '{\"REC_MNTH_STD_PRC\":\"REC_MNTH_STD_PRC\"}', vlocity_cmt__CalculationFormulaTags__c='[{\"text\":\"MRC ( TargetPathRangePricing )\",\"alias\":\"TargetPathRangePricing__MRC\",\"userDefined\":false,\"dataType\":\"Text\"}]');
        vlocity_cmt__CalculationProcedureStep__c step3 = new vlocity_cmt__CalculationProcedureStep__c (Name='a1L46000001ASQo', vlocity_cmt__Sequence__c=3,vlocity_cmt__Function__c='Calculation', vlocity_cmt__IsIncludedInResult__c=true, vlocity_cmt__CalculationProcedureVersionId__c= procVersion.Id,
                vlocity_cmt__CalculationFormulaLong__c='TargetPathRangePricing__NRC',vlocity_cmt__OutputMappingJSON__c = '{\"OT_STD_PRC\":\"OT_STD_PRC\"}',
                vlocity_cmt__OutputJSON__c='{\"name\":\"OT_STD_PRC\",\"dataType\":\"Currency\",\"alias\":\"OT_STD_PRC\"}',vlocity_cmt__CalculationFormulaTags__c='[{\"text\":\"MRC ( TargetPathRangePricing )\",\"alias\":\"TargetPathRangePricing__NRC\",\"userDefined\":false,\"dataType\":\"Text\"}]' );
        steps.add(step1);
        steps.add(step2);
        steps.add(step3);
        insert steps;

        List<vlocity_cmt__CalculationProcedureVariable__c> calcProcVariableList = new List<vlocity_cmt__CalculationProcedureVariable__c>{
                new vlocity_cmt__CalculationProcedureVariable__c(name='REC_MNTH_STD_PRC',vlocity_cmt__alias__c='REC_MNTH_STD_PRC',vlocity_cmt__datatype__c='Currency',vlocity_cmt__CalculationProcedureVersionId__c=procVersion.Id),
                new vlocity_cmt__CalculationProcedureVariable__c(name='OT_STD_PRC',vlocity_cmt__alias__c='OT_STD_PRC',vlocity_cmt__datatype__c='Currency',vlocity_cmt__defaultValue__c='27',vlocity_cmt__CalculationProcedureVersionId__c=procVersion.Id),
                new vlocity_cmt__CalculationProcedureVariable__c(name='Source Product Name',vlocity_cmt__alias__c='SourceProductName',vlocity_cmt__datatype__c='Text',vlocity_cmt__defaultValue__c='false',vlocity_cmt__CalculationProcedureVersionId__c=procVersion.Id),
                new vlocity_cmt__CalculationProcedureVariable__c(name='Source Product Code',vlocity_cmt__alias__c='SourceProductCode',vlocity_cmt__datatype__c='Text',vlocity_cmt__defaultValue__c='false',vlocity_cmt__CalculationProcedureVersionId__c=procVersion.Id),
                new vlocity_cmt__CalculationProcedureVariable__c(name='Characteristic Name',vlocity_cmt__alias__c='CharacteristicName',vlocity_cmt__datatype__c='Text',vlocity_cmt__defaultValue__c='false',vlocity_cmt__CalculationProcedureVersionId__c=procVersion.Id),
                new vlocity_cmt__CalculationProcedureVariable__c(name='Characteristic Value',vlocity_cmt__alias__c='CharacteristicValue',vlocity_cmt__datatype__c='Text',vlocity_cmt__defaultValue__c='false',vlocity_cmt__CalculationProcedureVersionId__c=procVersion.Id),
                new vlocity_cmt__CalculationProcedureVariable__c(name='Quantity',vlocity_cmt__alias__c='Quantity',vlocity_cmt__datatype__c='Text',vlocity_cmt__defaultValue__c='false',vlocity_cmt__CalculationProcedureVersionId__c=procVersion.Id),
                new vlocity_cmt__CalculationProcedureVariable__c(name='Target Product Name',vlocity_cmt__alias__c='TargetPathRangePricing__TargetProductName',vlocity_cmt__datatype__c='Text',vlocity_cmt__defaultValue__c='false',vlocity_cmt__CalculationProcedureVersionId__c=procVersion.Id),
                new vlocity_cmt__CalculationProcedureVariable__c(name='MRC',vlocity_cmt__alias__c='TargetPathRangePricing__MRC',vlocity_cmt__datatype__c='Text',vlocity_cmt__defaultValue__c='false',vlocity_cmt__CalculationProcedureVersionId__c=procVersion.Id),
                new vlocity_cmt__CalculationProcedureVariable__c(name='NRC',vlocity_cmt__alias__c='TargetPathRangePricing__NRC',vlocity_cmt__datatype__c='Text',vlocity_cmt__defaultValue__c='false',vlocity_cmt__CalculationProcedureVersionId__c=procVersion.Id)
                };
        insert calcProcVariableList;

        //Creating and enabling CalculationProcedureVersion
        update new vlocity_cmt__CalculationProcedureVersion__c(Id = procVersion.Id, vlocity_cmt__IsEnabled__c = true);

    }

    static private void testOverlappingAttributeRangeMatrixSetup() {
        insert new vlocity_cmt__TriggerSetup__c(Name = 'AllTriggers', vlocity_cmt__IsTriggerOn__c = true);
        parent = new vlocity_cmt__CalculationMatrix__c(Name = 'AttributeRangePricingMatrixTest');
        insert parent;

        version = new vlocity_cmt__CalculationMatrixVersion__c(Name = 'AttributeRangePricingMatrixTest Version', vlocity_cmt__VersionNumber__c = 5,
                vlocity_cmt__IsEnabled__c = false, vlocity_cmt__CalculationMatrixId__c = parent.Id,
                vlocity_cmt__StartDateTime__c = DateTime.now().addDays(-10), vlocity_cmt__EndDateTime__c = DateTime.now().addDays(10),vlocity_cmt__Priority__c = 5);
        insert version;

        //Populating Headers
        lineItems = new List<vlocity_cmt__CalculationMatrixRow__c>();
        lineItems.add(new vlocity_cmt__CalculationMatrixRow__c(vlocity_cmt__CalculationMatrixVersionId__c = version.Id, Name = 'Header',
                vlocity_cmt__InputData__c ='{\"listValues\":null,\"name":\"Characteristic Name\",\"label\":null,\"headerType\":\"Input\",\"displayOrder\":1,\"dataType\":\"Text\"}'
        ));
        lineItems.add(new vlocity_cmt__CalculationMatrixRow__c(vlocity_cmt__CalculationMatrixVersionId__c = version.Id, Name = 'Header',
                vlocity_cmt__InputData__c ='{\"listValues\":null,\"name":\"Source Product Code\",\"label\":null,\"headerType\":\"Input\",\"displayOrder\":2,\"dataType\":\"Text\"}'
        ));
        lineItems.add(new vlocity_cmt__CalculationMatrixRow__c(vlocity_cmt__CalculationMatrixVersionId__c = version.Id, Name = 'Header',
                vlocity_cmt__InputData__c ='{\"listValues\":null,\"name":\"Source Product Name\",\"label\":null,\"headerType\":\"Input\",\"displayOrder\":3,\"dataType\":\"Text\"}'
        ));
        lineItems.add(new vlocity_cmt__CalculationMatrixRow__c(vlocity_cmt__CalculationMatrixVersionId__c = version.Id, Name = 'Header',
                vlocity_cmt__InputData__c ='{\"listValues\":null,\"name":\"Characteristic Value\",\"label\":null,\"headerType\":\"Input\",\"displayOrder\":4,\"dataType\":\"Text\"}'
        ));
        lineItems.add(new vlocity_cmt__CalculationMatrixRow__c(vlocity_cmt__CalculationMatrixVersionId__c = version.Id, Name = 'Header',
                vlocity_cmt__InputData__c ='{\"listValues\":null,\"name":\"MRC\",\"label\":null,\"headerType\":\"Output\",\"displayOrder\":5,\"dataType\":\"Text\"}'
        ));
        lineItems.add(new vlocity_cmt__CalculationMatrixRow__c(vlocity_cmt__CalculationMatrixVersionId__c = version.Id, Name = 'Header',
                vlocity_cmt__InputData__c ='{\"listValues\":null,\"name":\"NRC\",\"label\":null,\"headerType\":\"Output\",\"displayOrder\":6,\"dataType\":\"Text\"}'
        ));
        insert lineItems;

        //Populating Row Data
        lineItems = new List<vlocity_cmt__CalculationMatrixRow__c>();
        lineItems.add(new vlocity_cmt__CalculationMatrixRow__c(vlocity_cmt__CalculationMatrixVersionId__c = version.Id,
                vlocity_cmt__InputData__c ='{"Characteristic Value\":\"0-15;50Mbps\",\"Characteristic Name\":"Internet Upload Speed;Internet Download Speed\",\"Source Product Code\":\"VLO-INT-0001\",\"Source Product Name\":\"Broadband Internet Small\"}',
                vlocity_cmt__OutputData__c = '{\"NRC\":\"0\",\"MRC\":\"15\"}'
        ));
        lineItems.add(new vlocity_cmt__CalculationMatrixRow__c(vlocity_cmt__CalculationMatrixVersionId__c = version.Id,
                vlocity_cmt__InputData__c ='{\"Characteristic Value\":\"0-20;75Mbps\",\"Characteristic Name\":"Internet Upload Speed;Internet Download Speed\",\"Source Product Code\":\"VLO-INT-0001\",\"Source Product Name\":\"Broadband Internet Small\"}',
                vlocity_cmt__OutputData__c = '{\"NRC\":\"0\",\"MRC\":\"25\"}'
        ));
        lineItems.add(new vlocity_cmt__CalculationMatrixRow__c(vlocity_cmt__CalculationMatrixVersionId__c = version.Id,
                vlocity_cmt__InputData__c ='{\"Characteristic Value\":\"0-10;100Mbps\",\"Characteristic Name\":"Internet Upload Speed;Internet Download Speed\",\"Source Product Code\":\"VLO-INT-0001\",\"Source Product Name\":\"Broadband Internet Small\"}',
                vlocity_cmt__OutputData__c = '{\"NRC\":\"0\",\"MRC\":\"30\"}'
        ));
        lineItems.add(new vlocity_cmt__CalculationMatrixRow__c(vlocity_cmt__CalculationMatrixVersionId__c = version.Id,
                vlocity_cmt__InputData__c ='{\"Characteristic Value\":\"0-5;125Mbps\",\"Characteristic Name\":"Internet Upload Speed;Internet Download Speed\",\"Source Product Code\":\"VLO-INT-0001\",\"Source Product Name\":\"Broadband Internet Small\"}',
                vlocity_cmt__OutputData__c = '{\"NRC\":\"0\",\"MRC\":\"35\"}'
        ));
        insert lineItems;

        lineItems = [SELECT Name, vlocity_cmt__InputData__c, vlocity_cmt__OutputData__c FROM vlocity_cmt__CalculationMatrixRow__c WHERE Name != 'Header'];
        update new vlocity_cmt__CalculationMatrixVersion__c(Id = version.Id, vlocity_cmt__IsEnabled__c = true);

        //service
        vlocity_cmt__CalculationProcedure__c calcProcedure = new vlocity_cmt__CalculationProcedure__c(Name='AttributeRangePricingDemoProcedureTest');
        insert calcProcedure;

        //Making isEnabled = false due to ERROR="Please add steps before enabling this procedure configuration."
        vlocity_cmt__CalculationProcedureVersion__c procVersion = new vlocity_cmt__CalculationProcedureVersion__c(Name='AttributeRangePricingDemo V3', vlocity_cmt__VersionNumber__c=5, vlocity_cmt__IsEnabled__c=false,
                vlocity_cmt__CalculationProcedureId__c=calcProcedure.Id, vlocity_cmt__StartDateTime__c = DateTime.now().addDays(-5), vlocity_cmt__EndDateTime__c = DateTime.now().addDays(5), vlocity_cmt__Priority__c=5);
        insert procVersion;

        List<vlocity_cmt__CalculationProcedureStep__c> steps = new List<vlocity_cmt__CalculationProcedureStep__c> ();
        vlocity_cmt__CalculationProcedureStep__c step1 = new vlocity_cmt__CalculationProcedureStep__c (Name='a1L46000001ASQm', vlocity_cmt__Sequence__c=1,vlocity_cmt__Function__c='Matrix Lookup', vlocity_cmt__CalculationMatrixId__c=parent.Id, vlocity_cmt__IsIncludedInResult__c=true, vlocity_cmt__CalculationProcedureVersionId__c= procVersion.Id,
                vlocity_cmt__Input__c='[{\"name\":\"Source Product Name\",\"listValues\":null,\"label\":null,\"dataType\":\"Text\",\"columnKey\":\"dea1b0\"},{\"name\":\"Source Product Code\",\"listValues\":null,\"label\":null,\"dataType\":\"Text\",\"columnKey\":\"15e771\"},{\"name\":\"Characteristic Name\",\"listValues\":null,\"label\":null,\"dataType\":\"Text\",\"columnKey\":\"a81456\"},{\"name\":\"Characteristic Value\",\"listValues\":null,\"label\":null,\"dataType\":\"Text\",\"columnKey\":\"880c2d\"}]',
                vlocity_cmt__OutputMappingJSON__c ='{\"MRC\":\"AttributeRangePricing__MRC\",\"NRC\":\"AttributeRangePricing__NRC\"}',
                vlocity_cmt__OutputJSON__c='[{\"name\":\"Target Product Name\",\"listValues\":null,\"label\":null,\"dataType\":\"Text\",\"columnKey\":\"fea7df\"},{\"name\":\"MRC\",\"listValues\":null,\"label\":null,\"dataType\":\"Text\",\"columnKey\":\"7776f5\"},{\"name\":\"NRC\",\"listValues\":null,\"label\":null,\"dataType\":\"Text\",\"columnKey\":\"ac5769\"}]');
        vlocity_cmt__CalculationProcedureStep__c step2 = new vlocity_cmt__CalculationProcedureStep__c (Name='a1L46000001ASQn', vlocity_cmt__Sequence__c=2,vlocity_cmt__Function__c='Calculation', vlocity_cmt__IsIncludedInResult__c=true, vlocity_cmt__CalculationProcedureVersionId__c= procVersion.Id,
                vlocity_cmt__CalculationFormulaLong__c='AttributeRangePricing__MRC', vlocity_cmt__OutputJSON__c='{\"name\":\"REC_MNTH_STD_PRC\",\"dataType\":\"Currency\",\"alias\":\"REC_MNTH_STD_PRC\"}',
                vlocity_cmt__OutputMappingJSON__c = '{\"REC_MNTH_STD_PRC\":\"REC_MNTH_STD_PRC\"}', vlocity_cmt__CalculationFormulaTags__c='[{\"text\":\"MRC ( AttributeRangePricing )\",\"alias\":\"AttributeRangePricing__MRC\",\"userDefined\":false,\"dataType\":\"Text\"}]');
        vlocity_cmt__CalculationProcedureStep__c step3 = new vlocity_cmt__CalculationProcedureStep__c (Name='a1L46000001ASQo', vlocity_cmt__Sequence__c=3,vlocity_cmt__Function__c='Calculation', vlocity_cmt__IsIncludedInResult__c=true, vlocity_cmt__CalculationProcedureVersionId__c= procVersion.Id,
                vlocity_cmt__CalculationFormulaLong__c='AttributeRangePricing__NRC',vlocity_cmt__OutputMappingJSON__c = '{\"OT_STD_PRC\":\"OT_STD_PRC\"}',
                vlocity_cmt__OutputJSON__c='{\"name\":\"OT_STD_PRC\",\"dataType\":\"Currency\",\"alias\":\"OT_STD_PRC\"}',vlocity_cmt__CalculationFormulaTags__c='[{\"text\":\"MRC ( AttributeRangePricing )\",\"alias\":\"AttributeRangePricing__NRC\",\"userDefined\":false,\"dataType\":\"Text\"}]' );
        steps.add(step1);
        steps.add(step2);
        steps.add(step3);
        insert steps;

        List<vlocity_cmt__CalculationProcedureVariable__c> calcProcVariableList = new List<vlocity_cmt__CalculationProcedureVariable__c>{
                new vlocity_cmt__CalculationProcedureVariable__c(name='REC_MNTH_STD_PRC',vlocity_cmt__alias__c='REC_MNTH_STD_PRC',vlocity_cmt__datatype__c='Currency',vlocity_cmt__CalculationProcedureVersionId__c=procVersion.Id),
                new vlocity_cmt__CalculationProcedureVariable__c(name='OT_STD_PRC',vlocity_cmt__alias__c='OT_STD_PRC',vlocity_cmt__datatype__c='Currency',vlocity_cmt__defaultValue__c='27',vlocity_cmt__CalculationProcedureVersionId__c=procVersion.Id),
                new vlocity_cmt__CalculationProcedureVariable__c(name='Source Product Name',vlocity_cmt__alias__c='SourceProductName',vlocity_cmt__datatype__c='Text',vlocity_cmt__defaultValue__c='false',vlocity_cmt__CalculationProcedureVersionId__c=procVersion.Id),
                new vlocity_cmt__CalculationProcedureVariable__c(name='Source Product Code',vlocity_cmt__alias__c='SourceProductCode',vlocity_cmt__datatype__c='Text',vlocity_cmt__defaultValue__c='false',vlocity_cmt__CalculationProcedureVersionId__c=procVersion.Id),
                new vlocity_cmt__CalculationProcedureVariable__c(name='Characteristic Name',vlocity_cmt__alias__c='CharacteristicName',vlocity_cmt__datatype__c='Text',vlocity_cmt__defaultValue__c='false',vlocity_cmt__CalculationProcedureVersionId__c=procVersion.Id),
                new vlocity_cmt__CalculationProcedureVariable__c(name='Characteristic Value',vlocity_cmt__alias__c='CharacteristicValue',vlocity_cmt__datatype__c='Text',vlocity_cmt__defaultValue__c='false',vlocity_cmt__CalculationProcedureVersionId__c=procVersion.Id),
                new vlocity_cmt__CalculationProcedureVariable__c(name='MRC',vlocity_cmt__alias__c='AttributeRangePricing__MRC',vlocity_cmt__datatype__c='Text',vlocity_cmt__defaultValue__c='false',vlocity_cmt__CalculationProcedureVersionId__c=procVersion.Id),
                new vlocity_cmt__CalculationProcedureVariable__c(name='NRC',vlocity_cmt__alias__c='AttributeRangePricing__NRC',vlocity_cmt__datatype__c='Text',vlocity_cmt__defaultValue__c='false',vlocity_cmt__CalculationProcedureVersionId__c=procVersion.Id)
                };
        insert calcProcVariableList;

        //Creating and enabling CalculationProcedureVersion
        update new vlocity_cmt__CalculationProcedureVersion__c(Id = procVersion.Id, vlocity_cmt__IsEnabled__c = true);

    }



    //Initializing Product Details
    static private void testProductSetup(){

        vlocity_cmt__TriggerSetup__c itemTrigger = new vlocity_cmt__TriggerSetup__c(Name='AllTriggers', vlocity_cmt__IsTriggerOn__c=true);
        insert itemTrigger;

        vlocity_cmt__CpqConfigurationSetup__c configSetup = new vlocity_cmt__CpqConfigurationSetup__c(Name = 'DeltaPrice', vlocity_cmt__SetupValue__c = 'True');
        insert configSetup;

        vlocity_cmt__CpqConfigurationSetup__c configSetup2 = new vlocity_cmt__CpqConfigurationSetup__c(Name = 'PricingPlanHelperLogging', vlocity_cmt__SetupValue__c = 'True');
        insert configSetup2;

        vlocity_cmt__AttributeCategory__c attrCategory = new vlocity_cmt__AttributeCategory__c(Name='Logistics', vlocity_cmt__DisplaySequence__c=23, vlocity_cmt__Code__c='VLO-PRO-0015');
		insert attrCategory;

        vlocity_cmt__Attribute__c  attr = new vlocity_cmt__Attribute__c(Name='Provider',vlocity_cmt__AttributeCategoryId__c=attrCategory.Id, vlocity_cmt__Code__c='Attribute-124', vlocity_cmt__ActiveFlg__c=True);
        insert attr;

        List<SObject> sObjList = new List<sObject>();
        Product2 prod1 = new Product2 (Name='Triple Play Bundle Small', ProductCode = 'VLO-BUN-0001');
        sObjList.add(prod1);

        Product2 prod2 = new Product2 (Name='Consumer Landline', ProductCode = 'VLO-PHN-0005');
        prod2.vlocity_cmt__AttributeMetadata__c = '{\"totalSize\":1,\"messages\":[],\"records\":[{\"messages\":[],\"displaySequence\":23,\"Code__c\":\"VLO-PRO-0015\",\"Name\":\"Logistics\",\"id\":\"a1R46000000S2KWEA0\",\"productAttributes\":{\"totalSize\":1,\"messages\":[],\"records\":[{\"messages\":[],\"code\":\"ATTRIBUTE-124\",\"dataType\":\"text\",\"inputType\":\"dropdown\",\"multiselect\":false,\"required\":false,\"readonly\":false,\"disabled\":false,\"filterable\":true,\"attributeId\":\"a1S46000000NqHeEAK\",\"label\":\"Provider\",\"displaySequence\":4,\"hasRules\":false,\"hidden\":false,\"cloneable\":true,\"isNotTranslatable\":false,\"values\":[{\"id\":\"1\",\"label\":\"AT&T\",\"value\":\"ATT\",\"displaySequence\":1},{\"id\":\"2\",\"label\":\"Verizon\",\"value\":\"Verizon\",\"displaySequence\":2},{\"id\":\"3\",\"label\":\"Xfinity\",\"value\":\"Xfinity\",\"displaySequence\":1}],\"userValues\":null}]}}]}';
        sObjList.add(prod2);

        Product2 prod3 = new Product2 (Name='Broadband Internet Small', ProductCode = 'VLO-INT-0001');
        sObjList.add(prod3);

        Product2 prod4 = new Product2 (Name='TV Small', ProductCode = 'VLO-TV-0025');
        sObjList.add(prod4);

        Product2 prod5 = new Product2 (Name='HD TV', ProductCode = 'VLO-TV-0008');
        sObjList.add(prod5);

        insert sObjList;
        sObjList.clear();

        // Create Product Child Item
        vlocity_cmt__ProductChildItem__c pci1 = new vlocity_cmt__ProductChildItem__c();
        pci1.vlocity_cmt__ParentProductId__c = prod1.Id;
        pci1.vlocity_cmt__ChildProductId__c = prod2.Id;
        pci1.Name = 'Test PCI1';
        pci1.vlocity_cmt__Quantity__c = 1.0;
        pci1.vlocity_cmt__MinQuantity__c = 1.0;
        pci1.vlocity_cmt__MaxQuantity__c = 25.0;
        pci1.vlocity_cmt__IsRootProductChildItem__c = false;
        pci1.vlocity_cmt__IsOverride__c = false;
        pci1.vlocity_cmt__ChildLineNumber__c = '0001';
        pci1.vlocity_cmt__IsVirtualItem__c = false;
        sObjList.add(pci1);

        vlocity_cmt__ProductChildItem__c pci2 = new vlocity_cmt__ProductChildItem__c();
        pci2.vlocity_cmt__ParentProductId__c = prod1.Id;
        pci2.vlocity_cmt__ChildProductId__c = prod3.Id;
        pci2.Name = 'Test PCI2';
        pci2.vlocity_cmt__Quantity__c = 1.0;
        pci2.vlocity_cmt__MinQuantity__c = 1.0;
        pci2.vlocity_cmt__MaxQuantity__c = 1.0;
        pci2.vlocity_cmt__IsRootProductChildItem__c = false;
        pci2.vlocity_cmt__IsOverride__c = false;
        pci2.vlocity_cmt__ChildLineNumber__c = '0002';
        pci2.vlocity_cmt__IsVirtualItem__c = false;
        sObjList.add(pci2);

        vlocity_cmt__ProductChildItem__c pci3 = new vlocity_cmt__ProductChildItem__c();
        pci3.vlocity_cmt__ParentProductId__c = prod1.Id;
        pci3.vlocity_cmt__ChildProductId__c = prod4.Id;
        pci3.Name = 'Test PCI3';
        pci3.vlocity_cmt__Quantity__c = 1.0;
        pci3.vlocity_cmt__MinQuantity__c = 1.0;
        pci3.vlocity_cmt__MaxQuantity__c = 1.0;
        pci3.vlocity_cmt__IsRootProductChildItem__c = false;
        pci3.vlocity_cmt__IsOverride__c = false;
        pci3.vlocity_cmt__ChildLineNumber__c = '0003';
        pci3.vlocity_cmt__IsVirtualItem__c = false;
        sObjList.add(pci3);

        vlocity_cmt__ProductChildItem__c pci4 = new vlocity_cmt__ProductChildItem__c();
        pci4.vlocity_cmt__ParentProductId__c = prod3.Id;
        pci4.vlocity_cmt__ChildProductId__c = prod4.Id;
        pci4.Name = 'Test PCI4';
        pci4.vlocity_cmt__Quantity__c = 1.0;
        pci4.vlocity_cmt__MinQuantity__c = 1.0;
        pci4.vlocity_cmt__MaxQuantity__c = 20.0;
        pci4.vlocity_cmt__IsRootProductChildItem__c = false;
        pci4.vlocity_cmt__IsOverride__c = false;
        pci4.vlocity_cmt__ChildLineNumber__c = '0001';
        pci4.vlocity_cmt__IsVirtualItem__c = false;
        sObjList.add(pci4);

        insert sObjList;
        sObjList.clear();

        Pricebook2 standardBook =  new Pricebook2(Id = Test.getStandardPricebookId(), Name = 'TestPricebook5', IsActive = true);
        Pricebook2 testPricebook = new Pricebook2(Name = 'TestPricebook7', IsActive = true);
        insert testPricebook;

        //Inserting into standard Pricebook
        PricebookEntry pbe11 = new PricebookEntry(Pricebook2Id = standardBook.Id,
                Product2Id = prod1.Id, UnitPrice = 10, vlocity_cmt__RecurringPrice__c = 5, IsActive = true);
        sObjList.add(pbe11);

        PricebookEntry pbe12 = new PricebookEntry(Pricebook2Id = standardBook.Id,
                Product2Id = prod2.Id, UnitPrice = 20, vlocity_cmt__RecurringPrice__c = 10, IsActive = true);
        sObjList.add(pbe12);

        PricebookEntry pbe13 = new PricebookEntry(Pricebook2Id = standardBook.Id,
                Product2Id = prod3.Id, UnitPrice = 30, vlocity_cmt__RecurringPrice__c = 15, IsActive = true);
        sObjList.add(pbe13);

        PricebookEntry pbe14 = new PricebookEntry(Pricebook2Id = standardBook.Id,
                Product2Id = prod4.Id, UnitPrice = 40, vlocity_cmt__RecurringPrice__c = 20, IsActive = true);
        sObjList.add(pbe14);

        PricebookEntry pbe15 = new PricebookEntry(Pricebook2Id = standardBook.Id,
                Product2Id = prod5.Id, UnitPrice = 50, vlocity_cmt__RecurringPrice__c = 25, IsActive = true);
        sObjList.add(pbe15);

        //insert sObjList;
        //sObjList.clear();

        //Inserting into Custom Pricebook
        PricebookEntry pbe1 = new PricebookEntry(Pricebook2Id = testPricebook.Id,
                Product2Id = prod1.Id, UnitPrice = 10, vlocity_cmt__RecurringPrice__c = 5, IsActive = true, UseStandardPrice = false);
        sObjList.add(pbe1);

        PricebookEntry pbe2 = new PricebookEntry(Pricebook2Id = testPricebook.Id,
                Product2Id = prod2.Id, UnitPrice = 20, vlocity_cmt__RecurringPrice__c = 10, IsActive = true, UseStandardPrice = false);
        sObjList.add(pbe2);

        PricebookEntry pbe3 = new PricebookEntry(Pricebook2Id = testPricebook.Id,
                Product2Id = prod3.Id, UnitPrice = 30, vlocity_cmt__RecurringPrice__c = 15, IsActive = true, UseStandardPrice = false);
        sObjList.add(pbe3);

        PricebookEntry pbe4 = new PricebookEntry(Pricebook2Id = testPricebook.Id,
                Product2Id = prod4.Id, UnitPrice = 40, vlocity_cmt__RecurringPrice__c = 20, IsActive = true, UseStandardPrice = false);
        sObjList.add(pbe4);

        PricebookEntry pbe5 = new PricebookEntry(Pricebook2Id = testPricebook.Id,
                Product2Id = prod5.Id, UnitPrice = 45, vlocity_cmt__RecurringPrice__c = 25, IsActive = true, UseStandardPrice = false);
        sObjList.add(pbe5);

        insert sObjList;
        sObjList.clear();

        vlocity_cmt__PriceList__c pl1 = new vlocity_cmt__PriceList__c(vlocity_cmt__Pricebook2Id__c = testPricebook.Id, vlocity_cmt__IsActive__c = true, vlocity_cmt__Code__c = 'TestPricebook5');
        insert pl1;

        // Create Object Type
        SObject sObj = [SELECT Id, SobjectType, DeveloperName FROM RecordType WHERE IsActive = TRUE and SobjectType = 'vlocity_cmt__ObjectClass__c' and DeveloperName = 'ObjectType' LIMIT 1];
        vlocity_cmt__ObjectClass__c chargeObjType = new vlocity_cmt__ObjectClass__c(Name = 'Charge', vlocity_cmt__ObjectApiName__c = 'PricingElement__c', RecordTypeId = sObj.Id);
        vlocity_cmt__ObjectClass__c discObjType = new vlocity_cmt__ObjectClass__c(Name = 'Discount', vlocity_cmt__ObjectApiName__c = 'PricingElement__c', RecordTypeId = sObj.Id);

        sObjList.clear();
        sObjList.add(chargeObjType);
        sObjList.add(discObjType);
        insert sObjList;
        sObjList.clear();

        vlocity_cmt__PricingVariable__c oneTimeStdPriceVar = new vlocity_cmt__PricingVariable__c(Name = 'One Time Std Price', vlocity_cmt__Code__c = 'OT_STD_PRC',vlocity_cmt__Aggregation__c = 'Unit',
                vlocity_cmt__ChargeType__c='One-time',vlocity_cmt__IsActive__c = true,vlocity_cmt__Scope__c = 'Line',vlocity_cmt__SubType__c = 'Standard',vlocity_cmt__Type__c = 'Price',
                vlocity_cmt__ValueType__c='Pricing Element',vlocity_cmt__CurrencyType__c='Currency');
        sObjList.add(oneTimeStdPriceVar);

        vlocity_cmt__PricingVariable__c mrcPriceVar = new vlocity_cmt__PricingVariable__c(Name = 'Recurring Monthly Std Price', vlocity_cmt__Code__c = 'REC_MNTH_STD_PRC',vlocity_cmt__Aggregation__c = 'Unit',
                vlocity_cmt__ChargeType__c='Recurring', vlocity_cmt__RecurringFrequency__c ='Monthly',vlocity_cmt__IsActive__c = true,vlocity_cmt__Scope__c = 'Line',vlocity_cmt__SubType__c = 'Standard',vlocity_cmt__Type__c = 'Price',
                vlocity_cmt__ValueType__c='Pricing Element',vlocity_cmt__CurrencyType__c='Currency');
        sObjList.add(mrcPriceVar);

        vlocity_cmt__PricingVariable__c uPriceVar = new vlocity_cmt__PricingVariable__c(Name = 'Usage Std Price', vlocity_cmt__Code__c = 'USAGE_STD_PRC',vlocity_cmt__Aggregation__c = 'Unit',
                vlocity_cmt__ChargeType__c='Usage', vlocity_cmt__IsActive__c = true,vlocity_cmt__Scope__c = 'Line',vlocity_cmt__SubType__c = 'Standard',vlocity_cmt__Type__c = 'Price',
                vlocity_cmt__ValueType__c='Pricing Element',vlocity_cmt__CurrencyType__c='Currency');
        sObjList.add(uPriceVar);

        insert sObjList;
        sObjList.clear();

        insert sObjList;

        // Create Pricing Element
        vlocity_cmt__PricingElement__c pElem1 = new vlocity_cmt__PricingElement__c(Name = 'One Time $100 Standalone Price', vlocity_cmt__ObjectTypeId__c = chargeObjType.Id, vlocity_cmt__Amount__c = 100.00,
                vlocity_cmt__Code__c = 'PELEM1', vlocity_cmt__EffectiveFromDate__c = Datetime.now(), vlocity_cmt__IsActive__c = true, vlocity_cmt__IsReusable__c = true, vlocity_cmt__PricingVariableId__c = oneTimeStdPriceVar.Id, vlocity_cmt__PriceListId__c = pl1.Id);
        vlocity_cmt__PricingElement__c pElem2 = new vlocity_cmt__PricingElement__c(Name = 'MRC $20 Standalone Price', vlocity_cmt__ObjectTypeId__c = chargeObjType.Id, vlocity_cmt__Amount__c = 20.00,
                vlocity_cmt__Code__c = 'PELEM2', vlocity_cmt__EffectiveFromDate__c = Datetime.now(), vlocity_cmt__IsActive__c = true, vlocity_cmt__IsReusable__c = true, vlocity_cmt__PricingVariableId__c = mrcPriceVar.Id, vlocity_cmt__PriceListId__c = pl1.Id);
        vlocity_cmt__PricingElement__c pElem4 = new vlocity_cmt__PricingElement__c(Name = 'One Time $400 Local Price', vlocity_cmt__ObjectTypeId__c = chargeObjType.Id, vlocity_cmt__Amount__c = 400.00,
                vlocity_cmt__Code__c = 'PELEM4', vlocity_cmt__EffectiveFromDate__c = Datetime.now(), vlocity_cmt__IsActive__c = true, vlocity_cmt__IsReusable__c = false, vlocity_cmt__PricingVariableId__c = oneTimeStdPriceVar.Id, vlocity_cmt__PriceListId__c = pl1.Id);
        vlocity_cmt__PricingElement__c pElem5 = new vlocity_cmt__PricingElement__c(Name = 'MRC $50 Local Price', vlocity_cmt__ObjectTypeId__c = chargeObjType.Id, vlocity_cmt__Amount__c = 50.00,
                vlocity_cmt__Code__c = 'PELEM5', vlocity_cmt__EffectiveFromDate__c = Datetime.now(), vlocity_cmt__IsActive__c = true, vlocity_cmt__IsReusable__c = false, vlocity_cmt__PricingVariableId__c = mrcPriceVar.Id, vlocity_cmt__PriceListId__c = pl1.Id);
        sObjList.clear();
        sObjList.add(pElem1);
        sObjList.add(pElem2);
        sObjList.add(pElem4);
        sObjList.add(pElem5);

        insert sObjList;
        sObjList.clear();


        List<vlocity_cmt__PricingElement__c> pricingElement = [SELECT Id, Name FROM vlocity_cmt__PricingElement__c];
        vlocity_cmt__PriceListEntry__c ple1 = new vlocity_cmt__PriceListEntry__c(vlocity_cmt__PriceListId__c=pl1.Id, vlocity_cmt__ProductId__c=prod1.Id, vlocity_cmt__PricingElementId__c = pElem1.Id, vlocity_cmt__EffectiveFromDate__c=Datetime.now(), vlocity_cmt__IsActive__c=true);
        sObjList.add(ple1);
        vlocity_cmt__PriceListEntry__c ple2 = new vlocity_cmt__PriceListEntry__c(vlocity_cmt__PriceListId__c=pl1.Id, vlocity_cmt__ProductId__c=prod2.Id, vlocity_cmt__PricingElementId__c = pElem4.Id, vlocity_cmt__EffectiveFromDate__c=Datetime.now(), vlocity_cmt__IsActive__c=true);
        sObjList.add(ple2);
        vlocity_cmt__PriceListEntry__c ple5 = new vlocity_cmt__PriceListEntry__c(vlocity_cmt__PriceListId__c=pl1.Id, vlocity_cmt__ProductId__c=prod3.Id, vlocity_cmt__PricingElementId__c = pElem1.Id, vlocity_cmt__EffectiveFromDate__c=Datetime.now(), vlocity_cmt__IsActive__c=true);
        sObjList.add(ple5);
        vlocity_cmt__PriceListEntry__c ple7 = new vlocity_cmt__PriceListEntry__c(vlocity_cmt__PriceListId__c=pl1.Id, vlocity_cmt__ProductId__c=prod4.Id, vlocity_cmt__PricingElementId__c = pElem1.Id, vlocity_cmt__EffectiveFromDate__c=Datetime.now(), vlocity_cmt__IsActive__c=true);
        sObjList.add(ple7);
        vlocity_cmt__PriceListEntry__c ple8 = new vlocity_cmt__PriceListEntry__c(vlocity_cmt__PriceListId__c=pl1.Id, vlocity_cmt__ProductId__c=prod5.Id, vlocity_cmt__PricingElementId__c = pElem1.Id, vlocity_cmt__EffectiveFromDate__c=Datetime.now(), vlocity_cmt__IsActive__c=true);
        sObjList.add(ple8);

        insert sObjList;
        sObjList.clear();

        //Creating PricingVariableBinding
        vlocity_cmt__PricingVariableBinding__c pvb1 = new vlocity_cmt__PricingVariableBinding__c(Name='One Time Std Price - OrderItem',vlocity_cmt__DestinationSObjectType__c='OrderItem',
                vlocity_cmt__DestinationFieldApiName__c = 'vlocity_cmt__OneTimeCharge__c', vlocity_cmt__PricingVariableId__c = oneTimeStdPriceVar.Id);
        sObjList.add(pvb1);
        vlocity_cmt__PricingVariableBinding__c pvb2 = new vlocity_cmt__PricingVariableBinding__c(Name='Recurring Monthly Std Price - OrderItem',vlocity_cmt__DestinationSObjectType__c='OrderItem',
                vlocity_cmt__DestinationFieldApiName__c = 'vlocity_cmt__RecurringCharge__c', vlocity_cmt__PricingVariableId__c = mrcPriceVar.Id);
        sObjList.add(pvb2);
        vlocity_cmt__PricingVariableBinding__c pvb3 = new vlocity_cmt__PricingVariableBinding__c(Name='Usage Std Price - OrderItem',vlocity_cmt__DestinationSObjectType__c='OrderItem',
                vlocity_cmt__DestinationFieldApiName__c = 'vlocity_cmt__UsageUnitPrice__c', vlocity_cmt__PricingVariableId__c = uPriceVar.Id);
        sObjList.add(pvb3);

        insert sObjList;
        sObjList.clear();

        Account a = new Account(Name='Account Test');
        insert a;

        vlocity_cmt__InterfaceImplementation__c iit1 = new vlocity_cmt__InterfaceImplementation__c (Name='PricingInterface');
        vlocity_cmt__InterfaceImplementation__c iit2 = new vlocity_cmt__InterfaceImplementation__c(Name='PricingSelectorInterface');
        vlocity_cmt__InterfaceImplementation__c intImpl = new vlocity_cmt__InterfaceImplementation__c (Name='TightestMatchInterface');
        vlocity_cmt__InterfaceImplementation__c iit = new vlocity_cmt__InterfaceImplementation__c (Name='ContextRuleService');
        sObjList.add(iit1);
        sObjList.add(iit2);
        sObjList.add(intImpl);
        sObjList.add(iit);
        insert sObjList;
        sObjList.clear();

        vlocity_cmt__InterfaceImplementationDetail__c iid1 = new vlocity_cmt__InterfaceImplementationDetail__c (Name = 'PricingElementServiceImplementation',
                vlocity_cmt__InterfaceId__c=iit1.Id, vlocity_cmt__IsActive__c=true);

        vlocity_cmt__InterfaceImplementationDetail__c iid2 = new vlocity_cmt__InterfaceImplementationDetail__c (Name = 'PricingComponentSelector',
                vlocity_cmt__InterfaceId__c=iit2.Id, vlocity_cmt__IsActive__c=true);

        vlocity_cmt__InterfaceImplementationDetail__c iit004_001 = new vlocity_cmt__InterfaceImplementationDetail__c
                (Name = 'TightestMatchServiceImplementation', vlocity_cmt__InterfaceId__c=intImpl.Id, vlocity_cmt__IsDefault__c=true,vlocity_cmt__IsActive__c=true);

        vlocity_cmt__InterfaceImplementationDetail__c iit_001 = new vlocity_cmt__InterfaceImplementationDetail__c
                (Name = 'ContextRuleService', vlocity_cmt__InterfaceId__c=iit.Id, vlocity_cmt__IsDefault__c=true,vlocity_cmt__IsActive__c=true);

        sObjList.add(iid1);
        sObjList.add(iid2);
        sObjList.add(iit004_001);
        sObjList.add(iit_001);
        insert sObjList;
        sObjList.clear();

        vlocity_cmt__TriggerSetup__c myTrigger = new vlocity_cmt__TriggerSetup__c(Name='AllTriggers', vlocity_cmt__IsTriggerOn__c=true);
        insert myTrigger;



        Order testOrder = new Order(Name='Test Order',EffectiveDate=System.today(),status='Draft',AccountId = a.Id, vlocity_cmt__PriceListId__c = pl1.Id, Pricebook2Id = testPricebook.Id);
        insert testOrder;
        orderId = testOrder.Id;

        List<priceBookEntry> priceBookEntry = [SELECT Id FROM PricebookEntry WHERE Product2Id =: prod1.Id];
        Id priceBookEntryId = priceBookEntry[0].Id;

        OrderItem orderItem = new OrderItem();
        orderItem.OrderId = testOrder.Id;
        orderItem.PricebookEntryId = pbe1.Id;
        orderItem.Quantity = 1;
        orderItem.vlocity_cmt__LineNumber__c = '0001';
        orderItem.UnitPrice = 100;
        orderItem.vlocity_cmt__ProvisioningStatus__c = 'New';
        sObjList.add(orderItem);

        //OrderItem Name : Consumer
        //Attributes : Verizon ..... Default Value : Verizon
        OrderItem orderItem2 = new OrderItem();
        orderItem2.OrderId = testOrder.Id;
        orderItem2.PricebookEntryId = pbe2.Id;
        orderItem2.Quantity = 1.0;
        orderItem2.vlocity_cmt__LineNumber__c = '0001.0001';
        orderItem2.UnitPrice = 100;
        orderItem2.vlocity_cmt__ProvisioningStatus__c = 'New';
        orderItem2.vlocity_cmt__JSONAttribute__c = '{\"VLO-PRO-0015\":[{\"$$AttributeDefinitionStart$$\":null,\"objectid__c\":\"01t46000003GrteAAC\",\"attributeid__c\":\"a1S46000000NqHeEAK\",\"attributecategoryid__c\":\"a1R46000000S2KWEA0\",\"categorycode__c\":\"VLO-PRO-0015\",\"categoryname__c\":\"Logistics\",\"attributeuniquecode__c\":\"ATTRIBUTE-124\",\"attributeconfigurable__c\":true,\"attributedisplaysequence__c\":\"4\",\"attributefilterable__c\":true,\"attributecloneable__c\":false,\"isactive__c\":true,\"attributedisplayname__c\":\"Provider\",\"displaysequence__c\":\"null\",\"categorydisplaysequence__c\":23,\"customconfiguitemplate__c\":null,\"formatmask__c\":null,\"hasrule__c\":false,\"isconfigurable__c\":true,\"ishidden__c\":false,\"valueinnumber__c\":null,\"objecttype__c\":\"Product2\",\"querycode__c\":null,\"isreadonly__c\":false,\"isquerydriven__c\":false,\"querylabel__c\":null,\"id\":\"a1Q46000000RhxAEAS\",\"isrequired__c\":false,\"rulemessage__c\":null,\"uidisplaytype__c\":\"Radiobutton\",\"value__c\":\"Verizon\",\"valuedatatype__c\":\"Picklist\",\"valuedescription__c\":null,\"attributeRunTimeInfo\":{\"dataType\":\"Picklist\",\"uiDisplayType\":\"Radiobutton\",\"default\":[{\"value\":\"Verizon\",\"id\":2,\"displayText\":\"Verizon\"}],\"values\":[{\"value\":\"ATT\",\"id\":1,\"displayText\":\"AT&T\"},{\"value\":\"Verizon\",\"id\":2,\"displayText\":\"Verizon\"},{\"value\":\"Xfinity\",\"id\":3,\"displayText\":\"Xfinity\"}],\"selectedItem\":{\"value\":\"Verizon\",\"id\":2,\"displayText\":\"Verizon\"}},\"$$AttributeDefinitionEnd$$\":null}]}';
        orderItem2.vlocity_cmt__AttributeSelectedValues__c = '{\"Attribute-124\":\"Verizon\"}';
        sObjList.add(orderItem2);

        //OrderItem Name : Broadband Internet Small
        //Attributes : Internet Upload Speed;Internet Download Speed  ......  Default : 80Mbps;16Mbps
        OrderItem orderItem3 = new OrderItem();
        orderItem3.OrderId = testOrder.Id;
        orderItem3.PricebookEntryId = pbe3.Id;
        orderItem3.Quantity = 5.0;
        orderItem3.vlocity_cmt__LineNumber__c = '0001.0002';
        orderItem3.UnitPrice = 100;
        orderItem3.vlocity_cmt__ProvisioningStatus__c = 'New';
        orderItem3.vlocity_cmt__JSONAttribute__c= '{\"INTERNET-CAT1\":[{\"$$AttributeDefinitionStart$$\":null,\"objectid__c\":\"01t46000003GrttAAC\",\"attributeid__c\":\"a1S46000000O2fqEAC\",\"attributecategoryid__c\":\"a1R46000000ths0EAA\",\"categorycode__c\":\"INTERNET-CAT1\",\"categoryname__c\":\"Internet\",\"attributeuniquecode__c\":\"ATTRIBUTE-1200\",\"attributeconfigurable__c\":true,\"attributedisplaysequence__c\":\"1\",\"attributefilterable__c\":true,\"attributecloneable__c\":true,\"isactive__c\":true,\"attributedisplayname__c\":\"Internet Download Speed\",\"displaysequence__c\":\"null\",\"categorydisplaysequence__c\":1,\"customconfiguitemplate__c\":null,\"formatmask__c\":null,\"hasrule__c\":false,\"isconfigurable__c\":true,\"ishidden__c\":false,\"valueinnumber__c\":null,\"objecttype__c\":\"Product2\",\"querycode__c\":null,\"isreadonly__c\":false,\"isquerydriven__c\":false,\"querylabel__c\":null,\"id\":\"a1Q46000000RhwvEAC\",\"isrequired__c\":false,\"rulemessage__c\":null,\"uidisplaytype__c\":\"Dropdown\",\"value__c\":\"80Mbps\",\"valuedatatype__c\":\"Picklist\",\"valuedescription__c\":null,\"attributeRunTimeInfo\":{\"dataType\":\"Picklist\",\"uiDisplayType\":\"Dropdown\",\"default\":[{\"value\":\"80Mbps\",\"id\":8,\"displayText\":\"80Mbps\"}],\"values\":[{\"value\":\"20Mbps\",\"id\":2,\"displayText\":\"20Mbps\"},{\"value\":\"100Mbps\",\"id\":10,\"displayText\":\"100Mbps\"},{\"value\":\"60Mbps\",\"id\":6,\"displayText\":\"60Mbps\"},{\"value\":\"40Mbps\",\"id\":4,\"displayText\":\"40Mbps\"},{\"value\":\"90Mbps\",\"id\":9,\"displayText\":\"90Mbps\"},{\"value\":\"50Mbps\",\"id\":5,\"displayText\":\"50Mbps\"},{\"value\":\"10Mbps\",\"id\":1,\"displayText\":\"10Mbps\"},{\"value\":\"30Mbps\",\"id\":3,\"displayText\":\"30Mbps\"},{\"value\":\"80Mbps\",\"id\":8,\"displayText\":\"80Mbps\"},{\"value\":\"70Mbps\",\"id\":7,\"displayText\":\"70Mbps\"}],\"selectedItem\":{\"value\":\"80Mbps\",\"id\":8,\"displayText\":\"80Mbps\"}},\"$$AttributeDefinitionEnd$$\":null},{\"$$AttributeDefinitionStart$$\":null,\"objectid__c\":\"01t46000003GrttAAC\",\"attributeid__c\":\"a1S46000000O2g0EAC\",\"attributecategoryid__c\":\"a1R46000000ths0EAA\",\"categorycode__c\":\"INTERNET-CAT1\",\"categoryname__c\":\"Internet\",\"attributeuniquecode__c\":\"ATTRIBUTE-1270\",\"attributeconfigurable__c\":true,\"attributedisplaysequence__c\":\"1\",\"attributefilterable__c\":true,\"attributecloneable__c\":true,\"isactive__c\":true,\"attributedisplayname__c\":\"Internet Upload Speed\",\"displaysequence__c\":\"null\",\"categorydisplaysequence__c\":1,\"customconfiguitemplate__c\":null,\"formatmask__c\":null,\"hasrule__c\":false,\"isconfigurable__c\":true,\"ishidden__c\":false,\"valueinnumber__c\":null,\"objecttype__c\":\"Product2\",\"querycode__c\":null,\"isreadonly__c\":false,\"isquerydriven__c\":false,\"querylabel__c\":null,\"id\":\"a1Q46000000RhwwEAC\",\"isrequired__c\":false,\"rulemessage__c\":null,\"uidisplaytype__c\":\"Dropdown\",\"value__c\":\"16Mbps\",\"valuedatatype__c\":\"Picklist\",\"valuedescription__c\":null,\"attributeRunTimeInfo\":{\"dataType\":\"Picklist\",\"uiDisplayType\":\"Dropdown\",\"default\":[{\"value\":\"16Mbps\",\"id\":8,\"displayText\":\"16Mbps\"}],\"values\":[{\"value\":\"8Mbps\",\"id\":4,\"displayText\":\"8Mbps\"},{\"value\":\"14Mbps\",\"id\":7,\"displayText\":\"14Mbps\"},{\"value\":\"12Mbps\",\"id\":6,\"displayText\":\"12Mbps\"},{\"value\":\"4Mbps\",\"id\":2,\"displayText\":\"4Mbps\"},{\"value\":\"18Mbps\",\"id\":9,\"displayText\":\"18Mbps\"},{\"value\":\"6Mbps\",\"id\":3,\"displayText\":\"6Mbps\"},{\"value\":\"2Mbps\",\"id\":1,\"displayText\":\"2Mbps\"},{\"value\":\"16Mbps\",\"id\":8,\"displayText\":\"16Mbps\"},{\"value\":\"10Mbps\",\"id\":5,\"displayText\":\"10Mbps\"},{\"value\":\"20Mbps\",\"id\":10,\"displayText\":\"20Mbps\"}],\"selectedItem\":{\"value\":\"16Mbps\",\"id\":8,\"displayText\":\"16Mbps\"}},\"$$AttributeDefinitionEnd$$\":null}]}';
        sObjList.add(orderItem3);

        //OrderItem Name : TV Small
        OrderItem orderItem4 = new OrderItem();
        orderItem4.OrderId = testOrder.Id;
        orderItem4.PricebookEntryId = pbe4.Id;
        orderItem4.Quantity = 1.0;
        orderItem4.vlocity_cmt__LineNumber__c = '0001.0003';
        orderItem4.UnitPrice = 100;
        orderItem4.vlocity_cmt__ProvisioningStatus__c = 'New';
        sObjList.add(orderItem4);

        //OrderItem Name : HD TV
        //Attributes : TV Content; TV Boxes Required .... Default : HD;4
        OrderItem orderItem5 = new OrderItem();
        orderItem5.OrderId = testOrder.Id;
        orderItem5.PricebookEntryId = pbe5.Id;
        orderItem5.Quantity = 5.0;
        orderItem5.vlocity_cmt__LineNumber__c = '0001.0003.0001';
        orderItem5.UnitPrice = 100;
        orderItem5.vlocity_cmt__ProvisioningStatus__c = 'New';
        orderItem5.vlocity_cmt__JSONAttribute__c= '{\"VLO-PRO-0015\":[{\"$$AttributeDefinitionStart$$\":null,\"objectid__c\":\"01t46000003GrtPAAS\",\"attributeid__c\":\"a1S46000000NqHbEAK\",\"attributecategoryid__c\":\"a1R46000000S2KWEA0\",\"categorycode__c\":\"VLO-PRO-0015\",\"categoryname__c\":\"Logistics\",\"attributeuniquecode__c\":\"ATTRIBUTE-123\",\"attributeconfigurable__c\":true,\"attributedisplaysequence__c\":\"1\",\"attributefilterable__c\":true,\"attributecloneable__c\":false,\"isactive__c\":true,\"attributedisplayname__c\":\"Part Number\",\"displaysequence__c\":\"null\",\"categorydisplaysequence__c\":23,\"customconfiguitemplate__c\":null,\"formatmask__c\":null,\"hasrule__c\":false,\"isconfigurable__c\":false,\"ishidden__c\":false,\"valueinnumber__c\":null,\"objecttype__c\":\"Product2\",\"querycode__c\":null,\"isreadonly__c\":false,\"isquerydriven__c\":false,\"querylabel__c\":null,\"id\":\"a1Q46000000RhwREAS\",\"isrequired__c\":false,\"rulemessage__c\":null,\"uidisplaytype__c\":null,\"value__c\":null,\"valuedatatype__c\":\"Text\",\"valuedescription__c\":null,\"attributeRunTimeInfo\":{\"dataType\":\"Text\",\"value\":null},\"$$AttributeDefinitionEnd$$\":null},{\"$$AttributeDefinitionStart$$\":null,\"objectid__c\":\"01t46000003GrtPAAS\",\"attributeid__c\":\"a1S46000000NqHdEAK\",\"attributecategoryid__c\":\"a1R46000000S2KWEA0\",\"categorycode__c\":\"VLO-PRO-0015\",\"categoryname__c\":\"Logistics\",\"attributeuniquecode__c\":\"ATTRIBUTE-125\",\"attributeconfigurable__c\":true,\"attributedisplaysequence__c\":\"3\",\"attributefilterable__c\":true,\"attributecloneable__c\":false,\"isactive__c\":true,\"attributedisplayname__c\":\"Supplier\",\"displaysequence__c\":\"null\",\"categorydisplaysequence__c\":23,\"customconfiguitemplate__c\":null,\"formatmask__c\":null,\"hasrule__c\":false,\"isconfigurable__c\":false,\"ishidden__c\":false,\"valueinnumber__c\":null,\"objecttype__c\":\"Product2\",\"querycode__c\":null,\"isreadonly__c\":false,\"isquerydriven__c\":false,\"querylabel__c\":null,\"id\":\"a1Q46000000RhwdEAC\",\"isrequired__c\":false,\"rulemessage__c\":null,\"uidisplaytype__c\":null,\"value__c\":null,\"valuedatatype__c\":\"Text\",\"valuedescription__c\":null,\"attributeRunTimeInfo\":{\"dataType\":\"Text\",\"value\":null},\"$$AttributeDefinitionEnd$$\":null}],\"VLO-PRO-0006\":[{\"$$AttributeDefinitionStart$$\":null,\"objectid__c\":\"01t46000003GrtPAAS\",\"attributeid__c\":\"a1S46000000NqIkEAK\",\"attributecategoryid__c\":\"a1R46000000S2M3EAK\",\"categorycode__c\":\"VLO-PRO-0006\",\"categoryname__c\":\"Cloud Services\",\"attributeuniquecode__c\":\"ATTRIBUTE-089\",\"attributeconfigurable__c\":true,\"attributedisplaysequence__c\":\"1\",\"attributefilterable__c\":false,\"attributecloneable__c\":false,\"isactive__c\":true,\"attributedisplayname__c\":\"Storage Space\",\"displaysequence__c\":\"null\",\"categorydisplaysequence__c\":14,\"customconfiguitemplate__c\":null,\"formatmask__c\":null,\"hasrule__c\":false,\"isconfigurable__c\":false,\"ishidden__c\":false,\"valueinnumber__c\":null,\"objecttype__c\":\"Product2\",\"querycode__c\":null,\"isreadonly__c\":false,\"isquerydriven__c\":false,\"querylabel__c\":null,\"id\":\"a1Q46000000RhwWEAS\",\"isrequired__c\":false,\"rulemessage__c\":null,\"uidisplaytype__c\":null,\"value__c\":null,\"valuedatatype__c\":\"Text\",\"valuedescription__c\":null,\"attributeRunTimeInfo\":{\"dataType\":\"Text\",\"value\":null},\"$$AttributeDefinitionEnd$$\":null}],\"VLO-PRO-0003\":[{\"$$AttributeDefinitionStart$$\":null,\"objectid__c\":\"01t46000003GrtPAAS\",\"attributeid__c\":\"a1S46000000NsE0EAK\",\"attributecategoryid__c\":\"a1R46000000S3Z8EAK\",\"categorycode__c\":\"VLO-PRO-0003\",\"categoryname__c\":\"Mobile Handset\",\"attributeuniquecode__c\":\"ATTRIBUTE-064\",\"attributeconfigurable__c\":true,\"attributedisplaysequence__c\":\"1\",\"attributefilterable__c\":true,\"attributecloneable__c\":true,\"isactive__c\":true,\"attributedisplayname__c\":\"Device Manufacturer\",\"displaysequence__c\":\"null\",\"categorydisplaysequence__c\":11,\"customconfiguitemplate__c\":null,\"formatmask__c\":null,\"hasrule__c\":false,\"isconfigurable__c\":false,\"ishidden__c\":false,\"valueinnumber__c\":null,\"objecttype__c\":\"Product2\",\"querycode__c\":null,\"isreadonly__c\":false,\"isquerydriven__c\":false,\"querylabel__c\":null,\"id\":\"a1Q46000000RhwMEAS\",\"isrequired__c\":false,\"rulemessage__c\":null,\"uidisplaytype__c\":null,\"value__c\":null,\"valuedatatype__c\":\"Text\",\"valuedescription__c\":null,\"attributeRunTimeInfo\":{\"dataType\":\"Text\",\"value\":null},\"$$AttributeDefinitionEnd$$\":null}],\"VLO-PRO-0002\":[{\"$$AttributeDefinitionStart$$\":null,\"objectid__c\":\"01t46000003GrtPAAS\",\"attributeid__c\":\"a1S46000000NqIgEAK\",\"attributecategoryid__c\":\"a1R46000000S2LZEA0\",\"categorycode__c\":\"VLO-PRO-0002\",\"categoryname__c\":\"TV Technology\",\"attributeuniquecode__c\":\"ATTRIBUTE-019\",\"attributeconfigurable__c\":true,\"attributedisplaysequence__c\":\"2\",\"attributefilterable__c\":true,\"attributecloneable__c\":false,\"isactive__c\":true,\"attributedisplayname__c\":\"TV Connection\",\"displaysequence__c\":\"null\",\"categorydisplaysequence__c\":10,\"customconfiguitemplate__c\":null,\"formatmask__c\":null,\"hasrule__c\":false,\"isconfigurable__c\":false,\"ishidden__c\":false,\"valueinnumber__c\":null,\"objecttype__c\":\"Product2\",\"querycode__c\":null,\"isreadonly__c\":false,\"isquerydriven__c\":false,\"querylabel__c\":null,\"id\":\"a1Q46000000RhwbEAC\",\"isrequired__c\":false,\"rulemessage__c\":null,\"uidisplaytype__c\":null,\"value__c\":null,\"valuedatatype__c\":\"Text\",\"valuedescription__c\":null,\"attributeRunTimeInfo\":{\"dataType\":\"Text\",\"value\":null},\"$$AttributeDefinitionEnd$$\":null},{\"$$AttributeDefinitionStart$$\":null,\"objectid__c\":\"01t46000003GrtPAAS\",\"attributeid__c\":\"a1S46000000NqIhEAK\",\"attributecategoryid__c\":\"a1R46000000S2LZEA0\",\"categorycode__c\":\"VLO-PRO-0002\",\"categoryname__c\":\"TV Technology\",\"attributeuniquecode__c\":\"ATTRIBUTE-044\",\"attributeconfigurable__c\":true,\"attributedisplaysequence__c\":\"3\",\"attributefilterable__c\":false,\"attributecloneable__c\":false,\"isactive__c\":true,\"attributedisplayname__c\":\"TV Boxes Required\",\"displaysequence__c\":\"null\",\"categorydisplaysequence__c\":10,\"customconfiguitemplate__c\":null,\"formatmask__c\":null,\"hasrule__c\":false,\"isconfigurable__c\":true,\"ishidden__c\":false,\"valueinnumber__c\":4,\"objecttype__c\":\"Product2\",\"querycode__c\":null,\"isreadonly__c\":false,\"isquerydriven__c\":false,\"querylabel__c\":null,\"id\":\"a1Q46000000RhwcEAC\",\"isrequired__c\":false,\"rulemessage__c\":null,\"uidisplaytype__c\":null,\"value__c\":\"4\",\"valuedatatype__c\":\"Number\",\"valuedescription__c\":null,\"attributeRunTimeInfo\":{\"dataType\":\"Number\",\"default\":\"4\",\"value\":4},\"$$AttributeDefinitionEnd$$\":null},{\"$$AttributeDefinitionStart$$\":null,\"objectid__c\":\"01t46000003GrtPAAS\",\"attributeid__c\":\"a1S46000000NqIfEAK\",\"attributecategoryid__c\":\"a1R46000000S2LZEA0\",\"categorycode__c\":\"VLO-PRO-0002\",\"categoryname__c\":\"TV Technology\",\"attributeuniquecode__c\":\"ATTRIBUTE-018\",\"attributeconfigurable__c\":true,\"attributedisplaysequence__c\":\"1\",\"attributefilterable__c\":true,\"attributecloneable__c\":false,\"isactive__c\":true,\"attributedisplayname__c\":\"TV Content\",\"displaysequence__c\":\"null\",\"categorydisplaysequence__c\":10,\"customconfiguitemplate__c\":null,\"formatmask__c\":null,\"hasrule__c\":false,\"isconfigurable__c\":true,\"ishidden__c\":false,\"valueinnumber__c\":null,\"objecttype__c\":\"Product2\",\"querycode__c\":null,\"isreadonly__c\":false,\"isquerydriven__c\":false,\"querylabel__c\":null,\"id\":\"a1Q46000000RhweEAC\",\"isrequired__c\":false,\"rulemessage__c\":null,\"uidisplaytype__c\":\"Dropdown\",\"value__c\":\"HD\",\"valuedatatype__c\":\"Picklist\",\"valuedescription__c\":null,\"attributeRunTimeInfo\":{\"dataType\":\"Picklist\",\"uiDisplayType\":\"Dropdown\",\"default\":[{\"value\":\"HD\",\"id\":2,\"displayText\":\"HD\"}],\"values\":[{\"value\":\"SD\",\"id\":1,\"displayText\":\"SD\"},{\"value\":\"HD\",\"id\":2,\"displayText\":\"HD\"}],\"selectedItem\":{\"value\":\"HD\",\"id\":2,\"displayText\":\"HD\"}},\"$$AttributeDefinitionEnd$$\":null}]}';
        sObjList.add(orderItem5);

        insert sObjList;
        sObjList.clear();

        // Create Pricing Plan
        vlocity_cmt__PricingPlan__c plan = new vlocity_cmt__PricingPlan__c(Name = 'Default Pricing Plan', vlocity_cmt__Code__c = 'DEFAULT_PRICING_PLAN', vlocity_cmt__IsActive__c = true);
        insert plan;

        //PricingPlanStep__c planStep11 = new PricingPlanStep__c(Name = 'Target Pricing Demo', ImplementationName__c = 'CustomPricingPlanStepImpl', IsActive__c = true, MethodName__c = 'GetMatrixPrice', Sequence__c = 101.0, PricingPlanId__c = plan.Id);
        //PricingPlanStep__c planStep12 = new PricingPlanStep__c(Name = 'Target Path Range Pricing Demo', ImplementationName__c = 'CustomPricingPlanStepImpl', IsActive__c = true, MethodName__c = 'GetMatrixPrice', Sequence__c = 102.0, PricingPlanId__c = plan.Id);
        vlocity_cmt__PricingPlanStep__c planStep13 = new vlocity_cmt__PricingPlanStep__c(Name = 'Target Path Pricing Demo', vlocity_cmt__ImplementationName__c = 'CustomPricingPlanStepImpl', vlocity_cmt__IsActive__c = true, vlocity_cmt__MethodName__c = 'GetMatrixPrice', vlocity_cmt__Sequence__c = 103.0, vlocity_cmt__PricingPlanId__c = plan.Id);
        //PricingPlanStep__c planStep14 = new PricingPlanStep__c(Name = 'Attribute Matrix Pricing Demo', ImplementationName__c = 'CustomPricingPlanStepImpl', IsActive__c = true, MethodName__c = 'GetMatrixPrice', Sequence__c = 104.0, PricingPlanId__c = plan.Id);

        //sObjList.add(planStep11);
        //sObjList.add(planStep12);
        sObjList.add(planStep13);
        //sObjList.add(planStep14);
        insert sObjList;
        sObjList.clear();

        // Create Time Plan and Policy
        vlocity_cmt__TimePlan__c timePlan1 = new vlocity_cmt__TimePlan__c(Name='1 Year Time Plan', vlocity_cmt__TotalDuration__c=1, vlocity_cmt__TotalDurationUoM__c='Year', vlocity_cmt__IsActive__c=True);
        vlocity_cmt__TimePlan__c timePlan2 = new vlocity_cmt__TimePlan__c(Name='6 Month Time Plan', vlocity_cmt__TotalDuration__c=6, vlocity_cmt__TotalDurationUoM__c='Month', vlocity_cmt__IsActive__c=True);
        sObjList.add(timePlan1);
        sObjList.add(timePlan2);
        insert sObjList;
        sObjList.clear();

        vlocity_cmt__TimePolicy__c timePolicy1 = new vlocity_cmt__TimePolicy__c(Name='Start Now End by Plan Duration', vlocity_cmt__StartTimePolicy__c='Purchase Date',vlocity_cmt__EndTimePolicy__c='End of Plan Duration', vlocity_cmt__IsActive__c=True);
        sObjList.add(timePolicy1);
        insert sObjList;
        sObjList.clear();

        loadPricingVariableMap();
    }

    static private void rangeABPWithDifferentQuantityMatrixSetup(){
        vlocity_cmt__TriggerSetup__c itemTrigger = new vlocity_cmt__TriggerSetup__c(Name='AllTriggers', vlocity_cmt__IsTriggerOn__c=true);
        insert itemTrigger;

        vlocity_cmt__CpqConfigurationSetup__c configSetup = new vlocity_cmt__CpqConfigurationSetup__c(Name = 'DeltaPrice', vlocity_cmt__SetupValue__c = 'True');
        insert configSetup;

        List<SObject> sObjList = new List<sObject>();
        Product2 prod1 = new Product2 (Name='RangeABP Product5913', ProductCode = 'RangeABP Product5913');
        sObjList.add(prod1);

        insert sObjList;
        sObjList.clear();


        Pricebook2 standardBook =  new Pricebook2(Id = Test.getStandardPricebookId(), Name = 'TestPricebook5', IsActive = true);
        Pricebook2 testPricebook = new Pricebook2(Name = 'TestPricebook7', IsActive = true);
        insert testPricebook;

        //Inserting into standard Pricebook
        PricebookEntry pbe11 = new PricebookEntry(Pricebook2Id = standardBook.Id,
                Product2Id = prod1.Id, UnitPrice = 10, vlocity_cmt__RecurringPrice__c = 5, IsActive = true);
        sObjList.add(pbe11);

        //Inserting into Custom Pricebook
        PricebookEntry pbe1 = new PricebookEntry(Pricebook2Id = testPricebook.Id,
                Product2Id = prod1.Id, UnitPrice = 10, vlocity_cmt__RecurringPrice__c = 5, IsActive = true, UseStandardPrice = false);
        sObjList.add(pbe1);

        insert sObjList;
        sObjList.clear();

        vlocity_cmt__PriceList__c pl1 = new vlocity_cmt__PriceList__c(vlocity_cmt__Pricebook2Id__c = testPricebook.Id, vlocity_cmt__IsActive__c = true, vlocity_cmt__Code__c = 'TestList');
        insert pl1;

        // Create Object Type
        SObject sObj = [SELECT Id, SobjectType, DeveloperName FROM RecordType WHERE IsActive = TRUE and SobjectType = 'vlocity_cmt__ObjectClass__c' and DeveloperName = 'ObjectType' LIMIT 1];
        vlocity_cmt__ObjectClass__c chargeObjType = new vlocity_cmt__ObjectClass__c(Name = 'Charge', vlocity_cmt__ObjectApiName__c = 'PricingElement__c', RecordTypeId = sObj.Id);
        vlocity_cmt__ObjectClass__c discObjType = new vlocity_cmt__ObjectClass__c(Name = 'Discount', vlocity_cmt__ObjectApiName__c = 'PricingElement__c', RecordTypeId = sObj.Id);

        sObjList.clear();
        sObjList.add(chargeObjType);
        sObjList.add(discObjType);
        insert sObjList;
        sObjList.clear();

        vlocity_cmt__PricingVariable__c oneTimeStdPriceVar = new vlocity_cmt__PricingVariable__c(Name = 'One Time Std Price', vlocity_cmt__Code__c = 'OT_STD_PRC',vlocity_cmt__Aggregation__c = 'Unit',
                vlocity_cmt__ChargeType__c='One-time',vlocity_cmt__IsActive__c = true,vlocity_cmt__Scope__c = 'Line',vlocity_cmt__SubType__c = 'Standard',vlocity_cmt__Type__c = 'Price',
                vlocity_cmt__ValueType__c='Pricing Element',vlocity_cmt__CurrencyType__c='Currency');
        sObjList.add(oneTimeStdPriceVar);

        vlocity_cmt__PricingVariable__c mrcPriceVar = new vlocity_cmt__PricingVariable__c(Name = 'Recurring Monthly Std Price', vlocity_cmt__Code__c = 'REC_MNTH_STD_PRC',vlocity_cmt__Aggregation__c = 'Unit',
                vlocity_cmt__ChargeType__c='Recurring', vlocity_cmt__RecurringFrequency__c ='Monthly',vlocity_cmt__IsActive__c = true,vlocity_cmt__Scope__c = 'Line',vlocity_cmt__SubType__c = 'Standard',vlocity_cmt__Type__c = 'Price',
                vlocity_cmt__ValueType__c='Pricing Element',vlocity_cmt__CurrencyType__c='Currency');
        sObjList.add(mrcPriceVar);
        insert sObjList;
        sObjList.clear();

        insert sObjList;

        // Create Pricing Element
        vlocity_cmt__PricingElement__c pElem1 = new vlocity_cmt__PricingElement__c(Name = 'One Time $100 Standalone Price', vlocity_cmt__ObjectTypeId__c = chargeObjType.Id, vlocity_cmt__Amount__c = 100.00,
                vlocity_cmt__Code__c = 'PELEM1', vlocity_cmt__EffectiveFromDate__c = Datetime.now(), vlocity_cmt__IsActive__c = true, vlocity_cmt__IsReusable__c = true, vlocity_cmt__PricingVariableId__c = oneTimeStdPriceVar.Id, vlocity_cmt__PriceListId__c = pl1.Id);
        vlocity_cmt__PricingElement__c pElem2 = new vlocity_cmt__PricingElement__c(Name = 'MRC $20 Standalone Price', vlocity_cmt__ObjectTypeId__c = chargeObjType.Id, vlocity_cmt__Amount__c = 20.00,
                vlocity_cmt__Code__c = 'PELEM2', vlocity_cmt__EffectiveFromDate__c = Datetime.now(), vlocity_cmt__IsActive__c = true, vlocity_cmt__IsReusable__c = true, vlocity_cmt__PricingVariableId__c = mrcPriceVar.Id, vlocity_cmt__PriceListId__c = pl1.Id);
        vlocity_cmt__PricingElement__c pElem4 = new vlocity_cmt__PricingElement__c(Name = 'One Time $400 Local Price', vlocity_cmt__ObjectTypeId__c = chargeObjType.Id, vlocity_cmt__Amount__c = 400.00,
                vlocity_cmt__Code__c = 'PELEM4', vlocity_cmt__EffectiveFromDate__c = Datetime.now(), vlocity_cmt__IsActive__c = true, vlocity_cmt__IsReusable__c = false, vlocity_cmt__PricingVariableId__c = oneTimeStdPriceVar.Id, vlocity_cmt__PriceListId__c = pl1.Id);
        vlocity_cmt__PricingElement__c pElem5 = new vlocity_cmt__PricingElement__c(Name = 'MRC $50 Local Price', vlocity_cmt__ObjectTypeId__c = chargeObjType.Id, vlocity_cmt__Amount__c = 50.00,
                vlocity_cmt__Code__c = 'PELEM5', vlocity_cmt__EffectiveFromDate__c = Datetime.now(), vlocity_cmt__IsActive__c = true, vlocity_cmt__IsReusable__c = false, vlocity_cmt__PricingVariableId__c = mrcPriceVar.Id, vlocity_cmt__PriceListId__c = pl1.Id);
        sObjList.clear();
        sObjList.add(pElem1);
        sObjList.add(pElem2);
        sObjList.add(pElem4);
        sObjList.add(pElem5);

        insert sObjList;
        sObjList.clear();


        List<vlocity_cmt__PricingElement__c> pricingElement = [SELECT Id, Name FROM vlocity_cmt__PricingElement__c];
        vlocity_cmt__PriceListEntry__c ple1 = new vlocity_cmt__PriceListEntry__c(vlocity_cmt__PriceListId__c=pl1.Id, vlocity_cmt__ProductId__c=prod1.Id, vlocity_cmt__PricingElementId__c = pElem1.Id, vlocity_cmt__EffectiveFromDate__c=Datetime.now(), vlocity_cmt__IsActive__c=true);
        sObjList.add(ple1);

        insert sObjList;
        sObjList.clear();

        //Creating PricingVariableBinding
        vlocity_cmt__PricingVariableBinding__c pvb1 = new vlocity_cmt__PricingVariableBinding__c(Name='One Time Std Price - OrderItem',vlocity_cmt__DestinationSObjectType__c='OrderItem',
                vlocity_cmt__DestinationFieldApiName__c = 'vlocity_cmt__OneTimeCharge__c', vlocity_cmt__PricingVariableId__c = oneTimeStdPriceVar.Id);
        sObjList.add(pvb1);
        vlocity_cmt__PricingVariableBinding__c pvb2 = new vlocity_cmt__PricingVariableBinding__c(Name='Recurring Monthly Std Price - OrderItem',vlocity_cmt__DestinationSObjectType__c='OrderItem',
                vlocity_cmt__DestinationFieldApiName__c = 'vlocity_cmt__RecurringCharge__c', vlocity_cmt__PricingVariableId__c = mrcPriceVar.Id);
        sObjList.add(pvb2);

        insert sObjList;
        sObjList.clear();

        Account a = new Account(Name='Account Test');
        insert a;

        vlocity_cmt__InterfaceImplementation__c iit1 = new vlocity_cmt__InterfaceImplementation__c (Name='PricingInterface');
        insert iit1;
        vlocity_cmt__InterfaceImplementationDetail__c iid1 = new vlocity_cmt__InterfaceImplementationDetail__c (Name = 'PricingPlanService',
                vlocity_cmt__InterfaceId__c=iit1.Id, vlocity_cmt__IsActive__c=true);
        insert iid1;

        vlocity_cmt__InterfaceImplementation__c intImpl = new vlocity_cmt__InterfaceImplementation__c (Name='TightestMatchInterface');
        insert intImpl;

        // vlocity_cmt__InterfaceImplementationDetail__c iit004_001 = new vlocity_cmt__InterfaceImplementationDetail__c
        //         (Name = 'TightestMatchServiceImplementation', vlocity_cmt__InterfaceId__c=intImpl.Id, vlocity_cmt__IsDefault__c=true,vlocity_cmt__IsActive__c=true);
        // insert iit004_001;

        vlocity_cmt__TriggerSetup__c myTrigger = new vlocity_cmt__TriggerSetup__c(Name='AllTriggers', vlocity_cmt__IsTriggerOn__c=true);
        insert myTrigger;
        vlocity_cmt__InterfaceImplementation__c iit = new vlocity_cmt__InterfaceImplementation__c (Name='ContextRuleService');
        insert iit;
        List<vlocity_cmt__InterfaceImplementationDetail__c> iidList = new List<vlocity_cmt__InterfaceImplementationDetail__c> ();
        vlocity_cmt__InterfaceImplementationDetail__c iit_001 = new vlocity_cmt__InterfaceImplementationDetail__c  (Name = 'ContextRuleService', vlocity_cmt__InterfaceId__c=iit.Id, vlocity_cmt__IsDefault__c=true,vlocity_cmt__IsActive__c=true);

        iidList.add(iit_001);
        insert iidList;


        Order testOrder = new Order(Name='Test Order',EffectiveDate=System.today(),status='Draft',AccountId = a.Id, vlocity_cmt__PriceListId__c = pl1.Id, Pricebook2Id = testPricebook.Id);
        insert testOrder;
        orderId = testOrder.Id;

        List<priceBookEntry> priceBookEntry = [SELECT Id FROM PricebookEntry WHERE Product2Id =: prod1.Id];
        Id priceBookEntryId = priceBookEntry[0].Id;

        //String jsonAttr = '{\"ea0557fa-f6c7-ec3e-0ce5-a09db41d6294\":[{\"$$AttributeDefinitionStart$$\":null,\"objectid__c\":\"01tf4000002X3yxAAC\",\"attributeid__c\":\"a09f4000002cHyrAAE\",\"attributecategoryid__c\":\"a08f4000008OiNGAA0\",\"categorycode__c\":\"ea0557fa-f6c7-ec3e-0ce5-a09db41d6294\",\"categoryname__c\":\"Internet Services 2\",\"attributeuniquecode__c\":\"Capacity\",\"attributeconfigurable__c\":true,\"attributedisplaysequence__c\":\"2\",\"attributefilterable__c\":true,\"attributecloneable__c\":true,\"isactive__c\":true,\"attributedisplayname__c\":\"Capacity\",\"displaysequence__c\":\"null\",\"categorydisplaysequence__c\":2,\"customconfiguitemplate__c\":null,\"formatmask__c\":null,\"hasrule__c\":false,\"isconfigurable__c\":false,\"ishidden__c\":false,\"valueinnumber__c\":null,\"objecttype__c\":\"Product2\",\"querycode__c\":null,\"isreadonly__c\":false,\"isnottranslatable__c\":false,\"isquerydriven__c\":false,\"querylabel__c\":null,\"id\":\"a1ff4000000rnfCAAQ\",\"isrequired__c\":false,\"rulemessage__c\":null,\"uidisplaytype__c\":\"Dropdown\",\"value__c\":\"2Mbps\",\"valuedatatype__c\":\"Picklist\",\"valuedescription__c\":null,\"attributeRunTimeInfo\":{\"dataType\":\"Picklist\",\"uiDisplayType\":\"Dropdown\",\"default\":[{\"value\":\"64Mbps\",\"id\":4,\"displayText\":\"64Mbps\"}],\"values\":[{\"value\":\"64Mbps\",\"id\":4,\"displayText\":\"64Mbps\"},{\"value\":\"128Mbps\",\"id\":7,\"displayText\":\"128Mbps\"}],\"selectedItem\":{\"value\":\"64Mbps\",\"id\":4,\"displayText\":\"64Mbps\"}},\"$$AttributeDefinitionEnd$$\":null}]}';
        //Changed from Mbps to GB
        String jsonAttrWithGB = '{\"ea0557fa-f6c7-ec3e-0ce5-a09db41d6294\":[{\"$$AttributeDefinitionStart$$\":null,\"objectid__c\":\"01tf4000002X3yxAAC\",\"attributeid__c\":\"a09f4000002cHyrAAE\",\"attributecategoryid__c\":\"a08f4000008OiNGAA0\",\"categorycode__c\":\"ea0557fa-f6c7-ec3e-0ce5-a09db41d6294\",\"categoryname__c\":\"Internet Services 2\",\"attributeuniquecode__c\":\"Capacity\",\"attributeconfigurable__c\":true,\"attributedisplaysequence__c\":\"2\",\"attributefilterable__c\":true,\"attributecloneable__c\":true,\"isactive__c\":true,\"attributedisplayname__c\":\"Capacity\",\"displaysequence__c\":\"null\",\"categorydisplaysequence__c\":2,\"customconfiguitemplate__c\":null,\"formatmask__c\":null,\"hasrule__c\":false,\"isconfigurable__c\":false,\"ishidden__c\":false,\"valueinnumber__c\":null,\"objecttype__c\":\"Product2\",\"querycode__c\":null,\"isreadonly__c\":false,\"isnottranslatable__c\":false,\"isquerydriven__c\":false,\"querylabel__c\":null,\"id\":\"a1ff4000000rnfCAAQ\",\"isrequired__c\":false,\"rulemessage__c\":null,\"uidisplaytype__c\":\"Dropdown\",\"value__c\":\"2GB\",\"valuedatatype__c\":\"Picklist\",\"valuedescription__c\":null,\"attributeRunTimeInfo\":{\"dataType\":\"Picklist\",\"uiDisplayType\":\"Dropdown\",\"default\":[{\"value\":\"64GB\",\"id\":4,\"displayText\":\"64GB\"}],\"values\":[{\"value\":\"64GB\",\"id\":4,\"displayText\":\"64GB\"},{\"value\":\"128GB\",\"id\":7,\"displayText\":\"128GB\"}],\"selectedItem\":{\"value\":\"64GB\",\"id\":4,\"displayText\":\"64GB\"}},\"$$AttributeDefinitionEnd$$\":null}]}';

        //String jsonAttr = '{"INTERNET-CAT1":[{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t46000003GrttAAC","attributeid__c":"a1S46000000O2g0EAC","attributecategoryid__c":"a1R46000000ths0EAA","categorycode__c":"INTERNET-CAT1","categoryname__c":"Internet","attributeuniquecode__c":"Capacity","attributeconfigurable__c":true,"attributedisplaysequence__c":"1","attributefilterable__c":true,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Capacity","displaysequence__c":"null","categorydisplaysequence__c":1,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":true,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a1Q46000000RhwwEAC","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Dropdown","value__c":"16Mbps","valuedatatype__c":"Picklist","valuedescription__c":null,"attributeRunTimeInfo":{"dataType":"Picklist","uiDisplayType":"Dropdown","default":[{"value":"64Mbps","id":4,"displayText":"64Mbps"}],"values":[{"value":"64Mbps","id":4,"displayText":"64Mbps"},{"value":"128Mbps","id":7,"displayText":"128Mbps"},],"selectedItem":{"value":"64Mbps","id":4,"displayText":"64Mbps"}},"$$AttributeDefinitionEnd$$":null}]}';
        //OrderItem Name : RangeABP Product5913
        //Attributes : Capacity  ......  SelectedItem : 64GB
        OrderItem orderItem3 = new OrderItem();
        orderItem3.OrderId = testOrder.Id;
        orderItem3.PricebookEntryId = pbe1.Id;
        orderItem3.Quantity = 5.0;
        orderItem3.vlocity_cmt__LineNumber__c = '0001';
        orderItem3.UnitPrice = 100;
        orderItem3.vlocity_cmt__ProvisioningStatus__c = 'New';
        //orderItem3.vlocity_cmt__JSONAttribute__c= '{\"INTERNET-CAT1\":[{\"$$AttributeDefinitionStart$$\":null,\"objectid__c\":\"01t46000003GrttAAC\",\"attributeid__c\":\"a1S46000000O2fqEAC\",\"attributecategoryid__c\":\"a1R46000000ths0EAA\",\"categorycode__c\":\"INTERNET-CAT1\",\"categoryname__c\":\"Internet\",\"attributeuniquecode__c\":\"ATTRIBUTE-1200\",\"attributeconfigurable__c\":true,\"attributedisplaysequence__c\":\"1\",\"attributefilterable__c\":true,\"attributecloneable__c\":true,\"isactive__c\":true,\"attributedisplayname__c\":\"Internet Download Speed\",\"displaysequence__c\":\"null\",\"categorydisplaysequence__c\":1,\"customconfiguitemplate__c\":null,\"formatmask__c\":null,\"hasrule__c\":false,\"isconfigurable__c\":true,\"ishidden__c\":false,\"valueinnumber__c\":null,\"objecttype__c\":\"Product2\",\"querycode__c\":null,\"isreadonly__c\":false,\"isquerydriven__c\":false,\"querylabel__c\":null,\"id\":\"a1Q46000000RhwvEAC\",\"isrequired__c\":false,\"rulemessage__c\":null,\"uidisplaytype__c\":\"Dropdown\",\"value__c\":\"80Mbps\",\"valuedatatype__c\":\"Picklist\",\"valuedescription__c\":null,\"attributeRunTimeInfo\":{\"dataType\":\"Picklist\",\"uiDisplayType\":\"Dropdown\",\"default\":[{\"value\":\"80Mbps\",\"id\":8,\"displayText\":\"80Mbps\"}],\"values\":[{\"value\":\"20Mbps\",\"id\":2,\"displayText\":\"20Mbps\"},{\"value\":\"100Mbps\",\"id\":10,\"displayText\":\"100Mbps\"},{\"value\":\"60Mbps\",\"id\":6,\"displayText\":\"60Mbps\"},{\"value\":\"40Mbps\",\"id\":4,\"displayText\":\"40Mbps\"},{\"value\":\"90Mbps\",\"id\":9,\"displayText\":\"90Mbps\"},{\"value\":\"50Mbps\",\"id\":5,\"displayText\":\"50Mbps\"},{\"value\":\"10Mbps\",\"id\":1,\"displayText\":\"10Mbps\"},{\"value\":\"30Mbps\",\"id\":3,\"displayText\":\"30Mbps\"},{\"value\":\"80Mbps\",\"id\":8,\"displayText\":\"80Mbps\"},{\"value\":\"70Mbps\",\"id\":7,\"displayText\":\"70Mbps\"}],\"selectedItem\":{\"value\":\"80Mbps\",\"id\":8,\"displayText\":\"80Mbps\"}},\"$$AttributeDefinitionEnd$$\":null},{\"$$AttributeDefinitionStart$$\":null,\"objectid__c\":\"01t46000003GrttAAC\",\"attributeid__c\":\"a1S46000000O2g0EAC\",\"attributecategoryid__c\":\"a1R46000000ths0EAA\",\"categorycode__c\":\"INTERNET-CAT1\",\"categoryname__c\":\"Internet\",\"attributeuniquecode__c\":\"ATTRIBUTE-1270\",\"attributeconfigurable__c\":true,\"attributedisplaysequence__c\":\"1\",\"attributefilterable__c\":true,\"attributecloneable__c\":true,\"isactive__c\":true,\"attributedisplayname__c\":\"Internet Upload Speed\",\"displaysequence__c\":\"null\",\"categorydisplaysequence__c\":1,\"customconfiguitemplate__c\":null,\"formatmask__c\":null,\"hasrule__c\":false,\"isconfigurable__c\":true,\"ishidden__c\":false,\"valueinnumber__c\":null,\"objecttype__c\":\"Product2\",\"querycode__c\":null,\"isreadonly__c\":false,\"isquerydriven__c\":false,\"querylabel__c\":null,\"id\":\"a1Q46000000RhwwEAC\",\"isrequired__c\":false,\"rulemessage__c\":null,\"uidisplaytype__c\":\"Dropdown\",\"value__c\":\"16Mbps\",\"valuedatatype__c\":\"Picklist\",\"valuedescription__c\":null,\"attributeRunTimeInfo\":{\"dataType\":\"Picklist\",\"uiDisplayType\":\"Dropdown\",\"default\":[{\"value\":\"16Mbps\",\"id\":8,\"displayText\":\"16Mbps\"}],\"values\":[{\"value\":\"8Mbps\",\"id\":4,\"displayText\":\"8Mbps\"},{\"value\":\"14Mbps\",\"id\":7,\"displayText\":\"14Mbps\"},{\"value\":\"12Mbps\",\"id\":6,\"displayText\":\"12Mbps\"},{\"value\":\"4Mbps\",\"id\":2,\"displayText\":\"4Mbps\"},{\"value\":\"18Mbps\",\"id\":9,\"displayText\":\"18Mbps\"},{\"value\":\"6Mbps\",\"id\":3,\"displayText\":\"6Mbps\"},{\"value\":\"2Mbps\",\"id\":1,\"displayText\":\"2Mbps\"},{\"value\":\"16Mbps\",\"id\":8,\"displayText\":\"16Mbps\"},{\"value\":\"10Mbps\",\"id\":5,\"displayText\":\"10Mbps\"},{\"value\":\"20Mbps\",\"id\":10,\"displayText\":\"20Mbps\"}],\"selectedItem\":{\"value\":\"16Mbps\",\"id\":8,\"displayText\":\"16Mbps\"}},\"$$AttributeDefinitionEnd$$\":null}]}';
        orderItem3.vlocity_cmt__JSONAttribute__c = jsonAttrWithGB;
        sObjList.add(orderItem3);

        insert sObjList;
        sObjList.clear();

        // Create Pricing Plan
        vlocity_cmt__PricingPlan__c plan = new vlocity_cmt__PricingPlan__c(Name = 'Default Pricing Plan', vlocity_cmt__Code__c = 'DEFAULT_PRICING_PLAN', vlocity_cmt__IsActive__c = true);
        insert plan;

        //Create PricingPlanSetp
        vlocity_cmt__PricingPlanStep__c planStep = new vlocity_cmt__PricingPlanStep__c(Name = 'Range Based ABP', vlocity_cmt__ImplementationName__c = 'CustomPricingPlanStepImpl', vlocity_cmt__IsActive__c = true, vlocity_cmt__MethodName__c = 'GetMatrixPrice', vlocity_cmt__Sequence__c = 103.0, vlocity_cmt__PricingPlanId__c = plan.Id);
        sObjList.add(planStep);
        insert sObjList;
        sObjList.clear();

        insert new vlocity_cmt__TriggerSetup__c(Name = 'AllTriggers', vlocity_cmt__IsTriggerOn__c = true);
        parent = new vlocity_cmt__CalculationMatrix__c(Name = 'RangeAttributePricingMatrix');
        insert parent;

        version = new vlocity_cmt__CalculationMatrixVersion__c(Name = 'RangeAttributePricingMatrix v2', vlocity_cmt__VersionNumber__c = 2,
                vlocity_cmt__IsEnabled__c = false, vlocity_cmt__CalculationMatrixId__c = parent.Id,
                vlocity_cmt__StartDateTime__c = DateTime.now().addDays(-10), vlocity_cmt__EndDateTime__c = DateTime.now().addDays(10),vlocity_cmt__Priority__c = 1);
        insert version;

        //Populating Headers
        lineItems = new List<vlocity_cmt__CalculationMatrixRow__c>();
        lineItems.add(new vlocity_cmt__CalculationMatrixRow__c(vlocity_cmt__CalculationMatrixVersionId__c = version.Id, Name = 'Header',
                vlocity_cmt__InputData__c ='{\"name\":\"Source Product Name\",\"listValues\":null,\"lineItemId\":\"a1Wf4000004FkU6EAK\",\"label\":null,\"headerType\":\"Input\",\"displayOrder\":1,\"dataType\":\"Text\",\"columnKey\":\"13c541\"}'
        ));
        lineItems.add(new vlocity_cmt__CalculationMatrixRow__c(vlocity_cmt__CalculationMatrixVersionId__c = version.Id, Name = 'Header',
                vlocity_cmt__InputData__c ='{\"name\":\"Source Product Code\",\"listValues\":null,\"lineItemId\":\"a1Wf4000004FkU7EAK\",\"label\":null,\"headerType\":\"Input\",\"displayOrder\":2,\"dataType\":\"Text\",\"columnKey\":\"3a0611\"}'
        ));
        lineItems.add(new vlocity_cmt__CalculationMatrixRow__c(vlocity_cmt__CalculationMatrixVersionId__c = version.Id, Name = 'Header',
                vlocity_cmt__InputData__c ='{\"name\":\"Characteristic Name\",\"listValues\":null,\"lineItemId\":\"a1Wf4000004FkU8EAK\",\"label\":null,\"headerType\":\"Input\",\"displayOrder\":3,\"dataType\":\"Text\",\"columnKey\":\"26ee5f\"}'
        ));
        lineItems.add(new vlocity_cmt__CalculationMatrixRow__c(vlocity_cmt__CalculationMatrixVersionId__c = version.Id, Name = 'Header',
                vlocity_cmt__InputData__c ='{\"name\":\"Characteristic Value\",\"listValues\":null,\"lineItemId\":\"a1Wf4000004FkU9EAK\",\"label\":null,\"headerType\":\"Input\",\"displayOrder\":4,\"dataType\":\"Text\",\"columnKey\":\"2a0cd2\"}'
        ));
        lineItems.add(new vlocity_cmt__CalculationMatrixRow__c(vlocity_cmt__CalculationMatrixVersionId__c = version.Id, Name = 'Header',
                vlocity_cmt__InputData__c ='{\"name\":\"Quantity\",\"listValues\":null,\"lineItemId\":\"a1Wf4000004FkUAEA0\",\"label\":null,\"headerType\":\"Input\",\"displayOrder\":5,\"dataType\":\"Text\",\"columnKey\":\"bd81e8\"}'
        ));
        lineItems.add(new vlocity_cmt__CalculationMatrixRow__c(vlocity_cmt__CalculationMatrixVersionId__c = version.Id, Name = 'Header',
                vlocity_cmt__InputData__c ='{\"name\":\"MRC\",\"listValues\":null,\"lineItemId\":\"a1Wf4000004FkUBEA0\",\"label\":null,\"headerType\":\"Output\",\"displayOrder\":6,\"dataType\":\"Text\",\"columnKey\":\"7cdae9\"}'
        ));
        lineItems.add(new vlocity_cmt__CalculationMatrixRow__c(vlocity_cmt__CalculationMatrixVersionId__c = version.Id, Name = 'Header',
                vlocity_cmt__InputData__c ='{\"name\":\"NRC\",\"listValues\":null,\"lineItemId\":\"a1Wf4000004FkU5EAK\",\"label\":null,\"headerType\":\"Output\",\"displayOrder\":7,\"dataType\":\"Text\",\"columnKey\":\"7cea71\"}'
        ));
        insert lineItems;


        //Populating Row Data
        lineItems = new List<vlocity_cmt__CalculationMatrixRow__c>();
        lineItems.add(new vlocity_cmt__CalculationMatrixRow__c(vlocity_cmt__CalculationMatrixVersionId__c = version.Id,
                vlocity_cmt__InputData__c ='{\"Quantity\" : \"3-8\",\"Characteristic Value\" : \"64GB\",\"Characteristic Name\" : \"Capacity\",\"Source Product Code\" : \"RangeABP Product5913\",\"Source Product Name\" : \"RangeABP Product5913\"}',
                vlocity_cmt__OutputData__c = '{ \"NRC\" : \"20\", \"MRC\" : \"10\" }',
                Name = '601b431b49323bff311431297909e578'
        ));
        lineItems.add(new vlocity_cmt__CalculationMatrixRow__c(vlocity_cmt__CalculationMatrixVersionId__c = version.Id,
                vlocity_cmt__InputData__c ='{\"Quantity\" : \"1-2\",\"Characteristic Value\" : \"64GB\",\"Characteristic Name\" : \"Capacity\",\"Source Product Code\" : \"RangeABP Product5913\",\"Source Product Name\" : \"RangeABP Product5913\"}',
                vlocity_cmt__OutputData__c = '{ \"NRC\" : \"10\", \"MRC\" : \"10\" }',
                Name  = 'f98e91b68697aedee136f5ce74c7ab15'
        ));
        lineItems.add(new vlocity_cmt__CalculationMatrixRow__c(vlocity_cmt__CalculationMatrixVersionId__c = version.Id,
                vlocity_cmt__InputData__c ='{\"Quantity\" : \"1-4\",\"Characteristic Value\" : \"128GB\",\"Characteristic Name\" : \"Capacity\",\"Source Product Code\" : \"RangeABP Product5913\",\"Source Product Name\" : \"RangeABP Product5913\"}',
                vlocity_cmt__OutputData__c = '{ \"NRC\" : \"40\", \"MRC\" : \"10\" }',
                Name = 'a39a02535a8372d9d89e9a0a83d8b673'
        ));
        lineItems.add(new vlocity_cmt__CalculationMatrixRow__c(vlocity_cmt__CalculationMatrixVersionId__c = version.Id,
                vlocity_cmt__InputData__c ='{\"Quantity\" : \"5-15\",\"Characteristic Value\" : \"128GB\",\"Characteristic Name\" : \"Capacity\",\"Source Product Code\" : \"RangeABP Product5913\",\"Source Product Name\" : \"RangeABP Product5913\"}',
                vlocity_cmt__OutputData__c = '{ \"NRC\" : \"50\", \"MRC\" : \"10\" }',
                    Name = 'cfd95f99ac97cb146f1803c15267212d'
        ));
        insert lineItems;

        lineItems = [SELECT Name, vlocity_cmt__InputData__c, vlocity_cmt__OutputData__c FROM vlocity_cmt__CalculationMatrixRow__c WHERE Name != 'Header'];
        update new vlocity_cmt__CalculationMatrixVersion__c(Id = version.Id, vlocity_cmt__IsEnabled__c = true);

        //service
        vlocity_cmt__CalculationProcedure__c calcProcedure = new vlocity_cmt__CalculationProcedure__c(Name='RangeAttributePricingProcedure');
        insert calcProcedure;

        //Making isEnabled = false due to ERROR="Please add steps before enabling this procedure configuration."
        vlocity_cmt__CalculationProcedureVersion__c procVersion = new vlocity_cmt__CalculationProcedureVersion__c(Name='RangeAttributePricingProcedure v2', vlocity_cmt__VersionNumber__c=2, vlocity_cmt__IsEnabled__c=false,
                vlocity_cmt__CalculationProcedureId__c=calcProcedure.Id, vlocity_cmt__StartDateTime__c = DateTime.now().addDays(-5), vlocity_cmt__EndDateTime__c = DateTime.now().addDays(5), vlocity_cmt__Priority__c=1);
        insert procVersion;

        List<vlocity_cmt__CalculationProcedureStep__c> steps = new List<vlocity_cmt__CalculationProcedureStep__c> ();
        vlocity_cmt__CalculationProcedureStep__c step1 = new vlocity_cmt__CalculationProcedureStep__c (Name='a1L46000001ASQm', vlocity_cmt__Sequence__c=1,vlocity_cmt__Function__c='Matrix Lookup', vlocity_cmt__CalculationMatrixId__c=parent.Id, vlocity_cmt__IsIncludedInResult__c=true, vlocity_cmt__CalculationProcedureVersionId__c= procVersion.Id,
                vlocity_cmt__Input__c='[{\"name\":\"Source Product Name\",\"listValues\":null,\"label\":null,\"dataType\":\"Text\",\"columnKey\":\"dea1b0\"},{\"name\":\"Source Product Code\",\"listValues\":null,\"label\":null,\"dataType\":\"Text\",\"columnKey\":\"15e771\"},{\"name\":\"Characteristic Name\",\"listValues\":null,\"label\":null,\"dataType\":\"Text\",\"columnKey\":\"a81456\"},{\"name\":\"Characteristic Value\",\"listValues\":null,\"label\":null,\"dataType\":\"Text\",\"columnKey\":\"880c2d\"},{\"name\":\"Quantity\",\"listValues\":null,\"label\":null,\"dataType\":\"Text\",\"columnKey\":\"94bbbe\"}]',
                vlocity_cmt__OutputMappingJSON__c ='{\"MRC\":\"RangeWithDifferentQuantityPricing__MRC\",\"NRC\":\"RangeWithDifferentQuantityPricing__NRC\"}',
                vlocity_cmt__OutputJSON__c='[{\"name\":\"MRC\",\"listValues\":null,\"label\":null,\"dataType\":\"Text\",\"columnKey\":\"7776f5\"},{\"name\":\"NRC\",\"listValues\":null,\"label\":null,\"dataType\":\"Text\",\"columnKey\":\"ac5769\"}]');
        vlocity_cmt__CalculationProcedureStep__c step2 = new vlocity_cmt__CalculationProcedureStep__c (Name='a1L46000001ASQn', vlocity_cmt__Sequence__c=2,vlocity_cmt__Function__c='Calculation', vlocity_cmt__IsIncludedInResult__c=true, vlocity_cmt__CalculationProcedureVersionId__c= procVersion.Id,
                vlocity_cmt__CalculationFormulaLong__c='RangeWithDifferentQuantityPricing__MRC', vlocity_cmt__OutputJSON__c='{\"name\":\"REC_MNTH_STD_PRC\",\"dataType\":\"Currency\",\"alias\":\"REC_MNTH_STD_PRC\"}',
                vlocity_cmt__OutputMappingJSON__c = '{\"REC_MNTH_STD_PRC\":\"REC_MNTH_STD_PRC\"}',
                vlocity_cmt__CalculationFormulaTags__c='[{\"text\":\"MRC ( RangeAttributePricingMatrix )\",\"alias\":\"RangeWithDifferentQuantityPricing__MRC\",\"userDefined\":false,\"dataType\":\"Text\"}]');
        vlocity_cmt__CalculationProcedureStep__c step3 = new vlocity_cmt__CalculationProcedureStep__c (Name='a1L46000001ASQo', vlocity_cmt__Sequence__c=3,vlocity_cmt__Function__c='Calculation', vlocity_cmt__IsIncludedInResult__c=true, vlocity_cmt__CalculationProcedureVersionId__c= procVersion.Id,
                vlocity_cmt__CalculationFormulaLong__c='RangeWithDifferentQuantityPricing__NRC', vlocity_cmt__OutputJSON__c='{\"name\":\"OT_STD_PRC\",\"dataType\":\"Currency\",\"alias\":\"OT_STD_PRC\"}',
                vlocity_cmt__OutputMappingJSON__c = '{\"OT_STD_PRC\":\"OT_STD_PRC\"}',
                vlocity_cmt__CalculationFormulaTags__c='[{\"text\":\"MRC ( RangeAttributePricingMatrix )\",\"alias\":\"RangeWithDifferentQuantityPricing__NRC\",\"userDefined\":false,\"dataType\":\"Text\"}]' );
        steps.add(step1);
        steps.add(step2);
        steps.add(step3);
        insert steps;

        List<vlocity_cmt__CalculationProcedureVariable__c> calcProcVariableList = new List<vlocity_cmt__CalculationProcedureVariable__c>{
                new vlocity_cmt__CalculationProcedureVariable__c(name='REC_MNTH_STD_PRC',vlocity_cmt__alias__c='REC_MNTH_STD_PRC',vlocity_cmt__datatype__c='Currency',vlocity_cmt__CalculationProcedureVersionId__c=procVersion.Id),
                new vlocity_cmt__CalculationProcedureVariable__c(name='OT_STD_PRC',vlocity_cmt__alias__c='OT_STD_PRC',vlocity_cmt__datatype__c='Currency',vlocity_cmt__CalculationProcedureVersionId__c=procVersion.Id),
                new vlocity_cmt__CalculationProcedureVariable__c(name='Source Product Name',vlocity_cmt__alias__c='SourceProductName',vlocity_cmt__datatype__c='Text',vlocity_cmt__CalculationProcedureVersionId__c=procVersion.Id),
                new vlocity_cmt__CalculationProcedureVariable__c(name='Source Product Code',vlocity_cmt__alias__c='SourceProductCode',vlocity_cmt__datatype__c='Text',vlocity_cmt__CalculationProcedureVersionId__c=procVersion.Id),
                new vlocity_cmt__CalculationProcedureVariable__c(name='Characteristic Name',vlocity_cmt__alias__c='CharacteristicName',vlocity_cmt__datatype__c='Text',vlocity_cmt__CalculationProcedureVersionId__c=procVersion.Id),
                new vlocity_cmt__CalculationProcedureVariable__c(name='Characteristic Value',vlocity_cmt__alias__c='CharacteristicValue',vlocity_cmt__datatype__c='Text',vlocity_cmt__CalculationProcedureVersionId__c=procVersion.Id),
                new vlocity_cmt__CalculationProcedureVariable__c(name='Quantity',vlocity_cmt__alias__c='Quantity',vlocity_cmt__datatype__c='Text',vlocity_cmt__CalculationProcedureVersionId__c=procVersion.Id),
                new vlocity_cmt__CalculationProcedureVariable__c(name='MRC',vlocity_cmt__alias__c='RangeAttributePricingMatrix__NRC',vlocity_cmt__datatype__c='Text',vlocity_cmt__CalculationProcedureVersionId__c=procVersion.Id),
                new vlocity_cmt__CalculationProcedureVariable__c(name='NRC',vlocity_cmt__alias__c='RangeAttributePricingMatrix__MRC',vlocity_cmt__datatype__c='Text',vlocity_cmt__CalculationProcedureVersionId__c=procVersion.Id)
                };
        insert calcProcVariableList;

        //Creating and enabling CalculationProcedureVersion
        update new vlocity_cmt__CalculationProcedureVersion__c(Id = procVersion.Id, vlocity_cmt__IsEnabled__c = true);

        loadPricingVariableMap();
    }

    static private void loadPricingVariableMap() {
        String query = 'SELECT Id, Name, vlocity_cmt__IsActive__c, vlocity_cmt__ChargeType__c, ';
        query += 'vlocity_cmt__Code__c, vlocity_cmt__CurrencyType__c, vlocity_cmt__RecurringFrequency__c, vlocity_cmt__Scope__c, vlocity_cmt__SubType__c, vlocity_cmt__Type__c, vlocity_cmt__ValueType__c, (SELECT Id, Name, vlocity_cmt__DestinationFieldApiName__c, ';
        query += 'vlocity_cmt__DestinationSObjectType__c, vlocity_cmt__PricingVariableId__c FROM vlocity_cmt__PricingVariableBindings__r) FROM vlocity_cmt__PricingVariable__c WHERE vlocity_cmt__IsActive__c = true';

        pricingVariableByCodeMap = new Map<String, vlocity_cmt__PricingVariable__c>();
        for (vlocity_cmt__PricingVariable__c pVar : Database.query(query)) {
                pricingVariableByCodeMap.put(pVar.vlocity_cmt__Code__c, pVar);
        }
    }

    /*
    JIRA ticket : CMT-5913
    Input : "RangeABP Product5913" order Item which has "Capacity"  ......  Selected : "64 GB" with Quantity 5
    Output : MRC 10 and NRC 20
    */
    static private testmethod void rangeABPWithDifferentQuantityRanges(){
        Map<String, Object> output = new Map<String, Object>();
        Map<String, Object> options = new Map<String,Object>();
        Map<String, Object> input = new Map<String, Object>();

        rangeABPWithDifferentQuantityMatrixSetup();

        sObject orderSObject = [SELECT Id FROM Order WHERE Id = :orderId];
        List<SObject> orderItemList = [SELECT   Id, PricebookEntryId, PricebookEntry.Product2.Name, PricebookEntry.Product2.ProductCode, Quantity,
                vlocity_cmt__PricingLogData__c, vlocity_cmt__ProvisioningStatus__c, vlocity_cmt__RecurringCharge__c,
                vlocity_cmt__OneTimeCharge__c, vlocity_cmt__JSONAttribute__c,vlocity_cmt__LineNumber__c,vlocity_cmt__Action__c, vlocity_cmt__SupplementalAction__c
                FROM OrderItem WHERE OrderId = :orderId];

        vlocity_cmt.PricingPlanService.putInPricingContext('Parent', orderSObject);
        vlocity_cmt.PricingPlanService.putInPricingContext('LineItemList', orderItemList);
        vlocity_cmt.PricingPlanService.putInPricingContext('PricingVariableDefinitionsMap', pricingVariableByCodeMap);

        input.put('ProcedureName','RangeAttributePricingProcedure');
        input.put('MatrixName','RangeAttributePricingMatrix');
        input.put('RangeFields','Quantity');
        input.put('UseDisplayTextForValues','true');
        input.put('IncludeAttrInfoInRangeKeys','true');

        Test.startTest();
        CustomPricingPlanStepImpl testing = new CustomPricingPlanStepImpl();
        testing.invokeMethod('GetMatrixPrice', input, output, options);

        Boolean assertExecuted = false;
        for(SObject orderItem : orderItemList){
            if(orderItem.get('vlocity_cmt__RecurringCharge__c')!=null)
            {
                System.assert(orderItem.get('vlocity_cmt__RecurringCharge__c') == 10.00 );
                System.assert(orderItem.get('vlocity_cmt__OneTimeCharge__c') == 20.00 );
                assertExecuted = true;
                break;
            }
        }
        System.assert(assertExecuted);
        Test.stopTest();
    }

    static private testmethod void testABPUsingBPOs()
    {

        Map<String, Object> output = new Map<String, Object>();
        Map<String, Object> options = new Map<String,Object>();
        Map<String, Object> input = new Map<String, Object>();
        flag = false;

        try
        {
                SObject calculationMatrixBPO = (SObject)Type.forName('CalculationMatrix').newInstance();
        }
        catch(Exception ex)
        {
                return;
        }


        Test.startTest();
        testProductSetup();
        testMatrixSetupUsingBPOs();

        sObject targetProduct = [SELECT Id, Name FROM Product2 WHERE Name = 'HD TV'];
        sObject orderSObject = [SELECT Id FROM Order WHERE Id = :orderId];
        List<SObject> orderItemList = [SELECT   Id, PricebookEntryId, PricebookEntry.Product2.Name, PricebookEntry.Product2.ProductCode, Quantity,
                vlocity_cmt__PricingLogData__c, vlocity_cmt__ProvisioningStatus__c, vlocity_cmt__RecurringCharge__c,
                vlocity_cmt__OneTimeCharge__c, vlocity_cmt__JSONAttribute__c,vlocity_cmt__LineNumber__c
                FROM OrderItem WHERE OrderId = :orderId];

        vlocity_cmt.PricingPlanService.putInPricingContext('Parent', orderSObject);
        vlocity_cmt.PricingPlanService.putInPricingContext('LineItemList', orderItemList);
        vlocity_cmt.PricingPlanService.putInPricingContext('PricingVariableDefinitionsMap', pricingVariableByCodeMap);

        input.put('ProcedureName','TargetPathRangePricingDemoProcedureTest');
        input.put('MatrixName','TargetPathRangePricing');
        input.put('Path3','Triple Play Bundle Small<TV Small<HD TV');
        input.put('RangeFields','Quantity');
        input.put('RangeAttributes','TV Boxes Required');
        input.put('SourceTargetABP','True');
        input.put('DecisionMatrix', 'True');

        CustomPricingPlanStepImpl testing = new CustomPricingPlanStepImpl();
        testing.invokeMethod('GetMatrixPrice',input,output,options);

        for(SObject orderItem : orderItemList)
        {
                if(orderItem.get('vlocity_cmt__RecurringCharge__c')!=null)
                {
                        System.assert(orderItem.get('vlocity_cmt__RecurringCharge__c') == 300.00 );
                        System.assert(orderItem.get('vlocity_cmt__OneTimeCharge__c') == 125.00 );
                }
        }

        Test.stopTest();
    }
    
    static private testmethod void testCachedApiResponseLoad()
    {
        Map<String, Object> output = new Map<String, Object>();
        Map<String, Object> options = new Map<String,Object>();
        Map<String, Object> input = new Map<String, Object>();
        flag = false;

        try {
            SObject calculationMatrixBPO = (SObject)Type.forName('CalculationMatrix').newInstance();
        }
        catch(Exception ex) {
            return;
        }

        testProductSetup();
        testMatrixSetupUsingBPOs();
        setupCachedApiResponse();
        
        Test.startTest();
        sObject targetProduct = [SELECT Id, Name FROM Product2 WHERE Name = 'HD TV'];
        sObject orderSObject = [SELECT Id FROM Order WHERE Id = :orderId];
        List<SObject> orderItemList = [SELECT   Id, PricebookEntryId, PricebookEntry.Product2.Name, PricebookEntry.Product2.ProductCode, Quantity,
                vlocity_cmt__PricingLogData__c, vlocity_cmt__ProvisioningStatus__c, vlocity_cmt__RecurringCharge__c,
                vlocity_cmt__OneTimeCharge__c, vlocity_cmt__JSONAttribute__c,vlocity_cmt__LineNumber__c
                FROM OrderItem WHERE OrderId = :orderId];

        vlocity_cmt.PricingPlanService.putInPricingContext('Parent', orderSObject);
        vlocity_cmt.PricingPlanService.putInPricingContext('LineItemList', orderItemList);
        vlocity_cmt.PricingPlanService.putInPricingContext('PricingVariableDefinitionsMap', pricingVariableByCodeMap);

        input.put('ProcedureName','TargetPathRangePricingDemoProcedureTest');
        input.put('MatrixName','TargetPathRangePricing');
        input.put('Path3','Triple Play Bundle Small<TV Small<HD TV');
        input.put('RangeFields','Quantity');
        input.put('RangeAttributes','TV Boxes Required');
        input.put('SourceTargetABP','True');
        input.put('DecisionMatrix', 'True');
        input.put('LargeMatrix', 'True');

        CustomPricingPlanStepImpl testing = new CustomPricingPlanStepImpl();
        testing.invokeMethod('GetMatrixPrice',input,output,options);

        for(SObject orderItem : orderItemList) {
            if(orderItem.get('vlocity_cmt__RecurringCharge__c')!=null) {
                System.assert(orderItem.get('vlocity_cmt__RecurringCharge__c') == 300.00 );
                System.assert(orderItem.get('vlocity_cmt__OneTimeCharge__c') == 125.00 );
            }
        }

        Test.stopTest();
    }

    // This is the utility set up for configuring/populating data for decision metrics and expression sets using BPOs. 
    static private void testMatrixSetupUsingBPOs() 
    {
        insert new vlocity_cmt__TriggerSetup__c(Name = 'AllTriggers', vlocity_cmt__IsTriggerOn__c = true);
        parentSobj = (SObject)Type.forName('CalculationMatrix').newInstance();
        parentSobj.put('Name', 'TargetPathRangePricing');  
        parentSobj.put('Type', 'Standard'); 
        insert parentSobj;

        //Populating Headers
        lineItemsSobj = new List<SObject>();
        SObject headerCharName =  (SObject)Type.forName('CalculationMatrixColumn').newInstance();
        headerCharName.put('CalculationMatrixId', parentSobj.Id); 
        headerCharName.put('Name', 'CharacteristicName');
        headerCharName.put('ApiName', 'CharacteristicName');
        headerCharName.put('ColumnType', 'Input');
        headerCharName.put('DataType', 'Text');
        headerCharName.put('DisplaySequence', 1);
        lineItemsSobj.add(headerCharName);

        SObject headerSourceProdCode =  (SObject)Type.forName('CalculationMatrixColumn').newInstance();
        headerSourceProdCode.put('CalculationMatrixId', parentSobj.Id); 
        headerSourceProdCode.put('Name', 'SourceProductCode');
        headerSourceProdCode.put('ApiName', 'SourceProductCode');
        headerSourceProdCode.put('ColumnType', 'Input');
        headerSourceProdCode.put('DataType', 'Text');
        headerSourceProdCode.put('DisplaySequence', 2);
        lineItemsSobj.add(headerSourceProdCode);

        SObject headerSourceProdName =  (SObject)Type.forName('CalculationMatrixColumn').newInstance();
        headerSourceProdName.put('CalculationMatrixId', parentSobj.Id); 
        headerSourceProdName.put('Name', 'SourceProductName');
        headerSourceProdName.put('ApiName', 'SourceProductName');
        headerSourceProdName.put('ColumnType', 'Input');
        headerSourceProdName.put('DataType', 'Text');
        headerSourceProdName.put('DisplaySequence', 3);
        lineItemsSobj.add(headerSourceProdName);

        SObject headerCharValue =  (SObject)Type.forName('CalculationMatrixColumn').newInstance();
        headerCharValue.put('CalculationMatrixId', parentSobj.Id); 
        headerCharValue.put('Name', 'CharacteristicValue');
        headerCharValue.put('ApiName', 'CharacteristicValue');
        headerCharValue.put('ColumnType', 'Input');
        headerCharValue.put('DataType', 'Text');
        headerCharValue.put('DisplaySequence', 4);
        lineItemsSobj.add(headerCharValue);

        SObject headerQuantity =  (SObject)Type.forName('CalculationMatrixColumn').newInstance();
        headerQuantity.put('CalculationMatrixId', parentSobj.Id); 
        headerQuantity.put('Name', 'Quantity');
        headerQuantity.put('ApiName', 'Quantity');
        headerQuantity.put('ColumnType', 'Input');
        headerQuantity.put('DataType', 'Text');
        headerQuantity.put('DisplaySequence', 5);
        lineItemsSobj.add(headerQuantity);

        SObject headerTargetProductName =  (SObject)Type.forName('CalculationMatrixColumn').newInstance();
        headerTargetProductName.put('CalculationMatrixId', parentSobj.Id); 
        headerTargetProductName.put('Name', 'TargetProductName');
        headerTargetProductName.put('ApiName', 'TargetProductName');
        headerTargetProductName.put('ColumnType', 'Output');
        headerTargetProductName.put('DataType', 'Text');
        headerTargetProductName.put('DisplaySequence', 6);
        lineItemsSobj.add(headerTargetProductName);

        SObject headerMRC =  (SObject)Type.forName('CalculationMatrixColumn').newInstance();
        headerMRC.put('CalculationMatrixId', parentSobj.Id); 
        headerMRC.put('Name', 'MRC');
        headerMRC.put('ApiName', 'MRC');
        headerMRC.put('ColumnType', 'Output');
        headerMRC.put('DataType', 'Text');
        headerMRC.put('DisplaySequence', 7);
        lineItemsSobj.add(headerMRC);

        SObject headerNRC =  (SObject)Type.forName('CalculationMatrixColumn').newInstance();
        headerNRC.put('CalculationMatrixId', parentSobj.Id); 
        headerNRC.put('Name', 'NRC');
        headerNRC.put('ApiName', 'NRC');
        headerNRC.put('ColumnType', 'Output');
        headerNRC.put('DataType', 'Text');
        headerNRC.put('DisplaySequence', 8);
        lineItemsSobj.add(headerNRC);
        insert lineItemsSobj;

        versionSobj = (SObject)Type.forName('CalculationMatrixVersion').newInstance();
        versionSobj.put('Name', 'TargetPathRangePricingMatrixTest Version');
        versionSobj.put('VersionNumber', 5);
        versionSobj.put('IsEnabled', false);
        versionSobj.put('CalculationMatrixId', parentSobj.Id);
        versionSobj.put('StartDateTime', DateTime.now().addDays(-10));
        versionSobj.put('EndDateTime', DateTime.now().addDays(10));
        versionSobj.put('Rank', 5);     
        insert versionSobj;



        //Populating Row Data
        lineItemsSobj = new List<SObject>();

        SObject decisionRow5 =  (SObject)Type.forName('CalculationMatrixRow').newInstance();
        decisionRow5.put('CalculationMatrixVersionId', versionSobj.Id);
        decisionRow5.put('InputData', '{\"Quantity\":\"1-10\",\"CharacteristicValue\":\"Xfinity\",\"CharacteristicName\":"Provider\",\"SourceProductCode\":\"VLO-PHN-0005\",\"SourceProductName\":\"Consumer Landline\"}');
        decisionRow5.put('OutputData', '{\"NRC\":\"105\",\"MRC\":\"50\",\"TargetProductName\":\"Path3\"}');
        lineItemsSobj.add(decisionRow5);

        SObject decisionRow6 =  (SObject)Type.forName('CalculationMatrixRow').newInstance();
        decisionRow6.put('CalculationMatrixVersionId', versionSobj.Id);
        decisionRow6.put('InputData', '{\"Quantity\":\"11-20\",\"CharacteristicValue\":\"Xfinity\",\"CharacteristicName\":"Provider\",\"SourceProductCode\":\"VLO-PHN-0005\",\"SourceProductName\":\"Consumer Landline\"}');
        decisionRow6.put('OutputData', '{\"NRC\":\"115\",\"MRC\":\"100\",\"TargetProductName\":\"Path3\"}');
        lineItemsSobj.add(decisionRow6);

        SObject decisionRow7 =  (SObject)Type.forName('CalculationMatrixRow').newInstance();
        decisionRow7.put('CalculationMatrixVersionId', versionSobj.Id);
        decisionRow7.put('InputData', '{\"Quantity\":\"1-10\",\"CharacteristicValue\":\"Verizon\",\"CharacteristicName\":"Provider\",\"SourceProductCode\":\"VLO-PHN-0005\",\"SourceProductName\":\"Consumer Landline\"}');
        decisionRow7.put('OutputData', '{\"NRC\":\"125\",\"MRC\":\"300\",\"TargetProductName\":\"Path3\"}');
        lineItemsSobj.add(decisionRow7);

        SObject decisionRow8 =  (SObject)Type.forName('CalculationMatrixRow').newInstance();
        decisionRow8.put('CalculationMatrixVersionId', versionSobj.Id);
        decisionRow8.put('InputData', '{\"Quantity\":\"11-20\",\"CharacteristicValue\":\"Verizon\",\"CharacteristicName\":"Provider\",\"SourceProductCode\":\"VLO-PHN-0005\",\"SourceProductName\":\"Consumer Landline\"}');
        decisionRow8.put('OutputData', '{\"NRC\":\"135\",\"MRC\":\"600\",\"TargetProductName\":\"Path3\"}');
        lineItemsSobj.add(decisionRow8);

        insert lineItemsSobj;

        String query = 'SELECT Name, InputData, OutputData FROM CalculationMatrixRow WHERE Name != \'Header\''; //check the query
        lineItemsSobj = Database.query(query);

        SObject calMatrixVersion =  (SObject)Type.forName('CalculationMatrixVersion').newInstance();
        calMatrixVersion.put('Id', versionSobj.Id);
        calMatrixVersion.put('IsEnabled', true);
        update calMatrixVersion; 

        SObject calcProcedure =  (SObject)Type.forName('CalculationProcedure').newInstance();
        calcProcedure.put('Name', 'TargetPathRangePricingDemoProcedureTest');
        insert calcProcedure;

        //Making isEnabled = false due to ERROR="Please add steps before enabling this procedure configuration."        
        SObject procVersion =  (SObject)Type.forName('CalculationProcedureVersion').newInstance();
        procVersion.put('Name', 'TargetPathRangePricingDemo V3');
        procVersion.put('VersionNumber', 5);
        procVersion.put('IsEnabled', false);
        procVersion.put('CalculationProcedureId', calcProcedure.Id);
        procVersion.put('StartDateTime', DateTime.now().addDays(-5));
        procVersion.put('EndDateTime', DateTime.now().addDays(5));
        procVersion.put('Rank', 5);

        insert procVersion;

        List<SObject> steps = new List<SObject>();

        SObject step1 =  (SObject)Type.forName('CalculationProcedureStep').newInstance();
        step1.put('Name', 'a1L46000001ASQm');
        step1.put('StageStepSequence', 1);
        step1.put('Stage', 'Calculation');
        step1.put('StepType', 'MatrixLookup');
        step1.put('CalculationMatrixId', parentSobj.Id);
        step1.put('IsResultIncluded', true);
        step1.put('CalculationProcedureVersionId', procVersion.Id);
        step1.put('InputVariablesFormatText', '[{\"name\":\"SourceProductName\",\"listValues\":null,\"label\":null,\"dataType\":\"Text\",\"columnKey\":\"dea1b0\"},{\"name\":\"SourceProductCode\",\"listValues\":null,\"label\":null,\"dataType\":\"Text\",\"columnKey\":\"15e771\"},{\"name\":\"CharacteristicName\",\"listValues\":null,\"label\":null,\"dataType\":\"Text\",\"columnKey\":\"a81456\"},{\"name\":\"CharacteristicValue\",\"listValues\":null,\"label\":null,\"dataType\":\"Text\",\"columnKey\":\"880c2d\"},{\"name\":\"Quantity\",\"listValues\":null,\"label\":null,\"dataType\":\"Text\",\"columnKey\":\"94bbbe\"}]');
        step1.put('OutputVariablesMappingText', '{\"TargetProductName\":\"TargetPathRangePricing__TargetProductName\",\"MRC\":\"TargetPathRangePricing__MRC\",\"NRC\":\"TargetPathRangePricing__NRC\"}');
        step1.put('OutputVariablesFormatText', '[{\"name\":\"TargetProductName\",\"listValues\":null,\"label\":null,\"dataType\":\"Text\",\"columnKey\":\"fea7df\"},{\"name\":\"MRC\",\"listValues\":null,\"label\":null,\"dataType\":\"Text\",\"columnKey\":\"7776f5\"},{\"name\":\"NRC\",\"listValues\":null,\"label\":null,\"dataType\":\"Text\",\"columnKey\":\"ac5769\"}]');

        SObject step2 =  (SObject)Type.forName('CalculationProcedureStep').newInstance();
        step2.put('Name', 'a1L46000001ASQn');
        step2.put('StageStepSequence', 2);
        step2.put('Stage', 'Calculation');
        step2.put('StepType', 'Calculation');
        step2.put('IsResultIncluded', true);
        step2.put('CalculationProcedureVersionId', procVersion.Id);
        step2.put('FormulaExpressionText', 'TargetPathRangePricing__MRC');
        step2.put('OutputVariablesFormatText', '{\"name\":\"REC_MNTH_STD_PRC\",\"dataType\":\"Currency\",\"alias\":\"REC_MNTH_STD_PRC\"}');
        step2.put('OutputVariablesMappingText', '{\"REC_MNTH_STD_PRC\":\"REC_MNTH_STD_PRC\"}');
        step2.put('FormulaUiFormattedText', '[{\"text\":\"MRC ( TargetPathRangePricing )\",\"alias\":\"TargetPathRangePricing__MRC\",\"userDefined\":false,\"dataType\":\"Text\"}]');

        SObject step3 =  (SObject)Type.forName('CalculationProcedureStep').newInstance();
        step3.put('Name', 'a1L46000001ASQo');
        step3.put('StageStepSequence', 3);
        step3.put('Stage', 'Calculation');
        step3.put('StepType', 'Calculation');
        step3.put('IsResultIncluded', true);
        step3.put('CalculationProcedureVersionId', procVersion.Id);
        step3.put('FormulaExpressionText', 'TargetPathRangePricing__NRC');
        step3.put('OutputVariablesMappingText', '{\"OT_STD_PRC\":\"OT_STD_PRC\"}');
        step3.put('OutputVariablesFormatText', '{\"name\":\"OT_STD_PRC\",\"dataType\":\"Currency\",\"alias\":\"OT_STD_PRC\"}');
        step3.put('FormulaUiFormattedText', '[{\"text\":\"MRC ( TargetPathRangePricing )\",\"alias\":\"TargetPathRangePricing__NRC\",\"userDefined\":false,\"dataType\":\"Text\"}]');

        steps.add(step1);
        steps.add(step2);
        steps.add(step3);
        insert steps;

        List<SObject> calcProcVariableList = new List<SObject>();  
        SObject calcProcedureVar1 =  (SObject)Type.forName('CalculationProcedureVariable').newInstance();
        calcProcedureVar1.put('name', 'REC_MNTH_STD_PRC');
        calcProcedureVar1.put('ApiName', 'REC_MNTH_STD_PRC');
        calcProcedureVar1.put('DataType', 'Currency');
        calcProcedureVar1.put('CalculationProcedureVersionId', procVersion.Id);

        calcProcVariableList.add(calcProcedureVar1);        

        SObject calcProcedureVar2 =  (SObject)Type.forName('CalculationProcedureVariable').newInstance();
        calcProcedureVar2.put('name', 'OT_STD_PRC');
        calcProcedureVar2.put('ApiName', 'OT_STD_PRC');
        calcProcedureVar2.put('DataType', 'Currency');
        calcProcedureVar2.put('DefaultValue', '27');
        calcProcedureVar2.put('CalculationProcedureVersionId', procVersion.Id);

        calcProcVariableList.add(calcProcedureVar2);     

        SObject calcProcedureVar3 =  (SObject)Type.forName('CalculationProcedureVariable').newInstance();
        calcProcedureVar3.put('ApiName', 'Source Product Name');
        calcProcedureVar3.put('Name', 'SourceProductName');
        calcProcedureVar3.put('DataType', 'Text');
        calcProcedureVar3.put('DefaultValue', 'false');
        calcProcedureVar3.put('CalculationProcedureVersionId', procVersion.Id);

        calcProcVariableList.add(calcProcedureVar3);     

        SObject calcProcedureVar4 =  (SObject)Type.forName('CalculationProcedureVariable').newInstance();
        calcProcedureVar4.put('ApiName', 'Source Product Code');
        calcProcedureVar4.put('Name', 'SourceProductCode');
        calcProcedureVar4.put('DataType', 'Text');
        calcProcedureVar4.put('DefaultValue', 'false');
        calcProcedureVar4.put('CalculationProcedureVersionId', procVersion.Id);

        calcProcVariableList.add(calcProcedureVar4);     

        SObject calcProcedureVar5 =  (SObject)Type.forName('CalculationProcedureVariable').newInstance();
        calcProcedureVar5.put('ApiName', 'Characteristic Name');
        calcProcedureVar5.put('Name', 'CharacteristicName');
        calcProcedureVar5.put('DataType', 'Text');
        calcProcedureVar5.put('DefaultValue', 'false');
        calcProcedureVar5.put('CalculationProcedureVersionId', procVersion.Id);

        calcProcVariableList.add(calcProcedureVar5);     

        SObject calcProcedureVar6 =  (SObject)Type.forName('CalculationProcedureVariable').newInstance();
        calcProcedureVar6.put('ApiName', 'Characteristic Value');
        calcProcedureVar6.put('Name', 'CharacteristicValue');
        calcProcedureVar6.put('DataType', 'Text');
        calcProcedureVar6.put('DefaultValue', 'false');
        calcProcedureVar6.put('CalculationProcedureVersionId', procVersion.Id);

        calcProcVariableList.add(calcProcedureVar6);     

        SObject calcProcedureVar7 =  (SObject)Type.forName('CalculationProcedureVariable').newInstance();
        calcProcedureVar7.put('name', 'Quantity');
        calcProcedureVar7.put('ApiName', 'Quantity');
        calcProcedureVar7.put('DataType', 'Text');
        calcProcedureVar7.put('DefaultValue', 'false');
        calcProcedureVar7.put('CalculationProcedureVersionId', procVersion.Id);

        calcProcVariableList.add(calcProcedureVar7);     

        SObject calcProcedureVar8 =  (SObject)Type.forName('CalculationProcedureVariable').newInstance();
        calcProcedureVar8.put('ApiName', 'Target Product Name');
        calcProcedureVar8.put('Name', 'TargetPathRangePricing__TargetProductName');
        calcProcedureVar8.put('DataType', 'Text');
        calcProcedureVar8.put('DefaultValue', 'false');
        calcProcedureVar8.put('CalculationProcedureVersionId', procVersion.Id);

        calcProcVariableList.add(calcProcedureVar8);     

        SObject calcProcedureVar9 =  (SObject)Type.forName('CalculationProcedureVariable').newInstance();
        calcProcedureVar9.put('ApiName', 'MRC');
        calcProcedureVar9.put('Name', 'TargetPathRangePricing__MRC');
        calcProcedureVar9.put('DataType', 'Text');
        calcProcedureVar9.put('DefaultValue', 'false');
        calcProcedureVar9.put('CalculationProcedureVersionId', procVersion.Id);

        calcProcVariableList.add(calcProcedureVar9);     

        SObject calcProcedureVar10 = (SObject)Type.forName('CalculationProcedureVariable').newInstance();
        calcProcedureVar10.put('ApiName', 'NRC');
        calcProcedureVar10.put('Name', 'TargetPathRangePricing__NRC');
        calcProcedureVar10.put('DataType', 'Text');
        calcProcedureVar10.put('DefaultValue', 'false');
        calcProcedureVar10.put('CalculationProcedureVersionId', procVersion.Id);

        calcProcVariableList.add(calcProcedureVar10);     


        insert calcProcVariableList;

        //Enable CalculationProcedureVersion        
        SObject calProcedureVersion =  (SObject)Type.forName('CalculationProcedureVersion').newInstance();
        calProcedureVersion.put('Id', procVersion.Id);
        calProcedureVersion.put('IsEnabled', true);
        update calProcedureVersion;
    }

    private static void setupCachedApiResponse()
    {
        List<SObject> sObjList = new List<SObject>();

        vlocity_cmt__CalculationMatrixVersion__c matrixVersionObj = [SELECT Id, Name FROM vlocity_cmt__CalculationMatrixVersion__c where Name ='TargetPathRangePricingMatrixTest Version' LIMIT 1];

        Map<String, Object> cacheMap = new Map<String, Object>();
        cacheMap.put('ProductCodeSet', new Set<String>{'VLO-PHN-0005'});
        cacheMap.put('AttrRowInfoKeySet', null);
        cacheMap.put('CacheTime', DateTime.now());

        vlocity_cmt__CachedApiResponse__c apiResp = new vlocity_cmt__CachedApiResponse__c();
        apiResp.vlocity_cmt__Code__c = 'TargetPathRangePricing';
        apiResp.vlocity_cmt__Type__c = 'compiledCalculationMatrix';                  
        apiResp.vlocity_cmt__CacheKey__c = 'AttrMatrixInfo' + String.valueOf(matrixVersionObj.Id);
        apiResp.vlocity_cmt__ApiResponse__c = JSON.serialize(cacheMap);
        apiResp.vlocity_cmt__OverflowSequence__c = 1;
        sObjList.add(apiResp);

        Map<String, Object> subCacheMap = new Map<String, Object>();
        subCacheMap.put('RangeAttrMapping', null);
        subCacheMap.put('RangeFieldMapping', null);
        Map<String, Object> productCodeMapping = new Map<String, Object>();
        productCodeMapping.put('Provider', new List<String>{'Provider'});        
        subCacheMap.put('ProductCodeMapping', productCodeMapping);
        subCacheMap.put('ProductCode', 'VLO-PHN-0005');
        subCacheMap.put('CacheTime', DateTime.now());      

        vlocity_cmt__CachedApiResponse__c apiResp2 = new vlocity_cmt__CachedApiResponse__c();
        apiResp2.vlocity_cmt__Code__c = 'TargetPathRangePricing';
        apiResp2.vlocity_cmt__Type__c = 'compiledCalculationMatrix';                  
        apiResp2.vlocity_cmt__CacheKey__c = PricingPlanHelper.generateCacheKey(String.valueOf(matrixVersionObj.Id) + 'VLO-PHN-0005');
        apiResp2.vlocity_cmt__ApiResponse__c = JSON.serialize(subCacheMap);
        apiResp2.vlocity_cmt__OverflowSequence__c = 1;
        sObjList.add(apiResp2);

        insert sObjList;
        sObjList.clear();
    }

    static private testmethod void testOutputAttributeMap(){

        Map<String, Object> output = new Map<String, Object>();
        Map<String, Object> options = new Map<String,Object>();
        Map<String, Object> input = new Map<String, Object>();
        flag = false;

        testProductSetup();
        testMatrixSetup();

        Test.startTest();

        sObject targetProduct = [SELECT Id, Name FROM Product2 WHERE Name = 'HD TV'];
        sObject orderSObject = [SELECT Id FROM Order WHERE Id = :orderId];
        List<SObject> orderItemList = [SELECT   Id, UnitPrice, PricebookEntryId, PricebookEntry.Product2.Name, PricebookEntry.Product2.ProductCode, Quantity,
                vlocity_cmt__PricingLogData__c, vlocity_cmt__ProvisioningStatus__c, vlocity_cmt__RecurringCharge__c, vlocity_cmt__OneTimeCharge__c,
                vlocity_cmt__JSONAttribute__c,vlocity_cmt__LineNumber__c, vlocity_cmt__Action__c, vlocity_cmt__SupplementalAction__c
                FROM OrderItem WHERE OrderId = :orderId];

        vlocity_cmt.PricingPlanService.putInPricingContext('Parent', orderSObject);
        vlocity_cmt.PricingPlanService.putInPricingContext('LineItemList', orderItemList);
        vlocity_cmt.PricingPlanService.putInPricingContext('PricingVariableDefinitionsMap', pricingVariableByCodeMap);
        vlocity_cmt.PricingPlanService.putInPricingContext('JsonAttrSupportResultsMap', new Map<String, Object>()); 

        input.put('ProcedureName','TargetPathRangePricingDemoProcedureTest');
        input.put('MatrixName','TargetPathRangePricingMatrixTest');
        input.put('RangeFields','Quantity');
        input.put('IncludeAttrInfoInRangeKeys','true');
        input.put('InputAttributeMap','Supplier=Supplier');
        input.put('InputVariableMap','InputTestVar=TestAttr');
        input.put('OutputAttributeMap','OT_STD_PRC=Provider');
        input.put('OutputVariableMap','OT_STD_PRC=OneTimeChargeVar');
        input.put('OutputFieldBindingMap','OT_STD_PRC=UnitPrice');

        CustomPricingPlanStepImpl testing = new CustomPricingPlanStepImpl();
        testing.invokeMethod('GetMatrixPrice',input,output,options);

        Boolean assertExecuted = false;
        for(SObject orderItem : orderItemList){
            if(orderItem.get('vlocity_cmt__RecurringCharge__c')!=null)
            {
                System.assert(orderItem.get('vlocity_cmt__RecurringCharge__c') == 300.00 );
                System.assert(orderItem.get('vlocity_cmt__OneTimeCharge__c') == 125.00 );
                assertExecuted = true;
                break;
            }
        }
        System.assert(assertExecuted);

        Test.stopTest();
    }

    static private testmethod void testGetRefreshOnlyPassedLineItems(){

	Map<String, Object> output = new Map<String, Object>();
        Map<String, Object> options = new Map<String,Object>();
        Map<String, Object> input = new Map<String, Object>();

        Map<String, Object> args = new Map<String, Object>();
        args.put('input', input);
        args.put('output', output);
        args.put('options', options);
        flag = false;

        Test.startTest();
        vlocity_cmt.VlocityFeatureService.SetFeatureValue('EnableV2AttributeModel', 'true');
        testProductSetup();
        testMatrixSetup();
        delete [select id from vlocity_cmt__CpqConfigurationSetup__c where Name = 'DeltaPrice'];
        vlocity_cmt__CpqConfigurationSetup__c configSetup = new vlocity_cmt__CpqConfigurationSetup__c(Name = 'DeltaPrice', vlocity_cmt__SetupValue__c = 'False');
        insert configSetup;

        sObject targetProduct = [SELECT Id, Name FROM Product2 WHERE Name = 'HD TV'];
        sObject orderSObject = [SELECT Id, RecordTypeId FROM Order WHERE Id = :orderId];
        List<SObject> orderItemList = [SELECT   Id, PricebookEntryId, PricebookEntry.Product2.Name, PricebookEntry.Product2.ProductCode, PricebookEntry.Product2.vlocity_cmt__AttributeMetadata__c,
                Quantity,vlocity_cmt__PricingLogData__c, vlocity_cmt__ProvisioningStatus__c, vlocity_cmt__RecurringCharge__c,
                vlocity_cmt__OneTimeCharge__c, vlocity_cmt__AttributeSelectedValues__c,vlocity_cmt__LineNumber__c,vlocity_cmt__Action__c, vlocity_cmt__SupplementalAction__c
                FROM OrderItem WHERE OrderId = :orderId];

        vlocity_cmt.PricingPlanService.putInPricingContext('Parent', orderSObject);
        vlocity_cmt.PricingPlanService.putInPricingContext('LineItemList', orderItemList);
        vlocity_cmt.PricingPlanService.putInPricingContext('PricingVariableDefinitionsMap', pricingVariableByCodeMap);

        input.put('ProcedureName','TargetPathRangePricingDemoProcedureTest');
        input.put('MatrixName','TargetPathRangePricingMatrixTest');
        //input.put('Path1','Triple Play Bundle Small<Consumer Landline');
        //input.put('Path2','Triple Play Bundle Small<Broadband Internet Small');
        input.put('Path3','Triple Play Bundle Small<TV Small<HD TV');
        input.put('RangeFields','Quantity');
        input.put('IncludeAttrInfoInRangeKeys','true');
        //input.put('RangeAttributes','TV Boxes Required');
        input.put('SourceTargetABP','true');
        input.put('InputVariableMap','value1');
       	input.put('FieldAttributes','value1');
        
        input.put('OutputAttributeMap','value2');
       	input.put('OutputVariableMap','value2');
        input.put('RunForPassedItemListContext', true);

        CustomPricingPlanStepImpl testing = new CustomPricingPlanStepImpl();
        testing.call('GetMatrixPrice',args);

        Boolean assertExecuted = false;
        for(SObject orderItem : orderItemList){
                assertExecuted = true;
                break;           
        }
        System.assert(assertExecuted);
        Test.stopTest();
    }


    static private testmethod void testGetMatrixPriceForRecordTypes(){

	Map<String, Object> output = new Map<String, Object>();
        Map<String, Object> options = new Map<String,Object>();
        Map<String, Object> input = new Map<String, Object>();

        Map<String, Object> args = new Map<String, Object>();
        args.put('input', input);
        args.put('output', output);
        args.put('options', options);
        flag = false;

        Test.startTest();
        vlocity_cmt.VlocityFeatureService.SetFeatureValue('EnableV2AttributeModel', 'true');
        testProductSetup();
        testMatrixSetup();
        delete [select id from vlocity_cmt__CpqConfigurationSetup__c where Name = 'DeltaPrice'];
        vlocity_cmt__CpqConfigurationSetup__c configSetup = new vlocity_cmt__CpqConfigurationSetup__c(Name = 'DeltaPrice', vlocity_cmt__SetupValue__c = 'False');
        insert configSetup;
        delete [select id from vlocity_cmt__CpqConfigurationSetup__c where Name = 'AttrMatrixInfoCachePartition'];
        vlocity_cmt__CpqConfigurationSetup__c configSetup2 = new vlocity_cmt__CpqConfigurationSetup__c(Name = 'AttrMatrixInfoCachePartition', vlocity_cmt__SetupValue__c = 'AttributeCache');
        insert configSetup2;
        
        sObject targetProduct = [SELECT Id, Name FROM Product2 WHERE Name = 'HD TV'];
        sObject orderSObject = [SELECT Id, RecordTypeId FROM Order WHERE Id = :orderId];
        List<SObject> orderItemList = [SELECT   Id, PricebookEntryId, PricebookEntry.Product2.Name, PricebookEntry.Product2.ProductCode, PricebookEntry.Product2.vlocity_cmt__AttributeMetadata__c,
                Quantity,vlocity_cmt__PricingLogData__c, vlocity_cmt__ProvisioningStatus__c, vlocity_cmt__RecurringCharge__c,
                vlocity_cmt__OneTimeCharge__c, vlocity_cmt__AttributeSelectedValues__c,vlocity_cmt__LineNumber__c,vlocity_cmt__Action__c, vlocity_cmt__SupplementalAction__c
                FROM OrderItem WHERE OrderId = :orderId];

        vlocity_cmt.PricingPlanService.putInPricingContext('Parent', orderSObject);
        vlocity_cmt.PricingPlanService.putInPricingContext('LineItemList', orderItemList);
        vlocity_cmt.PricingPlanService.putInPricingContext('PricingVariableDefinitionsMap', pricingVariableByCodeMap);

        input.put('ProcedureName','TargetPathRangePricingDemoProcedureTest');
        input.put('MatrixName','TargetPathRangePricingMatrixTest');
        //input.put('Path1','Triple Play Bundle Small<Consumer Landline');
        //input.put('Path2','Triple Play Bundle Small<Broadband Internet Small');
        input.put('Path3','Triple Play Bundle Small<TV Small<HD TV');
        input.put('RangeFields','Quantity');
        input.put('IncludeAttrInfoInRangeKeys','true');
        //input.put('RangeAttributes','TV Boxes Required');
        input.put('SourceTargetABP','true');
        input.put('InputVariableMap','value1');
       	input.put('FieldAttributes','value1');
        
        input.put('OutputAttributeMap','value2');
       	input.put('OutputVariableMap','value2');
        input.put('RunForPassedItemListContext', true);
        List<String> recordTypes = new List<String>{'Order', 'Quote'};
        input.put('RunOnlyForRecordTypes', recordTypes);

        CustomPricingPlanStepImpl testing = new CustomPricingPlanStepImpl();
        testing.call('GetMatrixPrice',args);

        Boolean assertExecuted = false;
        for(SObject orderItem : orderItemList){
                assertExecuted = true;
                break;           
        }
        System.assert(assertExecuted);
        Test.stopTest();
    }
}