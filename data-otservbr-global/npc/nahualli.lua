local internalNpcName = "Nahualli"
local npcType = Game.createNpcType(internalNpcName)
local npcConfig = {}

npcConfig.name = internalNpcName
npcConfig.description = internalNpcName

npcConfig.health = 100
npcConfig.maxHealth = npcConfig.health
npcConfig.walkInterval = 0
npcConfig.walkRadius = 0

npcConfig.outfit = {
	lookType = 146,
	lookHead = 85,
	lookBody = 7,
	lookLegs = 12,
	lookFeet = 19,
	lookAddons = 2,
}

npcConfig.flags = {
	floorchange = false,
}

npcConfig.voices = {
	interval = 15000,
	chance = 50,
	{ text = "Astral source wares and rare creature parts for sale." },
	{ text = "If you seek astral materials, ask me for a trade." },
}

npcConfig.shop = {
	{ itemName = "orc tooth", clientId = 10196, buy = 150 },
	{ itemName = "hellspawn tail", clientId = 10304, buy = 475 },
	{ itemName = "snake skin", clientId = 9694, buy = 400 },
	{ itemName = "compass", clientId = 10302, buy = 45 },
	{ itemName = "cultish mask", clientId = 9638, buy = 280 },
	{ itemName = "cultish robe", clientId = 9639, buy = 150 },
	{ itemName = "demonic skeletal hand", clientId = 9647, buy = 80 },
	{ itemName = "fiery heart", clientId = 9636, buy = 375 },
	{ itemName = "elvish talisman", clientId = 9635, buy = 45 },
	{ itemName = "frosty heart", clientId = 9661, buy = 280 },
	{ itemName = "petrified scream", clientId = 10420, buy = 250 },
	{ itemName = "mystical hourglass", clientId = 9660, buy = 700 },
	{ itemName = "metal spike", clientId = 10298, buy = 320 },
	{ itemName = "lion's mane", clientId = 9691, buy = 60 },
	{ itemName = "piece of dead brain", clientId = 9663, buy = 420 },
	{ itemName = "piece of scarab shell", clientId = 9641, buy = 45 },
	{ itemName = "poisonous slime", clientId = 9640, buy = 50 },
	{ itemName = "polar bear paw", clientId = 9650, buy = 30 },
	{ itemName = "vampire teeth", clientId = 9685, buy = 275 },
	{ itemName = "thick fur", clientId = 10307, buy = 150 },
	{ itemName = "swamp grass", clientId = 9686, buy = 20 },
	{ itemName = "strand of medusa hair", clientId = 10309, buy = 600 },
	{ itemName = "war crystal", clientId = 9654, buy = 460 },
	{ itemName = "winter wolf fur", clientId = 10295, buy = 20 },
	{ itemName = "wyrm scale", clientId = 9665, buy = 400 },
	{ itemName = "wyvern talisman", clientId = 9644, buy = 265 },
	{ itemName = "bloody pincers", clientId = 9633, buy = 100 },
	{ itemName = "cyclops toe", clientId = 9657, buy = 55 },
	{ itemName = "sabretooth", clientId = 10311, buy = 400 },
	{ itemName = "warmaster's wristguards", clientId = 10405, buy = 200 },
	{ itemName = "crawler head plating", clientId = 14079, buy = 210 },
	{ itemName = "deepling warts", clientId = 14012, buy = 180 },
	{ itemName = "waspoid wing", clientId = 14081, buy = 190 },
	{ itemName = "blazing bone", clientId = 16131, buy = 610 },
	{ itemName = "green dragon leather", clientId = 5877, buy = 100 },
	{ itemName = "green dragon scale", clientId = 5920, buy = 100 },
	{ itemName = "demon horn", clientId = 5954, buy = 1000 },
	{ itemName = "battle stone", clientId = 11447, buy = 290 },
	{ itemName = "broken shamanic staff", clientId = 11452, buy = 35 },
	{ itemName = "elven scouting glass", clientId = 11464, buy = 50 },
	{ itemName = "flask of embalming fluid", clientId = 11466, buy = 30 },
	{ itemName = "pile of grave earth", clientId = 11484, buy = 25 },
	{ itemName = "protective charm", clientId = 11444, buy = 60 },
	{ itemName = "rope belt", clientId = 11492, buy = 66 },
	{ itemName = "brimstone shell", clientId = 11703, buy = 210 },
	{ itemName = "brimstone fangs", clientId = 11702, buy = 380 },
	{ itemName = "draken sulphur", clientId = 11658, buy = 550 },
	{ itemName = "damselfly wing", clientId = 17458, buy = 20 },
	{ itemName = "piece of swampling wood", clientId = 17823, buy = 30 },
	{ itemName = "rorc feather", clientId = 18993, buy = 70 },
	{ itemName = "elven hoof", clientId = 18994, buy = 115 },
	{ itemName = "frazzle skin", clientId = 20199, buy = 400 },
	{ itemName = "silencer claws", clientId = 20200, buy = 390 },
	{ itemName = "goosebump leather", clientId = 20205, buy = 650 },
	{ itemName = "slime heart", clientId = 21194, buy = 160 },
	{ itemName = "moohtant horn", clientId = 21200, buy = 140 },
	{ itemName = "mooh'tah shell", clientId = 21202, buy = 110 },
	{ itemName = "seacrest hair", clientId = 21801, buy = 260 },
	{ itemName = "peacock feather fan", clientId = 21975, buy = 350 },
	{ itemName = "gloom wolf fur", clientId = 22007, buy = 70 },
	{ itemName = "wereboar hooves", clientId = 22053, buy = 175 },
	{ itemName = "ogre nose ring", clientId = 22189, buy = 210 },
	{ itemName = "some grimeleech wings", clientId = 22730, buy = 1200 },
	{ itemName = "vexclaw talon", clientId = 22728, buy = 1100 },
	{ itemName = "crystallized anger", clientId = 23507, buy = 400 },
	{ itemName = "energy vein", clientId = 23508, buy = 270 },
	{ itemName = "fairy wings", clientId = 25694, buy = 200 },
	{ itemName = "little bowl of myrrh", clientId = 25702, buy = 500 },
	{ itemName = "quill", clientId = 28567, buy = 1100 },
	{ itemName = "tarantula egg", clientId = 10281, buy = 80 },
	{ itemName = "mantassin tail", clientId = 11489, buy = 280 },
	{ itemName = "gold-brocaded cloth", clientId = 40529, buy = 175 },
}

