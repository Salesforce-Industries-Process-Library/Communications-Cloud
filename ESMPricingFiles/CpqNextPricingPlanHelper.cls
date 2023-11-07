global with sharing class CpqNextPricingPlanHelper extends PricingPlanHelper {

    private vlocity_cmt.CpqCartDocument cartDocument;
    private Map<String, vlocity_cmt.CpqCartDocumentItem> itemWrapperMap;

    global override void initializeParentAndLineItems(Map<String, Object> input)
    {
        isCpqNextFlow = true;
        cartDocument = (vlocity_cmt.CpqCartDocument) input.get('cartDocument');
        Map<String, Object> outputMap = cartDocument.call('getAllItems', new Map<String, Object>{ 'hierarchyLevel'=>-1});
        itemWrapperMap = (Map<String, vlocity_cmt.CpqCartDocumentItem>) outputMap.get('result');
        if(hasLineItems())
        {
            for(String itemId: itemWrapperMap.keySet())
            {
                vlocity_cmt.CpqCartDocumentItem item = itemWrapperMap.get(itemId);
                itemIdToItem.put(itemId, item);
                Map<String, Object> output = item.call('getItemField', new Map<String, Object>{'field'=>NSP + 'LineNumber__c'});
                String itemLineNumber = (String) output.get('result');
                if(!String.isBlank(itemLineNumber))
                {
                    lineNumberToItem.put(itemLineNumber, item);
                }
                else
                {
                    System.debug(LoggingLevel.ERROR, 'Line Number missing for line item with Id ' + itemId);
                    throw new PricingPlanHelperException('Line Number missing for line item with Id ' + itemId);
                }
            }
        }
    }

    global override boolean hasLineItems()
    {
        return (itemWrapperMap != null && !itemWrapperMap.isEmpty());
    }

    global override void clearExternalPriceFlag()
    {
        cartDocument.call('clearExternalPrice', null);
    }

    global override void populatePathMappings()
    {
        if (hasLineItems())
        {
            Map<String, String> parentLineNums = new Map<String, String>();
            for (String lineNum: lineNumberToItem.keySet())
            {
                Integer index = lineNum.lastIndexOf('.');
                if (index > 0)
                {
                    String parentLineNum = lineNum.substring(0, index);
                    parentLineNums.put(lineNum, parentLineNum);
                }
                else
                {
                    parentLineNums.put(lineNum, '');
                }

                vlocity_cmt.CpqCartDocumentItem item = (vlocity_cmt.CpqCartDocumentItem)lineNumberToItem.get(lineNum);
                Map<String, Object> output = item.call('getItemField', new Map<String, Object>{'field' => 'name'});
                String productName = (String)output.get('result');
                List<String> items = prodNameToItems.get(productName);
                if (items == null)
                {
                    items = new List<String>();
                    prodNameToItems.put(productName, items);
                }
                items.add(lineNum);

            }

            if (!productPathMapping.isEmpty())
            {
                for (String lineNum : lineNumberToItem.keySet())
                {
                    vlocity_cmt.CpqCartDocumentItem item = (vlocity_cmt.CpqCartDocumentItem)lineNumberToItem.get(lineNum);
                    Map<String, Object> output = item.call('getItemField',new Map<String, Object>{'field' => 'name'});

                    String productName = (String) output.get('result');

                    String productPath = productName;

                    String parentLineNum = parentLineNums.get(lineNum);

                    while (String.isNotBlank(parentLineNum))
                    {
                        vlocity_cmt.CpqCartDocumentItem parentItem = (vlocity_cmt.CpqCartDocumentItem) lineNumberToItem.get(parentLineNum);
                        output = parentItem.call('getItemField', new Map<String, Object>{'field' => 'name'});
                        productName = (String)output.get('result');
                        productPath = productName + '<' + productPath;
                        parentLineNum = parentLineNums.get(parentLineNum);
                    }
                    String pathKey = (String)productPathMapping.get(productPath);
                    if (String.isNotBlank(pathKey))
                    {
                        lineNumberToPathKeyMapping.put(lineNum, pathKey);
                    }
                }
            }
        }
    }

    global override List<Object> prepareInputMap()
    {
        List<Object> result = new List<Object>();
        Set<String> rangeFields = new Set<String>{NSP + 'AssetReferenceId__c', NSP + 'LineNumber__c', 'Quantity', productCodeField, 'name'};
        for(Object productCodeToRangeFields: rangeFieldMapping.values())
        {
            if(productCodeToRangeFields != null)
            {
                rangeFields.addAll(((Map<String, Object>) productCodeToRangeFields).keySet());
            }
        }
        for (String lineNumber: lineNumberToItem.keySet())
        {
            vlocity_cmt.CpqCartDocumentItem item = (vlocity_cmt.CpqCartDocumentItem) lineNumberToItem.get(lineNumber);
            Map<String, Object> output = item.call('getItemFields', new Map<String, Object>{'fields' => rangeFields});

            Map<String, Object> currentRowVals = (Map<String, Object>) output.get('result');

            String productCode = (String)currentRowVals.get(productCodeField);
            // TODO: add a product name field mapping
            String productName = (String)currentRowVals.get('name');
            Object quantity = currentRowVals.get('Quantity');
            currentRowVals.put('Id', currentRowVals.get(NSP + 'AssetReferenceId__c'));

            //If the given Product Code is not present in Matrix, no need to process it.
            if(!productCodeSet.contains(productCode))
            {
                continue;
            }

            if (!lineNumberToPathKeyMapping.isEmpty())
            {
                productName = replaceNameWithPath(productName, lineNumber);
            }

            output = item.call('getItemAttributes',new Map<String, Object>{'flattenedAttributeValues'=>true, 'useDisplayTextForValues'=>useDisplayTextForValues});

            result.addAll(prepareRowDataMap(productCode, productName, currentRowVals, (Map<String, Object>) output.get('result')));

        }
        return result;
    }

    global override Map<String, Object> replaceNumberWithId(String targetLineNumber, Map<String, Object> matrixResultRow, Boolean bFirst)
    {
        vlocity_cmt.CpqCartDocumentItem targetItem;
        if(String.isBlank(targetLineNumber))
        {
            String sourceItemId = (String) matrixResultRow.get('ID');
            targetItem = (vlocity_cmt.CpqCartDocumentItem) itemIdToItem.get(sourceItemId);
        } else
        {
            targetItem = (vlocity_cmt.CpqCartDocumentItem) lineNumberToItem.get(targetLineNumber);
        }
        Map<String, Object> output = targetItem.call('getItemField', new Map<String, Object>{'field' => 'vlocity_cmt__AssetReferenceId__c'});
        String targetItemId = (String) output.get('result');
        if(bFirst)
        {
            matrixResultRow.put('ID', targetItemId);
            return matrixResultRow;
        }
        else
        {
            Map<String, Object> clonedRow = matrixResultRow.clone();
            clonedRow.put('ID', targetItemId);
            return clonedRow;
        }
    }

    global override String getLineNumberFromItemId(String itemId) {
        vlocity_cmt.CpqCartDocumentItem item = (vlocity_cmt.CpqCartDocumentItem) itemIdToItem.get(itemId);

        Map<String, Object> output = item.call('getItemField', new Map<String, Object>{'field'=> NSP + 'LineNumber__c'});
        return (String) output.get('result');
   }

   @TestVisible
   protected override Map<String, String> getLineItemPricingVariableToFieldMap() {
        Map<String, String> toBeReturnedMap = new Map<String, String>();

        if(Test.isRunningTest())
        {
            toBeReturnedMap = new Map<String, String>{
                'REC_MNTH_STD_PRC'=>'vlocity_cmt__RecurringCharge__c',
                'OT_STD_PRC'=>'vlocity_cmt__OneTimeCharge__c'
            };
        }
        else {
            Map<String, Object> output = cartDocument.call('getPricingVariableMaps', null);

            Map<String, Object> result = (Map<String, Object>) output.get('result');
            if(result == null)
            {
                return null;
            }
            Map<String, Object> lineItemPricingVariableMap = (Map<String, Object>) result.get('lineItemPricingVariableToFieldMap');

            if(lineItemPricingVariableMap == null)
            {
                return null;
            }
            for(String pricingVar: lineItemPricingVariableMap.keySet()) {
                toBeReturnedMap.put(pricingVar, (String) lineItemPricingVariableMap.get(pricingVar));
            }
        }
       return toBeReturnedMap;
   }


    global override void setExternalPrice(Map<String, Object> input, Map<String, Object> output, Map<String, Object> options)
    {
        Map<String, Object> itemFields = new Map<String, Object>();
        List<Object> extPriceData = (List<Object>)input.get('externalPriceData');
        Map<String, String> pricingVariableToFieldMap = (Map<String, String>)input.get('pricingVariableToFieldMap');
        List<Object> timePlanPolicyList = (List<Object>)input.get('timePlanPolicyList');
        String message = (String)input.get('priceDetailMessage');
        Map<String, Id> unitOfMeasureToIdMap = (Map<String, Id>) input.get('unitOfMeasureToIdMap');
        Map<String, String> lineItemIdToUOM = new Map<String, String>();
        List<vlocity_cmt.CpqCartDocumentItem> updatedItemList = new List<vlocity_cmt.CpqCartDocumentItem>();

        if(extPriceData != null)
        {
            for (Object obj : extPriceData)
            {
                if (obj instanceOf Map<String, Object>)
                {
                    Map<String, Object> matrixResultRow = (Map<String, Object>)obj;
                    Map<String, Object> itemFieldDetails = new Map<String, Object>();
                    for (String fld : pricingVariableToFieldMap.keySet())
                    {
                        if(matrixResultRow.get(fld) == null)
                        {
                            continue;
                        }
                        String itemField = pricingVariableToFieldMap.get(fld);
                        Map<String, Object> fieldVals = new Map<String, Object>();
                        fieldVals.put('value', matrixResultRow.get(fld));
                        fieldVals.put('detail', message);
                        fieldVals.put('source', 'ABP');
                        fieldVals.put('code', fld);
                        itemFieldDetails.put(vlocity_cmt.CpqCartDocumentUtils.getInternalItemField(itemField), fieldVals);
                    }
                    itemFields.put(String.valueOf(matrixResultRow.get('ID')), itemFieldDetails);

                    //only for UOM
                    String uom = String.valueOf(matrixResultRow.get('UOM'));
                    if(String.isNotBlank(uom))
                    {
                        lineItemIdToUOM.put((Id)matrixResultRow.get('ID'), uom);
                    }
                }
            }
            if (isLogging)
            {
                System.debug('itemFields: ' + JSON.serialize(itemFields));
            }
        }
        //TODO: set price from UOM

        if (!itemFields.isEmpty())
        {
            if (itemWrapperMap != null && !itemWrapperMap.isEmpty())
            {
                Map<String, Object> externalPriceArgs = new Map<String, Object>();
                externalPriceArgs.put('pricingVariableToFieldMap', pricingVariableToFieldMap);
                externalPriceArgs.put('itemFieldsInfo', itemFields);
                externalPriceArgs.put('timePlanPolicyList', timePlanPolicyList);

                Map<String, Object> priceOutput = cartDocument.call('setExternalPrice', externalPriceArgs);
            }
        }
    }


    global override String getProductName(String lineNumber)
    {
        vlocity_cmt.CpqCartDocumentItem lineItem = (vlocity_cmt.CpqCartDocumentItem) lineNumberToItem.get(lineNumber);
        Map<String, Object> output = lineItem.call('getItemField', new Map<String, Object>{'field'=>'name'});
        return (String) output.get('result');
    }

    global override Object getItemField(String lineNumber, String field)
    {
        vlocity_cmt.CpqCartDocumentItem lineItem = (vlocity_cmt.CpqCartDocumentItem) lineNumberToItem.get(lineNumber);
        Map<String, Object> output = lineItem.call('getItemField', new Map<String, Object>{'field'=>field});
        return (String) output.get('result');
    }

    global override Object getAttributeMap(String itemId, Map<String, Object> jsonAttrSupportResults) {
        Map<String, Object> attrMap;
        Map<String, Object> attrCodeToDisplayName;
        Map<String, Object> jsonSupportResultMap = (Map<String, Object>) jsonAttrSupportResults.get(itemId);
        if (jsonSupportResultMap != null) {
            attrMap = (Map<String, Object>) jsonSupportResultMap.get('attributeCodeToValue');
            attrCodeToDisplayName = (Map<String, Object>) jsonSupportResultMap.get('attributeCodeToDisplayName');
            if (attrMap != null) {
                return jsonSupportResultMap;
            }
        }
        if (jsonSupportResultMap == null) {
            jsonSupportResultMap = new Map<String, Object>();
            jsonAttrSupportResults.put(itemId, jsonSupportResultMap);
        }

        vlocity_cmt.CpqCartDocumentItem item = (vlocity_cmt.CpqCartDocumentItem) itemIdToItem.get(itemId);
        Map<String, Object> output = item.call('getItemAttributes',new Map<String, Object>{'flattenedAttributeValues'=>true, 'useDisplayTextForValues'=>useDisplayTextForValues});

        jsonSupportResultMap.put('attributeCodeToValue',output.get('result'));
        jsonSupportResultMap.put('attributeCodeToDisplayName',attributeCodeToDisplayName);

        return jsonSupportResultMap;
    }

    private void processOutputAttributeAndVariableMap(Map<String, Object> input,List<Object> procResult,Map<String, Object> procAggrResult, Map<String, Object> jsonAttrSupportResults,Map<String, Object> outputVarMap) {
        String outputAttrMapStr = (String) input.get('OutputAttributeMap');
        String outputVarParamMapStr = (String) input.get('OutputVariableMap');
        if (procResult == null || procResult.isEmpty() ||
            (String.isBlank(outputAttrMapStr) && String.isBlank(outputVarParamMapStr))) {
            return;
        }

        Map<String, Object> outputAttrMap = new Map<String, Object>();
        if (String.isNotBlank(outputAttrMapStr)) {
            for (String entry : outputAttrMapStr.split(',')) {
                String[] params = entry.split('=');
                if (params.size() == 2) {
                    outputAttrMap.put(params[0].trim(), params[1].trim());
                }
            }
        }
        Map<String, Object> itemIdToUpdatedAttributes = (Map<String, Object>) vlocity_cmt.FlowStaticMap.flowMap.get('PricingPlanHelper_UpdatedAttributes');
        Map<String, Object> outputVarParamMap = new Map<String, Object>();
        if (String.isNotBlank(outputVarParamMapStr)) {
            for (String entry : outputVarParamMapStr.split(',')) {
                String[] params = entry.split('=');
                if (params.size() == 2) {
                    outputVarParamMap.put(params[0].trim(), params[1].trim());
                }
            }
        }

        Boolean hasAggregates = false;
        if (procAggrResult != null && !procAggrResult.isEmpty()) {
            hasAggregates = true;
        }

        if (isLogging) {
            System.debug('*** output attributes: ' + outputAttrMap);
            System.debug('*** output variable mapping: ' + outputVarParamMap);
            System.debug('*** lineNumberToAttributeCodeValueMap: ' + JSON.serialize(jsonAttrSupportResults));
        }

        Map<String, Object> attrMap;
        for (Object obj : procResult) { //procResult has output from matrix
            if (obj instanceof Map<String, Object>) {
                Map<String, Object> matrixResultRow = (Map<String, Object>) obj;
                String rowId = (String) matrixResultRow.get('ID');
                Map<String, Object> varMap = new Map<String, Object>();
                outputVarMap.put(rowId, varMap);
                for (String param : outputVarParamMap.keySet()) {
                    varMap.put((String) outputVarParamMap.get(param),matrixResultRow.get(param));
                    // overridden by an aggregate mapped to the variable
                    if (hasAggregates && procAggrResult.containsKey(param)) {
                        varMap.put((String) outputVarParamMap.get(param),procAggrResult.get(param));
                    }
                }

                vlocity_cmt.CpqCartDocumentItem item = (vlocity_cmt.CpqCartDocumentItem) itemWrapperMap.get(rowId);

                if (item != null) {
                    Map<String, Object> jsonAttrSupportRes = (Map<String, Object>) jsonAttrSupportResults.get(rowId);
                    if (!jsonAttrSupportRes.isEmpty()) {
                        attrMap = (Map<String, Object>) jsonAttrSupportRes.get('attributeCodeToValue');
                        Map<String, String> attrDisplayToCode = new Map<String, String>();
                        Map<String, Object> updatedAttrs = new Map<String, Object>();
                        for (String attCode : attrMap.keySet()) {
                            attrDisplayToCode.put((String)attributeCodeToDisplayName.get(attCode),attCode);
                        }

                        for (String key : outputAttrMap.keySet()) {
                            String attr = (String) outputAttrMap.get(key);
                            String attrCode = attrDisplayToCode.get(attr);
                            if (attrCode != null) {
                                Object val = matrixResultRow.get(key);
                                // overridden by an aggregate mapped to the same attribute
                                if (hasAggregates && procAggrResult.containsKey(key)) {
                                    val = procAggrResult.get(key);
                                }
                                Object currentVal = attrMap.get(attrCode);
                                // Only update if the value has changed
                                if (currentVal != val) {
                                    attrMap.put(attrCode, val);
                                }
                                item.call('setItemAttributes', new Map<String, Object>{'attributeCodeToValueMap'=>attrMap});
                            }
                        }
                    }
                }
            }
        }
        if (isLogging) {
          System.debug('*** output variable values: ' + JSON.serialize(outputVarMap));
        }
    }
}