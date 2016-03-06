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
  fpjson, jsonparser,

  consoleabuse,
  compoentry;


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

var
  j: TJSONData;
  entries: TJSONData;
  tmp: TJSONData;
  ce: TCompoEntry;
  i: Integer;
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
      if not ShowAllEntries and TCompoEntry.Hidden(tmp) then
      begin
        Inc(hidden);
        continue;
      end;

      ce:=TCompoEntry.Create(tmp);
      writeln(ce.ID:5,': ',ce.TitleAndAuthor);
      writeln('':10,'Status: ',ce.StatusString:12,
                    'GEMA: ':10,ce.GEMAStatusString);
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
      ce.Free;
    end;
    if hidden > 0 then
      writeln('':2,hidden,' compo entries were not listed.');
  end;
end.