local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)

npcType.onThink = function(npc, interval)
	npcHandler:onThink(npc, interval)
end

npcType.onAppear = function(npc, creature)
	npcHandler:onAppear(npc, creature)
end

npcType.onDisappear = function(npc, creature)
	npcHandler:onDisappear(npc, creature)
end

npcType.onMove = function(npc, creature, fromPosition, toPosition)
	npcHandler:onMove(npc, creature, fromPosition, toPosition)
end

npcType.onSay = function(npc, creature, type, message)
	npcHandler:onSay(npc, creature, type, message)
end

npcType.onCloseChannel = function(npc, creature)
	npcHandler:onCloseChannel(npc, creature)
end

npcHandler:setMessage(MESSAGE_GREET, "Greetings, |PLAYERNAME|. I trade in astral source materials and rare creature parts. Ask me for a {trade}.")
npcHandler:setMessage(MESSAGE_FAREWELL, "Safe travels.")
npcHandler:setMessage(MESSAGE_WALKAWAY, "Safe travels.")
npcHandler:setMessage(MESSAGE_SENDTRADE, "Take a look at my astral wares.")
npcHandler:addModule(FocusModule:new(), npcConfig.name, true, true, true)

npcType.onBuyItem = function(npc, player, itemId, subType, amount, ignore, inBackpacks, totalCost)
	npc:sellItem(player, itemId, amount, subType, 0, ignore, inBackpacks)
end

npcType.onSellItem = function(npc, player, itemId, subtype, amount, ignore, name, totalCost)
	player:sendTextMessage(MESSAGE_TRADE, string.format("Sold %ix %s for %i gold.", amount, name, totalCost))
end

npcType.onCheckItem = function(npc, player, clientId, subType) end

npcType:register(npcConfig)
