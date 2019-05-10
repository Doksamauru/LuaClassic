DEF_SERVERNAME     = 'A minecraft server'
DEF_SERVERMOTD     = 'This server uses LuaClassic'

CONF_VTYPERR       = 'Variable %s have wrong type, expected type: %s, but we got: %s'
CONF_INVALIDSYNTAX = 'Invalid syntax in %s file on line %d'

TMR_ERR            = 'timer %q error: %s'

CON_PROPINVALID    = '&cInvalid server.properties configuration'
CON_LJVER          = 'Server requires LuaJIT >= 2.0.0-beta11'
CON_SAVESUCC       = 'Configuration saved successfully'
CON_HELP           = 'For help, type "help" or "?"'
CON_START          = 'Starting LuaClassic server...'
CON_SAVEERR        = '&cConfiguration save failed!'
CON_BINDSUCC       = 'Server started on %s:%d'
CON_WSBINDSUCC     = ' (websocket port: %d)'
CON_WLOADERR       = 'No worlds loaded'
CON_WSAVE          = 'Saving worlds'
CON_SVSTOP         = 'Server stopped'
CON_WLOAD          = 'Loading worlds'
CON_USE            = 'Usage: %s'

CU_STOP            = 'stop - Stop the server'
CU_LEXEC           = '#<lua code> - Run lua code'
CU_RESTART         = 'restart - Restart the server'
CU_HELP            = 'help - Shows this list of commands'
CU_SAY             = 'say <message> - Send message to chat'
CU_KICK            = 'kick <player> [reason] - Kick player'
CU_LIST            = 'list - Shows a list of loaded worlds'
CU_LOADWORLD       = 'loadworld <worldname> - Load specified world'
CU_ADDPERM         = 'addperm <key> <permission> - Give permission'
CU_DELPERM         = 'delperm <key> <permission> - Delete permission'
CU_UNLOADWORLD     = 'unloadWorld <worldname> - Unload specified world'
CU_TP              = 'tp <player> <to> - Teleport player to another player'
CU_REGEN           = 'regen <world> [generator] [seed] - Regenerate specified world'
CU_PUT             = 'put <playername> <worldname> - Teleport player to specified world'

IE_SQL             = 'SQL troubles'
IE_GZ              = 'Map compression failed'
IE_UE              = 'Unexpected error'

ST_OFF             = '&cdisabled&f'
ST_ON              = '&aenabled&f'

KICK_CONNREJ       = 'Server rejected your connection attempt'
KICK_CPESEQERR     = 'Packet 0x10 not received before 0x11'
KICK_CPEEXTCOUNT   = 'Invalid CPE extensions count received'
KICK_INTERR        = 'Internal server error: %s'
KICK_PROTOVER      = 'Invalid protocol version'
KICK_INVALIDPACKET = 'Invalid packet received'
KICK_MAPTHREADERR  = 'Error in mapsend thread'
KICK_NOREASON      = 'Kicked without reason'
KICK_SVRST         = 'Server is restarting'
KICK_NAMETAKEN     = 'This nickname taken'
KICK_PACKETSIZE    = 'Invalid packet size'
KICK_SVSTOP        = 'Server stopped'
KICK_SFULL         = 'Server is full'
KICK_TIMEOUT       = 'Timed out'

MESG_DONE          = 'done'
MESG_DONEIN        = 'done in %.3fms'
MESG_EXEC          = '&aExecuted'
MESG_ERROR         = '&cError: %s'
MESG_EXECRET       = '&aExecuted: %s'
MESG_NAMENS        = '&cName not specified'
MESG_PLAYERNF      = '&cPlayer not found'
MESG_PLAYERNFA     = '&cPlayer %q not found'
MESG_PERMERROR     = 'You do not have &c%s&f permission.'
MESG_LEVELLOAD     = 'Please wait, server is loading this level...'
MESG_CONN          = 'Player %s connected to server'
MESG_DISCONN       = 'Player %s disconnected from server (%s)'
MESG_UNKNOWNCMD    = '&cUnknown command'
MESG_NOTWSCONN     = 'This port accepts only websocket connections.'

CMD_WMODE          = 'Readonly mode %s'
CMD_SVINFO1        = 'Server runned on &a%s &e%s &fwith &b%s'
CMD_SVINFO2        = 'Ram used: %.3fMB'
CMD_TIMEPRESETNF   = '&cTime preset not found'
CMD_TIMEDISALLOW   = '&cTime changing not allowed in the nether.'
CMD_SVER           = 'Current server version: &a%s [%d commits]'
CMD_TIMECHANGE     = 'Time in &a%s&f changed to &e%s'
CMD_SELMODE        = 'Selection mode %s'
CMD_SELCUBOID      = '&cSelect cuboid first'
CMD_CRPORTAL       = 'Portal created'
CMD_RMPORTAL       = 'Portal removed'
CMD_NEPORTAL       = '&cThis portal not exists'
CMD_SPAWNSET       = '&aSpawnpoint installed'
CMD_BLOCKID        = '&cInvalid block id'
CMD_WORLDLST       = 'Loaded worlds:'
CMD_TPDONE         = '&aTeleported'
CMD_GENSTART       = 'Generation started...'
CMD_GENERR         = 'Error in generator: %s'
CMD_WTCHANGE       = 'Weather in &a%s&f changed to &e%s'
CMD_WTINVALID      = '&cInvalid weather type'
CMD_WTCURR         = 'At this moment weather is &e%s&f'

WORLD_RO           = '&cThis world in readonly mode'
WORLD_NE           = '&cThis world not exists'
WORLD_TOOBIGDIM    = 'World dimensions is too big'
WORLD_INVALID      = '&cWorld have invalid format'
WORLD_WRITEFAIL    = '&cLevel data write operation failed!'
WORLD_CORRUPT      = '&cUnsupported map version or file corrupted.'
