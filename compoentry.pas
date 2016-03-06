{
  Copyright (c) 2016 Karoly Balogh <charlie@amigaspirit.hu>

  This work is free. You can redistribute it and/or modify it under the
  terms of the Do What The Fuck You Want To Public License, Version 2,
  as published by Sam Hocevar. See the COPYING file for more details.
}

{$MODE OBJFPC}
unit compoentry;

interface

uses
  sysutils,
  fpjson,

  consoleabuse;

type
  TCompoEntry = class
    FEntry: TJSONData;
  public
    constructor Create(const AJSONData: TJSONData);
    function Hidden: boolean;
    class function Hidden(const Entry: TJSONData): boolean;
    function TitleAndAuthor: AnsiString;
    function StatusString: String;
    function ID: Integer;
    function Num: Integer;
    function GEMAStatus: boolean;
    function GEMAStatusString: String;
  end;

implementation

constructor TCompoEntry.Create(const AJSONData: TJSONData);
begin
  FEntry:=AJSONData;
end;

function TCompoEntry.Hidden: boolean;
begin
  result:=Hidden(FEntry);
end;

class function TCompoEntry.Hidden(const Entry: TJSONData): boolean;
var
  s: String;
begin
  s:=Entry.FindPath('status_text').AsString;
  result:= (s = 'Disqualified') or (s = 'Checked');
end;

function TCompoEntry.TitleAndAuthor: AnsiString;
begin
  result:=CBold+FEntry.FindPath('title').AsString+CDefault+' by '
         +CBold+FEntry.FindPath('author').AsString+CDefault;
end;

function TCompoEntry.StatusString: String;
begin
  result:=FEntry.FindPath('status_text').AsString;
end;

function TCompoEntry.ID: Integer;
begin
  result:=FEntry.FindPath('id').AsInteger;
end;

function TCompoEntry.Num: Integer;
begin
  result:=FEntry.FindPath('entry_number').AsInteger;
end;

function TCompoEntry.GEMAStatus: boolean;
begin
  result:=FEntry.FindPath('composer_is_not_member_of_a_copyrightcollective').AsBoolean;
end;

function TCompoEntry.GEMAStatusString: String;
var
  s: boolean;
begin
  s:=GEMAStatus;
  if s then
    result:=CGreen
  else
    result:=CRed;

  result:=result+BoolToStr(s,true)+CDefault;
end;

end.
