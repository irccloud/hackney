
-module(hackney_sup).

-behaviour(supervisor).

%% API
-export([start_link/0]).

%% Supervisor callbacks
-export([init/1]).

%% Helper macro for declaring children of supervisor
-define(CHILD(I, Type), {I, {I, start_link, []}, permanent, 5000, Type, [I]}).

%% ===================================================================
%% API functions
%% ===================================================================

start_link() ->
    {ok, Pid} = supervisor:start_link({local, ?MODULE}, ?MODULE, []),
    %% start the pool handler
    PoolHandler = hackney_app:get_app_env(pool_handler, hackney_pool),
    ok = PoolHandler:start(),

    %% finish to start the application
    {ok, Pid}.

%% ===================================================================
%% Supervisor callbacks
%% ===================================================================

init([]) ->
    %% init the table to find a pool
    ets:new(hackney_pool, [named_table, set, public]),

    Manager= ?CHILD(hackney_manager, supervisor),

    {ok, { {one_for_one, 10000, 1}, [Manager]}}.
