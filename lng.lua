DEF_SERVERNAME     = 'A minecraft server'
DEF_SERVERMOTD     = 'This server uses LuaClassic'

CONF_VTYPERR       = 'Variable %s have wrong type, expected type: %s, but we got: %s'
CONF_INVALIDSYNTAX = 'Invalid syntax in %s file on line %d'

GZ_ERR             = 'gzip %s error: %s'
TMR_ERR            = 'timer %q error: %s'

CON_PROPINVALID    = 'Invalid server.properties configuration'
CON_SAVESUCC       = 'Configuration saved successfully'
CON_BINDSUCC       = 'Server started on %s:%d%s'
CON_WSBINDSUCC     = ' (websocket port: %d)'
CON_WSAVE          = 'Saving world %s...'
CON_WLOAD          = 'Loading worlds:'
CON_SVSTOP         = 'Server stopped'
CON_USE            = 'Usage: %s'

CC_SAY             = 'say <message>'
CC_TP              = 'tp <player> <to>'
CC_KICK            = 'kick <player> [reason]'
CC_ADDPERM         = 'addperm <key> <permission>'
CC_REGEN           = 'regen <world> [generator] [seed]'

KICK_CONNREJ       = 'Server rejected your connection attempt'
KICK_CPESEQERR     = 'Packet 0x10 not received before 0x11'
KICK_CPEEXTCOUNT   = 'Invalid CPE extensions count received'
KICK_SQLERR        = 'Internal server error: SQL troubles'
KICK_PROTOVER      = 'Invalid protocol version'
KICK_INVALIDPACKET = 'Invalid packet received'
KICK_MAPTHREADERR  = 'Error in mapsend thread'
KICK_NOREASON      = 'Kicked without reason'
KICK_NAMETAKEN     = 'This nickname taken'
KICK_PACKETSIZE    = 'Invalid packet size'
KICK_SFULL         = 'Server is full'
KICK_TIMEOUT       = 'Timed out'

MESG_DONE          = 'Done'
MESG_DONEIN        = 'Done in %.3fms'
MESG_EXEC          = 'Executed'
MESG_ERROR         = 'Error: %s'
MESG_EXECRET       = 'Executed: %s'
MESG_NAMENS        = 'Name not specified'
MESG_PLAYERNF      = 'Player not found'
MESG_PLAYERNFA     = 'Player %q not found'
MESG_PERMERROR     = 'You do not have &c%s&f permission.'
MESG_LEVELLOAD     = 'Please wait, server is loading this level...'
MESG_CONN          = 'Player %s connected to server'
MESG_DISCONN       = 'Player %s disconnected from server'
MESG_UNKNOWNCMD    = 'Unknown command'
MESG_NOTWSCONN     = 'Bad update request, this port accepts only websocket connections.'

CMD_WMODE          = 'Now world in %s mode'
CMD_SVINFO1        = 'Server runned on &a%s &e%s'
CMD_SVINFO2        = 'Ram used: %.3fMB'
CMD_TIMEDISALLOW   = 'Time changing not allowed in the nether.'
CMD_SVER           = 'Current server version: &a%s [%d commits]'
CMD_TIMECHANGE     = 'Time changed to %s'
CMD_SELMODEOFF     = 'Selection mode disabled'
CMD_SELMODEON      = 'Selection mode enabled'
CMD_SELCUBOID      = 'Select cuboid first'
CMD_CRPORTAL       = 'Portal created'
CMD_RMPORTAL       = 'Portal removed'
CMD_NEPORTAL       = 'This portal not exists'
CMD_SPAWNSET       = 'Spawnpoint installed'
CMD_BLOCKID        = 'Invalid block id'
CMD_WORLDLST       = 'Loaded worlds:'
CMD_TPDONE         = 'Teleported'
CMD_GENSTART       = 'Generation started...'
CMD_GENERR         = 'Error in generator: %s'

WORLD_RO           = '&cThis world in readonly mode'
WORLD_NE           = '&cThis world not exists'
WORLD_TOOBIGDIM    = 'World dimensions is too big'
WORLD_INVALID      = 'World have invalid format'
WORLD_WRITEFAIL    = 'Level data write operation failed!'

UNEXPECTED_ERROR   = 'Unexpected error'
