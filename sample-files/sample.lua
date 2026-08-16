-- Lua sample: tables, metatables, closures, varargs, long strings.

local json = require("json")

local DEFAULT_HEX = "#EEFFFF"
local MAX_DEPTH = 8
local HEX_PATTERN = "^#%x%x%x%x%x%x$"

local TokenKind = {
    COMMENT = "comment",
    KEYWORD = "keyword",
    STRING = "string",
    NUMBER = "constant.numeric",
}

local Swatch = {}
Swatch.__index = Swatch

function Swatch.new(label, hex, tags)
    local self = setmetatable({}, Swatch)

    self.label = label
    self.hex = hex or DEFAULT_HEX
    self.tags = tags or {}

    if not self.hex:match(HEX_PATTERN) then
        error(("Invalid hex value: %s"):format(self.hex), 2)
    end

    return self
end

function Swatch:describe()
    return string.format("%s => %s", self.label, self.hex)
end

function Swatch:luminance()
    local red = tonumber(self.hex:sub(2, 3), 16)
    local green = tonumber(self.hex:sub(4, 5), 16)
    local blue = tonumber(self.hex:sub(6, 7), 16)

    return (0.2126 * red + 0.7152 * green + 0.0722 * blue) / 255
end

function Swatch.__tostring(self)
    return self:describe()
end

local Registry = setmetatable({}, {
    __call = function(cls, ...)
        return cls.new(...)
    end,
})
Registry.__index = Registry

function Registry.new(name, opts)
    opts = opts or {}

    return setmetatable({
        name = name,
        strict = opts.strict or false,
        swatches = {},
        count = 0,
    }, Registry)
end

function Registry:add(...)
    for _, swatch in ipairs({ ... }) do
        if self.swatches[swatch.label] == nil then
            self.count = self.count + 1
        end
        self.swatches[swatch.label] = swatch
    end

    return self
end

function Registry:sorted_labels()
    local labels = {}

    for label, swatch in pairs(self.swatches) do
        if swatch.hex ~= DEFAULT_HEX then
            labels[#labels + 1] = label
        end
    end

    table.sort(labels)

    return labels
end

local help = [[
A long bracket string.
No escape processing happens here: \n stays literal.
Max depth is ]] .. MAX_DEPTH .. [[.
]]

local registry = Registry("Themes of Shibbir", { strict = true })

registry:add(
    Swatch.new("background", "#263238", { "ui" }),
    Swatch.new("keyword", "#C792EA")
)

for index, label in ipairs(registry:sorted_labels()) do
    local swatch = registry.swatches[label]
    local kind = swatch:luminance() < 0.5 and "dark" or "light"

    print(("%2d. %-12s %s (%s)"):format(index, label, swatch.hex, kind))
end

local ok, err = pcall(function()
    return Swatch.new("broken", "not-a-hex")
end)

if not ok then
    io.stderr:write("caught: " .. tostring(err) .. "\n")
end

print(help)
print(registry.count, TokenKind.COMMENT, #registry:sorted_labels())
