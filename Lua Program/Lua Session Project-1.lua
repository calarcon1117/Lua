--Intro to Software Engineering
--Christopher Alarcon
--Session project for Dr. Xiaolong WU - Trident University

function onload()


    --The names (in quotes) are the values I gave the object within the GUI
    --0 is reserved for Aces.
    cardNameTable= {
        ["Two"]=2, ["Three"]=3, ["Four"]=4, ["Five"]=5,
        ["Six"]=6, ["Seven"]=7, ["Eight"]=8, ["Nine"]=9, ["Ten"]=10,
        ["Jack"]=10, ["Queen"]=10, ["King"]=10, ["Ace"]=0
    }

    --This is what ties a scripting zone to a player/dealer
    --color is the player's color, z is the player's scripting zone
    --Dealer comes first!
    objectSets = {
        {color="Dealer", zone=getObjectFromGUID("275a5d"), value=0, count=0},
        {color="Purple", zone=getObjectFromGUID("63ef4e"), value=0, count=0},
        {color="Blue", zone=getObjectFromGUID("423ae1"), value=0, count=0},
        {color="Teal", zone=getObjectFromGUID("5c2692"), value=0, count=0},
        {color="Green", zone=getObjectFromGUID("595fa9"), value=0, count=0},
        {color="Yellow", zone=getObjectFromGUID("5b82fd"), value=0, count=0},
        {color="Orange", zone=getObjectFromGUID("38b2d7"), value=0, count=0},
        {color="Red", zone=getObjectFromGUID("8b37f7"), value=0, count=0},
        {color="Brown", zone=getObjectFromGUID("1c13af"), value=0, count=0}
    }

    --Object on which buttons are placed for things like "deal cards"
    cardHandler = getObjectFromGUID("77a0c3")
    bonusTimer = getObjectFromGUID("3cce5b")

    --Where decks are stored
    deckBag = {
        getObjectFromGUID("996d26")
    }

    --A zone where the deck is located in the GUI
    deckZone = getObjectFromGUID("885bf4")
    bonusZone = getObjectFromGUID("3c31e1")


    lockObjects()
    createButtons()
    checkForDeck()
    findCardsToCount()

    --Before executing the above needs to clear, like a check list
    --END OF CONFIGURATION SECTION
end





--Stops unnecessary movement of objects that may prevent program from executing

function lockObjects()
    for i, list in ipairs(objectLockdown) do
        list.interactable = false
    end
end

function onObjectPickedUp(color, object)
    if color ~= "Black" and not Player[color].promoted and not Player[color].host then
        if object.getPosition()[3] < -16 then
            object.translate({0,0.15,0})
            print(color .. ' picked up a ' .. object.tag .. ' titled "' .. object.getName() .. '" from the hidden zone!')
        end
        for i, set in ipairs(objectSets) do
            local objectsInZone = set.zone.getObjects()
            for i, found in ipairs(objectsInZone) do
                if found.tag == "Deck" or found.tag == "Card" then
                    if found == object then
                        object.translate({0,0.15,0})
                    end
                end
            end
        end
    end
end






--CARD ZONE COUNTING SECTION





--Looks for any cards in the scripting zones and sends them on to obtainCardValue
--Triggers next step, addValues(), after that
function findCardsToCount()
    for hand, set in ipairs(objectSets) do
        local cardList = findCa
        rdsInZone(set.zone)
        local deckList = findDecksInZone(set.zone)
        else
            objectSets[hand].zone.editButton({index=0, label="0"})
            set.value = 0
            set.count = 0
        end
    end
    timerStart()
end

--Gets a list of names from the card if they are face up
function obtainCardNames(hand, cardList, deckList)
    local cardNames = {}
    local facedownCount = 0
    local facedownCard = nil
    for i, card in ipairs(cardList) do
        local z = card.getRotation().z
        if z > 345 or z < 15 then
            table.insert(cardNames, card.getName())
        elseif hand == 1 then
            facedownCount = facedownCount + 1
            facedownCard = card
        end
    end
    for i, deck in ipairs(deckList) do
        local z = deck.getRotation().z
        if z > 345 or z < 15 then
            for j, card in ipairs(deck.getObjects()) do
                table.insert(cardNames, card.nickname)
            end
        end
    end
    objectSets[hand].count = #cardNames
    addCardValues(hand, cardNames, facedownCount, facedownCard)
end

