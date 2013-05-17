-module(tomato).

-export([start/0, stop/1, pritty_minutes/1]).

-define(DURATION_IN_SECONDS, 300).

start() -> 
	spawn(fun() -> loop() end).

stop(Pid) ->
	Pid ! stop.

loop() -> 
	loop(?DURATION_IN_SECONDS).

loop(0) ->
	notify("completed");
loop(Left) ->
	Next = Left-1,

	receive
			stop -> 
				stop();
			Message -> 
				notify("got ~p ~n", [Message]),
				loop(Next)	 
	after 1000 ->
		notify(integer_to_list(?DURATION_IN_SECONDS - Left)),	 
		loop(Next)
	end.

stop() -> 
	notify("voided").

notify(Text, Args) ->
	notify(lists:flatten(io_lib:format(Text, Args))).
notify(Text) ->
	io:format("notify ~p ~n", [Text]),
	gproc:send({p,l,tomato},Text).
