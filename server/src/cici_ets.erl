-module(cici_ets).

-export([create_table/0, get/3, insert/4, delete/2, current_time/0]).

create_table() ->
    Table =
        ets:new(flooo, [set, public, {write_concurrency, true}, {read_concurrency, true}]),
    Table.

get(Table, Key, CurrentTime) ->
    case ets:lookup(Table, Key) of
        [{_, Value, Expiry}] when Expiry =:= 0 orelse CurrentTime =< Expiry ->
            {ok, Value};
        [{_, _, _}] ->
            ets:delete(Table, Key),
            {error, nil};
        [] ->
            {error, nil}
    end.

insert(Table, Key, Value, Expiry) ->
    ets:insert(Table, {Key, Value, Expiry}).

delete(Table, Key) ->
    ets:delete(Table, Key).

current_time() ->
    erlang:system_time(second).