--Adds card values from their names
function addCardValues(hand, cardNames, facedownCount, facedownCard)
    local value = 0
    local aceCount = 0
    local sevenCount = 0
    local tenCount = 0
    local dealerBust = 0
    local stopCount = false
    for i, card in ipairs(cardNames) do
        for name, v in pairs(cardNameTable) do
            if card == name then
                if v == 0 then aceCount = aceCount + 1
                elseif v == 7 then sevenCount = sevenCount + 1
                elseif v == 10 then tenCount = tenCount + 1 end
                if hand == 1 then
                    if objectSets[hand].count > 4 or dealerBust > 0 then
                        stopCount = true
                    end
                        stopCount = true
                    elseif sevenCount == 3 and objectSets[hand].count == 3
                        stopCount = true
                    end
                end
                if not stopCount then value = value + v end
            end
        end
    end
    if aceCount > 0 and not stopCount then
        for i=1, aceCount do
            if value <= 10 then
                if aceCount == 1 and (tenCount == 1 and value == 10)
                    if aceCount > 1 and value == 10 then value = value + 1 else
                        if hand == 1 and facedownCount < 1 then value = value + 1 else
                            value = value + 11
                        end
                    end
                end
            else
                value = value + 1
            end
        end
    end
    displayResult(hand, value)

    --Checking for blackjack
    if hand == 1 then
        if #cardNames == 1 and facedownCount == 1 then
            checkForBlackjack(value, facedownCard)
        else
            revealBool = false
        end
    end
end

--Guess what THIS does.
function checkForBlackjack(value, facedownCard)
    local facedownValue = nil
    for name, v in pairs(cardNameTable) do
        if name == facedownCard.getName() then
            facedownValue = v
        end
    end
    if (facedownValue==0 and value==10) or (facedownValue==10 and value==11) then
        if revealBool == true then
            facedownCard.flip()
            broadcastToAll("Dealer has Blackjack!", {0.9,0.2,0.2})
            revealBool = false
        else
            revealBool = true
        end
    end
end




--DECK FINDINGSECTION





--checks for current deck when the tool loads, triggered by onload
function checkForDeck()
    local objectsInZone = deckZone.getObjects()
    for i, deck in ipairs(objectsInZone) do
        if deck.tag == "Deck" then
            mainDeck = deck
            break
        end
    end
end




--CARD DEALING SECTION


--Used to clear all cards
function clearCards(zoneToClear)
    local objectsInZone = zoneToClear.getObjects()
    for i, object in ipairs(objectsInZone) do
        local tag = object.tag
        if tag == "Card" or tag == "Deck" then
            destroyObject(object)
        end
    end
end

function clearCardsOnly(zoneToClear)
    local objectsInZone = zoneToClear.getObjects()
    for i, object in ipairs(objectsInZone) do
        local tag = object.tag
        if tag == "Card" or tag == "Deck" then
            destroyObject(object)
        end
    end
end

--Deals cards to the player. whichCard is a table with which # cards to deal
function dealDealer(whichCard)
    for i, v in ipairs(whichCard) do
        local pos = findCardPlacement(objectSets[1].zone, v)
        if v ~= 2 or (revealDealer and bonusCount < 5) then
            placeCard(pos, true)
        else
            placeCard(pos, false)
        end
    end
end

--Deals to player using same method as dealDealer
function dealPlayer(color, whichCard)
    for i, v in ipairs(whichCard) do
        local set = findObjectSetFromColor(color)
        local pos = findCardPlacement(set.zone, v)
        placeCard(pos, true)
    end
end

--Called by other functions to actually take the card needed
function placeCard(pos, flipBool)
    if mainDeck ~= nil then
        lastCard = mainDeck.takeObject({position=pos, flip=flipBool})
    else
        print("ERROR: No deck found")
    end
end




--FIND FUNCTION SECTION

--Returns any cards found in a scripting zone (zone)
function findCardsInZone(zone)
    local zoneObjectList = zone.getObjects()
    local foundCards = {}
    for i, object in ipairs(zoneObjectList) do
        if object.tag == "Card" then
            table.insert(foundCards, object)
        end
    end
    return foundCards
end



--Used to find card dealing positions, based on zone and which position the card should be in
function findCardPlacement(zone, spot)
    if zone == objectSets[1].zone then
        return {6.5 - 2.6 * (spot-1), 1.8, -4.84}
    else
        local pos = zone.getPosition()
        if spot <= 3 then
            return {pos.x+1-(1*(spot-1)), pos.y+0.5+(0.5*(spot-1)), pos.z-0.5}
        else
            return {pos.x+1-(1*(spot-4)), pos.y+0.5+(0.5*(spot-4)), pos.z+0.5}
        end
    end
end



--BUTTON CLICK FUNCTION SECTION

function hitCard(zone, color)
    if (color == "Black" or Player[color].promoted or Player[color].host) and color ~= "White" then
        local cardsInZone = #findCardsInZone(zone)
        local decksInZone = #findDecksInZone(zone)
        local pos = findCardPlacement(zone, cardsInZone + decksInZone + 1)
        placeCard(pos, true)
    end
end

