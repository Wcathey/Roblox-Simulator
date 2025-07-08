local CarsData = {
    StarterCars = {
        {
            Id = "car_sport",
            Name = "Crimson Falcon",
            Speed = 120,
            Acceleration = 8,
            ModelName = "CrimsonFalconModel",
            Description = "Sleek and fast, perfect for beginners eager to burn the streets.",
        },
        {
            Id = "car_muscle",
            Name = "Thunderclap",
            Speed = 100,
            Acceleration = 10,
            ModelName = "ThunderclapModel",
            Description = "Powerful muscle car with a roaring engine and quick acceleration.",
        },
        {
            Id = "car_compact",
            Name = "Shadow Sprint",
            Speed = 90,
            Acceleration = 12,
            ModelName = "ShadowSprintModel",
            Description = "Small and nimble, ideal for weaving through tight city corners.",
        },
    },

    RebirthCars = {
        {
            Id = "car_nightblade",
            Name = "Nightblade",
            Speed = 140,
            Acceleration = 11,
            ModelName = "NightbladeModel",
            Description = "A stealthy, ultra-fast car with superior handling and night vision HUD.",
            Requirements = {
                Level = 15,
                Rebirth = 0,
                Achievements = {"Win 20 races"},
            },
            SpecialPerks = {"Improved drifting", "Reduced tire wear"},
        },
        {
            Id = "car_ironphantom",
            Name = "Iron Phantom",
            Speed = 130,
            Acceleration = 9,
            ModelName = "IronPhantomModel",
            Description = "A heavily armored racer built for those who dare to dominate.",
            Requirements = {
                Level = 20,
                Rebirth = 1,
                Achievements = {"Collect 100 bounties"},
            },
            SpecialPerks = {"Damage resistance", "Bonus bounty rewards"},
        },
        {
            Id = "car_stormrunner",
            Name = "Stormrunner",
            Speed = 150,
            Acceleration = 13,
            ModelName = "StormrunnerModel",
            Description = "Lightning-fast with explosive acceleration, the Stormrunner leaves opponents in the dust.",
            Requirements = {
                Level = 25,
                Rebirth = 2,
                Achievements = {"Complete all side quests"},
            },
            SpecialPerks = {"Boost cooldown reduced", "XP gain increased by 10%"},
        },
        {
            Id = "car_glacier",
            Name = "Glacier",
            Speed = 110,
            Acceleration = 8,
            ModelName = "GlacierModel",
            Description = "A cool, calm vehicle with enhanced traction for slippery conditions.",
            Requirements = {
                Level = 10,
                Rebirth = 0,
                Achievements = {"Win 5 bounties"},
            },
            SpecialPerks = {"Improved handling on wet roads"},
        },
        {
            Id = "car_phoenix",
            Name = "Phoenix",
            Speed = 135,
            Acceleration = 12,
            ModelName = "PhoenixModel",
            BadgeId = 23456793,
            Description = "Reborn from the ashes, this car boasts fiery speed and resilience.",
            Requirements = {
                Level = 30,
                Rebirth = 3,
                Achievements = {"Rebirth 5 times"},
            },
            SpecialPerks = {"Afterburner boost", "Rebirth bonus XP"},
        },
    },

    GamePassCars = {
        {
            Id = "car_neonvortex",
            Name = "Neon Vortex",
            Speed = 160,
            Acceleration = 14,
            ModelName = "NeonVortexModel",
            GamePassId = 12345678,  -- Replace with your actual Game Pass ID
            Description = "An eye-catching futuristic racer with neon lights and unmatched speed.",
            SpecialPerks = {"Customizable neon glow", "Exclusive sound effects"},
            Tradeable = true,
        },
        {
            Id = "car_royalphantom",
            Name = "Royal Phantom",
            Speed = 145,
            Acceleration = 12,
            ModelName = "RoyalPhantomModel",
            BadgeId = 34567891,
            GamePassId = 87654321,
            Description = "Luxurious and powerful, only for the elite racers.",
            SpecialPerks = {"Exclusive horn", "Armor plating"},
            Tradeable = true,
        },
        {
            Id = "car_crimsonhawk",
            Name = "Crimson Hawk",
            Speed = 155,
            Acceleration = 13,
            ModelName = "CrimsonHawkModel",
            GamePassId = 11223344,
            Description = "Sleek design with aggressive styling and blazing speed.",
            SpecialPerks = {"Boost trail effect", "VIP-only decals"},
            Tradeable = true,
        },
    },

    Requirements = {
        car_nightblade = {
            MinLevel = 15,
            MinRebirth = 0,
            RequiredAchievements = {"Win 20 races"},
        },
        car_ironphantom = {
            MinLevel = 20,
            MinRebirth = 1,
            RequiredAchievements = {"Collect 100 bounties"},
        },
        car_stormrunner = {
            MinLevel = 25,
            MinRebirth = 2,
            RequiredAchievements = {"Complete all side quests"},
        },
        car_glacier = {
            MinLevel = 10,
            MinRebirth = 0,
            RequiredAchievements = {"Win 5 bounties"},
        },
        car_phoenix = {
            MinLevel = 30,
            MinRebirth = 3,
            RequiredAchievements = {"Rebirth 5 times"},
        },
    },
}

return CarsData
