{
  Copyright (c) 2016 Karoly Balogh <charlie@amigaspirit.hu>

  This work is free. You can redistribute it and/or modify it under the
  terms of the Do What The Fuck You Want To Public License, Version 2,
  as published by Sam Hocevar. See the COPYING file for more details.
}

{$MODE OBJFPC}
{.$DEFINE NO_CONSOLE_COLORS}
program pmclient;

uses
  classes, sysutils,
  fphttpclient,
  fpjson, jsonparser;

const
{$IFNDEF NO_CONSOLE_COLORS}
{$IFDEF HASAMIGA}
{$DEFINE CONSOLE_HAS_COLORS}
  DEFAULT = #27'[0m';
  BOLD    = #27'[1m';
  RED     = BOLD;
  GREEN   = BOLD;
{$ELSE}
{$IFDEF HASUNIX}
{$DEFINE CONSOLE_HAS_COLORS}
  DEFAULT = #27'[0m';
  BOLD    = #27'[1m';
  RED     = #27'[31m';
  GREEN   = #27'[32m';
{$ENDIF}
{$ENDIF}
{$ENDIF}

{$IFNDEF CONSOLE_HAS_COLORS}
  DEFAULT = '';
  BOLD    = '';
  RED     = '';
  GREEN   = '';
{$ENDIF}


const
  USER_AGENT = 'PartyMeisterClient/0.1337 ('+{$I %FPCTARGETOS%}+'-'+{$I %FPCTARGETCPU%}+')';
  URL = 'http://192.168.10.1/~charlie/competition_entries.json';

function GetJSONData(AFileName: String): TJSONData;
var
  S: TFileStream;
  P: TJSONParser;
begin
  S:=TFileStream.Create(AFileName,fmOpenRead);
  try
    P:=TJSONParser.Create(S);
    try
      P.Strict:=true;
      result:=P.Parse;
    finally
      P.Free;
    end;
  finally
    S.Free;
  end;
end;

function GetJSONfromURL(const URL: String): TJSONData;
var
  S: AnsiString;
  c: TFPCustomHTTPClient;
begin
  writeln('Downloading from: ',URL);
  c:=TFPCustomHTTPClient.Create(nil);
  c.AddHeader('User-Agent',USER_AGENT);
  s:=c.Get(URL);
  FreeAndNil(c);

  result:=GetJSON(s);
end;

procedure ShowJSONData(indent: Integer; Data : TJSONData);
Var
  I : Integer;
  D : TJSONData;
  S : TStringList;
begin
  if Assigned(Data) then
    begin
    Case Data.JSONType of
      jtArray,
      jtObject:
        begin
        S:=TstringList.Create;
        try
          For I:=0 to Data.Count-1 do
            If Data.JSONtype=jtArray then
              S.AddObject(IntToStr(I),Data.items[i])
            else
              S.AddObject(TJSONObject(Data).Names[i],Data.items[i]);
          For I:=0 to S.Count-1 do
            begin
              D:=TJSONData(S.Objects[i]);
              if assigned(D) and
                 (D.JSONType <> jtArray) and
                 (D.JSONType <> jtObject) and
                 (D.JSONType <> jtNull) then
              begin
                writeln(' ':indent,s[i],' : ',D.AsString);
              end
              else
              begin
                writeln(' ':indent,s[i]);
                ShowJSONData(indent+4,D);
              end;
            end
        finally
          S.Free;
        end;
        end;
      jtNull:begin end;
    else
      writeln(' ':indent,Data.AsString);
    end;
    end;
end;

{ returns true when the compo entry must be hidden }
function HideCompoEntry(const e: TJSONdata): boolean;
var
  s: String;
begin
  s:=e.FindPath('status_text').AsString;
  result:= (s = 'Disqualified') or (s = 'Checked');
end;

var
  j: TJSONData;
  entries: TJSONData;
  tmp: TJSONData;
  i: Integer;
  s: String;
  hidden: Integer;

const
  ShowAllEntries = true;

begin
  j:=GetJSONfromURL(URL);

  tmp:=j.FindPath('competition');
  writeln('COMPO: ',tmp.AsString);
  writeln(StringOfChar('=',length('compo: '+tmp.AsString)));

  hidden:=0;
  entries:=j.FindPath('entries');
  if assigned(entries) then
  begin
    for i:=0 to entries.Count-1 do
    begin
      tmp:=entries.Items[i];
      if not ShowAllEntries and HideCompoEntry(tmp) then
      begin
        Inc(hidden);
        continue;
      end;

      writeln(tmp.FindPath('id').AsString:5,': ',
              BOLD,tmp.FindPath('title').AsString,DEFAULT,' by ',BOLD,tmp.FindPath('author').AsString,DEFAULT);
      writeln('':10,'Status: ',tmp.FindPath('status_text').AsString:12,
                    'GEMA: ':10,RED,tmp.FindPath('composer_is_not_member_of_a_copyrightcollective').AsString,DEFAULT);
      tmp:=tmp.FindPath('files');
      if assigned(tmp) and (tmp.JSONType = jtArray) then
      begin
        if tmp.Count > 0 then
        begin
          tmp:=tmp.Items[tmp.Count-1];
          writeln('':10,tmp.FindPath('name').AsString,' from ',tmp.FindPath('link').AsString);
        end
        else
          writeln('':10,'No downloads yet.');
      end;
    end;
    if hidden > 0 then
      writeln('':2,hidden,' compo entries were not listed.');
  end;
end.
