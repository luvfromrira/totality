const { REST, Routes } = require('discord.js');
const { token, clientId, guildId } = require('./config');
const commands = require('./commands');

new REST({ version: '10' }).setToken(token)
  .put(Routes.applicationGuildCommands(clientId, guildId), { body: commands })
  .then(() => console.log(`Registered ${commands.length} commands.`))
  .catch((e) => { console.error(e); process.exit(1); });
