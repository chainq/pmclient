{
  Copyright (c) 2016 Karoly Balogh <charlie@amigaspirit.hu>

  This work is free. You can redistribute it and/or modify it under the
  terms of the Do What The Fuck You Want To Public License, Version 2,
  as published by Sam Hocevar. See the COPYING file for more details.
}

{$MODE OBJFPC}
unit consoleabuse;

interface

const
{$IFDEF HASAMIGA}
{$DEFINE CONSOLE_HAS_COLORS}
  CON_DEFAULT = #27'[0m';
  CON_BOLD    = #27'[1m';
  CON_RED     = BOLD;
  CON_GREEN   = BOLD;
{$ELSE}
{$IFDEF HASUNIX}
{$DEFINE CONSOLE_HAS_COLORS}
  CON_DEFAULT = #27'[0m';
  CON_BOLD    = #27'[1m';
  CON_RED     = #27'[31m';
  CON_GREEN   = #27'[32m';
{$ENDIF}
{$ENDIF}

{$IFNDEF CONSOLE_HAS_COLORS}
  CON_DEFAULT = '';
  CON_BOLD    = '';
  CON_RED     = '';
  CON_GREEN   = '';
{$ENDIF}
var
  CDefault, CBold, CRed, CGreen: String;

procedure SetConsoleColors(enable: boolean);

implementation

procedure SetConsoleColors(enable: boolean);
begin
  if enable then
  begin
    CDefault:=CON_DEFAULT;
    CBold:=CON_BOLD;
    CRed:=CON_RED;
    CGreen:=CON_GREEN;
  end
  else
  begin
    CDefault:='';
    CBold:='';
    CRed:='';
    CGreen:='';
  end;
end;

begin
  SetConsoleColors(true);
end.
