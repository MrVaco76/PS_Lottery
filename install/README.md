## Support 

Join our Discord for support and feature scripts: https://discord.gg/XQHVstYRGx


## What does it do exactly?
This script enables you to integrate a lottery feature into your server. Players can purchase tickets that contribute to a growing prize pool when used. The increment of the prize pool per ticket purchase is configurable through the settings. The maximum ticket limit per person is also configurable in the configuration file.

You can manage all aspects of the lottery using the /lotteryadmin command (customizable via the configuration file). The lottery drawing can be automated according to your configuration settings.

Every aspect of the system is customizable, including the notification system (client-side and server-side functions).

## Installation instructions

1. Download the script.
2. Place it in your resources folder.
3. import the sql file to you database.
4. Edit the configuration file.
5. Add the item to your inventory.
6. Add the picture to your inventory.
7. Add the following line to your server.cfg: ensure PS_Lottery.
8. Add the permission "Lottery.AdminMenue" to your server.cfg 
9. Restart the server. 

## Depencies 

- ox-lib
- oxmysql

item for qb-core: 

	['lotteryticket']  = {['name'] = 'lotteryticket', ['label'] = 'lotteryticket', ['weight'] = 200, ['type'] = 'item',  ['image'] = 'lotteryticket.png',                    ['unique'] = false, ['useable'] = true, ['shouldClose'] = true, ['combinable'] = nil,  
    ['description'] = 'Included with the ticket, you're entered into the lottery draw next Saturday and have a chance at the jackpot.'},

item for ox-inventory: 

['lotteryticket'] = {
    label = 'Lottoschein',
    weight = 5,
    stack = true,
    close = true,
    client = {
        image = 'lotteryticket.png',
        usabe = true
    }
},


If you have any additional details or specific configuration options you'd like to include, feel free to let me know!


PlexScripts
