unit ConsoleConsts;

interface

resourcestring
  sInvalidCommand = '- Error: Invalid Command';

  sStartSuccess = 'IBS_gds_db started successfully.';
  sStopSuccess = 'IBS_gds_db stopped successfully.';
  sRestartSuccess = 'IBS_gds_db restarted successfully.';
  sStartFailure = 'Failed to start IBS_gds_db.';
  sStopFailure = 'Failed to stop IBS_gds_db.';
  sRestartFailure = 'Failed to restart IBS_gds_db.';

  sCommands = 'Enter a Command: ' + slineBreak +
    '   - "start" start the service' + slineBreak +
    '   - "stop" to stop the service' + slineBreak +
    '   - "restart" to restart the service' + slineBreak +
    '   - "status" for service status' + slineBreak +
    '   - "help" to show commands' + slineBreak +
    '   - "exit" to close the application';

const
  cArrow = '-> ';
  cCommandStart = 'start';
  cCommandStop = 'stop';
  cCommandStatus = 'status';
  cCommandHelp = 'help';
  cCommandRestart = 'restart';
  cCommandExit = 'exit';

implementation

end.
