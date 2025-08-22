# Localization Guide

This repository includes a PCF control that exposes localized strings to your Canvas app. Use this guide to add new labels, translate them, and keep resources in sync.

## Overview

- PCF control: `Inventory.Mobile.Controls.Localization`
- Output: a single object property, `Labels`, containing key/value pairs of localized strings
- Where strings live:
  - Control resx files: `Solution/Export/Controls/msdyn_Inventory.Mobile.Controls.Localization/Localization.<LCID>.resx`
  - Control bundle: `Solution/Export/Controls/msdyn_Inventory.Mobile.Controls.Localization/bundle.js`
  - Control manifest: `Solution/Export/Controls/msdyn_Inventory.Mobile.Controls.Localization/ControlManifest.xml`
  - Canvas copies (en-US in this repo):
    - `CanvasAppSource/Resources/Controls/Inventory.Mobile.Controls.Localization.Localization.1033.resx`
    - `CanvasAppSource/Resources/Controls/Inventory.Mobile.Controls.Localization.Localization.1033.json`
    - `CanvasAppSource/Resources/Controls/Inventory.Mobile.Controls.Localization.bundle.js`

Important: The control only emits the keys listed in an internal array inside `bundle.js`. Adding a key to a `.resx` alone is not enough—you must also add it to that key list (or rebuild from source if you have it).

---

## Quick start: add one label (en-US)

Example key: `msdyn_scm_NewHelpText`

1) Add the key to the control’s en-US resx

- File: `Solution/Export/Controls/msdyn_Inventory.Mobile.Controls.Localization/Localization.1033.resx`
- Insert inside `<root>`:

```xml
<data name="msdyn_scm_NewHelpText" xml:space="preserve">
  <value>This is the new help text.</value>
</data>
```

2) Make the control emit the key

- File: `Solution/Export/Controls/msdyn_Inventory.Mobile.Controls.Localization/bundle.js`
- At the top, find the array of keys (it starts with entries like `"msdyn_scm_Next"`, etc.). Add:

```text
"msdyn_scm_NewHelpText"
```

3) Keep Canvas resources in sync (en-US)

- File: `CanvasAppSource/Resources/Controls/Inventory.Mobile.Controls.Localization.Localization.1033.resx`
  - Add the same `<data>` entry as in step 1.
- File: `CanvasAppSource/Resources/Controls/Inventory.Mobile.Controls.Localization.Localization.1033.json`
  - Add: `"msdyn_scm_NewHelpText": "This is the new help text."`
- File: `CanvasAppSource/Resources/Controls/Inventory.Mobile.Controls.Localization.bundle.js`
  - If this bundle contains the key list, add `"msdyn_scm_NewHelpText"` there as well to mirror changes.

4) Use the label in your Canvas app

- Insert the control (e.g., named `Localization1`). Reference your string as:

```powerfx
Localization1.Labels.msdyn_scm_NewHelpText
```

---

## Add translations for other languages

For each supported language LCID, add the same key to its resx file under:

- `Solution/Export/Controls/msdyn_Inventory.Mobile.Controls.Localization/Localization.<LCID>.resx`

XML example:

```xml
<data name="msdyn_scm_NewHelpText" xml:space="preserve">
  <value>Localized value for this language</value>
</data>
```

Notes:
- If a translation is missing, runtime typically falls back to en-US; still, always include `Localization.1033.resx`.
- Preserve `xml:space="preserve"` when whitespace matters.

---

## Add a brand-new language (LCID)

1) Create the new resx file in the control folder, e.g. `Localization.1044.resx`.
2) Register it in the control manifest by adding a line like this under `<resources>`:

```xml
<resx path="Localization.1044.resx" version="1.0.0" />
```

File to edit:

- `Solution/Export/Controls/msdyn_Inventory.Mobile.Controls.Localization/ControlManifest.xml`

3) Optionally add Canvas-side copies if you maintain those per language under `CanvasAppSource/Resources/Controls/`.

---

## Optional: Generate a Power Fx table from resx

There’s a helper script that converts `.resx` to a Power Fx table for initializing labels in Canvas:

- Script: `scripts/LocalizerTool/LocalizerTool.ps1`

Usage (PowerShell):

```powershell
.\u005cscripts\LocalizerTool\LocalizerTool.ps1 -CopyToClipboard
```

Note: The script expects `.resx` in a `Translations/` folder by default. Adjust the script paths or mirror your resx files there if you want to use it.

---

## Optional: Keep JSON and bundles in sync automatically

Use the sync script to regenerate the Canvas JSON from the control’s en-US resx, and to rewrite the key arrays in both control bundles so the control emits all keys that exist in the resx.

- Script: `scripts/LocalizationSync/Sync-Localization.ps1`

Examples (PowerShell):

```powershell
# Sync JSON and both bundles from the default canonical resx
.\scripts\LocalizationSync\Sync-Localization.ps1

# Also overwrite the Canvas resx with the control resx (use with care)
.\scripts\LocalizationSync\Sync-Localization.ps1 -UpdateCanvasResx

# Specify custom paths if needed
.\scripts\LocalizationSync\Sync-Localization.ps1 -CanonicalResxPath "path\to\Localization.1033.resx"
```

Notes:
- The script rewrites the key arrays in `bundle.js` files to match the resx keys. Run it after adding/removing keys in resx.
- Keys are sorted for stable diffs.
- The regex targets the `var t=[...];` declaration pattern present in both bundles.

---

## Troubleshooting

- I added the key to `.resx` but don’t see it:
  - Ensure you also added the key to the key list in `bundle.js` (and the Canvas bundle copy, if present).
- My new language isn’t picked up:
  - Confirm its `.resx` is listed in `ControlManifest.xml`.
- Quotes/whitespace look off:
  - In JSON, escape quotes correctly.
  - In resx, use `xml:space="preserve"` when whitespace is significant.

---

## Reference paths

- Control bundle: `Solution/Export/Controls/msdyn_Inventory.Mobile.Controls.Localization/bundle.js`
- Control resx: `Solution/Export/Controls/msdyn_Inventory.Mobile.Controls.Localization/Localization.<LCID>.resx`
- Control manifest: `Solution/Export/Controls/msdyn_Inventory.Mobile.Controls.Localization/ControlManifest.xml`
- Canvas copies (en-US):
  - JSON: `CanvasAppSource/Resources/Controls/Inventory.Mobile.Controls.Localization.Localization.1033.json`
  - RESX: `CanvasAppSource/Resources/Controls/Inventory.Mobile.Controls.Localization.Localization.1033.resx`
  - Bundle: `CanvasAppSource/Resources/Controls/Inventory.Mobile.Controls.Localization.bundle.js`
