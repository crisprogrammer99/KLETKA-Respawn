local UEHelpers = require("UEHelpers")
local TAG = "[KletkaRespawn] "

local ABILITY_PACKAGE = "/ElevatorCore/Blueprints/Environment/SpawnPoint/GA_Respawn_Manual"
local ABILITY_CLASS_PATH = "/ElevatorCore/Blueprints/Environment/SpawnPoint/GA_Respawn_Manual.GA_Respawn_Manual_C"

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

local function get_respawn_ability_class()
    local cls = StaticFindObject(ABILITY_CLASS_PATH)
    if valid(cls) then
        return cls
    end

    print(TAG .. "GA_Respawn_Manual no estaba cargada; intentando LoadAsset...\n")
    local ok, err = pcall(function()
        LoadAsset(ABILITY_PACKAGE)
    end)
    if not ok then
        print(TAG .. "LoadAsset produjo error: " .. tostring(err) .. "\n")
    end

    cls = StaticFindObject(ABILITY_CLASS_PATH)
    return cls
end

local function get_asc(ps)
    if not valid(ps) then return nil end

    local ok, asc = pcall(function()
        return ps:GetLyraAbilitySystemComponent()
    end)
    if ok and valid(asc) then
        return asc
    end

    -- Fallback por propiedad reflejada de LyraPlayerState.
    ok, asc = pcall(function()
        return ps.AbilitySystemComponent
    end)
    if ok and valid(asc) then
        return asc
    end

    return nil
end

local function dump_players()
    print(TAG .. "===== DIAGNOSTICO v0.5 =====\n")

    local abilityClass = get_respawn_ability_class()
    print(TAG .. "GA_Respawn_Manual class=" .. fullname(abilityClass) .. "\n")

    for i, pc in ipairs(get_controllers()) do
        if valid(pc) then
            local ps = state_of(pc)
            local pawn = pawn_of(pc)
            local asc = get_asc(ps)

            print(string.format(
                "%s[%d]\n  PC=%s\n  PlayerState=%s\n  Pawn=%s\n  Estado=%s\n  ASC=%s\n",
                TAG,
                i,
                fullname(pc),
                fullname(ps),
                fullname(pawn),
                is_spectator(pawn) and "MUERTO/ESPECTADOR" or (is_hero(pawn) and "VIVO/HEROE" or "OTRO"),
                fullname(asc)
            ))
        end
    end

    print(TAG .. "===== FIN =====\n")
end

local function activate_real_respawn()
    local abilityClass = get_respawn_ability_class()
    if not valid(abilityClass) then
        print(TAG .. "ERROR: no se pudo obtener GA_Respawn_Manual_C.\n")
        return
    end

    print(TAG .. "Usando la habilidad REAL de KLETKA: " .. fullname(abilityClass) .. "\n")

    local count = 0

    for i, pc in ipairs(get_controllers()) do
        if valid(pc) then
            local oldPawn = pawn_of(pc)

            if is_spectator(oldPawn) then
                count = count + 1

                local ps = state_of(pc)
                local asc = get_asc(ps)

                print(string.format(
                    "%s===== ACTIVANDO RESPAWN REAL [%d] =====\n  PC=%s\n  PlayerState=%s\n  Pawn antes=%s\n  ASC=%s\n",
                    TAG, i, fullname(pc), fullname(ps), fullname(oldPawn), fullname(asc)
                ))

                if not valid(asc) then
                    print(TAG .. "ERROR: no se pudo obtener AbilitySystemComponent del PlayerState.\n")
                else
                    local ok, activated = pcall(function()
                        return asc:TryActivateAbilityByClass(abilityClass, true)
                    end)

                    if not ok then
                        print(TAG .. "ERROR TryActivateAbilityByClass: " .. tostring(activated) .. "\n")
                    else
                        print(TAG .. "TryActivateAbilityByClass returned=" .. tostring(activated) .. "\n")

                        if activated then
                            print(TAG .. "GA_Respawn_Manual aceptada. Esperando a que KLETKA complete su flujo normal...\n")
                        else
                            print(TAG .. "La ASC rechazo GA_Respawn_Manual. Envia este log; comprobaremos specs/tags de activacion.\n")
                        end

                        delayed(500, function()
                            if valid(pc) then
                                print(TAG .. "Pawn a 0.5s=" .. fullname(pawn_of(pc)) .. "\n")
                            end
                        end)

                        delayed(1500, function()
                            if valid(pc) then
                                print(TAG .. "Pawn a 1.5s=" .. fullname(pawn_of(pc)) .. "\n")
                            end
                        end)

                        delayed(3500, function()
                            if valid(pc) then
                                local finalPawn = pawn_of(pc)
                                print(TAG .. "Pawn a 3.5s=" .. fullname(finalPawn) .. "\n")

                                if is_hero(finalPawn) then
                                    print(TAG .. "EXITO: KLETKA ha ejecutado su flujo real de GA_Respawn_Manual y el jugador posee B_Hero_Elevator_C.\n")
                                    print(TAG .. "Comprueba movimiento, modelo visible, camara, inventario, vida e interacciones.\n")
                                elseif is_spectator(finalPawn) then
                                    print(TAG .. "FALLO: sigue en B_Spectator_C tras activar la habilidad real.\n")
                                else
                                    print(TAG .. "RESULTADO INTERMEDIO: Pawn distinto de Hero/Spectator; envia el log.\n")
                                end
                            end
                        end)
                    end
                end
            end
        end
    end

    print(TAG .. "Jugadores muertos detectados: " .. tostring(count) .. "\n")
end

print(TAG .. "v0.5 cargado.\n")
print(TAG .. "Hallazgo JMAP: B_RespawnPoint usa ASC:TryActivateAbilityByClass(GA_Respawn_Manual_C).\n")
print(TAG .. "F7 = diagnostico de Pawn + ASC + clase de respawn.\n")
print(TAG .. "F8 = activar directamente GA_Respawn_Manual en cada jugador B_Spectator_C.\n")
print(TAG .. "Esta version NO crea Pawns manualmente y NO hace UnPossess.\n")

RegisterKeyBind(Key.F7, function()
    ExecuteInGameThread(dump_players)
end)

RegisterKeyBind(Key.F8, function()
    ExecuteInGameThread(activate_real_respawn)
end)
