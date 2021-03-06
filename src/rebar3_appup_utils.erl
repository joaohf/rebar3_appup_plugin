-module(rebar3_appup_utils).

-export([prop_check/3,
         make_proplist/2,
         find_files/3,
         find_files_by_ext/2, find_files_by_ext/3,
         now_str/0]).

%% Helper function for checking values and aborting when needed
prop_check(true, _, _) -> true;
prop_check(false, Msg, Args) -> rebar_api:abort(Msg, Args).

make_proplist([{_,_}=H|T], Acc) ->
    make_proplist(T, [H|Acc]);
make_proplist([H|T], Acc) ->
    App = element(1, H),
    Ver = element(2, H),
    make_proplist(T, [{App,Ver}|Acc]);
make_proplist([], Acc) ->
    Acc.

find_files(Dir, Regex, Recursive) ->
    filelib:fold_files(Dir, Regex, Recursive,
                       fun(F, Acc) -> [F | Acc] end, []).

%% Find files by extension, for example ".erl", avoiding resource fork
%% files in OS X.  Such files are named for example src/._xyz.erl
%% Such files may also appear with network filesystems on OS X.
%%
%% The Ext is really a regexp, with any leading dot implicitly
%% escaped, and anchored at the end of the string.
%%
find_files_by_ext(Dir, Ext) ->
    find_files_by_ext(Dir, Ext, true).

find_files_by_ext(Dir, Ext, Recursive) ->
    %% Convert simple extension to proper regex
    EscapeDot = case Ext of
                    "." ++ _ ->
                        "\\";
                    _ ->
                        %% allow for other suffixes, such as _pb.erl
                        ""
                end,
    ExtRe = "^[^._].*" ++ EscapeDot ++ Ext ++ [$$],
    find_files(Dir, ExtRe, Recursive).

now_str() ->
    {{Year, Month, Day}, {Hour, Minute, Second}} = calendar:local_time(),
    lists:flatten(io_lib:format("~4b/~2..0b/~2..0b ~2..0b:~2..0b:~2..0b",
                                [Year, Month, Day, Hour, Minute, Second])).
