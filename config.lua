Config = {}

Config.Framework = "qb-core"  --Integrate your framework (ESX/qb-core) here.
Config.locales = "en" -- Specify your preferred language here. (en/de)
Config.UseTarget = true -- You can disable the target system. Players can check any lottery sign to see if they've won.
Config.Targetsystem = "qb-target" --qb-target or ox-target
Config.MoneyType = "bank" --Specify whether the winner receives the money as bank or cash. (For ESX, money will be added here if it should be cash)
Config.AdminMenueCommand = "lotteryadmin" -- Here's the command to open the lottery admin menu.

Config.LotteryItem = "lotto" --Include your item for the lottery here.
Config.MaxEntries = 5 --How many entries can each person have for every draw
Config.IncreasePotAmountPerTicket = 100 -- This is the amount by which the pot grows with each ticket.
Config.LotteryDrawAuto = '0 19 * * wed' -- Specify when the lottery should be drawn. You can refer to the following resources for understanding: https://overextended.dev/ox_lib/Modules/Cron/Server and https://crontab.guru/
Config.UseCommandToCheckwin = false --If players can check if they've won the lottery using a command, specify 'true' or 'false'.
Config.CommandCheckwin = "Checklottery" -- The command to check if they've won the lottery, if UseCommandToCheckWin is set to true