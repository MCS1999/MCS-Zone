Change `MapleHearts` to `YourFramework` RUN SQL > PROFIT 


you will need to edit the following resources to get this to work if you are not familiar with developing and figuring things out on your own then this resource is not for you.

qb-multicharacter>client 
`replace` > TriggerEvent('mhrp-clothes:client:CreateFirstCharacter') with
            TriggerEvent('mhrp_charCreation:defaultReset')

`replace` > TriggerEvent('mhrp-clothing:client:loadPlayerClothing', data, charPed) with
            TriggerServerEvent('mhrp_charCreation:get_character_current')

qb-spawn>client 
    when ever your character is being spawned you need to run this event `TriggerServerEvent('mhrp_charCreation:get_character_current'`


there is no event yet for housing but all you would need to do is create an event to open the outfits function and you should be set this is FARRRR from being perfect but its functionality works you can create your character, you can use the stores and you can save and load outfits it has many more features and much potential but that will come with time.

if you have any issue post this on the github and it will be fixed whenever i have time or someone makes a pr :D enjoy!