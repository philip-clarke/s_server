-module(s_server_tests).
-compile([debug_info]).
-include_lib("eunit/include/eunit.hrl").

-define(setup(F), {setup, fun start/0, fun stop/1, F}).

%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% TESTS DESCRIPTIONS %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%

% Starting and stopping the server is ok, however when I run the ping_test, it seems that the server is started twice !
basic_start_stop_test_() -> [
    ?_assertMatch({ok, _}, s_server:start_link()),
    ?_assert(ok =:= s_server:stop()),
    ?_assertMatch({ok, _}, s_server:start_link()),
    ?_assert(ok =:= s_server:stop())].


start_stop_test_() -> {
    "Test that the server can be started, stopped and has a registered name",
    {setup,
     fun start/0,
     fun stop/1,
     fun is_registered/1}
}.


ping_test_() -> {
    "Test that the response to ping is pong",
    {setup,
     fun start/0,
     fun stop/1,
     fun respond_with_pong/1}
}.


 
%%%%%%%%%%%%%%%%%%%%%%%
%%% SETUP FUNCTIONS %%%
%%%%%%%%%%%%%%%%%%%%%%%
start() ->
    {ok, Pid} = s_server:start_link(),
    Pid.

wait_for_exit(Pid) ->
    MRef = erlang:monitor(process, Pid),
    receive {'DOWN', MRef, _, _, _} -> ok end.

stop(Pid) ->
    s_server:stop(),
    wait_for_exit(Pid).

 
%%%%%%%%%%%%%%%%%%%%
%%% ACTUAL TESTS %%%
%%%%%%%%%%%%%%%%%%%%
is_registered(Pid) ->
    [?_assert(erlang:is_process_alive(Pid)),
     ?_assertEqual(Pid, whereis(s_server))].

respond_with_pong(Pid) ->
    Result = s_server:ping(),
    [?_assertEqual(pong, Result)].
 
%%%%%%%%%%%%%%%%%%%%%%%%
%%% HELPER FUNCTIONS %%%
%%%%%%%%%%%%%%%%%%%%%%%%
