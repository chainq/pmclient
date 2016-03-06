{
  Copyright (c) 2016 Karoly Balogh <charlie@amigaspirit.hu>

  This work is free. You can redistribute it and/or modify it under the
  terms of the Do What The Fuck You Want To Public License, Version 2,
  as published by Sam Hocevar. See the COPYING file for more details.
}

{$MODE OBJFPC}
unit systemdep;

interface

{$IFDEF HASAMIGA}
uses
  sockets;
{$ENDIF}

function HasNetwork: boolean;

implementation

{$IFDEF HASAMIGA}
function HasNetwork: boolean;
begin
  { check if the startup code successfully opened bsdsocket.library }
  result:=SocketBase <> nil;
end;
{$ELSE}
function HasNetwork: boolean;
begin
  result:=true;
end;
{$ENDIF}

end.
