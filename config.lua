Config = {}
Config.Debug = false
Config.Framework = "qb-core"  --Integrate your framework (ESX/qb-core) here.
Config.locales = "en" -- Specify your preferred language here. (en/de)
Config.Inventory = "Old-QbInventory"  -- Choose your inventory system: New-QbInventory, Old-QbInventory, OX-Inventory, qs-inventory or custom
Config.UseTarget = true -- You can disable the target system. Players can check any lottery sign to see if they've won.
Config.TargetSystem = "qb-target" --qb-target or ox-target
Config.MoneyType = "bank" -- Specify whether the seller receives money as bank or cash (for ESX, specify 'money' if required)
Config.AdminMenueCommand = "lotteryadmin" -- Here's the command to open the lottery admin menu.
Config.Progressbar =  "qb-progressbar"  --qb-progressbar/ ESX-Progressbar/ox-progressbar/ ox-progressCircle/ custom-progressbar
Config.OpenLotteryTicketDuration = 5000
Config.OpenLotteryTicketLabel = "Lottery ticket is filled out!"

Config.LotteryItem = "lotteryticket" --Include your item for the lottery here.
Config.MaxEntries = 5 --How many entries can each person have for every draw
Config.IncreasePotAmountPerTicket = 100 -- This is the amount by which the pot grows with each ticket.
Config.LotteryDrawAuto = '0 19 * * sat' -- Specify when the lottery should be drawn. You can refer to the following resources for understanding: https://overextended.dev/ox_lib/Modules/Cron/Server and https://crontab.guru/
Config.UseCommandToCheckwin = false --If players can check if they've won the lottery using a command, specify 'true' or 'false'.
Config.CommandCheckwin = "Checklottery" -- The command to check if they've won the lottery, if UseCommandToCheckWin is set to true

Config.TargetPropModels = { -- Props for the targetsystem to check if the player has won the lottery
"v_ret_247_lotterysign",
--Add as many as you want here.

}


----Discord Webhook----

Config.ServerName = "Atombude" --Put here your servername
Config.BotName = "PlexScripts" --Put here your name from the Bot
Config.IconURL = "https://i.imgur.com/PB4LO09.png" --Put here your Boticon
Config.Titel = "Parkingmeter system" --Put here tet titel from the message

--Your Discordweblink need to be placed in server/server_functions.lua line 66