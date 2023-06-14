# Communications-Cloud

## Permission Sets

The `SamplePermissionSets.zip` contains the following Permission Sets:
- Base_Runtime_ReadOnly
- Base_Runtime_ViewAndManageBillPayment_CC_User
- Base_Runtime_ViewAndManageBillPayment
- CLMInd_Admin_All
- CLMInd_DocuSign_Runtime_All
- CLMInd_FA_Runtime_All
- CLMInd_Runtime_All
- CPQ_Admin_All
- CPQ_Runtime_CartOperations_CC_User
- CPQ_Runtime_CartOperations
- CPQ_Runtime_CPQCartUI
- CPQ_Runtime_InvokeOdinNotification
- CPQ_Runtime_ViewAndApplyDiscounts
- DC_Runtime_Shopping_CC_User
- DC_Runtime_Shopping
- DocGenInd_Design_All
- DocGenInd_Docusign_Runtime_All
- DocGenInd_Runtime_All
- EPC_Admin_All
- EPC_Design_All
- EPC_ReadOnly_All
- ESM_Runtime_CC_User
- ESM_Runtime
- ESM_SelfService_Community_User
- ESM_SelfService_External_User
- MSM_Runtime_Agent
- MSM_Runtime_Customer
- SFIOmniObjectsPermissions_GuestUser
- SFIOmniObjectsPermissions
- SFIOmniObjectsPermissionsAdmin

Follow the below steps to deploy the `SamplePermissionSets.zip` in an Org:

1. Go to Workbench -> migration -> Deploy
2. Choose the SamplePermissionSets.zip file.
3. Check the Single Package checkbox.
4. Click Next -> Deploy
5. In the Results section, verify -> success: <span style="color: green;">true</span>

# Configuration Requirements

# To Install

'Download' the TMF620_Multipack.json and TMF620_AttributeCategory.json datapack files to your device.

Open the target org where the datapacks will be installed and navigate to the 'Omnistudio Integration Procedures' page.

Click 'Import' and add the datapack then click 'Next'.

On the next screen 'Select Items to Import', ensure all items are selected then click 'Next'.
 - If you see the message "Import has warnings" please proceed to install the datapack as normal.

On the next screen 'Review Items to Import' review the items then click 'Next'.

When the import is complete you can now activate the components, click 'Activate now', review the components on the next screen then click 'Next'.
Please note: Dataraptors do not require activating.

When the activation is complete and the selected components have all activated, click 'Done'.

Repeat this process for both datapack files.

# TMF620_Multipack Package Includes
# Integration Procedure 
SFITMForumCatalog

SFITMForumCategory

SFITMForumProductOfferingPrice

TMF-TMForumCreateCatalog

TMF-TMForumCreateCategory

TMF-TMForumCreateProductOfferingPrice

TMF-TMForumCreateProductOffering

TMF-TMForumCreateProductSpecification

TMF-TMForumProductOffering

TMF-TMForumProductSpecification

# DataRaptor 
SFITMForumGetCategoryInputResponse

SFITMForumGetCategoryResponseTransform

SFITMForumGetProductOfferingPriceInput

SFITMForumGetProductOfferingPriceResult

SFITMForumTransformGetCatalogInputResponse

SFITMForumTransformGetCatalogResponse

TMF-TMForumCategoryRequestTransform

TMF-TMForumCategoryResponseTransform

TMF-TMForumGetDefaultPriceList

TMF-TMForumProductOfferingInput

TMF-TMForumProductOfferingPriceInput

TMF-TMForumProductOfferingPriceResult

TMF-TMForumProductOfferingResult

TMF-TMForumProductSpecificationRequestTransform

TMF-TMForumProductSpecificationResponseTransform

TMF-TMForumTransformCatalogRequest

TMF-TMForumTransformCatalogResponse

# TMF620_AttributeCategory Package Includes
# Attribute Category
TMForum
