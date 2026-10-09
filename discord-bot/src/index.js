const {
  Client, GatewayIntentBits, Events, ChannelType, PermissionFlagsBits, MessageFlags,
  ModalBuilder, TextInputBuilder, TextInputStyle, ActionRowBuilder, ButtonBuilder, ButtonStyle, EmbedBuilder,
} = require('discord.js');
const config = require('./config');
const store = require('./store');
const ui = require('./embeds');

store.load();
const client = new Client({ intents: [GatewayIntentBits.Guilds] });

const ephemeral = (i, content) => {
  const payload = typeof content === 'string' ? { content } : content;
  const opts = { ...payload, flags: MessageFlags.Ephemeral };
  if (i.deferred && !i.replied) return i.editReply(payload);
  return i.replied ? i.followUp(opts) : i.reply(opts);
};
const isStaff = (member) =>
  member?.roles?.cache?.has(config.staffRoleId) || member?.permissions?.has(PermissionFlagsBits.ManageGuild);

async function fetchMessage(channelId, messageId) {
  if (!channelId || !messageId) return null;
  const ch = await client.channels.fetch(channelId).catch(() => null);
  return ch ? ch.messages.fetch(messageId).catch(() => null) : null;
}

async function refreshInvite(group) {
  const msg = await fetchMessage(group.inviteChannelId, group.inviteMessageId);
  if (msg) await msg.edit(ui.inviteMessage(group)).catch(console.error);
}

async function dmMembers(group, content) {
  for (const m of group.members) {
    const user = await client.users.fetch(m.id).catch(() => null);
    await user?.send(content).catch(() => {});
  }
}

// ---------- Run lifecycle ----------

async function createRun(i, users) {
  const hostId = i.user.id;
  if (!store.getPlayer(hostId)) return ephemeral(i, '❌ You are not verified. Ask a staff member to link your Roblox account.');
  if (store.openGroupFor(hostId)) return ephemeral(i, '❌ You are already in an open run group. Use **My Run** to view it.');

  const ids = [...new Set(users.map((u) => u.id))];
  const problems = [];
  for (const u of users) {
    if (u.bot) problems.push(`${u} is a bot.`);
    else if (u.id === hostId) problems.push('You cannot select yourself — you are automatically the host.');
    else if (!store.getPlayer(u.id)) problems.push(`${u} is not verified.`);
    else if (store.openGroupFor(u.id)) problems.push(`${u} is already in an open run group.`);
  }
  if (problems.length) return ephemeral(i, `❌ Could not create the run:\n${[...new Set(problems)].join('\n')}`);
  if (ids.length < 1 || ids.length > 3) return ephemeral(i, '❌ Select 1-3 other players.');

  const group = store.createGroup(hostId, ids);
  const channel = i.channel;
  const msg = await channel.send({ ...ui.inviteMessage(group), allowedMentions: { users: ids } });
  group.inviteChannelId = channel.id;
  group.inviteMessageId = msg.id;
  store.save();
  return ephemeral(i, `✅ Created **Run Group #${group.id}**. Waiting for your players to accept: ${msg.url}`);
}

async function respondInvite(i, group, accept) {
  const member = group.members.find((m) => m.id === i.user.id);
  if (!member || member.id === group.hostId) return ephemeral(i, '❌ This invitation is not for you.');
  if (group.state !== 'pending') return ephemeral(i, '❌ This invitation is no longer open.');
  if (member.status !== 'pending') return ephemeral(i, 'You already responded to this invitation.');

  if (accept) {
    member.status = 'accepted';
    if (group.members.every((m) => m.status === 'accepted')) group.state = 'ready';
  } else {
    member.status = 'declined';
    group.state = 'cancelled';
    group.cancelReason = `<@${member.id}> declined. Run cancelled.`;
  }
  store.save();
  await i.update(ui.inviteMessage(group));
  if (group.state === 'ready') {
    await i.followUp({ content: `<@${group.hostId}> everyone accepted! Press **Start My Run** on the panel to begin.`, allowedMentions: { users: [group.hostId] } });
  }
}

