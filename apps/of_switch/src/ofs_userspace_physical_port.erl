%%%-------------------------------------------------------------------
%%% @author Konrad Kaplita <konrad.kaplita@erlang-solutions.com>
%%% @copyright (C) 2012, Konrad Kaplita
%%% @doc
%%%
%%% @end
%%% Created :  4 Apr 2012 by Konrad Kaplita <konrad.kaplita@erlang-solutions.com>
%%%-------------------------------------------------------------------
-module(ofs_userspace_physical_port).

-behaviour(gen_server).

%% API
-export([start_link/0,
         send/2,
         stop/1]).

%% gen_server callbacks
-export([init/1,
         handle_call/3,
         handle_cast/2,
         handle_info/2,
         terminate/2,
         code_change/3]).

-include_lib("of_switch/include/of_switch_userspace.hrl").

-record(state, {}).

%%%===================================================================
%%% API
%%%===================================================================

-spec start_link() -> {ok, pid()} | ignore | {error, term()}.
start_link() ->
    gen_server:start_link(?MODULE, [], []).

-spec send(pid(), binary()) -> ok.
send(Pid, Pkt) ->
    gen_server:call(Pid, {send, Pkt}).

-spec stop(pid()) -> ok.
stop(Pid) ->
    gen_server:cast(Pid, stop).

%%%===================================================================
%%% gen_server callbacks
%%%===================================================================

-spec init(list()) -> {ok, #state{}} |
                      {ok, #state{}, timeout()} |
                      ignore |
                      {stop, Reason :: term()}.
init([]) ->
    {ok, #state{}}.

-spec handle_call(Request :: term(), From :: {pid(), Tag :: term()}, #state{}) ->
                         {reply, Reply :: term(), #state{}} |
                         {reply, Reply :: term(), #state{}, timeout()} |
                         {noreply, #state{}} |
                         {noreply, #state{}, timeout()} |
                         {stop, Reason :: term() , Reply :: term(), #state{}} |
                         {stop, Reason :: term(), #state{}}.
handle_call({send, _Pkt}, _From, State) ->
    {reply, ok, State};
handle_call(_Request, _From, State) ->
    {reply, ok, State}.

-spec handle_cast(Msg :: term(), #state{}) -> {noreply, #state{}} |
                                              {noreply, #state{}, timeout()} |
                                              {stop, Reason :: term(), #state{}}.
handle_cast(stop, State) ->
    {stop, shutdown, State};
handle_cast(_Msg, State) ->
    {noreply, State}.

-spec handle_info(Info :: term(), #state{}) -> {noreply, #state{}} |
                                               {noreply, #state{}, timeout()} |
                                               {stop, Reason :: term(), #state{}}.
handle_info({pkt, Packet}, State) ->
    OFSPacket = of_switch_userspace:pkt_to_ofs(Packet),
    of_switch_userspace:route(OFSPacket),
    {noreply, State};
handle_info(_Info, State) ->
    {noreply, State}.

-spec terminate(Reason :: term(), #state{}) -> none().
terminate(_Reason, _State) ->
    ok.

-spec code_change(Vsn :: term() | {down, Vsn :: term()}, #state{}, Extra :: term()) ->
                         {ok, #state{}} |
                         {error, Reason :: term()}.
code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

%%%===================================================================
%%% Internal functions
%%%===================================================================