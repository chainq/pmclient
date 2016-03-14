{$MODE OBJFPC}
unit requests;

interface

uses
  sysutils,
  fphttpclient,fpjson,jsonparser,jsonconf;

const
  USER_AGENT = 'PartyMeisterClient/0.1337 ('+{$I %FPCTARGETOS%}+'-'+{$I %FPCTARGETCPU%}+')';

type
  TAPIRequest = class
    FServerHost: UnicodeString;
    FAPIToken: UnicodeString;
    FAPIPath: UnicodeString;
    FAPIURL: UnicodeString;
    FLastRequest: TJSONData;
  public
    constructor Create(const cfg: TJSONConfig);
    function Get(const APIFunction: AnsiString): TJSONData;

    function GetStatus: Integer; overload;
    function GetMessage: AnsiString; overload;
    function GetData: TJSONData; overload;

    class function GetStatus(const req: TJSONData): Integer; overload;
    class function GetMessage(const req: TJSONData): AnsiString; overload;
    class function GetData(const req: TJSONData): TJSONData; overload;
  end;

implementation


constructor TAPIRequest.Create(const cfg: TJSONConfig);
begin
  FServerHost:=cfg.GetValue('/partymeister/server_host','');
  FAPIPath:=cfg.GetValue('/partymeister/api_path','');
  FAPIToken:=cfg.GetValue('/partymeister/api_token','');

  FAPIURL:='http://'+FServerHost+FAPIPath;
end;

function TAPIRequest.Get(const APIFunction: AnsiString): TJSONData;
var
  RequestURL: UnicodeString;
  s: AnsiString;
  c: TFPCustomHTTPClient;
begin
  result:=nil;
  RequestURL:=FAPIURL+UnicodeString(APIFunction);
  writeln('Sending request: [',RequestURL,']');

  c:=TFPCustomHTTPClient.Create(nil);
  c.AddHeader('User-Agent',USER_AGENT);
  c.AddHeader('Token',AnsiString(FAPIToken));

  s:=c.Get(AnsiString(RequestURL));
  FreeAndNil(c);

  FLastRequest:=GetJSON(s);
  result:=FLastRequest;
end;

function TAPIRequest.GetStatus: Integer; overload;
begin
  result:=GetStatus(FLastRequest);
end;

function TAPIRequest.GetMessage: AnsiString; overload;
begin
  result:=GetMessage(FLastRequest);
end;

function TAPIRequest.GetData: TJSONData; overload;
begin
  result:=GetData(FLastRequest);
end;

class function TAPIRequest.GetStatus(const req: TJSONData): Integer; overload;
begin
  result:=req.FindPath('status').AsInteger;
end;

class function TAPIRequest.GetMessage(const req: TJSONData): AnsiString; overload;
begin
  result:=req.FindPath('message').AsString;
end;

class function TAPIRequest.GetData(const req: TJSONData): TJSONData; overload;
begin
  result:=req.FindPath('data');
end;

end.
