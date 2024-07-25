
if Config.UseTarget == true then
if Config.Targetsystem == "qb-target" then 

    
	exports[Config.Targetsystem]:AddTargetModel("v_ret_247_lotterysign",  
     { options = {{ type = "client", event = "PS_Lottery:CheckWinClient", icon = 'fas fa-chair',  label = translations.CheckWin, }}, distance = 2.5, })

elseif Config.Targetsystem == "ox-target" then 

    exports.ox_target:addModel(
    'v_ret_247_lotterysign', 
    { 
        {
            drawSprite = true,
            distance = 2.5,
            event = 'PS_Lottery:CheckWinClient',   
            icon = 'fas fa-box',              
            label = translations.CheckWin,     
            debug = false 
        }
  
    })
end

end