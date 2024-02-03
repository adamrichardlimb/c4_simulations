-- Server-side script
if SERVER then

    -- Command to run the test
    concommand.Add("c4_test", function(ply, cmd, args)

        local blast_version = string.upper(args[1])
        local test_type = string.upper(args[2])
        local output_filename = string.upper(args[3])
        local blast_type = ""

        if args[4] then
            blast_type = string.upper(args[4])
        end

        if blast_version ~= "VANILLA" and blast_version ~= "ADJUSTED" then
            print("Blast version must be either VANILLA or ADJUSTED!")
            return
        end

        if not output_filename then
            print("Please supply an output filename!")
        end

        --Reassign these below based on the test type
        local offset_x = 0
        local blastPos = Vector(1280,0,0)

        if test_type ~= "WALL" and test_type ~= "OPEN" then
            print("Must specify a test as either WALL or OPEN!")
            return
        end

        if test_type == "WALL" then
            blastPos = Vector(-50,0,5)
            offset_x = 50
        end

        -- Ensure the player is valid
        if not IsValid(ply) then return end

        --Ends at 
        local max_offset = 1010
        local increment = 1

        -- Clearing previous data in the file
        file.Write(output_filename, "")

         hook.Add("EntityTakeDamage", "TrackC4Damage", function(target, dmgInfo)
             if (table.HasValue(player.GetAll(), target)) then
                 local damageTaken = dmgInfo:GetDamage()
                 local result = offset_x .. "," .. damageTaken .. "\n"
                 file.Append(output_filename, result)
             end
         end)

        -- Repeating test with increasing offset
        timer.Create("C4TestTimer", 3, 0, function()

            if offset_x > max_offset then
                timer.Remove("C4TestTimer")
                hook.Remove("EntityTakeDamage", "TrackC4Damage")
                print("Test completed: Maximum offset reached.")
                return
            end

            --Flip value if simulating without a wall
            local playerPos = blastPos

            if test_type == "WALL" then
                playerPos = playerPos + Vector(offset_x, 0, 0)
            else
                playerPos = playerPos - Vector(offset_x, 0, 0)
            end


            -- Set the players position
            ply:SetPos(playerPos)

            -- Delay to ensure player has teleported
            timer.Simple(1, function()
                -- Simulate C4 based on version
                if blast_version == "VANILLA" then
                    RunConsoleCommand("simulate_vanilla_c4", blastPos.x, blastPos.y, blastPos.z, blast_type)
                else
                    RunConsoleCommand("simulate_adjusted_c4", blastPos.x, blastPos.y, blastPos.z)
                end

                -- Delay to simulate C4 explosion and calculate damage
                timer.Simple(1.5, function()
                    -- Restart the round after C4 simulation
                    RunConsoleCommand("ttt_roundrestart")

                    -- Increment the offset for the next iteration, after a delay to ensure all previous actions are completed
                    timer.Simple(1, function()
                        offset_x = offset_x + increment
                    end)
                end)
            end)
        end)
    end)
end
