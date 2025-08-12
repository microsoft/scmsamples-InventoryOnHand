# Inventory On-Hand Mobile App Onboarding Guide

This guide explains how to set up Microsoft Dynamics 365 Supply Chain Management and Dataverse for the Inventory On-Hand mobile app, install the app, and configure users for access.

---

## Prerequisites

### 1. System Requirements
- You must be using **Microsoft Dynamics 365 Supply Chain Management version 10.0.40 or later**.

### 2. Set Up a Dataverse Environment
The Inventory On-Hand mobile app relies on **Dataverse**. You must ensure your environment is properly configured.

#### Steps:
1. Sign in to the **Power Platform admin center**: [https://admin.powerplatform.microsoft.com](https://admin.powerplatform.microsoft.com)
2. Navigate to **Environments > New**.
3. Set up a new environment or choose an existing one.
4. Ensure **"Enable Dynamics 365 apps"** is enabled.
5. Ensure **Power Apps Component Framework (PCF)** is enabled.

---

## Licensing Requirements
Each user must have a **valid Microsoft Entra ID license** and the required **security roles**.

### Required Security Roles:
- **Finance and Operations Basic User** (for Supply Chain Management)

To review licensing details, please see the [Dynamics 365 Licensing Guide](https://go.microsoft.com/fwlink/?LinkId=866544).

---
# Build, install, and other development processes
## Prerequisites
### Microsoft Power Platform CLI
- Install [Microsoft Power Platform CLI](https://aka.ms/PowerAppsCLI).

## Generate a new Canvas App binary
- Run the script 
```powershell
.\scripts\MsAppPackTool\MsAppPackTool.ps1
```
- This generates **msdyn_inventorymobile_b5ede_DocumentUri.msapp** under **/Solution/Export/CanvasApps**, which is compiled based on the source code at /CanvasAppSource

---

## Generate a new solution
- Run the script 
```powershell
.\scripts\SolutionPackTool\SolutionPackTool.ps1
``` 
- This generates **msdyn_InventoryMobile_managed.zip** and **msdyn_InventoryMobile.zip** under **/bin**
---

## Installing the Mobile App in Dataverse

Follow these steps to install the **Dynamics 365 Inventory On-Hand Mobile Application** in Dataverse:

1. **Navigate to the PowerApps Portal**: [https://make.powerapps.com](https://make.powerapps.com)
2. **Navigate to the Solutions tab on the left side**
3. Select **Import Solution**
4. Optional: You might need to sign the solution file first, if your organization demands solutions to be signed - [Sign Tool](https://learn.microsoft.com/en-us/dotnet/framework/tools/signtool-exe)
5. **Import either the managed or unmanaged zip file from /bin**

---

## Applying changes
- Open the Inventory On-Hand App in edit mode from the PowerApps portal
- Make the required changes there
- Download a copy of the app
- Unpack the downloaded **.msapp** into this repository by running the script
```powershell
.\scripts\MsAppUnpackTool\MsAppUnpackTool.ps1 <msapp_file_path>
```
- Your changes are now reflected in /CanvasAppSource
- You can now generate a new app binary, followed by a new solution, using the steps described above.

---

## Additional Resources
For more details, including **security roles** and **Finance and Operations Inventory On-Hand setup** , refer to the official Microsoft documentation:  
[Onboarding the Inventory On-Hand Mobile App](https://learn.microsoft.com/en-us/dynamics365/supply-chain/inventory/inventory-onhand-mobile-app).
