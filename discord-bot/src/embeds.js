const {
  EmbedBuilder, ActionRowBuilder, ButtonBuilder, ButtonStyle, UserSelectMenuBuilder,
} = require('discord.js');
const store = require('./store');
const { botName, maxSlots } = require('./config');

const COLOR = 0x2b2d42;
const ICON = { pending: '⏳', accepted: '✅', declined: '❌' };

const footer = (text) => ({ text: `${botName} • ${text}` });

function formatDuration(ms) {
  const s = Math.floor(ms / 1000);
  const h = Math.floor(s / 3600), m = Math.floor((s % 3600) / 60), sec = s % 60;
  return h ? `${h}h ${m}m ${sec}s` : `${m}m ${sec}s`;
}

function panelMessage() {
  const embed = new EmbedBuilder()
    .setColor(COLOR)
    .setTitle('SANE Run Control')
    .setDescription(
      'Create and manage runs from this panel. Slash commands remain available, but they are not required for the normal run workflow.\n\n' +
      '**Create a Run**\nUse the player selector below to choose **1-3 other verified players**. Selecting them immediately creates the invitation with you as the host.\n\n' +
      '**Run Controls**\n**My Run** — View your current group\n**Start My Run** — Start once everyone accepts\n' +
      '**End My Run** — Submit the reached shift\n**Active Runs** — View Run 1-3 usage\n**My Stats** — View your performance summary\n\n' +
      '**Run Slots**\nRon automatically assigns the first available slot: **Run 1**, **Run 2**, then **Run 3**.',
    )
    .setFooter(footer('Persistent Run Control Panel'))
    .setTimestamp();

  const select = new ActionRowBuilder().addComponents(
    new UserSelectMenuBuilder()
      .setCustomId('panel:select')
      .setPlaceholder('Select 1-3 players to create a run')
      .setMinValues(1)
      .setMaxValues(3),
  );
  const buttons = new ActionRowBuilder().addComponents(
    new ButtonBuilder().setCustomId('panel:myrun').setLabel('My Run').setStyle(ButtonStyle.Secondary),
    new ButtonBuilder().setCustomId('panel:start').setLabel('Start My Run').setStyle(ButtonStyle.Success),
    new ButtonBuilder().setCustomId('panel:end').setLabel('End My Run').setStyle(ButtonStyle.Danger),
    new ButtonBuilder().setCustomId('panel:active').setLabel('Active Runs').setStyle(ButtonStyle.Primary),
    new ButtonBuilder().setCustomId('panel:stats').setLabel('My Stats').setStyle(ButtonStyle.Secondary),
  );
  return { embeds: [embed], components: [select, buttons] };
}

function memberLines(group) {
  return group.members.map((m) => {
    const roblox = store.getPlayer(m.id)?.robloxUsername || 'unknown';
    const host = m.id === group.hostId ? ' **(Host)**' : '';
    return `${ICON[m.status]} <@${m.id}>${host}\n└ Roblox: \`${roblox}\``;
  }).join('\n\n');
}

function statusText(group) {
  switch (group.state) {
    case 'pending': return 'Waiting for players to accept.';
    case 'ready': return 'Everyone accepted! The host can now press **Start My Run**.';
    case 'active': return `🟢 In progress in **Run ${group.slot}** (<#${group.channelId}>) — started <t:${Math.floor(group.startedAt / 1000)}:R>.`;
    case 'submitted': return `📨 Submitted **Shift ${group.shift}** (${formatDuration(group.endedAt - group.startedAt)}). Awaiting staff approval.`;
    case 'approved': return `🏆 Approved: **Shift ${group.shift}** (${formatDuration(group.endedAt - group.startedAt)}) by <@${group.decidedBy}>.`;
    case 'rejected': return `🚫 Submission of Shift ${group.shift} rejected by <@${group.decidedBy}>.`;
    case 'cancelled': return group.cancelReason || 'Run cancelled.';
    default: return group.state;
  }
}

