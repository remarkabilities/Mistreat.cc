script_key="key here";

getgenv().Mistreat = {
    Intro = false,
    Silent = {
        hitParts = {"Head", "UpperTorso", "HumanoidRootPart", "LowerTorso"},
        FOV = 30,
        Prediction = 0.125,
        knockCheck = true,
    },
    Camlock = {
        Key = "C",
        ClosestPart = false,
        Prediction = 0.25,
        Ground = {
            Part = "HumanoidRootPart",
            SmoothingValue = 0.06663,
            EasingStyle = "Exponential",
            EasingDirection = "InOut",
        },
        Jump = {
            JumpPart = "UpperTorso",
            SmoothingValue = 0.09352,
            EasingStyle = "Sine",
            EasingDirection = "InOut",
            JumpoffsetX = 1.5,
            JumpoffsetY = 0 
        },
        Settings = {
            SendNotification = false,
            DisableOnTargetDeath = true,
            DisableOnPlayerDeath = true,
        }
    },
    AntiAimViewer = {
        AntiAimViewer = false,
    },
    Spin = {
        Speed = 3600,
        BindKey = 'V',
        Angle = 180,
    },
    Resolver = {
        Enabled = true,
        Universal = true,
        AutoDetect = true,
    },
    Esp = {
        Enabled = true,
        Key = "B"
    },
    AutoPredictionSets = {
        Enabled = true,
        Mode = "V2", -- Custom/Default/V1/V2
        PingSets = {
            P10_20 = "0.11",
            P20_30 = "0.11",
            P30_40 = "0.11",
            P40_50 = "0.11",
            P50_60 = "0.11",
            P60_70 = "0.11",
            P70_80 = "0.2",
            P80_90 = "0.4",
            P90_100 = "0.4",
            P100_110 = "0.11",
            P110_120 = "0.11",
            P120_130 = "0.11",
            P130_140 = "0.11",
            P140_150 = "0.11",
            P150_160 = "0.11",
            P160_170 = "0.11",
            P170_180 = "0.11",
            P180_190 = "0.11",
            P190_200 = "0.11",
            P200_INF = "0.11",
        }
    }
}

loadstring(game:HttpGet("https://api.luarmor.net/files/v3/loaders/3f08456f80d55484b26f5861f96567d6.lua"))()
