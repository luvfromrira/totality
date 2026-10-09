# Ron Not From Accounting — SANE Run Bot

Private Discord bot for managing **Anomaly Cafe** (Roblox) runs in the SANE server:
player verification & records, group creation, private run channels, run timers,
shift submissions and staff approval.

## Setup
1. Create an application at <https://discord.com/developers/applications>, add a bot, copy the token.
2. Invite it with scopes `bot applications.commands` and permissions: **Manage Channels, Manage Roles,
   View Channels, Send Messages, Embed Links, Read Message History**.
3. `cp .env.example .env` and fill it in (IDs via Developer Mode → right-click → Copy ID).
4. `npm install`
5. `npm run deploy` (registers slash commands in your server — rerun if commands change)
6. `npm start`

If `PANEL_CHANNEL_ID` is set, the panel is posted automatically on first start; otherwise a staff
member runs `/panel` in the desired channel. The panel is re-synced every time the bot starts.

## Workflow
1. **Staff** link players with `/verify user:@someone roblox:TheirName`.
2. A verified player picks 1-3 other verified players in the panel's selector → an invitation
   (Run Group #N) appears with **Accept / Decline / Cancel My Run**.
3. When everyone accepts, the host presses **Start My Run**. Ron takes the first free slot
   (Run 1 → 2 → 3), creates a private channel for the group + staff, and starts the timer.
4. The host presses **End My Run** and enters the shift reached. The slot frees up, the channel locks,
   and a submission goes to the approval channel.
5. Staff **Approve** or **Reject**. Stats update, members are DM'd, and the run channel is deleted after a minute.

## Commands
| Command | Who | |
|---|---|---|
| `/verify`, `/unverify` | Staff | Link / unlink a Roblox account |
| `/panel` | Staff | Post the Run Control panel here |
| `/forceend group:N` | Staff | Cancel any open group and remove its channel |
| `/profile [user]`, `/leaderboard` | Everyone | Player records |
| `/run create|view|start|end|cancel|active|stats` | Everyone | Same as the panel buttons |

## Data
Everything is saved to `data/db.json` (players, Roblox links, stats, every run group's history).
Back this file up; it is git-ignored.
