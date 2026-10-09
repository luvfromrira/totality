// Tiny JSON-file store. Writes go to a temp file first so a crash never leaves a half-written database.
const fs = require('fs');
const path = require('path');

const DATA_DIR = path.join(__dirname, '..', 'data');
const DB_FILE = path.join(DATA_DIR, 'db.json');

const empty = () => ({ players: {}, groups: {}, nextGroupId: 1, panel: null });

let db;
function load() {
  fs.mkdirSync(DATA_DIR, { recursive: true });
  db = fs.existsSync(DB_FILE) ? { ...empty(), ...JSON.parse(fs.readFileSync(DB_FILE, 'utf8')) } : empty();
  return db;
}

function save() {
  const tmp = DB_FILE + '.tmp';
  fs.writeFileSync(tmp, JSON.stringify(db, null, 2));
  fs.renameSync(tmp, DB_FILE);
}

const OPEN_STATES = ['pending', 'ready', 'active', 'submitted'];

const newStats = () => ({ runs: 0, approved: 0, rejected: 0, bestShift: 0, totalShifts: 0, totalTimeMs: 0, hosted: 0 });

module.exports = {
  load,
  save,
  get db() { return db; },

  getPlayer: (id) => db.players[id] || null,
  setPlayer(id, robloxUsername, verifiedBy) {
    const existing = db.players[id];
    db.players[id] = {
      robloxUsername,
      verifiedBy,
      verifiedAt: Date.now(),
      stats: existing?.stats || newStats(),
    };
    save();
    return db.players[id];
  },
  removePlayer(id) {
    delete db.players[id];
    save();
  },

  createGroup(hostId, inviteeIds) {
    const id = db.nextGroupId++;
    db.groups[id] = {
      id,
      hostId,
      members: [
        { id: hostId, status: 'accepted' },
        ...inviteeIds.map((m) => ({ id: m, status: 'pending' })),
      ],
      state: 'pending',
      slot: null,
      channelId: null,
      inviteChannelId: null,
      inviteMessageId: null,
      approvalMessageId: null,
      createdAt: Date.now(),
      startedAt: null,
      endedAt: null,
      shift: null,
      decidedBy: null,
    };
    save();
    return db.groups[id];
  },
  getGroup: (id) => db.groups[id] || null,
  // The open (not finished/cancelled) group a user belongs to, if any.
  openGroupFor(userId) {
    return Object.values(db.groups).find(
      (g) => OPEN_STATES.includes(g.state) && g.members.some((m) => m.id === userId),
    ) || null;
  },
  activeGroups: () => Object.values(db.groups).filter((g) => g.state === 'active'),
  freeSlot(max) {
    const used = new Set(Object.values(db.groups).filter((g) => g.state === 'active').map((g) => g.slot));
    for (let s = 1; s <= max; s++) if (!used.has(s)) return s;
    return null;
  },
  newStats,
};
