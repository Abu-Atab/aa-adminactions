# aa-adminactions

Made By: **Abu Atab DEV Team**

---

## Overview

**aa-adminactions** is a FiveM QBCore resource that provides an **Admin Actions** menu using **ox_lib**.
It allows authorized staff to perform safe actions on nearby players:

- Give Money (Cash / Bank / Black Money item)
- Give Items (from qb-core items list)
- Give Car (spawns instantly for the target + sets ownership + gives keys)
- Give Job (select job + grade)

The resource is **server-authoritative** (menu opens only after server permission check) and includes **strong anti-bypass validation** for all events.

---

## Showcase

### Screenshot

![Showcase Image](https://imgur.com/a/NMPeTou)
 
### Video Preview

![Watch the video](https://streamable.com/vo2if3)

---

## Core Features

* **ox_lib context menu** UI
* Actions:
  * **Give Money**: Cash / Bank / Black Money (item name from settings)
  * **Give Items**: Select any item from `QBCore.Shared.Items`
  * **Give Car**:
    * Vehicle spawns **instantly** for target
    * Vehicle stored in DB as owned
    * Keys given automatically (supports common qb-vehiclekeys events)
    * Supports custom plate + safe plate validation
  * **Give Job**:
    * Select from `QBCore.Shared.Jobs`
    * Grade validation (must exist in job grades)
* **Security**:
  * Menu opening is **server-approved only**
  * All server events enforce permission checks
  * Distance checks to prevent remote abuse
  * Cooldown for anti-spam
  * Anti-collision for vehicle plate duplication (auto-random if taken)
* **Discord logs** (optional) via `aa-log_lib`
  * Includes:
    * Admin name
    * Player name
    * Action type
    * Item/Amount/Vehicle Code/Plate
    * Job/Grade

---

## Dependencies

Required:

* [qb-core](https://github.com/qbcore-framework/qb-core)
* [ox_lib](https://github.com/overextended/ox_lib)
* [oxmysql](https://github.com/overextended/oxmysql)
* [aa-log_lib](https://github.com/abu-atab/aa-log_lib) (Discord logs)

---

## Installation

1. Put the resource in your `resources` folder:

```

aa-adminactions

````

2. Add to `server.cfg`:

```cfg
ensure aa-adminactions
````

3. Restart server.

---

## Configuration

All settings are located in:

```
settings.lua
```

### Main options

* Locale:

  * `Settings.Locale = "en"` or `"ar"`

* Command:

  * `Settings.Command = "actionsmenu"` (example)

* Permissions:

  * `Settings.Permission.Mode = "all" | "jobs" | "citizenids" | "qbadmin"`
  * `Settings.Permission.Jobs = { ... }`
  * `Settings.Permission.CitizenIds = { ... }`
  * `Settings.Permission.QBAdminPerms = { ... }`
  * Note: qbadmin mode uses your server’s ACE/command-based admin permission check.

* Money:

  * Enable/disable Cash/Bank/Black
  * Black money item name:

    * `Settings.Money.BlackItemName = "black_money"`

* Limits:

  * Max money amount
  * Max item amount

* Security:

  * `Settings.Security.MaxDistance`
  * `Settings.Security.CooldownSeconds`
  * `Settings.Security.CarRequestTimeoutSeconds`

* Vehicle:

  * Enable/disable Give Car
  * Plate validation length
  * Spawn distance

* Logging:

  * `Settings.Logging.Enabled = true/false`
  * `Settings.Logging.Webhook = "YOUR_WEBHOOK_HERE"`

---

## How To Use

### Open menu (command)

Use:

```
/actionsmenu
```

> The menu will only open if you have permission.

---

## Logs (Discord)

If you use `aa-log_lib`, enable logs and set webhook in:

```
settings.lua
```

Example:

```lua
Settings.Logging.Enabled = true
Settings.Logging.Webhook = "YOUR_WEBHOOK_HERE"
```

Log format includes:

* Admin
* Player
* Action
* Item Name / Amount
* Vehicle Code / Plate
* Job / Grade

---

## Links

* Discord: **[Abu Atab DEV](https://discord.gg/ZVrTWVvf5f)**
* GitHub: **[@Abu-Atab](https://github.com/abu-atab)**

---

## Support & Updates

Support, updates, and announcements are provided **only** through the official Discord server.

Join here:
**[Abu Atab DEV](https://discord.gg/ZVrTWVvf5f)**

---

## IMPORTANT NOTICE

This resource is **protected** and provided for **personal server use only**.
Any form of redistribution, resale, leaking, or re-uploading is **strictly prohibited**.

By using this resource, you automatically agree to all terms listed in the license file.