async function cancelRun(i, group) {
  if (!group || !['pending', 'ready'].includes(group.state)) return ephemeral(i, '❌ You have no run that can be cancelled. Started runs must be ended with **End My Run**.');
  if (group.hostId !== i.user.id) return ephemeral(i, '❌ Only the host can cancel this run.');
  group.state = 'cancelled';
  group.cancelReason = `Cancelled by the host <@${group.hostId}>.`;
  store.save();
  if (i.isButton() && i.message.id === group.inviteMessageId) return i.update(ui.inviteMessage(group));
  await refreshInvite(group);
  return ephemeral(i, `✅ Run Group #${group.id} cancelled.`);
}

async function startRun(i) {
  const group = store.openGroupFor(i.user.id);
  if (!group) return ephemeral(i, '❌ You are not in a run group.');
  if (group.hostId !== i.user.id) return ephemeral(i, '❌ Only the host can start the run.');
  if (group.state === 'active') return ephemeral(i, `Your run is already in progress in <#${group.channelId}>.`);
  if (group.state === 'pending') return ephemeral(i, '⏳ Not everyone has accepted yet.');
  if (group.state !== 'ready') return ephemeral(i, '❌ This run cannot be started.');

  const slot = store.freeSlot(config.maxSlots);
  if (!slot) return ephemeral(i, '❌ All run slots (Run 1-3) are in use. Check **Active Runs** and try again later.');

  await i.deferReply({ flags: MessageFlags.Ephemeral });
  const guild = i.guild;
  const overwrites = [
    { id: guild.roles.everyone.id, deny: [PermissionFlagsBits.ViewChannel] },
    { id: client.user.id, allow: [PermissionFlagsBits.ViewChannel, PermissionFlagsBits.SendMessages, PermissionFlagsBits.ManageChannels] },
    { id: config.staffRoleId, allow: [PermissionFlagsBits.ViewChannel, PermissionFlagsBits.SendMessages] },
    ...group.members.map((m) => ({ id: m.id, allow: [PermissionFlagsBits.ViewChannel, PermissionFlagsBits.SendMessages, PermissionFlagsBits.AttachFiles] })),
  ];
  let channel;
  try {
    channel = await guild.channels.create({
      name: `run-${slot}-group-${group.id}`,
      type: ChannelType.GuildText,
      parent: config.runCategoryId || undefined,
      permissionOverwrites: overwrites,
      topic: `SANE Run ${slot} • Run Group #${group.id}`,
    });
  } catch (e) {
    console.error(e);
    return i.editReply('❌ I could not create the private run channel. Check my **Manage Channels** permission.');
  }

  group.state = 'active';
  group.slot = slot;
  group.channelId = channel.id;
  group.startedAt = Date.now();
  store.save();

  const runEmbed = new EmbedBuilder()
    .setColor(ui.COLOR)
    .setTitle(`Run ${slot} — Run Group #${group.id}`)
    .setDescription(`${group.members.map((m) => `<@${m.id}>`).join(' ')}\n\n⏱️ Timer started <t:${Math.floor(group.startedAt / 1000)}:R> (<t:${Math.floor(group.startedAt / 1000)}:T>).\n\nWhen you finish, the host presses **End My Run** and submits the shift you reached. Post screenshot proof here for staff.`)
    .setFooter({ text: `${config.botName} • Run Timer` });
  await channel.send({
    content: group.members.map((m) => `<@${m.id}>`).join(' '),
    embeds: [runEmbed],
    components: [new ActionRowBuilder().addComponents(
      new ButtonBuilder().setCustomId(`run:end:${group.id}`).setLabel('End My Run').setStyle(ButtonStyle.Danger),
    )],
  });
  await refreshInvite(group);
  return i.editReply(`✅ **Run ${slot}** started! Head to ${channel}.`);
}

