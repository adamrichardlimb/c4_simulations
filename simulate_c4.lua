if SERVER then

	-- Stolen straight from source - only changed r to be fixed since we're not simulating what happens when we defuse C4 (yet)
	local function applyVanillaSphericalDamage(center, dmgowner)
		-- It seems intuitive to use FindInSphere here, but that will find all ents
		-- in the radius, whereas there exist only ~16 players. Hence it is more
		-- efficient to cycle through all those players and do a Lua-side distance
		-- check.

		local r = 90000

		-- pre-declare to avoid realloc
		local d = 0.0
		local diff = nil
		local dmg = 0
		for _, ent in ipairs(player.GetAll()) do
		   if IsValid(ent) and ent:Team() == TEAM_TERROR then

		      -- dot of the difference with itself is distance squared
		      diff = center - ent:GetPos()
		      d = diff:Dot(diff)

    	      print("Player Position = ", ent:GetPos())
    	      print("Distance between Player and Bomb = ", math.sqrt(d))

		      if d < r then
		         -- deadly up to a certain range, then a quick falloff within 100 units
		         d = math.max(0, math.sqrt(d) - 490)
		         dmg = -0.01 * (d^2) + 125

		         local dmginfo = DamageInfo()
		         dmginfo:SetDamage(dmg)
		         dmginfo:SetAttacker(dmgowner)
		         dmginfo:SetInflictor(ent)
		         dmginfo:SetDamageType(DMG_BLAST)
		         dmginfo:SetDamageForce(center - ent:GetPos())
		         dmginfo:SetDamagePosition(ent:GetPos())

		         ent:TakeDamageInfo(dmginfo)
		      end
		   end
		end
	end

	-- Also stolen from source, but removed superfluous stuff
	local function applyAdjustedSphericalDamage(center, dmgowner)
		-- It seems intuitive to use FindInSphere here, but that will find all ents
		-- in the radius, whereas there exist only ~16 players. Hence it is more
		-- efficient to cycle through all those players and do a Lua-side distance
		-- check.

		local d = 0.0
    	local diff = nil
    	local dmg = 0
    	local dmg_reduction = 0
    	for _, player in ipairs(player.GetAll()) do
    	   if IsValid(player) and player:Team() == TEAM_TERROR then

    	      local player_pos = player:GetPos()

    	      -- dot of the difference with itself is distance squared, so sqrt
    	      diff = center - player_pos
    	      distance = math.sqrt(diff:Dot(diff))

    	      print("Player Position = ", player_pos)
    	      print("Distance between Player and Bomb = ", distance)

    	      if distance > 400 then return end

    	      if distance > 300 then
    	         --If the C4 is behind a wall, then apply additional falloff
    	         -- Create a trace table
    	         local traceResult = util.QuickTrace(center, player_pos, player)

    	         -- Check if trace hit the world
    	         if traceResult.HitWorld then
    	             print("Wall!")
    	             PrintTable(traceResult)
    	             dmg_reduction = (100 * math.ease.OutExpo( (distance - 300) / 100))
    	             print("Reduction = ", dmg_reduction)
    	         else
    	             print("No wall!")
    	             PrintTable(traceResult)
    	             dmg_reduction = (100 * math.ease.OutQuad( (distance - 300) / 100))
    	             print("Reduction = ", dmg_reduction)
    	         end

    	         dmg = 100 - dmg_reduction
    	      else
    	         dmg = 100
    	      end

    	      -- If the world sits between the C4 and the player - cut damage in half


    	     local dmginfo = DamageInfo()
    	     dmginfo:SetDamage(dmg)
    	     dmginfo:SetAttacker(dmgowner)
    	     dmginfo:SetInflictor(player)
    	     dmginfo:SetDamageType(DMG_BLAST)
    	     dmginfo:SetDamageForce(center - player_pos)
    	     dmginfo:SetDamagePosition(player_pos)

    	     player:TakeDamageInfo(dmginfo)
    	   end
    	end
	end

	concommand.Add("simulate_vanilla_c4", function(ply, cmd, args)
		local blast_pos = Vector(args[1], args[2], args[3])
		local simulation_type = string.upper(args[4])
		local C4_text = ""

		if simulation_type == "" then
			C4_text = "Simulating C4 with both Spherical and Blast Damage at: "
		elseif simulation_type == "SPHERE" then
			C4_text = "Simulating C4 with just Sphere Damage at: "
		elseif simulation_type == "BLAST" then
			C4_text = "Simulating C4 with just Blast Damage at: "
		end

		print(C4_text, blast_pos)

        if simulation_type == "" then
			applyVanillaSphericalDamage(blast_pos, ply)
        	util.BlastDamage(ply, ply, blast_pos, 400, 200)
		elseif simulation_type == "SPHERE" then
			applyVanillaSphericalDamage(blast_pos, ply)
		elseif simulation_type == "BLAST" then
        	util.BlastDamage(ply, ply, blast_pos, 400, 200)
		end
	end)

	concommand.Add("simulate_adjusted_c4", function(ply, cmd, args)
		local blast_pos = Vector(args[1], args[2], args[3])

        print("Simulating adjusted C4 explosion at: ", blast_pos)

        applyAdjustedSphericalDamage(blast_pos, ply)
	end)
end