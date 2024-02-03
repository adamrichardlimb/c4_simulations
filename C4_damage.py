import pandas as pd
from operator import add
import math
import numpy as np
import matplotlib.pyplot as plt

def OutSine(x):
    return math.sin((x * math.pi) / 2)

def OutExpo(x):
    return 1 if x == 1 else 1 - 2 ** (-10 * x)

def OutQuad(x):
    return 1 - pow((1 - x), 2)

def OutCubic(x):
    return 1 - pow((1 - x), 3)

def OutQuart(x):
    return 1 - pow((1 - x), 4)

def OutQuint(x):
    return 1 - pow((1 - x), 5)

def SphereDamage(position):
    r = 562500
    diff = np.subtract([0,0,0], position)
    d = np.dot(diff, diff)

    if d < r:
        damage_adjustment = max(0.0, math.sqrt(d) - 490)
        potential_damage = -0.01 * (damage_adjustment * damage_adjustment) + 125
        if potential_damage < 0: return 0
        else: return potential_damage
    else:
        return 0

def SphereDamageAdjusted(position, wall):
    diff = np.subtract([0,0,0], position)
    distance = math.sqrt(np.dot(diff, diff))

    if distance > 1000:
        return 0

    if (distance > 540):
        if wall:
            dmg = 100 - (100 * OutExpo( (distance - 540) / 460))
        else:
            dmg = 100 - (100 * OutQuad( (distance - 540) / 460))

    else:
        dmg = 100

    return dmg if dmg > 0 else 0

def importAndClipReadings(csv):
    df = pd.read_csv(csv)

    df["damage"] = df["damage"].clip(upper=100, lower=0)

    result_filtered = df.groupby('distance').sum().reset_index()

    return result_filtered["damage"].clip(upper=100, lower=0)

sphere_distance = []
sphere_damage = []
sphere_damage_adjusted = []
sphere_damage_adjusted_wall = []

for i in range(0, 1010, 10):
    position = [i, 0, 0]
    sphere_distance.append(i)
    sphere_damage.append(SphereDamage(position))
    sphere_damage_adjusted.append(SphereDamageAdjusted(position, False))
    sphere_damage_adjusted_wall.append(SphereDamageAdjusted(position, True))


# reading CSV file
data = pd.read_csv("blast_damage_test.csv")
blast_distance = list(map(int, data["distance"].tolist()))
blast_damage = list(map(float, data["damage"].tolist()))

total_damage = list(map(add, sphere_damage, blast_damage))


df = pd.read_csv("c4_damage_test.csv")
filtered_df = df[df['damage'] > 0]
# Group by 'distance' and sum 'damage' after filtering
result_filtered = filtered_df.groupby('distance').sum().reset_index()
result_filtered["damage"] = result_filtered["damage"].clip(upper=100)

df2 = pd.read_csv("c4_damage_test_player.csv")
filtered_df2 = df2[df2['damage'] >= 0]
# Group by 'distance' and sum 'damage' after filtering
result_filtered2 = filtered_df2.groupby('distance').sum().reset_index()
result_filtered2["damage"] = result_filtered2["damage"].clip(upper=100)

df3 = pd.read_csv("c4_damage_test_player_wall.csv")
filtered_df3 = df3[df3['damage'] >= 0]
# Group by 'distance' and sum 'damage' after filtering
result_filtered3 = filtered_df3.groupby('distance').sum().reset_index()
result_filtered3["damage"] = result_filtered3["damage"].clip(upper=100)

df4 = pd.read_csv("c4_damage_test_player_adjusted_wallcutoff.csv")
filtered_df4 = df4[df4['damage'] >= 0]
# Group by 'distance' and sum 'damage' after filtering
result_filtered4 = filtered_df4.groupby('distance').sum().reset_index()
result_filtered4["damage"] = result_filtered4["damage"].clip(upper=100)

df5 = pd.read_csv("c4_damage_test_player_adjusted_wall_decay.csv")
filtered_df5 = df5[df5['damage'] >= 0]
# Group by 'distance' and sum 'damage' after filtering
result_filtered5 = filtered_df5.groupby('distance').sum().reset_index()
result_filtered5["damage"] = result_filtered5["damage"].clip(upper=100)

'''
plt.plot(blast_distance, result_filtered["damage"])
plt.plot(blast_distance, result_filtered2["damage"])
plt.plot(blast_distance, result_filtered3["damage"])
plt.plot(blast_distance, result_filtered4["damage"])
plt.xlabel("Distance from C4")
plt.ylabel("Damage taken")
plt.show()


#plt.plot(sphere_distance, sphere_damage)

# The original damage to the player with no wall
plt.plot(blast_distance, result_filtered2["damage"], label="Original Damage (No Wall)")
# The new simulated damage to the player with no wall
plt.plot(sphere_distance, sphere_damage_adjusted, label="Simulated Damage (No Wall)")

# The original damage to the player with the wall
plt.plot(blast_distance, result_filtered3["damage"], label="Original Damage (Wall)")
# The new simulated damage to the player with the wall
plt.plot(sphere_distance, sphere_damage_adjusted_wall, label="Simulated Damage (Wall)")

# The experimental damage to the player with no wall
plt.plot(sphere_distance, result_filtered4["damage"], label="Experimental Damage (No Wall)")

# The experimental damage to the player with a wall
plt.plot(sphere_distance, result_filtered5["damage"], label="Experimental Damage (Wall)")

plt.xlabel("Distance from C4")
plt.ylabel("Damage taken")
plt.legend()
plt.show()
'''

vanilla_open = importAndClipReadings("vanilla_open_blast_and_spherical_damage.csv")
adjusted_open = importAndClipReadings("adjusted_open_blast_and_spherical_damage.csv")
vanilla_wall = importAndClipReadings("vanilla_wall_blast_and_spherical_damage.csv")
diffused_wall = importAndClipReadings("vanilla_wall_diffused.csv")
diffused_open = importAndClipReadings("vanilla_open_diffused.csv")
adjusted_wall = importAndClipReadings("adjusted_wall_blast_and_spherical_damage.csv")
adjusted_diffused_wall = importAndClipReadings("adjusted_wall_diffused.csv")
adjusted_diffused_open = importAndClipReadings("adjusted_open_diffused.csv")


plt.plot(range(0, 1001, 1), vanilla_open, label="Undiffused Damage with Line of Sight")
plt.plot(range(0, 1001, 1), vanilla_wall, label="Undiffused Damage with No Line of Sight")
plt.plot(range(0, 1001, 1), diffused_open, label="Diffused Damage with Line of Sight")
plt.plot(range(0, 1001, 1), diffused_wall, label="Diffused Damage with No Line of Sight")
#plt.plot(range(0, 1001, 1), adjusted_open, label = "Adjusted Damage with Line of Sight")
#plt.plot(range(0, 1001, 1), adjusted_wall, label = "Adjusted Damage with No Line of Sight")
#plt.plot(range(0, 1001, 1), adjusted_diffused_open, label = "Diffused Adjusted Damage with Line of Sight")
#plt.plot(range(0, 1001, 1), adjusted_diffused_wall, label = "Diffused Adjusted Damage with No Line of Sight")

'''
df = pd.read_csv("c4_amplitude.csv")

plt.plot(df["time"], df["amplitude"])
plt.xlabel("Time to Explode (s)")
plt.ylabel("Amplitude of C4 beep (dB)")
'''
plt.xlabel("Distance from C4")
plt.ylabel("Damage taken")
plt.legend()

plt.show()