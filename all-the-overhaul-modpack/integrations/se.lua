-- Recipe balancing

-- Electric motor with rare metals
local motorRecipe = data["raw"].recipe["rare-metal-electric-motor"]
motorRecipe.normal.ingredients = {
    { "iron-gear-wheel", 1 },
    { "iron-plate", 1 },
    { "aluminum-cable", 1 },
    { "rare-metals", 1 }
}
motorRecipe.expensive.ingredients = {
    { "iron-gear-wheel", 1 },
    { "iron-plate", 1 },
    { "aluminum-cable", 1 },
    { "rare-metals", 3 }
}
motorRecipe.normal.results[1].amount = 1
motorRecipe.expensive.results[1].amount = 1

-- Core fragment processing and scrap recycling use the same numbers for balancing reasons
local function resourceYield(factor)
    factor = factor or 1

    local function f(result)
        if (not result.amount) then
            result.amount = 1
        end
        result.probability = result.probability * factor
        if (result.probability >= 1) then
            result.amount = math.floor(result.probability)
            result.probability = result.probability - result.amount
        end
        if (result.probability <= 0) then
            result.probability = nil
        end
        return result
    end

    return {
        -- High yield
        f({ probability = 0.25, name = "copper-ore" }),
        f({ probability = 0.2, name = "stone" }),
        f({ probability = 0.2, name = "iron-ore" }),
        f({ probability = 0.2, name = "tin-ore" }),
        f({ probability = 0.2, name = "lead-ore" }),
        f({ probability = 0.2, name = "flake-graphite" }),

        -- Medium yield
        f({ probability = 0.1, name = "coal" }),
        f({ probability = 0.1, name = "zircon" }),
        f({ probability = 0.1, name = "aluminum-ore" }),
        f({ probability = 0.1, name = "zinc-ore" }),
        f({ probability = 0.1, name = "nickel-ore" }),
        f({ probability = 0.1, name = "bismuth-ore" }),
        f({ probability = 0.1, name = "tungsten-ore" }),

        -- Low yield
        f({ probability = 0.05, name = "indite-ore" }),
        f({ probability = 0.05, name = "tantalite-ore" }),
        f({ probability = 0.05, name = "chromite-ore" }),
        f({ probability = 0.05, name = "manganese-ore" }),
        f({ probability = 0.05, name = "limestone" }),
        f({ probability = 0.05, name = "raw-rare-metals" }),
        f({ probability = 0.05, name = "silver-ore" }),

        -- Rare
        f({ probability = 0.025, name = "uranium-ore" }),
        f({ probability = 0.025, name = "gold-ore" }),
        f({ probability = 0.025, name = "titanium-ore" }),
        f({ probability = 0.025, name = "thorium-ore" }),
        f({ probability = 0.025, name = "cobaltite-ore" }),
    }
end

-- Core fragment processing
-- Results per 20 core fragments
data.raw.recipe["se-core-fragment-omni"].results = table.assign(
        resourceYield(20), {
            { amount = 32, name = "crude-oil", type = "fluid" },
            { amount = 16, name = "gas", type = "fluid" },
            { amount = 12, name = "water", type = "fluid" },
            { amount = 6, name = "mineral-water", type = "fluid" },
            { amount = 4, name = "se-pyroflux", type = "fluid" }
        })

-- Scrap recycling
-- Results per 1 scrap
data.raw.recipe["se-scrap-recycling"].results = table.assign(
        resourceYield(0.2), {
            { amount = 1, probability = 0.32, name = "heavy-oil", type = "fluid" }
        })

-- Remove the alternative singularity card
atom.util.recipe.removeByName("singularity-tech-card-alt")

-- Balance recipe for delivery canon capsule
data.raw.recipe["se-delivery-cannon-capsule"].result_count = 2

-- Move adaptive armour 3 to a better position in the tech tree
atom.util.Technology("se-adaptive-armour-3").replacePrerequisite("space-science-pack", "kr-lithium-sulfur-battery")

-- Remove iron and airtight seal from solid rocket fuel recipes to be consistent with other recipes and other fuels
local rocketFuelRecipes = {
    "rocket-fuel-with-ammonia",
    "rocket-fuel-with-hydrogen-chloride",
    "se-vulcanite-rocket-fuel",
    "rocket-fuel"
}
for _, recipeName in pairs(rocketFuelRecipes) do
    atom.util.Recipe(recipeName).removeIngredient("iron-plate")
    atom.util.Recipe(recipeName).removeIngredient("airtight-seal")
end

-- Balance glass
local glassVulcanite = atom.util.Recipe("se-glass-vulcanite")
glassVulcanite.replaceIngredient("sand", "quartz")
glassVulcanite.replaceIngredient("se-pyroflux", 1)
glassVulcanite.replaceResult("glass", 21)

-- Fix modifiers for "physical projectile damage" that SE overrides
local turretDamageBonus = { 0.2, 0.2, 0.2, 0.2, 0.3, 0.3, 0.3, 0.3, 0.4, 0.4, 0.4, 0.4, 0.5, 0.5, 0.5, 0.5, 0.6, 0.6 }
for i = 1, 18 do
    local tech = data.raw.technology["physical-projectile-damage-" .. i]
    for j, effect in pairs(tech.effects) do
        if (effect.turret_id) then
            tech.effects[j] = nil
        end
        if (effect.ammo_category) then
            effect.modifier = turretDamageBonus[i]
        end
    end
end