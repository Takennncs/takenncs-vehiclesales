# takenncs-vehiclesales

A simple and efficient vehicle sales system for FiveM (QBCore). Allows players to sell their vehicles to other players with a modern UI.

## ✨ Features

- 🚗 Sell vehicles to other players with `/sellvehicle [ID] [PRICE]`
- 💰 Money is transferred directly from buyer's bank to seller's bank
- 🔒 Security checks:
  - Cannot sell to yourself
  - Buyer must be within 3 meters
  - Only own vehicles can be sold
  - Checks if buyer has enough money
- 🎨 Modern dark-themed UI
- 📱 Easy to use interface
- 🔑 Automatic vehicle key transfer (if `takenncs-vehiclekeys` is installed)

## 📋 Requirements

- [QBCore Framework](https://github.com/qbcore-framework)
- [oxmysql](https://github.com/overextended/oxmysql)

## 📦 Installation

1. Download the resource
2. Place it in your `resources` folder
3. Add to your `server.cfg`:

## ensure takenncs-vehiclesales

4. Configure the settings in `config.lua` if needed

## 🚀 Usage

### As a Seller:
1. Get into the vehicle you want to sell
2. Type `/sellvehicle [playerID] [price]`
   - Example: `/sellvehicle 2 50000`
3. Wait for the buyer to accept

### As a Buyer:
1. When someone offers you a vehicle, a UI will appear
2. Click "JAH, OSTAN" to buy or "EI, KEELDU" to decline
3. Money is automatically taken from your bank

## ⚙️ Configuration

```lua
Config = {}

Config.RemoveMoneyOnSign = true  -- Always true for this version
Config.DateFormat = '%d-%m-%Y'   -- Date format for logs

Config.BlacklistedVehicles = { 
    -- Add vehicle models that cannot be sold
    -- Example: "POLICE", "AMBULANCE"
}
```

## 🔒 Security Features

- Self-sale protection: Cannot sell vehicles to yourself
- Distance check: Buyer must be within 3 meters
- Ownership verification: Only vehicles in player_vehicles table can be sold
- Double-check: Distance is checked again right before transaction
- Bank balance check: Verifies buyer has enough money

## 📝 Commands
``/sellvehicle ID HIND``

## 📄 License
This project is licensed under the MIT License

## 👨‍💻 Author
- takenncs
- GitHub: @Takennncs

## 🙏 Credits

- QBCore Team for the framework
- FontAwesome for icons
- Bootstrap for UI components
