return {
    {
        name = "Spawn Area Crate",
        id = "spawn_area_crate",
        description = "A mysterious crate containing various items to boost your racing experience!",
        image = "rbxassetid://12345678", -- Replace with actual crate image ID
        cost = {
            single = 10,
            triple = 25
        },
        items = {
            -- 🔹 Speed Potions
            {
                name = "Speed Potion +10%",
                image = "rbxassetid://117247241781112",
                rarity = "Common",
            },
            {
                name = "Speed Potion +25%",
                image = "rbxassetid://12345679",
                rarity = "Uncommon",
            },
            {
                name = "Speed Potion +50%",
                image = "rbxassetid://12345680",
                rarity = "Epic",
            },
            {
                name = "Speed Potion +70%",
                image = "rbxassetid://12345681",
                rarity = "Legendary",
            },

            -- 🔹 Handling Potions
            {
                name = "Handling Potion +10%",
                image = "rbxassetid://75078388969211",
                rarity = "Common",
            },
            {
                name = "Handling Potion +25%",
                image = "rbxassetid://12345683",
                rarity = "Uncommon",
            },
            {
                name = "Handling Potion +50%",
                image = "rbxassetid://12345684",
                rarity = "Epic",
            },
            {
                name = "Handling Potion +70%",
                image = "rbxassetid://12345685",
                rarity = "Legendary",
            },

            -- 🔹 Fuel Potions (more fuel from races)
            {
                name = "Fuel Potion +10%",
                image = "rbxassetid://95034421336443",
                rarity = "Common",
            },
            {
                name = "Fuel Potion +25%",
                image = "rbxassetid://137767702349518",
                rarity = "Uncommon",
            },
            {
                name = "Fuel Potion +50%",
                image = "rbxassetid://135275123278916",
                rarity = "Epic",
            },
            {
                name = "Fuel Potion +70%",
                image = "rbxassetid://117689003489876",
                rarity = "Legendary",
            },

            -- 🔹 Gem Potions (more gems earned)
            {
                name = "Gem Potion +10%",
                image = "rbxassetid://109272599161386",
                rarity = "Rare",
            },
            {
                name = "Gem Potion +25%",
                image = "rbxassetid://12345690",
                rarity = "Epic",
            },
            {
                name = "Gem Potion +50%",
                image = "rbxassetid://12345691",
                rarity = "Legendary",
            },

            -- 🔹 Rare Power Item
            {
                name = "Nitro Boost (Max Speed)",
                image = "rbxassetid://131096858511486",
                rarity = "Mythic",
            },

            -- 🗺️ Exotic Items
            {
                name = "Secret Map Piece",
                image = "rbxassetid://12345690",
                rarity = "Exotic",
            },
            {
                name = "Exotic Car Key",
                image = "rbxassetid://12345691",
                rarity = "Exotic",
            },
            {
                name = "Mystic Engine Upgrade",
                image = "rbxassetid://12345692",
                rarity = "Exotic",
            },
            {
                name = "Transformation Crystal",
                image = "rbxassetid://12345693",
                rarity = "Exotic",
            }
        },
        rarityWeights = {
            Common = 50,
            Uncommon = 30,
            Rare = 15,
            Epic = 4,
            Legendary = 1,
            Mythic = 0.5,
            Exotic = 0.2,
        }
    }
    -- Future crates can be added here
    -- {
    --     name = "Premium Crate",
    --     id = "premium_crate",
    --     description = "Premium items with better odds!",
    --     image = "rbxassetid://...",
    --     cost = {
    --         single = 50,
    --         triple = 120
    --     },
    --     items = {...},
    --     rarityWeights = {...}
    -- }
}