function shiftModal(group) {
  return new ModalBuilder().setCustomId(`modal:end:${group.id}`).setTitle(`End Run Group #${group.id}`).addComponents(
    new ActionRowBuilder().addComponents(
      new TextInputBuilder().setCustomId('shift').setLabel('Shift reached').setPlaceholder('e.g. 12')
        .setStyle(TextInputStyle.Short).setRequired(true).setMaxLength(4),
    ),
    new ActionRowBuilder().addComponents(
      new TextInputBuilder().setCustomId('notes').setLabel('Notes for staff (optional)')
        .setStyle(TextInputStyle.Paragraph).setRequired(false).setMaxLength(500),
    ),
  );
}

async function endRun(i) {
  const group = store.openGroupFor(i.user.id);
  if (!group || group.state !== 'active') return ephemeral(i, '❌ You do not have a run in progress.');
  if (group.hostId !== i.user.id) return ephemeral(i, '❌ Only the host can end the run.');
  return i.showModal(shiftModal(group));
}

async function submitShift(i, group) {
  if (!group || group.state !== 'active' || group.hostId !== i.user.id) return ephemeral(i, '❌ This run can no longer be submitted.');
  const shift = Number.parseInt(i.fields.getTextInputValue('shift').trim(), 10);
  if (!Number.isInteger(shift) || shift < 0 || shift > 9999) return ephemeral(i, '❌ Shift must be a whole number.');

  group.state = 'submitted';
  group.shift = shift;
  group.endedAt = Date.now();
  group.notes = i.fields.getTextInputValue('notes')?.trim() || null;
  for (const m of group.members) {
    const p = store.getPlayer(m.id);
    if (!p) continue;
    p.stats.runs++;
    if (m.id === group.hostId) p.stats.hosted++;
  }
  store.save();

  const approvalChannel = await client.channels.fetch(config.approvalChannelId || group.inviteChannelId).catch(() => null);
  const payload = ui.approvalMessage(group);
  if (group.notes) payload.embeds[0].addFields({ name: 'Notes', value: group.notes });
  const msg = await approvalChannel?.send({ content: `<@&${config.staffRoleId}> new shift submission`, ...payload, allowedMentions: { roles: [config.staffRoleId] } });
  group.approvalChannelId = approvalChannel?.id || null;
  group.approvalMessageId = msg?.id || null;
  store.save();

  // Lock the run channel: members can still read it while staff review.
  const runChannel = await client.channels.fetch(group.channelId).catch(() => null);
  if (runChannel) {
    for (const m of group.members) await runChannel.permissionOverwrites.edit(m.id, { SendMessages: false }).catch(() => {});
    await runChannel.send(`🛑 Run ended. **Shift ${shift}** submitted in ${ui.formatDuration(group.endedAt - group.startedAt)}. Waiting for staff approval.`).catch(() => {});
  }
  await refreshInvite(group);
  return ephemeral(i, `✅ Submitted **Shift ${shift}**. Run ${group.slot} is now free. Staff will review your submission.`);
}

async function decide(i, group, approve) {
  if (!isStaff(i.member)) return ephemeral(i, '❌ Only staff can review submissions.');
  if (!group || group.state !== 'submitted') return ephemeral(i, 'This submission was already reviewed.');

  group.state = approve ? 'approved' : 'rejected';
  group.decidedBy = i.user.id;
  group.decidedAt = Date.now();
  for (const m of group.members) {
    const p = store.getPlayer(m.id);
    if (!p) continue;
    if (approve) {
      p.stats.approved++;
      p.stats.totalShifts += group.shift;
      p.stats.totalTimeMs += group.endedAt - group.startedAt;
      p.stats.bestShift = Math.max(p.stats.bestShift, group.shift);
    } else {
      p.stats.rejected++;
    }
  }
  store.save();

  const payload = ui.approvalMessage(group);
  if (group.notes) payload.embeds[0].addFields({ name: 'Notes', value: group.notes });
  await i.update(payload);
  await refreshInvite(group);
  await dmMembers(group, approve
    ? `🏆 Your SANE run (Group #${group.id}, **Shift ${group.shift}**) was approved!`
    : `🚫 Your SANE run (Group #${group.id}, Shift ${group.shift}) was rejected by staff.`);

  const runChannel = await client.channels.fetch(group.channelId).catch(() => null);
  if (runChannel) {
    await runChannel.send(`${approve ? '✅ Approved' : '❌ Rejected'} by ${i.user}. This channel will be deleted in 1 minute.`).catch(() => {});
    setTimeout(() => runChannel.delete('Run reviewed').catch(() => {}), 60_000);
  }
}

