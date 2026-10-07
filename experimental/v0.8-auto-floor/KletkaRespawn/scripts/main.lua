local UEHelpers = require("UEHelpers")
local TAG = "[KletkaRespawn] "

local RESPAWN_PACKAGE = "/ElevatorCore/Blueprints/Environment/SpawnPoint/GA_Respawn_Manual"
local RESPAWN_CLASS_PATH = "/ElevatorCore/Blueprints/Environment/SpawnPoint/GA_Respawn_Manual.GA_Respawn_Manual_C"

-- Trigger principal: función NATIVA del GameMode.
local FLOOR_HOOK_PATH = "/Script/LyraGame.LyraGameMode:SetSessionCurrentFloor"

-- Fallback al terminar el movimiento del ascensor.
local ELEVATOR_PACKAGE = "/ElevatorCore/Blueprints/Cage/B_Elevator"
local FINISH_MOVE_HOOK_PATH = "/ElevatorCore/Blueprints/Cage/B_Elevator.B_Elevator_C:MulticastFinishMove"

local RESPAWN_DELAY_MS = 700

local last_floor = nil
local trigger_pending = false
local trigger_serial = 0

local function valid(obj)
    if obj == nil then return false end
    local ok, result = pcall(function() return obj:IsValid() end)
    return ok and result
end

local function fullname(obj)
    if not valid(obj) then return "<invalid>" end
    local ok, result = pcall(function() return obj:GetFullName() end)
    if ok then return tostring(result) end
    return "<valid object>"
end

local function pawn_of(pc)
    local ok, pawn = pcall(function() return pc.Pawn end)
    if ok and valid(pawn) then return pawn end
    return nil
end

local function state_of(pc)
    local ok, ps = pcall(function() return pc.PlayerState end)
    if ok and valid(ps) then return ps end
    return nil
end

local function contains(obj, text)
    if not valid(obj) then return false end
    return string.find(fullname(obj), text, 1, true) ~= nil
end

local function is_spectator(pawn)
    return contains(pawn, "B_Spectator_C")
end

local function is_hero(pawn)
    return contains(pawn, "B_Hero_Elevator_C")
end

local function get_controllers()
    return FindAllOf("PlayerController") or {}
end

local function delayed(ms, fn)
    if ExecuteInGameThreadWithDelay ~= nil then
        ExecuteInGameThreadWithDelay(ms, fn)
    else
        ExecuteWithDelay(ms, function()
            ExecuteInGameThread(fn)
        end)
    end
end

local function ensure_asset(package_path)
    local ok, err = pcall(function()
        LoadAsset(package_path)
    end)
    if not ok then
        print(TAG .. "Aviso LoadAsset(" .. package_path .. "): " .. tostring(err) .. "\n")
    end
end

local function read_scalar_param(param)
    if type(param) == "number" or type(param) == "boolean" or type(param) == "string" then
        return param
    end

    local ok, value = pcall(function() return param:get() end)
    if ok then return value end

    ok, value = pcall(function() return param:Get() end)
    if ok then return value end

    return nil
end

local function get_respawn_ability_class()
    local cls = StaticFindObject(RESPAWN_CLASS_PATH)
    if valid(cls) then return cls end
    ensure_asset(RESPAWN_PACKAGE)
    return StaticFindObject(RESPAWN_CLASS_PATH)
end

local function get_asc(ps)
    if not valid(ps) then return nil end

    local ok, asc = pcall(function()
        return ps:GetLyraAbilitySystemComponent()
    end)
    if ok and valid(asc) then return asc end

    ok, asc = pcall(function()
        return ps.AbilitySystemComponent
    end)
    if ok and valid(asc) then return asc end

    return nil
end

local function activate_respawn_for_dead(reason)
    local gm = UEHelpers:GetGameModeBase()
    if not valid(gm) then
        print(TAG .. "Respawn ignorado: no hay AuthorityGameMode. Debes ser HOST.\n")
        return
    end

    local ability_class = get_respawn_ability_class()
    if not valid(ability_class) then
        print(TAG .. "ERROR: GA_Respawn_Manual_C no disponible.\n")
        return
    end

    local dead_count = 0
    local activated_count = 0

    print(TAG .. "===== RESPAWN " .. tostring(reason) .. " =====\n")

    for i, pc in ipairs(get_controllers()) do
        if valid(pc) and is_spectator(pawn_of(pc)) then
            dead_count = dead_count + 1

            local ps = state_of(pc)
            local asc = get_asc(ps)

            print(string.format(
                "%sMuerto [%d]: PC=%s | ASC=%s\n",
                TAG, i, fullname(pc), fullname(asc)
            ))

            if valid(asc) then
                local ok, activated = pcall(function()
                    return asc:TryActivateAbilityByClass(ability_class, true)
                end)

                if not ok then
                    print(TAG .. "ERROR TryActivateAbilityByClass: " .. tostring(activated) .. "\n")
                elseif activated then
                    activated_count = activated_count + 1
                    print(TAG .. "GA_Respawn_Manual aceptada para jugador [" .. tostring(i) .. "].\n")
                else
                    print(TAG .. "GA_Respawn_Manual rechazada para jugador [" .. tostring(i) .. "].\n")
                end
            else
                print(TAG .. "ERROR: ASC no disponible para jugador [" .. tostring(i) .. "].\n")
            end
        end
    end

    print(TAG .. "Muertos detectados=" .. tostring(dead_count) ..
        " | respawns activados=" .. tostring(activated_count) .. "\n")
    print(TAG .. "===== FIN RESPAWN =====\n")