function dealButtonPressed(o, color)
    if (color == "Black" or Player[color].promoted or Player[color].host) and color ~= "White" then
        if not lockout then
            lockoutTimer(10)
            if mainDeck == nil or mainDeck.getQuantity() < 40 then
                newDeck()
                deckBool = true
            end
            for i, set in pairs(objectSets) do
                clearPlayerActions(set.zone)
                clearCardsOnly(set.zone)
            end
            if bonusCount ~= 0 then
                countBonus()
            elseif bonusActive and bonusCount == 0 then
                clearBonus()
            end
            local playerList = getSeatedPlayers()
            --local playerList = {"Brown", "Red", "Orange", "Yellow", "Green", "Teal", "Blue", "Purple"} --debug line
            dealOrder = {}
                        break
                    end
                end
            end
            startLuaCoroutine(Global, "dealInOrder")
        else
            broadcastToColor("Error: Button delay is active.\nWait a moment then try again.", color, {1,0.25,0.25})
        end
    end
end

function newDeck()
    if mainDeck ~= nil then
        destroyObject(mainDeck)
    end
    obtainDeck()
end

function dealInOrder()
    local firstToGo = nil
    if deckBool then
        waitFrames(120)
        deckBool = false
    end
    if firstToGo ~= nil then
        delayedCallback('whoGoesFirst', {set=firstToGo}, 1)
    else
        concludeLockout()
    end
    return 1
end

function whoGoesFirst(table)
    if table.set.value > 21 then
        passPlayerActions(table.set.zone)
    else
        createPlayerActions(table.set.zone)
    end
    Timer.destroy(table.id)
    concludeLockout()
end

function createPlayerActions(zone)
    zone.createButton({
        label="Stand", click_function="playerStand", function_owner=nil,
        position={1,-1.7,3.05}, rotation={0,180,0}, height=400, width=400, font_size=140
    })
    zone.createButton({
        label="Hit", click_function="playerHit", function_owner=nil,
        position={-1,-1.7,3.05}, rotation={0,180,0}, height=400, width=400, font_size=140
    })
end

function clearPlayerActions(zone)
    local zoneButtons = #zone.getButtons()
    if zoneButtons > 1 then
        for i = 1, zoneButtons - 1 do zone.removeButton(i) end
    end
end

function passPlayerActions(zone)
    local nextInLine = nil
    for i, set in ipairs(reverseTable(objectSets)) do
        if set.color == "Dealer" then
            revealHandZone(set.zone)
            break
        elseif set.zone == zone then
            nextInLine = i + 1
        elseif i == nextInLine then
            local cardsInZone = #findCardsInZone(set.zone)
            local decksInZone = #findDecksInZone(set.zone)
            if (cardsInZone ~= 0 or decksInZone ~= 0) and set.value <= 21 then
                createPlayerActions(set.zone)
                break
            end
            nextInLine = nextInLine + 1
        end
    end
end

function playerHit(zone, color)
    local set = findObjectSetFromZone(zone)
    if color == set.color or color == "Black" or Player[color].promoted or Player[color].host then
        if not lockout then
            lockoutTimer(1.5)
            if set.value > 21 then
                clearPlayerActions(zone)
            else
                forcedCardDraw(zone)
                delayedCallback('checkForBust', {set=set}, 1.3)
            end
        else
            broadcastToColor("Error: Button delay is active.\nWait a moment then try again.", color, {1,0.25,0.25})
        end
    end
end


function checkForBust(table)
    if table.set.value > 21 then
        clearPlayerActions(table.set.zone)
        passPlayerActions(table.set.zone)
    end
    Timer.destroy(table.id)
end

function playerStand(zone, color)
    local set = findObjectSetFromZone(zone)
    if color == set.color or color == "Black" or Player[color].promoted or Player[color].host then
        if not lockout then
            lockoutTimer(1)
            clearPlayerActions(zone)
            passPlayerActions(zone)
        else
            broadcastToColor("Error: Button delay is active.\nWait a moment then try again.", color, {1,0.25,0.25})
        end
    end
end





--BUTTON CREATION SECTION

--Button creation, trigger is in onload()
function createButtons()
    --Card count displays, get created first so they have index of 0 on their zones
    for i, v in ipairs(objectSets) do
        local pos = {0,-1.7,3.05} if i==1 then pos = {0,-1.7,-2.865} end
        local rot = {0,180,0} --if i==1 then rot = {0,0,0} end
        v.zone.createButton({
            label="0", click_function="hitCard", function_owner=nil,
            position=pos, rotation=rot, height=560, width=560, font_size=400
        })
    end
    cardHandler.createButton({
        label="Deal\ncards", click_function="dealButtonPressed", function_owner=nil,
        position={-0.46,0.19,-0.19}, rotation={0,0,0}, width=450, height=450, font_size=150
    })
end
