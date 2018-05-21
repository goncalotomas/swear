-module(swear).

%% API exports
-export([scan/1, scan/2]).

%%====================================================================
%% API functions
%%====================================================================
scan(Str) ->
    scan_files(lang_files(all_languages()), Str).

scan(Str, [H|_T] = Langs) when is_list(H) ->
    scan_files(lang_files(Langs), Str).

%%====================================================================
%% Internal functions
%%====================================================================
all_languages() ->
    PrivDir = code:priv_dir(swear),
    {ok, Filenames} = file:list_dir(PrivDir),
    Filenames.

lang_files(Langs) ->
    PrivDir = code:priv_dir(swear),
    {ok, Filenames} = file:list_dir(PrivDir),
    FilesPerLang = lists:map(fun(Lang) ->
                        lists:filter(fun(Filename) ->
                            nomatch =/= string:find(Filename, Lang, leading)
                        end, Filenames)
                    end, Langs),
    lists:map(fun(Filename) -> PrivDir ++ "/" ++ Filename end, lists:umerge(FilesPerLang)).

scan_files([], _Str) ->
    false;
scan_files([H|T], Str) ->
    scan_lines(read_lines(H), Str) orelse scan_files(T, Str).

scan_lines(Lines, Str) ->
    scan_lines(Lines, Str, false).

scan_lines([], _Str, Accum) ->
    Accum;
scan_lines([H|T], Str, Accum) ->
    CaseFold = string:casefold(Str),
    nomatch =/= string:find(CaseFold, H, leading) orelse scan_lines(T, Str, Accum).

read_lines(FileName) ->
    {ok, Pid} = file:open(FileName, [read, {encoding, utf8}]),
    try
        string:tokens(get_all_lines(Pid), "\n")
    after
        file:close(Pid)
    end.

get_all_lines(Pid) ->
    case io:get_line(Pid, "") of
        eof  -> [];
        Line -> Line ++ get_all_lines(Pid)
    end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%                                                     Eunit Tests                                                    %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

-ifdef(TEST).
-include_lib("eunit/include/eunit.hrl").

global_swear_scan_test() ->
    ?assert(?MODULE:scan("shit")),
    ?assert(?MODULE:scan("merda")),
    ?assert(not ?MODULE:scan("lisbon")).

english_swear_not_detected_in_other_languages_test() ->
    ?assert(not ?MODULE:scan("shit", ["pt"])),
    ?assert(not ?MODULE:scan("shit", ["es"])),
    ?assert(not ?MODULE:scan("shit", ["fr"])),
    ?assert(not ?MODULE:scan("shit", ["ar", "es", "pt", "fr"])).

portuguese_swear_detected_in_list_of_languages_test() ->
    ?assert(not ?MODULE:scan("merda", ["es"])),
    ?assert(not ?MODULE:scan("merda", ["en"])),
    ?assert(?MODULE:scan("merda", ["en", "pt", "es"])),
    ?assert(?MODULE:scan("merda", ["pt", "en", "es"])),
    ?assert(?MODULE:scan("merda", ["en", "es", "pt"])),
    ?assert(?MODULE:scan("merda", ["en", "pt"])),
    ?assert(?MODULE:scan("merda", ["pt"])).

empty_language_scan_fails_test() ->
    ?assertError(function_clause, ?MODULE:scan("shit", [])),
    ?assertError(function_clause, ?MODULE:scan("shit", "")).

foreseen_incorrect_usage_fails_test() ->
    ?assertError(function_clause, ?MODULE:scan("shit", "en")).

-endif.
