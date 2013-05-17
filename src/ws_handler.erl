-module(ws_handler).
-behaviour(cowboy_websocket_handler).

-export([init/3]).
-export([websocket_init/3]).
-export([websocket_handle/3]).
-export([websocket_info/3]).
-export([websocket_terminate/3]).

-record(tomatoState, {pid}).

init({tcp, http}, _Req, _Opts) ->
	{upgrade, protocol, cowboy_websocket}.

websocket_init(_TransportName, Req, _Opts) ->
	gproc:reg({p,l, tomato}),
	{ok, Req, #tomatoState{}}.

websocket_handle({text, Msg}, Req, State) ->
	io:format("in-> ~p ~n", [Msg]),

	NewState = case Msg of
		<<"start">> -> 
			io:format("start ~n"),
			Pid = tomato:start(),
			State#tomatoState{pid=Pid};	
		<<"void">> -> 
			io:format("void ~n"),
			tomato:stop(State#tomatoState.pid),
			#tomatoState{};
		_ -> 
			io:format("unknown ~p ~n", [Msg]),
			State 
	end,

	{reply, {text, << Msg/binary >>}, Req, NewState};
websocket_handle(_Data, Req, State) ->
	{ok, Req, State}.

websocket_info(Msg,Req,State) ->
	io:format("out-> ~p ~n", [Msg]),
  	{reply, {text, Msg}, Req, State, hibernate};
websocket_info(_Info, Req, State) ->
	{ok, Req, State}.

websocket_terminate(_Reason, _Req, _State) ->
	ok.
