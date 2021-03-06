%%%-------------------------------------------------------------------
%%% @copyright (C) 2014, 2600Hz
%%% @doc
%%% Device document manipulation
%%% @end
%%% @contributors
%%%   James Aimonetti
%%%-------------------------------------------------------------------
-module(kz_device).

-export([sip_username/1, set_sip_username/2
         ,sip_password/1, set_sip_password/2
         ,sip_settings/1, set_sip_settings/2
        ]).

-include("kz_documents.hrl").

-spec sip_username(wh_json:object()) -> api_binary().
sip_username(DeviceJObj) ->
    wh_json:get_value([<<"sip">>, <<"username">>], DeviceJObj).

-spec sip_password(wh_json:object()) -> api_binary().
sip_password(DeviceJObj) ->
    wh_json:get_value([<<"sip">>, <<"password">>], DeviceJObj).

-spec sip_settings(wh_json:object()) -> api_object().
sip_settings(DeviceJObj) ->
    wh_json:get_value(<<"sip">>, DeviceJObj).


-spec set_sip_username(wh_json:object(), ne_binary()) -> wh_json:object().
set_sip_username(DeviceJObj, Username) ->
    wh_json:set_value([<<"sip">>, <<"username">>], Username, DeviceJObj).

-spec set_sip_password(wh_json:object(), ne_binary()) -> wh_json:object().
set_sip_password(DeviceJObj, Password) ->
    wh_json:set_value([<<"sip">>, <<"password">>], Password, DeviceJObj).

-spec set_sip_settings(wh_json:object(), wh_json:object()) -> wh_json:object().
set_sip_settings(DeviceJObj, SipJObj) ->
    wh_json:set_value(<<"sip">>, SipJObj, DeviceJObj).
