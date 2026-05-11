-module(roadrunner_httparena_handler).
-behaviour(roadrunner_handler).

-export([routes/0]).
-export([handle/1]).

-spec routes() -> [roadrunner_router:route()].
routes() ->
    [
        {~"/baseline11", ?MODULE, undefined},
        {~"/pipeline", ?MODULE, undefined},
        {~"/json/:count", ?MODULE, undefined}
    ].

-spec handle(roadrunner_req:request()) -> roadrunner_handler:result().
handle(Req) ->
    handle_route(roadrunner_req:path(Req), Req).

handle_route(~"/baseline11", Req) ->
    baseline11(Req);
handle_route(~"/pipeline", Req) ->
    {roadrunner_resp:text(200, ~"ok"), Req};
handle_route(<<"/json/", _/binary>>, Req) ->
    json_endpoint(Req);
handle_route(_, Req) ->
    {roadrunner_resp:not_found(), Req}.

baseline11(Req) ->
    A = qs_int(~"a", Req, 0),
    B = qs_int(~"b", Req, 0),
    {BodyN, Req2} =
        case roadrunner_req:method(Req) of
            ~"POST" ->
                {ok, Body, ReqR} = roadrunner_req:read_body(Req),
                {body_int(Body), ReqR};
            _ ->
                {0, Req}
        end,
    {roadrunner_resp:text(200, integer_to_binary(A + B + BodyN)), Req2}.

json_endpoint(Req) ->
    Count = binding_int(~"count", Req, 0),
    M = qs_int(~"m", Req, 1),
    All = roadrunner_httparena_dataset:items(),
    Items = lists:sublist(All, max(0, Count)),
    Processed = [add_total(I, M) || I <- Items],
    Body = #{~"items" => Processed, ~"count" => length(Processed)},
    {roadrunner_resp:json(200, Body), Req}.

add_total(Item, M) ->
    Price = maps:get(~"price", Item),
    Qty = maps:get(~"quantity", Item),
    Item#{~"total" => Price * Qty * M}.

binding_int(Key, Req, Default) ->
    case roadrunner_req:bindings(Req) of
        #{Key := V} when is_binary(V) -> bin_int(V, Default);
        _ -> Default
    end.

qs_int(Key, Req, Default) ->
    case lists:keyfind(Key, 1, roadrunner_req:parse_qs(Req)) of
        {Key, V} when is_binary(V) -> bin_int(V, Default);
        _ -> Default
    end.

bin_int(<<>>, Default) ->
    Default;
bin_int(Bin, Default) ->
    case string:to_integer(Bin) of
        {N, _} when is_integer(N) -> N;
        _ -> Default
    end.

body_int(<<>>) -> 0;
body_int(Bin) -> bin_int(Bin, 0).
