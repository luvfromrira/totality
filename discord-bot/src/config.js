require('dotenv').config();

const required = ['DISCORD_TOKEN', 'CLIENT_ID', 'GUILD_ID', 'STAFF_ROLE_ID'];
for (const key of required) {
  if (!process.env[key]) throw new Error(`Missing ${key} in .env`);
}

module.exports = {
  token: process.env.DISCORD_TOKEN,
  clientId: process.env.CLIENT_ID,
  guildId: process.env.GUILD_ID,
  staffRoleId: process.env.STAFF_ROLE_ID,
  panelChannelId: process.env.PANEL_CHANNEL_ID || null,
  runCategoryId: process.env.RUN_CATEGORY_ID || null,
  approvalChannelId: process.env.APPROVAL_CHANNEL_ID || null,
  maxSlots: 3,
  botName: 'Ron Not From Accounting',
};
