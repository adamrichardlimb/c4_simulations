-- Server-side script
if SERVER then
    -- Command to run the test
    concommand.Add("test_blastdamage_ttt", function(ply, cmd, args)

        -- Ensure the player is valid
        if not IsValid(ply) then return end

        local offset_x = 0
        local max_offset = 1100
        local increment = 10
        local fileName = "blast_damage_test.txt"

        -- Clearing previous data in the file
        file.Write(fileName, "")

        -- Repeating test with increasing offset
        timer.Create("BlastDamageTestTimer", 3, 0, function()

            if offset_x > max_offset then
                timer.Remove("BlastDamageTestTimer")
                print("Test completed: Maximum offset reached.")
                return
            end

            -- Create a bot
            local bot = player.CreateNextBot("TestBot")
            if not IsValid(bot) then return end

            hook.Add("EntityTakeDamage", "TrackBotDamage", function(target, dmgInfo)
                if target == bot then
                    print("Bot took damage!")
                    local damageTaken = dmgInfo:GetDamage()
                    local result = offset_x .. ", " .. damageTaken .. "\n"
                    file.Append(fileName, result)

                    hook.Remove("EntityTakeDamage", "TrackBotDamage")
                end
            end)

            RunConsoleCommand("ttt_roundrestart")

            timer.Simple(2, function()
                -- Disable the bot's AI
                RunConsoleCommand("ai_disabled", 1)

                local goodPos = Vector(-3186, -1569, -12736)

                -- Get the position where the player is looking
                local blastPos = goodPos + Vector(0, 0, 1)  -- Slightly above the ground for blast
                local botPos = blastPos + Vector(offset_x, 0, 0) -- Offset for bot spawn

                -- Set the bot's position
                bot:SetPos(botPos)

                -- Store the initial health of the bot
                local initialHealth = bot:Health()

                -- Apply Blast Damage after a short delay
                timer.Simple(1, function()  -- Delay for 1 second
                    if IsValid(bot) then
                        local damage = 200  -- Change damage value as needed
                        local radius = 1000  -- Change radius as needed
                        util.BlastDamage(ply, ply, blastPos, radius, damage)

                        -- Calculate damage after another short delay
                        timer.Simple(0.1, function()
                            if IsValid(bot) then
                                local damageTaken = initialHealth - bot:Health()

                                -- Optional: Remove the bot after the test
                                bot:Kick("Test completed")
                                -- Increment the offset for the next iteration
                                offset_x = offset_x + increment
                            end
                        end)
                    end
                end)
            end)
        end)
    end)
end
