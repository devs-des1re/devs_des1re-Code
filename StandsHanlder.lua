--// Services
local PlayersService = game:GetService("Players")
local WorkspaceService = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")
local InsertService = game:GetService("InsertService")

--// Variables
local Map = WorkspaceService:FindFirstChild("Map")
local ClothingStandsFolder = Map:FindFirstChild("ClothingStands")
local ShirtStands = ClothingStandsFolder:FindFirstChild("ShirtStands")

local RemoteEvents = ReplicatedStorage:FindFirstChild("RemoteEvents")
local PurchaseEvent = RemoteEvents:FindFirstChild("PurchaseEvent")
local TryEvent = RemoteEvents:FindFirstChild("TryEvent")

--// Functions
function TryEventOnServerEvent(player: Player)
	local character = player.Character or player.CharacterAdded:Wait()
	local Shirt = character:FindFirstChildOfClass("Shirt")
	local Pants = character:FindFirstChildOfClass("Pants")
	
	local PlayerValues = player:FindFirstChild("PlayerValues")
	local OriginalShirt = PlayerValues:FindFirstChild("OriginalShirt")
	local OriginalPants = PlayerValues:FindFirstChild("OriginalPants")
	
	if character ~= nil then
		Shirt.ShirtTemplate = OriginalShirt.Value
		Pants.PantsTemplate = OriginalPants.Value
	end
end

local function GetPrice(assetId : number)
	local asset = MarketplaceService:GetProductInfo(assetId, Enum.InfoType.Asset)
	if asset then
		return asset.PriceInRobux
	end
end

--// Loops
for _, stand in ShirtStands:GetChildren() do
	if stand:IsA("Model") and stand.Name == "ShirtStand" then
		local ShirtId = stand:FindFirstChild("ShirtId")
		local Dummy = stand:FindFirstChild("Dummy")
		local PriceBoardTextLabel = stand:FindFirstChild("BaseParts"):FindFirstChild("PriceBoard"):FindFirstChild("SurfaceGui"):FindFirstChild("TextLabel")
		if ShirtId or Dummy or PriceBoardTextLabel ~= nil then
			local ShirtInstance = Instance.new("Shirt")
			ShirtInstance.Parent = Dummy
			ShirtInstance.Name = "Shirt"
			ShirtInstance.ShirtTemplate = InsertService:LoadAsset(ShirtId.Value).Shirt.ShirtTemplate
			PriceBoardTextLabel.Text = GetPrice(ShirtId.Value)
			
			local Buttons = stand:FindFirstChild("Buttons")
			for _, clickDetector in Buttons:GetDescendants() do
				if clickDetector:IsA("ClickDetector") then
					clickDetector.MouseClick:Connect(function(player: Player)
						if clickDetector.Parent.Name == "TryButton" then
							local character = player.Character or player.CharacterAdded:Wait()
							local shirt = character:FindFirstChildOfClass("Shirt")
							if character and shirt ~= nil then
								shirt.ShirtTemplate = InsertService:LoadAsset(ShirtId.Value).Shirt.ShirtTemplate
								TryEvent:FireClient(player)
							end
						elseif clickDetector.Parent.Name == "BuyButton" then
							PurchaseEvent:FireClient(player, ShirtId.Value)
						end
					end)
				end
			end
		else
			stand:Destroy()
		end
	end
end

--// Connections
TryEvent.OnServerEvent:Connect(TryEventOnServerEvent)
