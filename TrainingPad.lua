-- Coloca este script en un Part llamado "TrainingPad" (o el nombre que quieras)
-- El Part debe ser CanCollide = true y tener un TouchInterest

local TrainingPad = script.Parent
local Players = game:GetService("Players")

-- Configuración
local SPEED_GAIN = 0.5          -- Cuánta velocidad gana por segundo
local MAX_SPEED = 50            -- Velocidad máxima que se puede alcanzar
local TRAINING_COOLDOWN = 1     -- Tiempo mínimo entre ganancias (segundos)

local playersTraining = {}      -- Guarda quién está entrenando

local function startTraining(player)
	if playersTraining[player] then return end
	
	local character = player.Character
	if not character then return end
	
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid then return end
	
	playersTraining[player] = true
	
	-- Bucle de entrenamiento
	task.spawn(function()
		while playersTraining[player] do
			-- Comprueba que el jugador sigue tocando el pad
			local touching = false
			for _, part in pairs(character:GetDescendants()) do
				if part:IsA("BasePart") then
					local parts = workspace:GetPartsInPart(TrainingPad)
					for _, p in pairs(parts) do
						if p:IsDescendantOf(character) then
							touching = true
							break
						end
					end
				end
			end
			
			if not touching then
				playersTraining[player] = nil
				break
			end
			
			-- Aumenta la velocidad de forma legítima
			local currentSpeed = humanoid.WalkSpeed
			if currentSpeed < MAX_SPEED then
				humanoid.WalkSpeed = math.min(currentSpeed + SPEED_GAIN, MAX_SPEED)
			end
			
			task.wait(TRAINING_COOLDOWN)
		end
	end)
end

local function stopTraining(player)
	playersTraining[player] = nil
end

-- Cuando un jugador toca el pad
TrainingPad.Touched:Connect(function(hit)
	local character = hit.Parent
	local player = Players:GetPlayerFromCharacter(character)
	
	if player and not playersTraining[player] then
		startTraining(player)
	end
end)

-- Cuando deja de tocar
TrainingPad.TouchEnded:Connect(function(hit)
	local character = hit.Parent
	local player = Players:GetPlayerFromCharacter(character)
	
	if player then
		stopTraining(player)
	end
end)

-- Limpieza si el jugador se va
Players.PlayerRemoving:Connect(function(player)
	playersTraining[player] = nil
end)