end

local function schedule_level_respawn(reason)
    if trigger_pending then
        print(TAG .. "Trigger duplicado ignorado: " .. tostring(reason) .. "\n")
        return
    end

    trigger_pending = true
    trigger_serial = trigger_serial + 1
    local my_serial = trigger_serial

    print(TAG .. "Cambio/llegada de planta detectado (" .. tostring(reason) ..
        "). Respawn automatico en " .. tostring(RESPAWN_DELAY_MS) .. " ms.\n")

    delayed(RESPAWN_DELAY_MS, function()
        if my_serial ~= trigger_serial then return end
        activate_respawn_for_dead("AUTOMATICO CAMBIO DE PLANTA")
        trigger_pending = false
    end)
end

local function install_floor_hook()
    local fn = StaticFindObject(FLOOR_HOOK_PATH)
    print(TAG .. "SetSessionCurrentFloor object=" .. fullname(fn) .. "\n")

    local ok, pre_id, post_id = pcall(function()
        return RegisterHook(
            FLOOR_HOOK_PATH,
            function(Context, NewFloorParam)
                local new_floor = read_scalar_param(NewFloorParam)
                print(TAG .. "SetSessionCurrentFloor PRE: NewFloor=" ..
                    tostring(new_floor) .. " | last_floor=" .. tostring(last_floor) .. "\n")
            end,
            function(Context, NewFloorParam)
                local new_floor = read_scalar_param(NewFloorParam)
                print(TAG .. "SetSessionCurrentFloor POST: NewFloor=" ..
                    tostring(new_floor) .. " | last_floor=" .. tostring(last_floor) .. "\n")

                if type(new_floor) == "number" then
                    if last_floor == nil then
                        last_floor = new_floor
                        print(TAG .. "Planta inicial registrada=" .. tostring(new_floor) ..
                            "; no se hace respawn por carga inicial.\n")
                        return
                    end

                    if new_floor == last_floor then
                        print(TAG .. "Misma planta; evento ignorado.\n")
                        return
                    end

                    local old_floor = last_floor
                    last_floor = new_floor
                    schedule_level_respawn(
                        "SetSessionCurrentFloor " .. tostring(old_floor) .. " -> " .. tostring(new_floor)
                    )
                else
                    schedule_level_respawn("SetSessionCurrentFloor (NewFloor no legible)")
                end
            end
        )
    end)

    if ok then
        print(TAG .. "Hook NATIVO SetSessionCurrentFloor instalado. ids=" ..
            tostring(pre_id) .. "," .. tostring(post_id) .. "\n")
        return true
    else
        print(TAG .. "ERROR hook SetSessionCurrentFloor: " .. tostring(pre_id) .. "\n")
        return false
    end
end

local function install_finish_move_hook()
    ensure_asset(ELEVATOR_PACKAGE)

    local fn = StaticFindObject(FINISH_MOVE_HOOK_PATH)
    print(TAG .. "MulticastFinishMove object=" .. fullname(fn) .. "\n")

    local ok, pre_id, post_id = pcall(function()
        return RegisterHook(
            FINISH_MOVE_HOOK_PATH,
            function(Context)
                print(TAG .. "MulticastFinishMove PRE detectado.\n")
            end,
            function(Context)
                print(TAG .. "MulticastFinishMove POST detectado.\n")
                schedule_level_respawn("MulticastFinishMove")
            end
        )
    end)

    if ok then
        print(TAG .. "Hook MulticastFinishMove instalado. ids=" ..
            tostring(pre_id) .. "," .. tostring(post_id) .. "\n")
        return true
    else
        print(TAG .. "ERROR hook MulticastFinishMove: " .. tostring(pre_id) .. "\n")
        return false
    end
end

local function dump_players()
    print(TAG .. "===== DIAGNOSTICO v0.8 =====\n")
    print(TAG .. "last_floor=" .. tostring(last_floor) ..
        " | trigger_pending=" .. tostring(trigger_pending) .. "\n")

    for i, pc in ipairs(get_controllers()) do
        if valid(pc) then
            local p = pawn_of(pc)
            print(string.format(
                "%s[%d] %s | Pawn=%s\n",
                TAG, i,
                is_spectator(p) and "MUERTO/ESPECTADOR"
                    or (is_hero(p) and "VIVO/HEROE" or "OTRO"),
                fullname(p)
            ))
        end
    end

    print(TAG .. "===== FIN =====\n")
end

print(TAG .. "v0.8 cargado.\n")
print(TAG .. "AUTO principal: LyraGameMode:SetSessionCurrentFloor(int NewFloor).\n")
print(TAG .. "AUTO fallback: B_Elevator_C:MulticastFinishMove.\n")
print(TAG .. "F7 = diagnostico.\n")
print(TAG .. "F8 = respawn manual probado de v0.5.\n")
print(TAG .. "Hooks de puertas eliminados.\n")

local floor_hook_ok = install_floor_hook()
local finish_hook_ok = install_finish_move_hook()

print(TAG .. "Resumen hooks: SetSessionCurrentFloor=" .. tostring(floor_hook_ok) ..
    " | MulticastFinishMove=" .. tostring(finish_hook_ok) .. "\n")

RegisterKeyBind(Key.F7, function()
    ExecuteInGameThread(dump_players)
end)

RegisterKeyBind(Key.F8, function()
    ExecuteInGameThread(function()
        activate_respawn_for_dead("MANUAL F8")
    end)
end)
