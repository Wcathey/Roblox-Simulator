-- src/Server/init.server.lua

print("[InitServer] Starting server initialization...")

-- Require the CrateService module
local CrateService = require(script.Services.CrateService)

print("[InitServer] CrateService initialized.")

-- Optionally, you can expose CrateService globally or return it
-- For example:
-- _G.CrateService = CrateService
-- or
-- return CrateService
