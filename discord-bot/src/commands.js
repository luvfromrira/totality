const { SlashCommandBuilder, PermissionFlagsBits } = require('discord.js');

module.exports = [
  new SlashCommandBuilder().setName('verify').setDescription('Staff: link a Discord user to their Roblox account')
    .addUserOption((o) => o.setName('user').setDescription('Discord user').setRequired(true))
    .addStringOption((o) => o.setName('roblox').setDescription('Roblox username').setRequired(true)),
  new SlashCommandBuilder().setName('unverify').setDescription('Staff: remove a player\'s verification (keeps nothing)')
    .addUserOption((o) => o.setName('user').setDescription('Discord user').setRequired(true)),
  new SlashCommandBuilder().setName('profile').setDescription('View a player\'s record')
    .addUserOption((o) => o.setName('user').setDescription('Discord user (defaults to you)')),
  new SlashCommandBuilder().setName('leaderboard').setDescription('Top players by best approved shift'),
  new SlashCommandBuilder().setName('panel').setDescription('Staff: post the Run Control panel in this channel')
    .setDefaultMemberPermissions(PermissionFlagsBits.ManageGuild),
  new SlashCommandBuilder().setName('forceend').setDescription('Staff: cancel any open run group')
    .addIntegerOption((o) => o.setName('group').setDescription('Run group number').setRequired(true)),
  new SlashCommandBuilder().setName('run').setDescription('Run controls')
    .addSubcommand((s) => s.setName('create').setDescription('Create a run with 1-3 players')
      .addUserOption((o) => o.setName('player1').setDescription('Player').setRequired(true))
      .addUserOption((o) => o.setName('player2').setDescription('Player'))
      .addUserOption((o) => o.setName('player3').setDescription('Player')))
    .addSubcommand((s) => s.setName('view').setDescription('View your current group'))
    .addSubcommand((s) => s.setName('start').setDescription('Start your run once everyone accepts'))
    .addSubcommand((s) => s.setName('end').setDescription('Submit the shift you reached'))
    .addSubcommand((s) => s.setName('cancel').setDescription('Cancel your run (host only, before it starts)'))
    .addSubcommand((s) => s.setName('active').setDescription('View Run 1-3 usage'))
    .addSubcommand((s) => s.setName('stats').setDescription('View your performance summary')),
].map((c) => c.toJSON());
