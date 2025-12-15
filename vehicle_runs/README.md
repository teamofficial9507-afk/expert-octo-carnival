# VehRaid Resource Deployment Checklist

## Files to place
- Place the resource folder (e.g., `vehicle_runs`) into your server `resources` directory.
- Ensure the folder contains:
  - `fxmanifest.lua`
  - `server.lua` (merged server code)
  - `client.lua` (merged client code)
  - `config.lua` (optional; used for spawn lists and tuning)
  - `html/index.html`, `html/style.css`, `html/client.js`
  - `sql/vehicle_runs.sql`

## Dependencies
- QBCore framework installed and running.
- One of the following MySQL wrappers installed and configured:
  - **oxmysql** (recommended)
  - **ghmattimysql**
  - **mysql-async**
- Add `goldbar` item to your QBCore `shared/items.lua`:
  ```lua
  ['goldbar'] = {
    label = 'Gold Bar',
    weight = 100,
    stack = true,
    close = true,
    description = 'A shiny gold bar'
  },
Database
Either let the resource create tables automatically on start, or run sql/vehicle_runs.sql manually in your MySQL database.

Configuration options to tune
RUN_TIMEOUT in server.lua — how long a run lasts before despawn.

REWARD_AMOUNT — gold bars awarded per destroyed vehicle.

SPAWN_INTERVAL_MS, MAX_CONCURRENT_RUNS, MIN_PLAYERS_TO_SPAWN, SPAWN_WINDOW — automatic spawner behavior.

spawnPoints, destPoints, and spawnBlacklist arrays in server.lua — customize spawn/destination locations and no-spawn zones.

Replace vehicle model (rumpo) with your preferred model.

Admin commands
/spawnrun — spawn a test run (admin only).

/vehraid_autotoggle — toggle automatic spawns (admin only).

/vehraid_autostatus — show auto-spawn status.
Troubleshooting
Vehicles not visible to all players: ensure vehicles are created as mission entities and networked (VehToNet used).

DB errors: verify MySQL wrapper is installed and DB credentials are correct.

Leaderboard not updating: confirm leaderboard table exists and server can write to DB.

NUI not opening: ensure ui_page is set and html files are present.

Optional improvements
Replace native notifications with your preferred QBCore notification wrapper.

Add display names to leaderboard rows by joining player names on fetch (store display name on update).

Integrate a dedicated traffic-light resource for more realistic AI stopping behavior.# vehicle_runs

Simple vehicular run resource for QBCore servers.

## What it does
- Spawns networked vehicles that drive to destinations.
- Clients create the vehicle (server requests a client to spawn and register the netId).
- Rewards players who destroy the target vehicle.
- Logs runs to `vehicle_runs` table (if DB wrapper is available).
- No leaderboard UI included.

## Installation
1. Place the resource folder in your `resources` directory (e.g., `resources/[local]/vehicle_runs`).
2. Ensure `fxmanifest.lua`, `server.lua`, `client.lua`, and `config.lua` are present.
3. Start or restart the resource:
