-module(tid).

-export([new/0, new/1, next/0, to_string/1, clockid/1]).

-record(tid, {timestamp :: integer(), clockid :: integer()}).

-define(FIRST_CHAR, "234567abcdefghij").
-define(REST_CHARS, "234567abcdefghijklmnopqrstuvwxyz").
-define(BASE32_CHARS, ?REST_CHARS).
-define(TID_LENGTH, 13).
-define(MAX_CLOCKID, 1023).

next() ->
    Timestamp = erlang:system_time(microsecond),
    LastTid =
        case persistent_term:get({?MODULE, last_tid}, undefined) of
            undefined ->
                #tid{timestamp = 0, clockid = 0};
            Value ->
                Value
        end,

    NewTid =
        if Timestamp > LastTid#tid.timestamp ->
               #tid{timestamp = Timestamp, clockid = 0};
           Timestamp =:= LastTid#tid.timestamp ->
               NewClockId = (LastTid#tid.clockid + 1) band ?MAX_CLOCKID,
               if NewClockId =< LastTid#tid.clockid ->
                      #tid{timestamp = Timestamp + 1, clockid = 0};
                  true ->
                      #tid{timestamp = Timestamp, clockid = NewClockId}
               end;
           true ->
               #tid{timestamp = LastTid#tid.timestamp + 1, clockid = 0}
        end,

    persistent_term:put({?MODULE, last_tid}, NewTid),
    NewTid.

new() ->
    Timestamp = erlang:system_time(microsecond),
    ClockId = rand:uniform(1024),
    #tid{timestamp = Timestamp, clockid = ClockId}.

new(TidString) when is_list(TidString) ->
    case string:chr(TidString, $-) of
        0 ->
            ok;
        _ ->
            error({invalid_tid, "Hyphens are not allowed in TID format"})
    end,

    case validate_tid_string(TidString) of
        true ->
            try
                Combined = decode_base32sortable(TidString),
                ClockId = Combined band ?MAX_CLOCKID,
                Timestamp = Combined bsr 10,
                #tid{timestamp = Timestamp, clockid = ClockId}
            catch
                _:_ ->
                    error({invalid_tid, "Failed to decode TID string"})
            end;
        false ->
            error({invalid_tid, "Invalid TID format"})
    end.

clockid(#tid{clockid = ClockId}) ->
    ClockId.

to_string(#tid{timestamp = Timestamp, clockid = ClockId}) ->
    encode_tid(Timestamp, ClockId).

validate_tid_string(TidString) ->
    case TidString of
        [FirstChar | Rest] ->
            length(TidString) =:= ?TID_LENGTH
            andalso string:chr(?FIRST_CHAR, FirstChar) > 0
            andalso lists:all(fun(C) -> string:chr(?REST_CHARS, C) > 0 end, Rest);
        _ ->
            false
    end.

encode_tid(Timestamp, ClockId) ->
    Combined = Timestamp bsl 10 bor ClockId,
    encode_base32(Combined).

encode_base32(Num) ->
    encode_base32(Num, ?TID_LENGTH, []).

encode_base32(0, 0, Acc) ->
    Acc;
encode_base32(_, 0, Acc) ->
    Acc;
encode_base32(Num, Length, Acc) ->
    CharIdx = Num rem 32,
    Char = lists:nth(CharIdx + 1, ?BASE32_CHARS),
    encode_base32(Num div 32, Length - 1, [Char | Acc]).

decode_base32sortable(String) ->
    lists:foldl(fun(Char, Acc) ->
                   Value = char_to_value(Char),
                   Acc * 32 + Value
                end,
                0,
                String).

char_to_value(Char) ->
    case string:chr(?BASE32_CHARS, Char) - 1 of
        -1 ->
            error({invalid_character, Char});
        Value ->
            Value
    end.