async function forceEnd(i, group) {
  if (!group || !['pending', 'ready', 'active', 'submitted'].includes(group.state)) return ephemeral(i, '❌ That group is not open.');
  const wasActive = group.state === 'active' || group.state === 'submitted';
  group.state = 'cancelled';
  group.cancelReason = `Force-ended by staff (${i.user}).`;
  store.save();
  await refreshInvite(group);
  const approval = await fetchMessage(group.approvalChannelId, group.approvalMessageId);
  await approval?.edit({ components: [] }).catch(() => {});
  if (wasActive && group.channelId) {
    const ch = await client.channels.fetch(group.channelId).catch(() => null);
    await ch?.delete('Run force-ended').catch(() => {});
  }
  return ephemeral(i, `✅ Run Group #${group.id} force-ended.`);
}

// ---------- Info views ----------

function viewMyRun(i) {
  const group = store.openGroupFor(i.user.id);
  if (!group) return ephemeral(i, 'You are not in an open run group. Use the player selector on the panel to create one.');
  return ephemeral(i, { embeds: [ui.groupEmbed(group)] });
}

function viewStats(i, user = i.user) {
  if (!store.getPlayer(user.id)) return ephemeral(i, user.id === i.user.id ? '❌ You are not verified yet.' : `❌ ${user} is not verified.`);
  return ephemeral(i, { embeds: [ui.statsEmbed(user.id)] });
}

function leaderboard(i) {
  const top = Object.entries(store.db.players)
    .filter(([, p]) => p.stats.approved > 0)
    .sort(([, a], [, b]) => b.stats.bestShift - a.stats.bestShift || b.stats.approved - a.stats.approved)
    .slice(0, 10);
  const desc = top.length
    ? top.map(([id, p], n) => `**${n + 1}.** <@${id}> (\`${p.robloxUsername}\`) — Best Shift **${p.stats.bestShift}**, ${p.stats.approved} approved`).join('\n')
    : 'No approved runs yet.';
  return ephemeral(i, { embeds: [new EmbedBuilder().setColor(ui.COLOR).setTitle('SANE Leaderboard').setDescription(desc)] });
}

// ---------- Slash commands ----------

