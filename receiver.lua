local modem_side = "right"
local encrypt_key = "samiscool"
os.loadAPI("aes.lua")

local function main()
    local mod = peripheral.wrap(modem_side)
    mod.open(1810)

    while true do
        local _, side, rec, send, msg = os.pullEvent("modem_message")
        if rec == 1810 then
            local text = aes.decrypt(encrypt_key, msg)
            print(text)
        end
    end
end

main()