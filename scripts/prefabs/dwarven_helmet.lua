local assets =
{
    Asset("ANIM", "anim/hat_miner.zip"),
    Asset("ANIM", "anim/hat_miner_off.zip"),

    Asset( "IMAGE", "images/inventoryimages/junkerang.tex" ),
	Asset( "ATLAS", "images/inventoryimages/junkerang.xml" ),
}

local function onequip(inst, owner)

	owner.AnimState:OverrideSymbol("swap_hat", "hat_miner", "swap_hat")

    owner.AnimState:Show("HAT")
    owner.AnimState:Show("HAT_HAIR")
    owner.AnimState:Hide("HAIR_NOHAT")
    owner.AnimState:Hide("HAIR")

    if owner:HasTag("player") then
        owner.AnimState:Hide("HEAD")
        owner.AnimState:Show("HEAD_HAT")
    end

    if inst.components.fueled ~= nil then
        inst.components.fueled:StartConsuming()
    end
end

local function onunequip(inst, owner)

    owner.AnimState:ClearOverrideSymbol("swap_hat")
    owner.AnimState:Hide("HAT")
    owner.AnimState:Hide("HAT_HAIR")
    owner.AnimState:Show("HAIR_NOHAT")
    owner.AnimState:Show("HAIR")

    if owner:HasTag("player") then
        owner.AnimState:Show("HEAD")
        owner.AnimState:Hide("HEAD_HAT")
    end

    if inst.components.fueled ~= nil then
        inst.components.fueled:StopConsuming()
    end
end

local function dwarven_helmet_turnon(inst)
    local owner = inst.components.inventoryitem ~= nil and inst.components.inventoryitem.owner or nil
    if not inst.components.fueled:IsEmpty() then
        if inst._light == nil or not inst._light:IsValid() then
            inst._light = SpawnPrefab("minerhatlight")
        end
        if owner ~= nil then
            onequip(inst, owner)
            inst._light.entity:SetParent(owner.entity)
        end
        inst.components.fueled:StartConsuming()
        inst.SoundEmitter:PlaySound("dontstarve/common/minerhatAddFuel")
    elseif owner ~= nil then
        onequip(inst, owner, "hat_miner_off")
    end
end

local function dwarven_helmet_turnoff(inst)
    if inst.components.equippable ~= nil and inst.components.equippable:IsEquipped() then
        local owner = inst.components.inventoryitem ~= nil and inst.components.inventoryitem.owner or nil
        if owner ~= nil then
            onequip(inst, owner, "hat_miner_off")
        end
    end
    inst.components.fueled:StopConsuming()
    inst.SoundEmitter:PlaySound("dontstarve/common/minerhatOut")
    if inst._light ~= nil then
        if inst._light:IsValid() then
            inst._light:Remove()
        end
        inst._light = nil
    end
end

local function dwarven_helmet_unequip(inst, owner)
    onunequip(inst, owner)
    dwarven_helmet_turnoff(inst)
end

local function dwarven_helmet_perish(inst)
    local equippable = inst.components.equippable
    if equippable ~= nil and equippable:IsEquipped() then
        local owner = inst.components.inventoryitem ~= nil and inst.components.inventoryitem.owner or nil
        if owner ~= nil then
            local data =
            {
                prefab = inst.prefab,
                equipslot = equippable.equipslot,
            }
            dwarven_helmet_turnoff(inst)
            owner:PushEvent("torchranout", data)
            return
        end
    end
    dwarven_helmet_turnoff(inst)
end

local function dwarven_helmet_takefuel(inst)
    if inst.components.equippable ~= nil and inst.components.equippable:IsEquipped() then
        dwarven_helmet_turnon(inst)
    end
end

local function dwarven_helmet_onremove(inst)
    if inst._light ~= nil and inst._light:IsValid() then
        inst._light:Remove()
    end
end

local function minerhatlightfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddLight()
    inst.entity:AddNetwork()

    inst:AddTag("FX")

    inst.Light:SetFalloff(0.4)
    inst.Light:SetIntensity(.7)
    inst.Light:SetRadius(2.5)
    inst.Light:SetColour(180 / 255, 195 / 255, 150 / 255)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

    return inst
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)


    inst.AnimState:SetBank("hat_miner")
    inst.AnimState:SetBuild("minerhat")
    inst.AnimState:PlayAnimation("anim")

    inst:AddTag("hat")
    inst:AddTag("waterproofer")

    inst.entity:AddSoundEmitter()

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end


    inst:AddComponent("inspectable")
    inst:AddComponent("tradable")


    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem:SetOnDroppedFn(dwarven_helmet_turnoff)
    inst.components.inventoryitem.imagename = "junkerang"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/junkerang.xml"

    inst:AddComponent("equippable")
    inst.components.equippable.equipslot = EQUIPSLOTS.HEAD
    inst.components.equippable:SetOnEquip(dwarven_helmet_turnon)
    inst.components.equippable:SetOnUnequip(dwarven_helmet_unequip)

    inst:AddComponent("fueled")
    inst.components.fueled.fueltype = FUELTYPE.CAVE
    inst.components.fueled:InitializeFuelLevel(TUNING.MINERHAT_LIGHTTIME)
    inst.components.fueled:SetDepletedFn(dwarven_helmet_perish)
    inst.components.fueled.ontakefuelfn = dwarven_helmet_takefuel
    inst.components.fueled.accepting = true

    inst:AddComponent("waterproofer")
    inst.components.waterproofer:SetEffectiveness(TUNING.WATERPROOFNESS_SMALL)

    inst._light = nil
    inst.OnRemoveEntity = dwarven_helmet_onremove


    MakeHauntableLaunch(inst)

    return inst
end


return  Prefab("common/inventory/dwarven_helmet", fn, assets),
        Prefab("minerhatlight", minerhatlightfn)