async function onCommand(i) {
  const staffOnly = ['verify', 'unverify', 'panel', 'forceend'];
  if (staffOnly.includes(i.commandName) && !isStaff(i.member)) return ephemeral(i, '❌ Staff only.');

  switch (i.commandName) {
    case 'verify': {
      const user = i.options.getUser('user');
      const roblox = i.options.getString('roblox').trim();
      if (user.bot) return ephemeral(i, '❌ Bots cannot be verified.');
      if (!/^[A-Za-z0-9_]{3,20}$/.test(roblox)) return ephemeral(i, '❌ That is not a valid Roblox username (3-20 letters, numbers or underscores).');
      const taken = Object.entries(store.db.players).find(([id, p]) => id !== user.id && p.robloxUsername.toLowerCase() === roblox.toLowerCase());
      if (taken) return ephemeral(i, `❌ \`${roblox}\` is already linked to <@${taken[0]}>.`);
      store.setPlayer(user.id, roblox, i.user.id);
      return ephemeral(i, `✅ Verified ${user} as Roblox \`${roblox}\`.`);
    }
    case 'unverify': {
      const user = i.options.getUser('user');
      if (!store.getPlayer(user.id)) return ephemeral(i, `${user} is not verified.`);
      if (store.openGroupFor(user.id)) return ephemeral(i, `❌ ${user} is in an open run group. End or force-end it first.`);
      store.removePlayer(user.id);
      return ephemeral(i, `✅ Removed verification and records for ${user}.`);
    }
    case 'profile': return viewStats(i, i.options.getUser('user') || i.user);
    case 'leaderboard': return leaderboard(i);
    case 'panel': {
      const msg = await i.channel.send(ui.panelMessage());
      const old = store.db.panel;
      store.db.panel = { channelId: i.channel.id, messageId: msg.id };
      store.save();
      if (old) (await fetchMessage(old.channelId, old.messageId))?.delete().catch(() => {});
      return ephemeral(i, '✅ Run Control panel posted.');
    }
    case 'forceend': return forceEnd(i, store.getGroup(i.options.getInteger('group')));
    case 'run': {
      switch (i.options.getSubcommand()) {
        case 'create': return createRun(i, ['player1', 'player2', 'player3'].map((n) => i.options.getUser(n)).filter(Boolean));
        case 'view': return viewMyRun(i);
        case 'start': return startRun(i);
        case 'end': return endRun(i);
        case 'cancel': return cancelRun(i, store.openGroupFor(i.user.id));
        case 'active': return ephemeral(i, { embeds: [ui.activeRunsEmbed()] });
        case 'stats': return viewStats(i);
      }
    }
  }
}

// ---------- Components ----------

async function onComponent(i) {
  const [scope, action, idStr] = i.customId.split(':');
  const group = idStr ? store.getGroup(Number(idStr)) : null;

  if (scope === 'panel') {
    switch (action) {
      case 'select': {
        const users = [...i.users.values()];
        await i.deferReply({ flags: MessageFlags.Ephemeral });
        // Reset the selector so the next person starts with an empty menu.
        await i.message.edit(ui.panelMessage()).catch(() => {});
        return createRun(i, users);
      }
      case 'myrun': return viewMyRun(i);
      case 'start': return startRun(i);
      case 'end': return endRun(i);
      case 'active': return ephemeral(i, { embeds: [ui.activeRunsEmbed()] });
      case 'stats': return viewStats(i);
    }
  }
  if (scope === 'run') {
    if (!group) return ephemeral(i, '❌ That run group no longer exists.');
    switch (action) {
      case 'accept': return respondInvite(i, group, true);
      case 'decline': return respondInvite(i, group, false);
      case 'cancel': return cancelRun(i, group);
      case 'end':
        if (group.state !== 'active') return ephemeral(i, '❌ This run is not in progress.');
        if (group.hostId !== i.user.id) return ephemeral(i, '❌ Only the host can end the run.');
        return i.showModal(shiftModal(group));
    }
  }
  if (scope === 'staff') return decide(i, group, action === 'approve');
  if (scope === 'modal' && action === 'end') return submitShift(i, group);
}

// ---------- Wiring ----------

client.once(Events.ClientReady, async () => {
  console.log(`Logged in as ${client.user.tag}`);
  // Keep the persistent panel up to date, or post it if a panel channel is configured and none exists.
  const saved = store.db.panel;
  const existing = saved && await fetchMessage(saved.channelId, saved.messageId);
  if (existing) {
    await existing.edit(ui.panelMessage()).catch(console.error);
  } else if (config.panelChannelId) {
    const ch = await client.channels.fetch(config.panelChannelId).catch(() => null);
    const msg = await ch?.send(ui.panelMessage()).catch(console.error);
    if (msg) { store.db.panel = { channelId: ch.id, messageId: msg.id }; store.save(); }
  }
});

client.on(Events.InteractionCreate, async (i) => {
  try {
    if (i.isChatInputCommand()) await onCommand(i);
    else if (i.isButton() || i.isUserSelectMenu() || i.isModalSubmit()) await onComponent(i);
  } catch (e) {
    console.error(e);
    await ephemeral(i, '⚠️ Something went wrong. Please try again or contact staff.').catch(() => {});
  }
});

client.login(config.token);