function groupEmbed(group) {
  return new EmbedBuilder()
    .setColor(COLOR)
    .setTitle(`Run Group #${group.id}`)
    .setDescription(memberLines(group))
    .addFields({ name: 'Status', value: statusText(group) })
    .setFooter(footer('Run Management'))
    .setTimestamp();
}

function inviteMessage(group) {
  const open = group.state === 'pending' || group.state === 'ready';
  const pending = group.members.filter((m) => m.status === 'pending').map((m) => `<@${m.id}>`);
  const content = group.state === 'pending' && pending.length ? `Run invitation for ${pending.join(' ')}` : `Run Group #${group.id}`;
  const row = new ActionRowBuilder().addComponents(
    new ButtonBuilder().setCustomId(`run:accept:${group.id}`).setLabel('Accept').setStyle(ButtonStyle.Success).setDisabled(group.state !== 'pending'),
    new ButtonBuilder().setCustomId(`run:decline:${group.id}`).setLabel('Decline').setStyle(ButtonStyle.Danger).setDisabled(group.state !== 'pending'),
    new ButtonBuilder().setCustomId(`run:cancel:${group.id}`).setLabel('Cancel My Run').setStyle(ButtonStyle.Secondary).setDisabled(!open),
  );
  return { content, embeds: [groupEmbed(group)], components: [row] };
}

function approvalMessage(group) {
  const embed = groupEmbed(group).setTitle(`Shift Submission — Run Group #${group.id}`).addFields(
    { name: 'Shift Reached', value: String(group.shift), inline: true },
    { name: 'Run Time', value: formatDuration(group.endedAt - group.startedAt), inline: true },
    { name: 'Slot', value: `Run ${group.slot}`, inline: true },
  );
  const decided = group.state !== 'submitted';
  const row = new ActionRowBuilder().addComponents(
    new ButtonBuilder().setCustomId(`staff:approve:${group.id}`).setLabel('Approve').setStyle(ButtonStyle.Success).setDisabled(decided),
    new ButtonBuilder().setCustomId(`staff:reject:${group.id}`).setLabel('Reject').setStyle(ButtonStyle.Danger).setDisabled(decided),
  );
  return { embeds: [embed], components: [row] };
}

function activeRunsEmbed() {
  const lines = [];
  for (let s = 1; s <= maxSlots; s++) {
    const g = store.activeGroups().find((x) => x.slot === s);
    lines.push(g
      ? `**Run ${s}** — 🔴 In use by Group #${g.id} (host <@${g.hostId}>), started <t:${Math.floor(g.startedAt / 1000)}:R>`
      : `**Run ${s}** — 🟢 Available`);
  }
  return new EmbedBuilder().setColor(COLOR).setTitle('Active Runs').setDescription(lines.join('\n')).setFooter(footer('Run Slots'));
}

function statsEmbed(userId) {
  const p = store.getPlayer(userId);
  const st = p.stats;
  const avg = st.approved ? (st.totalShifts / st.approved).toFixed(1) : '—';
  return new EmbedBuilder()
    .setColor(COLOR)
    .setTitle('Player Stats')
    .setDescription(`<@${userId}> • Roblox: \`${p.robloxUsername}\``)
    .addFields(
      { name: 'Runs Submitted', value: String(st.runs), inline: true },
      { name: 'Approved', value: String(st.approved), inline: true },
      { name: 'Rejected', value: String(st.rejected), inline: true },
      { name: 'Best Shift', value: String(st.bestShift || '—'), inline: true },
      { name: 'Average Shift', value: String(avg), inline: true },
      { name: 'Runs Hosted', value: String(st.hosted), inline: true },
      { name: 'Total Approved Run Time', value: formatDuration(st.totalTimeMs) },
    )
    .setFooter(footer(`Verified ${new Date(p.verifiedAt).toLocaleDateString('en-GB')}`));
}

module.exports = { panelMessage, groupEmbed, inviteMessage, approvalMessage, activeRunsEmbed, statsEmbed, formatDuration, COLOR };
