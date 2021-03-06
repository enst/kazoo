%%%-------------------------------------------------------------------
%%% @copyright (C) 2011-2014, 2600Hz
%%% @doc
%%% Notification messages, like voicemail left
%%% @end
%%% @contributors
%%%   James Aimonetti
%%%   Karl Anderson
%%%-------------------------------------------------------------------
-module(wapi_notifications).

-export([bind_q/2, unbind_q/2]).
-export([declare_exchanges/0]).

-export([voicemail/1, voicemail_v/1
         ,voicemail_full/1, voicemail_full_v/1
         ,fax_inbound/1, fax_inbound_v/1
         ,fax_inbound_error/1, fax_inbound_error_v/1
         ,fax_outbound/1, fax_outbound_v/1
         ,fax_outbound_error/1, fax_outbound_error_v/1
         ,register/1, register_v/1
         ,deregister/1, deregister_v/1
         ,pwd_recovery/1, pwd_recovery_v/1
         ,new_account/1, new_account_v/1
         ,port_request/1, port_request_v/1
         ,port_cancel/1, port_cancel_v/1
         ,ported/1, ported_v/1
         ,cnam_request/1, cnam_request_v/1
         ,low_balance/1, low_balance_v/1
         ,topup/1, topup_v/1
         ,transaction/1, transaction_v/1
         ,system_alert/1, system_alert_v/1
         ,webhook/1, webhook_v/1
         %% published on completion of notification
         ,notify_update/1, notify_update_v/1
        ]).

-export([publish_voicemail/1, publish_voicemail/2
         ,publish_voicemail_full/1, publish_voicemail_full/2
         ,publish_fax_inbound/1, publish_fax_inbound/2
         ,publish_fax_outbound/1, publish_fax_outbound/2
         ,publish_fax_inbound_error/1, publish_fax_inbound_error/2
         ,publish_fax_outbound_error/1, publish_fax_outbound_error/2
         ,publish_register/1, publish_register/2
         ,publish_deregister/1, publish_deregister/2
         ,publish_pwd_recovery/1, publish_pwd_recovery/2
         ,publish_new_account/1, publish_new_account/2
         ,publish_port_request/1, publish_port_request/2
         ,publish_port_cancel/1, publish_port_cancel/2
         ,publish_ported/1, publish_ported/2
         ,publish_cnam_request/1, publish_cnam_request/2
         ,publish_low_balance/1, publish_low_balance/2
         ,publish_topup/1, publish_topup/2
         ,publish_transaction/1, publish_transaction/2
         ,publish_system_alert/1, publish_system_alert/2
         ,publish_webhook/1, publish_webhook/2
         ,publish_notify_update/2, publish_notify_update/3
        ]).

-include_lib("whistle/include/wh_api.hrl").

-define(NOTIFY_VOICEMAIL_NEW, <<"notifications.voicemail.new">>).
-define(NOTIFY_VOICEMAIL_FULL, <<"notifications.voicemail.full">>).
-define(NOTIFY_FAX_INBOUND, <<"notifications.fax.inbound">>).
-define(NOTIFY_FAX_OUTBOUND, <<"notifications.fax.outbound">>).
-define(NOTIFY_FAX_INBOUND_ERROR, <<"notifications.fax.inbound_error">>).
-define(NOTIFY_FAX_OUTBOUND_ERROR, <<"notifications.fax.outbound_error">>).
-define(NOTIFY_DEREGISTER, <<"notifications.sip.deregister">>).
%%-define(NOTIFY_REGISTER_OVERWRITE, <<"notifications.sip.register_overwrite">>).
-define(NOTIFY_REGISTER, <<"notifications.sip.register">>).
-define(NOTIFY_PWD_RECOVERY, <<"notifications.password.recovery">>).
-define(NOTIFY_NEW_ACCOUNT, <<"notifications.account.new">>).
%% -define(NOTIFY_DELETE_ACCOUNT, <<"notifications.account.delete">>).
-define(NOTIFY_PORT_REQUEST, <<"notifications.number.port">>).
-define(NOTIFY_PORT_CANCEL, <<"notifications.number.port_cancel">>).
-define(NOTIFY_PORTED, <<"notifications.number.ported">>).
-define(NOTIFY_CNAM_REQUEST, <<"notifications.number.cnam">>).
-define(NOTIFY_LOW_BALANCE, <<"notifications.account.low_balance">>).
-define(NOTIFY_TOPUP, <<"notifications.account.topup">>).
-define(NOTIFY_TRANSACTION, <<"notifications.account.transaction">>).
-define(NOTIFY_SYSTEM_ALERT, <<"notifications.system.alert">>).
-define(NOTIFY_WEBHOOK_CALLFLOW, <<"notifications.webhook.callflow">>).

%% Notify New Voicemail
-define(VOICEMAIL_HEADERS, [<<"From-User">>, <<"From-Realm">>
                            ,<<"To-User">>, <<"To-Realm">>
                            ,<<"Account-DB">>
                            ,<<"Voicemail-Box">>, <<"Voicemail-Name">>
                            ,<<"Voicemail-Timestamp">>
                           ]).
-define(OPTIONAL_VOICEMAIL_HEADERS, [<<"Voicemail-Length">>, <<"Call-ID">>
                                     ,<<"Caller-ID-Number">>, <<"Caller-ID-Name">>
                                     ,<<"Voicemail-Transcription">>
                                     ,<<"Account-ID">>
                                    ]).
-define(VOICEMAIL_VALUES, [{<<"Event-Category">>, <<"notification">>}
                           ,{<<"Event-Name">>, <<"new_voicemail">>}
                          ]).
-define(VOICEMAIL_TYPES, []).

%% Notify Voicemail full
-define(VOICEMAIL_FULL_HEADERS, [<<"Account-DB">>
                                 ,<<"Voicemail-Box">> ,<<"Voicemail-Number">>
                                 ,<<"Max-Message-Count">> ,<<"Message-Count">>
                                ]).
-define(OPTIONAL_VOICEMAIL_FULL_HEADERS, [<<"Account-ID">>]).
-define(VOICEMAIL_FULL_VALUES, [{<<"Event-Category">>, <<"notification">>}
                                ,{<<"Event-Name">>, <<"voicemail_full">>}
                               ]).
-define(VOICEMAIL_FULL_TYPES, []).

%% Notify New Fax
-define(FAX_INBOUND_HEADERS, [<<"From-User">>, <<"From-Realm">>
                              ,<<"To-User">>, <<"To-Realm">>
                              ,<<"Account-ID">>, <<"Fax-ID">>
                             ]).
-define(OPTIONAL_FAX_INBOUND_HEADERS, [<<"Caller-ID-Name">>, <<"Caller-ID-Number">>
                                       ,<<"Callee-ID-Name">>, <<"Callee-ID-Number">>
                                       ,<<"Call-ID">>, <<"Fax-Info">>
                                       ,<<"Owner-ID">>, <<"FaxBox-ID">>
                                       ,<<"Fax-Notifications">>, <<"Fax-Timestamp">>
                                      ]).
-define(FAX_INBOUND_VALUES, [{<<"Event-Category">>, <<"notification">>}
                             ,{<<"Event-Name">>, <<"inbound_fax">>}
                            ]).
-define(FAX_INBOUND_TYPES, []).

-define(FAX_INBOUND_ERROR_HEADERS, [<<"From-User">>, <<"From-Realm">>
                                    ,<<"To-User">>, <<"To-Realm">>
                                    ,<<"Account-ID">>
                                   ]).
-define(OPTIONAL_FAX_INBOUND_ERROR_HEADERS, [<<"Caller-ID-Name">>, <<"Caller-ID-Number">>
                                             ,<<"Callee-ID-Name">>, <<"Callee-ID-Number">>
                                             ,<<"Call-ID">>, <<"Fax-Info">>, <<"Fax-ID">>
                                             ,<<"Owner-ID">>, <<"FaxBox-ID">>
                                             ,<<"Fax-Notifications">>, <<"Fax-Error">>
                                             ,<<"Fax-Timestamp">>
                                            ]).
-define(FAX_INBOUND_ERROR_VALUES, [{<<"Event-Category">>, <<"notification">>}
                                   ,{<<"Event-Name">>, <<"inbound_fax_error">>}
                                  ]).
-define(FAX_INBOUND_ERROR_TYPES, []).

-define(FAX_OUTBOUND_HEADERS, [<<"Caller-ID-Number">>, <<"Callee-ID-Number">>
                               ,<<"Account-ID">>, <<"Fax-JobId">>
                              ]).
-define(OPTIONAL_FAX_OUTBOUND_HEADERS, [<<"Caller-ID-Name">>, <<"Callee-ID-Name">>
                                        ,<<"Call-ID">>, <<"Fax-Info">>
                                        ,<<"Owner-ID">>, <<"FaxBox-ID">>
                                        ,<<"Fax-Notifications">>, <<"Fax-Timestamp">>
                                       ]).
-define(FAX_OUTBOUND_VALUES, [{<<"Event-Category">>, <<"notification">>}
                              ,{<<"Event-Name">>, <<"outbound_fax">>}
                             ]).
-define(FAX_OUTBOUND_TYPES, []).

-define(FAX_OUTBOUND_ERROR_HEADERS, [<<"Fax-JobId">>]).
-define(OPTIONAL_FAX_OUTBOUND_ERROR_HEADERS, [<<"Caller-ID-Name">>, <<"Callee-ID-Name">>
                                              ,<<"Caller-ID-Number">>, <<"Callee-ID-Number">>
                                              ,<<"Call-ID">>, <<"Fax-Info">>
                                              ,<<"Owner-ID">>, <<"FaxBox-ID">>
                                              ,<<"Fax-Notifications">>, <<"Fax-Error">>
                                              ,<<"Account-ID">>, <<"Fax-Timestamp">>
                                             ]).
-define(FAX_OUTBOUND_ERROR_VALUES, [{<<"Event-Category">>, <<"notification">>}
                                    ,{<<"Event-Name">>, <<"outbound_fax_error">>}
                                   ]).
-define(FAX_OUTBOUND_ERROR_TYPES, []).

%% Notify Deregister
-define(DEREGISTER_HEADERS, [<<"Username">>, <<"Realm">>, <<"Account-ID">>]).
-define(OPTIONAL_DEREGISTER_HEADERS, [<<"Status">>, <<"User-Agent">>, <<"Call-ID">>, <<"Profile-Name">>, <<"Presence-Hosts">>
                                      ,<<"From-User">>, <<"From-Host">>, <<"FreeSWITCH-Hostname">>, <<"RPid">>
                                      ,<<"To-User">>, <<"To-Host">>, <<"Network-IP">>, <<"Network-Port">>
                                      ,<<"Event-Timestamp">>, <<"Contact">>, <<"Expires">>, <<"Account-DB">>
                                      ,<<"Authorizing-ID">>, <<"Suppress-Unregister-Notify">>
                                     ]).
-define(DEREGISTER_VALUES, [{<<"Event-Category">>, <<"notification">>}
                            ,{<<"Event-Name">>, <<"deregister">>}
                           ]).
-define(DEREGISTER_TYPES, []).

%% Notify Register
-define(REGISTER_HEADERS, [<<"Username">>, <<"Realm">>, <<"Account-ID">>]).
-define(OPTIONAL_REGISTER_HEADERS, [<<"Owner-ID">>, <<"User-Agent">>, <<"Call-ID">>
                                        ,<<"From-User">>, <<"From-Host">>
                                        ,<<"To-User">>, <<"To-Host">>
                                        ,<<"Network-IP">>, <<"Network-Port">>
                                        ,<<"Event-Timestamp">>, <<"Contact">>
                                        ,<<"Expires">>, <<"Account-DB">>
                                        ,<<"Authorizing-ID">>, <<"Authorizing-Type">>
                                        ,<<"Suppress-Unregister-Notify">>
                                     ]).
-define(REGISTER_VALUES, [{<<"Event-Category">>, <<"notification">>}
                            ,{<<"Event-Name">>, <<"register">>}
                           ]).
-define(REGISTER_TYPES, []).

%% Notify Password Recovery
-define(PWD_RECOVERY_HEADERS, [<<"Email">>, <<"Password">>, <<"Account-ID">>]).
-define(OPTIONAL_PWD_RECOVERY_HEADERS, [<<"First-Name">>, <<"Last-Name">>, <<"Account-DB">>, <<"Request">>]).
-define(PWD_RECOVERY_VALUES, [{<<"Event-Category">>, <<"notification">>}
                              ,{<<"Event-Name">>, <<"password_recovery">>}
                             ]).
-define(PWD_RECOVERY_TYPES, []).

%% Notify New Account
-define(NEW_ACCOUNT_HEADERS, [<<"Account-ID">>]).
-define(OPTIONAL_NEW_ACCOUNT_HEADERS, [<<"Account-DB">>, <<"Account-Name">>, <<"Account-API-Key">>, <<"Account-Realm">>]).
-define(NEW_ACCOUNT_VALUES, [{<<"Event-Category">>, <<"notification">>}
                              ,{<<"Event-Name">>, <<"new_account">>}
                             ]).
-define(NEW_ACCOUNT_TYPES, []).

%% Notify Port Request
-define(PORT_REQUEST_HEADERS, [<<"Account-ID">>]).
-define(OPTIONAL_PORT_REQUEST_HEADERS, [<<"Authorized-By">>, <<"Port-Request-ID">>
                                        ,<<"Number-State">>, <<"Local-Number">>
                                        ,<<"Number">>, <<"Port">>, <<"Version">>
                                       ]).
-define(PORT_REQUEST_VALUES, [{<<"Event-Category">>, <<"notification">>}
                              ,{<<"Event-Name">>, <<"port_request">>}
                             ]).
-define(PORT_REQUEST_TYPES, []).

% Notify Port Cancel
-define(PORT_CANCEL_HEADERS, [<<"Account-ID">>]).
-define(OPTIONAL_PORT_CANCEL_HEADERS, [<<"Authorized-By">>, <<"Port-Request-ID">>
                                        ,<<"Number-State">>, <<"Local-Number">>
                                        ,<<"Number">>, <<"Port">>
                                       ]).
-define(PORT_CANCEL_VALUES, [{<<"Event-Category">>, <<"notification">>}
                              ,{<<"Event-Name">>, <<"port_cancel">>}
                             ]).
-define(PORT_CANCEL_TYPES, []).

%% Notify Ported Request
-define(PORTED_HEADERS, [<<"Account-ID">>, <<"Number">>, <<"Port">>]).
-define(OPTIONAL_PORTED_HEADERS, [<<"Number-State">>, <<"Local-Number">>, <<"Authorized-By">>, <<"Request">>]).
-define(PORTED_VALUES, [{<<"Event-Category">>, <<"notification">>}
                        ,{<<"Event-Name">>, <<"ported">>}
                       ]).
-define(PORTED_TYPES, []).

%% Notify Cnam Request
-define(CNAM_REQUEST_HEADERS, [<<"Account-ID">>, <<"Number">>, <<"Cnam">>]).
-define(OPTIONAL_CNAM_REQUEST_HEADERS, [<<"Number-State">>, <<"Local-Number">>, <<"Acquired-For">>, <<"Request">>]).
-define(CNAM_REQUEST_VALUES, [{<<"Event-Category">>, <<"notification">>}
                              ,{<<"Event-Name">>, <<"cnam_request">>}
                             ]).
-define(CNAM_REQUEST_TYPES, []).

%% Notify Low Balance
-define(LOW_BALANCE_HEADERS, [<<"Account-ID">>, <<"Current-Balance">>]).
-define(OPTIONAL_LOW_BALANCE_HEADERS, []).
-define(LOW_BALANCE_VALUES, [{<<"Event-Category">>, <<"notification">>}
                             ,{<<"Event-Name">>, <<"low_balance">>}
                            ]).
-define(LOW_BALANCE_TYPES, []).

%% Notify Top Up
-define(TOPUP_HEADERS, [<<"Account-ID">>]).
-define(OPTIONAL_TOPUP_HEADERS, []).
-define(TOPUP_VALUES, [{<<"Event-Category">>, <<"notification">>}
                        ,{<<"Event-Name">>, <<"low_balance">>}
                      ]).
-define(TOPUP_TYPES, []).


%% Notify Transaction
-define(TRANSACTION_HEADERS, [<<"Account-ID">>, <<"Transaction">>]).
-define(OPTIONAL_TRANSACTION_HEADERS, [<<"Service-Plan">>, <<"Billing-ID">>]).
-define(TRANSACTION_VALUES, [{<<"Event-Category">>, <<"notification">>}
                             ,{<<"Event-Name">>, <<"transaction">>}
                            ]).
-define(TRANSACTION_TYPES, []).

%% Notify System Alert
-define(SYSTEM_ALERT_HEADERS, [<<"Subject">>, <<"Message">>]).
-define(OPTIONAL_SYSTEM_ALERT_HEADERS, [<<"Pid">>, <<"Module">>, <<"Line">>, <<"Request-ID">>, <<"Section">>
                                            ,<<"Node">>, <<"Details">>, <<"Account-ID">>
                                       ]).
-define(SYSTEM_ALERT_VALUES, [{<<"Event-Category">>, <<"notification">>}
                              ,{<<"Event-Name">>, <<"system_alert">>}
                             ]).
-define(SYSTEM_ALERT_TYPES, []).

%% Notify webhook
-define(WEBHOOK_HEADERS, [<<"Hook">>, <<"Data">>]).
-define(OPTIONAL_WEBHOOK_HEADERS, [<<"Timestamp">>]).
-define(WEBHOOK_VALUES, [{<<"Event-Category">>, <<"notification">>}
                         ,{<<"Event-Name">>, <<"webhook">>}
                        ]).
-define(WEBHOOK_TYPES, []).

-define(NOTIFY_UPDATE_HEADERS, [<<"Status">>]).
-define(OPTIONAL_NOTIFY_UPDATE_HEADERS, [<<"Failure-Message">>]).
-define(NOTIFY_UPDATE_VALUES, [{<<"Event-Category">>, <<"notification">>}
                               ,{<<"Event-Name">>, <<"update">>}
                               ,{<<"Status">>, [<<"completed">>, <<"failed">>, <<"pending">>]}
                              ]).
-define(NOTIFY_UPDATE_TYPES, []).


%%--------------------------------------------------------------------
%% @doc
%% Takes proplist, creates JSON string or error
%% @end
%%--------------------------------------------------------------------
voicemail(Prop) when is_list(Prop) ->
    case voicemail_v(Prop) of
        'true' -> wh_api:build_message(Prop, ?VOICEMAIL_HEADERS, ?OPTIONAL_VOICEMAIL_HEADERS);
        'false' -> {'error', "Proplist failed validation for voicemail"}
    end;
voicemail(JObj) -> voicemail(wh_json:to_proplist(JObj)).

-spec voicemail_v(api_terms()) -> boolean().
voicemail_v(Prop) when is_list(Prop) ->
    wh_api:validate(Prop, ?VOICEMAIL_HEADERS, ?VOICEMAIL_VALUES, ?VOICEMAIL_TYPES);
voicemail_v(JObj) -> voicemail_v(wh_json:to_proplist(JObj)).

%%--------------------------------------------------------------------
%% @doc
%% Takes proplist, creates JSON string or error
%% @end
%%--------------------------------------------------------------------
voicemail_full(Prop) when is_list(Prop) ->
    case voicemail_full_v(Prop) of
        'true' -> wh_api:build_message(Prop, ?VOICEMAIL_FULL_HEADERS, ?OPTIONAL_VOICEMAIL_FULL_HEADERS);
        'false' -> {'error', "Proplist failed validation for voicemail_full"}
    end;
voicemail_full(JObj) -> voicemail_full(wh_json:to_proplist(JObj)).

-spec voicemail_full_v(api_terms()) -> boolean().
voicemail_full_v(Prop) when is_list(Prop) ->
    wh_api:validate(Prop, ?VOICEMAIL_FULL_HEADERS, ?VOICEMAIL_FULL_VALUES, ?VOICEMAIL_FULL_TYPES);
voicemail_full_v(JObj) -> voicemail_full_v(wh_json:to_proplist(JObj)).

%%--------------------------------------------------------------------
%% @doc
%% Takes proplist, creates JSON string or error
%% @end
%%--------------------------------------------------------------------
fax_inbound(Prop) when is_list(Prop) ->
    case fax_inbound_v(Prop) of
        'true' -> wh_api:build_message(Prop, ?FAX_INBOUND_HEADERS, ?OPTIONAL_FAX_INBOUND_HEADERS);
        'false' -> {'error', "Proplist failed validation for inbound_fax"}
    end;
fax_inbound(JObj) -> fax_inbound(wh_json:to_proplist(JObj)).

-spec fax_inbound_v(api_terms()) -> boolean().
fax_inbound_v(Prop) when is_list(Prop) ->
    wh_api:validate(Prop, ?FAX_INBOUND_HEADERS, ?FAX_INBOUND_VALUES, ?FAX_INBOUND_TYPES);
fax_inbound_v(JObj) -> fax_inbound_v(wh_json:to_proplist(JObj)).

%%--------------------------------------------------------------------
%% @doc
%% Takes proplist, creates JSON string or error
%% @end
%%--------------------------------------------------------------------
fax_outbound(Prop) when is_list(Prop) ->
    case fax_outbound_v(Prop) of
        'true' -> wh_api:build_message(Prop, ?FAX_OUTBOUND_HEADERS, ?OPTIONAL_FAX_OUTBOUND_HEADERS);
        'false' -> {'error', "Proplist failed validation for outbound_fax"}
    end;
fax_outbound(JObj) -> fax_outbound(wh_json:to_proplist(JObj)).

-spec fax_outbound_v(api_terms()) -> boolean().
fax_outbound_v(Prop) when is_list(Prop) ->
    wh_api:validate(Prop, ?FAX_OUTBOUND_HEADERS, ?FAX_OUTBOUND_VALUES, ?FAX_OUTBOUND_TYPES);
fax_outbound_v(JObj) -> fax_outbound_v(wh_json:to_proplist(JObj)).

%%--------------------------------------------------------------------
%% @doc
%% Takes proplist, creates JSON string or error
%% @end
%%--------------------------------------------------------------------
fax_inbound_error(Prop) when is_list(Prop) ->
    case fax_inbound_error_v(Prop) of
        'true' -> wh_api:build_message(Prop, ?FAX_INBOUND_ERROR_HEADERS, ?OPTIONAL_FAX_INBOUND_ERROR_HEADERS);
        'false' -> {'error', "Proplist failed validation for inbound_fax_error"}
    end;
fax_inbound_error(JObj) -> fax_inbound_error(wh_json:to_proplist(JObj)).

-spec fax_inbound_error_v(api_terms()) -> boolean().
fax_inbound_error_v(Prop) when is_list(Prop) ->
    wh_api:validate(Prop, ?FAX_INBOUND_ERROR_HEADERS, ?FAX_INBOUND_ERROR_VALUES, ?FAX_INBOUND_ERROR_TYPES);
fax_inbound_error_v(JObj) -> fax_inbound_error_v(wh_json:to_proplist(JObj)).

%%--------------------------------------------------------------------
%% @doc
%% Takes proplist, creates JSON string or error
%% @end
%%--------------------------------------------------------------------
fax_outbound_error(Prop) when is_list(Prop) ->
    case fax_outbound_error_v(Prop) of
        'true' -> wh_api:build_message(Prop, ?FAX_OUTBOUND_ERROR_HEADERS, ?OPTIONAL_FAX_OUTBOUND_ERROR_HEADERS);
        'false' -> {'error', "Proplist failed validation for outbound_fax_error"}
    end;
fax_outbound_error(JObj) -> fax_outbound_error(wh_json:to_proplist(JObj)).

-spec fax_outbound_error_v(api_terms()) -> boolean().
fax_outbound_error_v(Prop) when is_list(Prop) ->
    wh_api:validate(Prop, ?FAX_OUTBOUND_ERROR_HEADERS, ?FAX_OUTBOUND_ERROR_VALUES, ?FAX_OUTBOUND_ERROR_TYPES);
fax_outbound_error_v(JObj) -> fax_outbound_error_v(wh_json:to_proplist(JObj)).

%%--------------------------------------------------------------------
%% @doc Register (unregister is a key word) - see wiki
%% Takes proplist, creates JSON string or error
%% @end
%%--------------------------------------------------------------------
register(Prop) when is_list(Prop) ->
    case register_v(Prop) of
        'true' -> wh_api:build_message(Prop, ?REGISTER_HEADERS, ?OPTIONAL_REGISTER_HEADERS);
        'false' -> {'error', "Proplist failed validation for register"}
    end;
register(JObj) -> register(wh_json:to_proplist(JObj)).

-spec register_v(api_terms()) -> boolean().
register_v(Prop) when is_list(Prop) ->
    wh_api:validate(Prop, ?REGISTER_HEADERS, ?REGISTER_VALUES, ?REGISTER_TYPES);
register_v(JObj) -> register_v(wh_json:to_proplist(JObj)).

%%--------------------------------------------------------------------
%% @doc Deregister (unregister is a key word) - see wiki
%% Takes proplist, creates JSON string or error
%% @end
%%--------------------------------------------------------------------
deregister(Prop) when is_list(Prop) ->
    case deregister_v(Prop) of
        'true' -> wh_api:build_message(Prop, ?DEREGISTER_HEADERS, ?OPTIONAL_DEREGISTER_HEADERS);
        'false' -> {'error', "Proplist failed validation for deregister"}
    end;
deregister(JObj) -> deregister(wh_json:to_proplist(JObj)).

-spec deregister_v(api_terms()) -> boolean().
deregister_v(Prop) when is_list(Prop) ->
    wh_api:validate(Prop, ?DEREGISTER_HEADERS, ?DEREGISTER_VALUES, ?DEREGISTER_TYPES);
deregister_v(JObj) -> deregister_v(wh_json:to_proplist(JObj)).

%%--------------------------------------------------------------------
%% @doc Pwd_Recovery (unregister is a key word) - see wiki
%% Takes proplist, creates JSON string or error
%% @end
%%--------------------------------------------------------------------
pwd_recovery(Prop) when is_list(Prop) ->
    case pwd_recovery_v(Prop) of
        'true' -> wh_api:build_message(Prop, ?PWD_RECOVERY_HEADERS, ?OPTIONAL_PWD_RECOVERY_HEADERS);
        'false' -> {'error', "Proplist failed validation for pwd_recovery"}
    end;
pwd_recovery(JObj) -> pwd_recovery(wh_json:to_proplist(JObj)).

-spec pwd_recovery_v(api_terms()) -> boolean().
pwd_recovery_v(Prop) when is_list(Prop) ->
    wh_api:validate(Prop, ?PWD_RECOVERY_HEADERS, ?PWD_RECOVERY_VALUES, ?PWD_RECOVERY_TYPES);
pwd_recovery_v(JObj) -> pwd_recovery_v(wh_json:to_proplist(JObj)).

%%--------------------------------------------------------------------
%% @doc New account notification - see wiki
%% Takes proplist, creates JSON string or error
%% @end
%%--------------------------------------------------------------------
new_account(Prop) when is_list(Prop) ->
    case new_account_v(Prop) of
        'true' -> wh_api:build_message(Prop, ?NEW_ACCOUNT_HEADERS, ?OPTIONAL_NEW_ACCOUNT_HEADERS);
        'false' -> {'error', "Proplist failed validation for new_account"}
    end;
new_account(JObj) -> new_account(wh_json:to_proplist(JObj)).

-spec new_account_v(api_terms()) -> boolean().
new_account_v(Prop) when is_list(Prop) ->
    wh_api:validate(Prop, ?NEW_ACCOUNT_HEADERS, ?NEW_ACCOUNT_VALUES, ?NEW_ACCOUNT_TYPES);
new_account_v(JObj) -> new_account_v(wh_json:to_proplist(JObj)).

%%--------------------------------------------------------------------
%% @doc Port request notification - see wiki
%% Takes proplist, creates JSON string or error
%% @end
%%--------------------------------------------------------------------
port_request(Prop) when is_list(Prop) ->
    case port_request_v(Prop) of
        'true' -> wh_api:build_message(Prop, ?PORT_REQUEST_HEADERS, ?OPTIONAL_PORT_REQUEST_HEADERS);
        'false' -> {'error', "Proplist failed validation for port_request"}
    end;
port_request(JObj) -> port_request(wh_json:to_proplist(JObj)).

-spec port_request_v(api_terms()) -> boolean().
port_request_v(Prop) when is_list(Prop) ->
    wh_api:validate(Prop, ?PORT_REQUEST_HEADERS, ?PORT_REQUEST_VALUES, ?PORT_REQUEST_TYPES);
port_request_v(JObj) -> port_request_v(wh_json:to_proplist(JObj)).

%%--------------------------------------------------------------------
%% @doc Port cancel notification - see wiki
%% Takes proplist, creates JSON string or error
%% @end
%%--------------------------------------------------------------------
port_cancel(Prop) when is_list(Prop) ->
    case port_cancel_v(Prop) of
        'true' -> wh_api:build_message(Prop, ?PORT_CANCEL_HEADERS, ?OPTIONAL_PORT_CANCEL_HEADERS);
        'false' -> {'error', "Proplist failed validation for port_cancel"}
    end;
port_cancel(JObj) -> port_cancel(wh_json:to_proplist(JObj)).

-spec port_cancel_v(api_terms()) -> boolean().
port_cancel_v(Prop) when is_list(Prop) ->
    wh_api:validate(Prop, ?PORT_CANCEL_HEADERS, ?PORT_CANCEL_VALUES, ?PORT_CANCEL_TYPES);
port_cancel_v(JObj) -> port_cancel_v(wh_json:to_proplist(JObj)).

%%--------------------------------------------------------------------
%% @doc Ported request notification - see wiki
%% Takes proplist, creates JSON string or error
%% @end
%%--------------------------------------------------------------------
ported(Prop) when is_list(Prop) ->
    case ported_v(Prop) of
        'true' -> wh_api:build_message(Prop, ?PORTED_HEADERS, ?OPTIONAL_PORTED_HEADERS);
        'false' -> {'error', "Proplist failed validation for ported"}
    end;
ported(JObj) -> ported(wh_json:to_proplist(JObj)).

-spec ported_v(api_terms()) -> boolean().
ported_v(Prop) when is_list(Prop) ->
    wh_api:validate(Prop, ?PORTED_HEADERS, ?PORTED_VALUES, ?PORTED_TYPES);
ported_v(JObj) -> ported_v(wh_json:to_proplist(JObj)).

%%--------------------------------------------------------------------
%% @doc Cnam request notification - see wiki
%% Takes proplist, creates JSON string or error
%% @end
%%--------------------------------------------------------------------
cnam_request(Prop) when is_list(Prop) ->
    case cnam_request_v(Prop) of
        'true' -> wh_api:build_message(Prop, ?CNAM_REQUEST_HEADERS, ?OPTIONAL_CNAM_REQUEST_HEADERS);
        'false' -> {'error', "Proplist failed validation for cnam_request"}
    end;
cnam_request(JObj) -> cnam_request(wh_json:to_proplist(JObj)).

-spec cnam_request_v(api_terms()) -> boolean().
cnam_request_v(Prop) when is_list(Prop) ->
    wh_api:validate(Prop, ?CNAM_REQUEST_HEADERS, ?CNAM_REQUEST_VALUES, ?CNAM_REQUEST_TYPES);
cnam_request_v(JObj) -> cnam_request_v(wh_json:to_proplist(JObj)).

%%--------------------------------------------------------------------
%% @doc Low Balance notification - see wiki
%% Takes proplist, creates JSON string or error
%% @end
%%--------------------------------------------------------------------
low_balance(Prop) when is_list(Prop) ->
    case low_balance_v(Prop) of
        'true' -> wh_api:build_message(Prop, ?LOW_BALANCE_HEADERS, ?OPTIONAL_LOW_BALANCE_HEADERS);
        'false' -> {'error', "Proplist failed validation for low_balance"}
    end;
low_balance(JObj) -> low_balance(wh_json:to_proplist(JObj)).

-spec low_balance_v(api_terms()) -> boolean().
low_balance_v(Prop) when is_list(Prop) ->
    wh_api:validate(Prop, ?LOW_BALANCE_HEADERS, ?LOW_BALANCE_VALUES, ?LOW_BALANCE_TYPES);
low_balance_v(JObj) -> low_balance_v(wh_json:to_proplist(JObj)).


%%--------------------------------------------------------------------
%% @doc Topup notification - see wiki
%% Takes proplist, creates JSON string or error
%% @end
%%--------------------------------------------------------------------
topup(Prop) when is_list(Prop) ->
    case topup_v(Prop) of
        'true' -> wh_api:build_message(Prop, ?TOPUP_HEADERS, ?OPTIONAL_TOPUP_HEADERS);
        'false' -> {'error', "Proplist failed validation for topup"}
    end;
topup(JObj) -> topup(wh_json:to_proplist(JObj)).

-spec topup_v(api_terms()) -> boolean().
topup_v(Prop) when is_list(Prop) ->
    wh_api:validate(Prop, ?TOPUP_HEADERS, ?TOPUP_VALUES, ?TOPUP_TYPES);
topup_v(JObj) -> topup_v(wh_json:to_proplist(JObj)).

%%--------------------------------------------------------------------
%% @doc Low Balance notification - see wiki
%% Takes proplist, creates JSON string or error
%% @end
%%--------------------------------------------------------------------
transaction(Prop) when is_list(Prop) ->
    case transaction_v(Prop) of
        'true' -> wh_api:build_message(Prop, ?TRANSACTION_HEADERS, ?OPTIONAL_TRANSACTION_HEADERS);
        'false' -> {'error', "Proplist failed validation for transaction"}
    end;
transaction(JObj) -> transaction(wh_json:to_proplist(JObj)).

-spec transaction_v(api_terms()) -> boolean().
transaction_v(Prop) when is_list(Prop) ->
    wh_api:validate(Prop, ?TRANSACTION_HEADERS, ?TRANSACTION_VALUES, ?TRANSACTION_TYPES);
transaction_v(JObj) -> transaction_v(wh_json:to_proplist(JObj)).

%%--------------------------------------------------------------------
%% @doc System alert notification - see wiki
%% Takes proplist, creates JSON string or error
%% @end
%%--------------------------------------------------------------------
system_alert(Prop) when is_list(Prop) ->
    case system_alert_v(Prop) of
        'true' -> wh_api:build_message(Prop, ?SYSTEM_ALERT_HEADERS, ?OPTIONAL_SYSTEM_ALERT_HEADERS);
        'false' -> {'error', "Proplist failed validation for system_alert"}
    end;
system_alert(JObj) -> system_alert(wh_json:to_proplist(JObj)).

-spec system_alert_v(api_terms()) -> boolean().
system_alert_v(Prop) when is_list(Prop) ->
    wh_api:validate(Prop, ?SYSTEM_ALERT_HEADERS, ?SYSTEM_ALERT_VALUES, ?SYSTEM_ALERT_TYPES);
system_alert_v(JObj) -> system_alert_v(wh_json:to_proplist(JObj)).

%%--------------------------------------------------------------------
%% @doc webhook notification - see wiki
%% Takes proplist, creates JSON string or error
%% @end
%%--------------------------------------------------------------------
webhook(Prop) when is_list(Prop) ->
    case webhook_v(Prop) of
        'true' -> wh_api:build_message(Prop, ?WEBHOOK_HEADERS, ?OPTIONAL_WEBHOOK_HEADERS);
        'false' -> {'error', "Proplist failed validation for webhook"}
    end;
webhook(JObj) -> webhook(wh_json:to_proplist(JObj)).

-spec webhook_v(api_terms()) -> boolean().
webhook_v(Prop) when is_list(Prop) ->
    wh_api:validate(Prop, ?WEBHOOK_HEADERS, ?WEBHOOK_VALUES, ?WEBHOOK_TYPES);
webhook_v(JObj) -> webhook_v(wh_json:to_proplist(JObj)).

%%--------------------------------------------------------------------
%% @doc System alert notification - see wiki
%% Takes proplist, creates JSON string or error
%% @end
%%--------------------------------------------------------------------
notify_update(Prop) when is_list(Prop) ->
    case notify_update_v(Prop) of
        'true' -> wh_api:build_message(Prop, ?NOTIFY_UPDATE_HEADERS, ?OPTIONAL_NOTIFY_UPDATE_HEADERS);
        'false' -> {'error', "Proplist failed validation for notify_update"}
    end;
notify_update(JObj) -> notify_update(wh_json:to_proplist(JObj)).

-spec notify_update_v(api_terms()) -> boolean().
notify_update_v(Prop) when is_list(Prop) ->
    wh_api:validate(Prop, ?NOTIFY_UPDATE_HEADERS, ?NOTIFY_UPDATE_VALUES, ?NOTIFY_UPDATE_TYPES);
notify_update_v(JObj) -> notify_update_v(wh_json:to_proplist(JObj)).

-spec bind_q(ne_binary(), wh_proplist()) -> 'ok'.
bind_q(Queue, Props) ->
    bind_to_q(Queue, props:get_value('restrict_to', Props)).

bind_to_q(Q, 'undefined') ->
    'ok' = amqp_util:bind_q_to_notifications(Q, <<"notifications.*.*">>);
bind_to_q(Q, ['new_voicemail'|T]) ->
    'ok' = amqp_util:bind_q_to_notifications(Q, ?NOTIFY_VOICEMAIL_NEW),
    bind_to_q(Q, T);
bind_to_q(Q, ['voicemail_full'|T]) ->
    'ok' = amqp_util:bind_q_to_notifications(Q, ?NOTIFY_VOICEMAIL_FULL),
    bind_to_q(Q, T);
bind_to_q(Q, ['inbound_fax'|T]) ->
    'ok' = amqp_util:bind_q_to_notifications(Q, ?NOTIFY_FAX_INBOUND),
    bind_to_q(Q, T);
bind_to_q(Q, ['outbound_fax'|T]) ->
    'ok' = amqp_util:bind_q_to_notifications(Q, ?NOTIFY_FAX_OUTBOUND),
    bind_to_q(Q, T);
bind_to_q(Q, ['new_fax'|T]) ->
    'ok' = amqp_util:bind_q_to_notifications(Q, ?NOTIFY_FAX_INBOUND),
    'ok' = amqp_util:bind_q_to_notifications(Q, ?NOTIFY_FAX_OUTBOUND),
    bind_to_q(Q, T);
bind_to_q(Q, ['inbound_fax_error'|T]) ->
    'ok' = amqp_util:bind_q_to_notifications(Q, ?NOTIFY_FAX_INBOUND_ERROR),
    bind_to_q(Q, T);
bind_to_q(Q, ['outbound_fax_error'|T]) ->
    'ok' = amqp_util:bind_q_to_notifications(Q, ?NOTIFY_FAX_OUTBOUND_ERROR),
    bind_to_q(Q, T);
bind_to_q(Q, ['fax_error'|T]) ->
    'ok' = amqp_util:bind_q_to_notifications(Q, ?NOTIFY_FAX_INBOUND_ERROR),
    'ok' = amqp_util:bind_q_to_notifications(Q, ?NOTIFY_FAX_OUTBOUND_ERROR),
    bind_to_q(Q, T);
bind_to_q(Q, ['register'|T]) ->
    'ok' = amqp_util:bind_q_to_notifications(Q, ?NOTIFY_REGISTER),
    bind_to_q(Q, T);
bind_to_q(Q, ['deregister'|T]) ->
    'ok' = amqp_util:bind_q_to_notifications(Q, ?NOTIFY_DEREGISTER),
    bind_to_q(Q, T);
bind_to_q(Q, ['pwd_recovery'|T]) ->
    'ok' = amqp_util:bind_q_to_notifications(Q, ?NOTIFY_PWD_RECOVERY),
    bind_to_q(Q, T);
bind_to_q(Q, ['new_account'|T]) ->
    'ok' = amqp_util:bind_q_to_notifications(Q, ?NOTIFY_NEW_ACCOUNT),
    bind_to_q(Q, T);
bind_to_q(Q, ['port_request'|T]) ->
    'ok' = amqp_util:bind_q_to_notifications(Q, ?NOTIFY_PORT_REQUEST),
    bind_to_q(Q, T);
bind_to_q(Q, ['port_cancel'|T]) ->
    'ok' = amqp_util:bind_q_to_notifications(Q, ?NOTIFY_PORT_CANCEL),
    bind_to_q(Q, T);
bind_to_q(Q, ['ported'|T]) ->
    'ok' = amqp_util:bind_q_to_notifications(Q, ?NOTIFY_PORTED),
    bind_to_q(Q, T);
bind_to_q(Q, ['cnam_requests'|T]) ->
    'ok' = amqp_util:bind_q_to_notifications(Q, ?NOTIFY_CNAM_REQUEST),
    bind_to_q(Q, T);
bind_to_q(Q, ['low_balance'|T]) ->
    'ok' = amqp_util:bind_q_to_notifications(Q, ?NOTIFY_LOW_BALANCE),
    bind_to_q(Q, T);
bind_to_q(Q, ['topup'|T]) ->
    'ok' = amqp_util:bind_q_to_notifications(Q, ?NOTIFY_TOPUP),
    bind_to_q(Q, T);
bind_to_q(Q, ['transaction'|T]) ->
    'ok' = amqp_util:bind_q_to_notifications(Q, ?NOTIFY_TRANSACTION),
    bind_to_q(Q, T);
bind_to_q(Q, ['system_alerts'|T]) ->
    'ok' = amqp_util:bind_q_to_notifications(Q, ?NOTIFY_SYSTEM_ALERT),
    bind_to_q(Q, T);
bind_to_q(Q, ['webhook'|T]) ->
    'ok' = amqp_util:bind_q_to_notifications(Q, ?NOTIFY_WEBHOOK_CALLFLOW),
    bind_to_q(Q, T);
bind_to_q(_Q, []) ->
    'ok'.

-spec unbind_q(ne_binary(), wh_proplist()) -> 'ok'.

unbind_q(Queue, Props) ->
    unbind_q_from(Queue, props:get_value('restrict_to', Props)).

unbind_q_from(Q, 'undefined') ->
    'ok' = amqp_util:unbind_q_from_notifications(Q, <<"notifications.*.*">>);
unbind_q_from(Q, ['new_voicemail'|T]) ->
    'ok' = amqp_util:unbind_q_from_notifications(Q, ?NOTIFY_VOICEMAIL_NEW),
    unbind_q_from(Q, T);
unbind_q_from(Q, ['voicemail_full'|T]) ->
    'ok' = amqp_util:unbind_q_from_notifications(Q, ?NOTIFY_VOICEMAIL_FULL),
    unbind_q_from(Q, T);
unbind_q_from(Q, ['inbound_fax'|T]) ->
    'ok' = amqp_util:unbind_q_from_notifications(Q,?NOTIFY_FAX_INBOUND),
    unbind_q_from(Q, T);
unbind_q_from(Q, ['outbound_fax'|T]) ->
    'ok' = amqp_util:unbind_q_from_notifications(Q,?NOTIFY_FAX_OUTBOUND),
    unbind_q_from(Q, T);
unbind_q_from(Q, ['new_fax'|T]) ->
    'ok' = amqp_util:unbind_q_from_notifications(Q,?NOTIFY_FAX_INBOUND),
    'ok' = amqp_util:unbind_q_from_notifications(Q,?NOTIFY_FAX_OUTBOUND),
    unbind_q_from(Q, T);
unbind_q_from(Q, ['inbound_fax_error'|T]) ->
    'ok' = amqp_util:unbind_q_from_notifications(Q,?NOTIFY_FAX_INBOUND_ERROR),
    unbind_q_from(Q, T);
unbind_q_from(Q, ['outbound_fax_error'|T]) ->
    'ok' = amqp_util:unbind_q_from_notifications(Q,?NOTIFY_FAX_OUTBOUND_ERROR),
    unbind_q_from(Q, T);
unbind_q_from(Q, ['fax_error'|T]) ->
    'ok' = amqp_util:unbind_q_from_notifications(Q,?NOTIFY_FAX_OUTBOUND_ERROR),
    'ok' = amqp_util:unbind_q_from_notifications(Q,?NOTIFY_FAX_INBOUND_ERROR),
    unbind_q_from(Q, T);
unbind_q_from(Q, ['register'|T]) ->
    'ok' = amqp_util:unbind_q_from_notifications(Q, ?NOTIFY_REGISTER),
    unbind_q_from(Q, T);
unbind_q_from(Q, ['deregister'|T]) ->
    'ok' = amqp_util:unbind_q_from_notifications(Q, ?NOTIFY_DEREGISTER),
    unbind_q_from(Q, T);
unbind_q_from(Q, ['pwd_recovery'|T]) ->
    'ok' = amqp_util:unbind_q_from_notifications(Q, ?NOTIFY_PWD_RECOVERY),
    unbind_q_from(Q, T);
unbind_q_from(Q, ['new_account'|T]) ->
    'ok' = amqp_util:unbind_q_from_notifications(Q, ?NOTIFY_NEW_ACCOUNT),
    unbind_q_from(Q, T);
unbind_q_from(Q, ['port_request'|T]) ->
    'ok' = amqp_util:unbind_q_from_notifications(Q, ?NOTIFY_PORT_REQUEST),
    unbind_q_from(Q, T);
unbind_q_from(Q, ['port_cancel'|T]) ->
    'ok' = amqp_util:unbind_q_from_notifications(Q, ?NOTIFY_PORT_CANCEL),
    unbind_q_from(Q, T);
unbind_q_from(Q, ['ported'|T]) ->
    'ok' = amqp_util:unbind_q_from_notifications(Q, ?NOTIFY_PORTED),
    unbind_q_from(Q, T);
unbind_q_from(Q, ['cnam_request'|T]) ->
    'ok' = amqp_util:unbind_q_from_notifications(Q, ?NOTIFY_CNAM_REQUEST),
    unbind_q_from(Q, T);
unbind_q_from(Q, ['low_balance'|T]) ->
    'ok' = amqp_util:unbind_q_from_notifications(Q, ?NOTIFY_LOW_BALANCE),
    unbind_q_from(Q, T);
unbind_q_from(Q, ['topup'|T]) ->
    'ok' = amqp_util:unbind_q_from_notifications(Q, ?NOTIFY_TOPUP),
    unbind_q_from(Q, T);
unbind_q_from(Q, ['transaction'|T]) ->
    'ok' = amqp_util:unbind_q_from_notifications(Q, ?NOTIFY_TRANSACTION),
    unbind_q_from(Q, T);
unbind_q_from(Q, ['system_alert'|T]) ->
    'ok' = amqp_util:unbind_q_from_notifications(Q, ?NOTIFY_SYSTEM_ALERT),
    unbind_q_from(Q, T);
unbind_q_from(Q, ['webhook'|T]) ->
    'ok' = amqp_util:unbind_q_from_notifications(Q, ?NOTIFY_WEBHOOK_CALLFLOW),
    unbind_q_from(Q, T);
unbind_q_from(_Q, []) ->
    'ok'.

%%--------------------------------------------------------------------
%% @doc
%% declare the exchanges used by this API
%% @end
%%--------------------------------------------------------------------
-spec declare_exchanges() -> 'ok'.
declare_exchanges() ->
    amqp_util:notifications_exchange().

-spec publish_voicemail(api_terms()) -> 'ok'.
-spec publish_voicemail(api_terms(), ne_binary()) -> 'ok'.
publish_voicemail(JObj) -> publish_voicemail(JObj, ?DEFAULT_CONTENT_TYPE).
publish_voicemail(Voicemail, ContentType) ->
    {'ok', Payload} = wh_api:prepare_api_payload(Voicemail, ?VOICEMAIL_VALUES, fun ?MODULE:voicemail/1),
    amqp_util:notifications_publish(?NOTIFY_VOICEMAIL_NEW, Payload, ContentType).

-spec publish_voicemail_full(api_terms()) -> 'ok'.
-spec publish_voicemail_full(api_terms(), ne_binary()) -> 'ok'.
publish_voicemail_full(JObj) -> publish_voicemail_full(JObj, ?DEFAULT_CONTENT_TYPE).
publish_voicemail_full(Voicemail, ContentType) ->
    {'ok', Payload} = wh_api:prepare_api_payload(Voicemail, ?VOICEMAIL_FULL_VALUES, fun ?MODULE:voicemail_full/1),
    amqp_util:notifications_publish(?NOTIFY_VOICEMAIL_FULL, Payload, ContentType).

-spec publish_fax_inbound(api_terms()) -> 'ok'.
-spec publish_fax_inbound(api_terms(), ne_binary()) -> 'ok'.
publish_fax_inbound(JObj) -> publish_fax_inbound(JObj, ?DEFAULT_CONTENT_TYPE).
publish_fax_inbound(Fax, ContentType) ->
    {'ok', Payload} = wh_api:prepare_api_payload(Fax,?FAX_INBOUND_VALUES, fun ?MODULE:fax_inbound/1),
    amqp_util:notifications_publish(?NOTIFY_FAX_INBOUND, Payload, ContentType).

-spec publish_fax_outbound(api_terms()) -> 'ok'.
-spec publish_fax_outbound(api_terms(), ne_binary()) -> 'ok'.
publish_fax_outbound(JObj) -> publish_fax_outbound(JObj, ?DEFAULT_CONTENT_TYPE).
publish_fax_outbound(Fax, ContentType) ->
    {'ok', Payload} = wh_api:prepare_api_payload(Fax, ?FAX_OUTBOUND_VALUES, fun ?MODULE:fax_outbound/1),
    amqp_util:notifications_publish(?NOTIFY_FAX_OUTBOUND, Payload, ContentType).

-spec publish_fax_inbound_error(api_terms()) -> 'ok'.
-spec publish_fax_inbound_error(api_terms(), ne_binary()) -> 'ok'.
publish_fax_inbound_error(JObj) -> publish_fax_inbound_error(JObj, ?DEFAULT_CONTENT_TYPE).
publish_fax_inbound_error(Fax, ContentType) ->
    {'ok', Payload} = wh_api:prepare_api_payload(Fax, ?FAX_INBOUND_ERROR_VALUES, fun ?MODULE:fax_inbound_error/1),
    amqp_util:notifications_publish(?NOTIFY_FAX_INBOUND_ERROR, Payload, ContentType).

-spec publish_fax_outbound_error(api_terms()) -> 'ok'.
-spec publish_fax_outbound_error(api_terms(), ne_binary()) -> 'ok'.
publish_fax_outbound_error(JObj) -> publish_fax_outbound_error(JObj, ?DEFAULT_CONTENT_TYPE).
publish_fax_outbound_error(Fax, ContentType) ->
    {'ok', Payload} = wh_api:prepare_api_payload(Fax, ?FAX_OUTBOUND_ERROR_VALUES, fun ?MODULE:fax_outbound_error/1),
    amqp_util:notifications_publish(?NOTIFY_FAX_OUTBOUND_ERROR, Payload, ContentType).

-spec publish_register(api_terms()) -> 'ok'.
-spec publish_register(api_terms(), ne_binary()) -> 'ok'.
publish_register(JObj) -> publish_register(JObj, ?DEFAULT_CONTENT_TYPE).
publish_register(API, ContentType) ->
    {'ok', Payload} = wh_api:prepare_api_payload(API, ?REGISTER_VALUES, fun ?MODULE:register/1),
    amqp_util:notifications_publish(?NOTIFY_REGISTER, Payload, ContentType).

-spec publish_deregister(api_terms()) -> 'ok'.
-spec publish_deregister(api_terms(), ne_binary()) -> 'ok'.
publish_deregister(JObj) -> publish_deregister(JObj, ?DEFAULT_CONTENT_TYPE).
publish_deregister(API, ContentType) ->
    {'ok', Payload} = wh_api:prepare_api_payload(API, ?DEREGISTER_VALUES, fun ?MODULE:deregister/1),
    amqp_util:notifications_publish(?NOTIFY_DEREGISTER, Payload, ContentType).

-spec publish_pwd_recovery(api_terms()) -> 'ok'.
-spec publish_pwd_recovery(api_terms(), ne_binary()) -> 'ok'.
publish_pwd_recovery(JObj) -> publish_pwd_recovery(JObj, ?DEFAULT_CONTENT_TYPE).
publish_pwd_recovery(API, ContentType) ->
    {'ok', Payload} = wh_api:prepare_api_payload(API, ?PWD_RECOVERY_VALUES, fun ?MODULE:pwd_recovery/1),
    amqp_util:notifications_publish(?NOTIFY_PWD_RECOVERY, Payload, ContentType).

-spec publish_new_account(api_terms()) -> 'ok'.
-spec publish_new_account(api_terms(), ne_binary()) -> 'ok'.
publish_new_account(JObj) -> publish_new_account(JObj, ?DEFAULT_CONTENT_TYPE).
publish_new_account(API, ContentType) ->
    {'ok', Payload} = wh_api:prepare_api_payload(API, ?NEW_ACCOUNT_VALUES, fun ?MODULE:new_account/1),
    amqp_util:notifications_publish(?NOTIFY_NEW_ACCOUNT, Payload, ContentType).

-spec publish_port_request(api_terms()) -> 'ok'.
-spec publish_port_request(api_terms(), ne_binary()) -> 'ok'.
publish_port_request(JObj) -> publish_port_request(JObj, ?DEFAULT_CONTENT_TYPE).
publish_port_request(API, ContentType) ->
    {'ok', Payload} = wh_api:prepare_api_payload(API, ?PORT_REQUEST_VALUES, fun ?MODULE:port_request/1),
    amqp_util:notifications_publish(?NOTIFY_PORT_REQUEST, Payload, ContentType).

-spec publish_port_cancel(api_terms()) -> 'ok'.
-spec publish_port_cancel(api_terms(), ne_binary()) -> 'ok'.
publish_port_cancel(JObj) -> publish_port_cancel(JObj, ?DEFAULT_CONTENT_TYPE).
publish_port_cancel(API, ContentType) ->
    {'ok', Payload} = wh_api:prepare_api_payload(API, ?PORT_CANCEL_VALUES, fun ?MODULE:port_cancel/1),
    amqp_util:notifications_publish(?NOTIFY_PORT_CANCEL, Payload, ContentType).

-spec publish_ported(api_terms()) -> 'ok'.
-spec publish_ported(api_terms(), ne_binary()) -> 'ok'.
publish_ported(JObj) -> publish_ported(JObj, ?DEFAULT_CONTENT_TYPE).
publish_ported(API, ContentType) ->
    {'ok', Payload} = wh_api:prepare_api_payload(API, ?PORTED_VALUES, fun ?MODULE:ported/1),
    amqp_util:notifications_publish(?NOTIFY_PORTED, Payload, ContentType).

-spec publish_cnam_request(api_terms()) -> 'ok'.
-spec publish_cnam_request(api_terms(), ne_binary()) -> 'ok'.
publish_cnam_request(JObj) -> publish_cnam_request(JObj, ?DEFAULT_CONTENT_TYPE).
publish_cnam_request(API, ContentType) ->
    {'ok', Payload} = wh_api:prepare_api_payload(API, ?CNAM_REQUEST_VALUES, fun ?MODULE:cnam_request/1),
    amqp_util:notifications_publish(?NOTIFY_CNAM_REQUEST, Payload, ContentType).

-spec publish_low_balance(api_terms()) -> 'ok'.
-spec publish_low_balance(api_terms(), ne_binary()) -> 'ok'.
publish_low_balance(JObj) -> publish_low_balance(JObj, ?DEFAULT_CONTENT_TYPE).
publish_low_balance(API, ContentType) ->
    {'ok', Payload} = wh_api:prepare_api_payload(API, ?LOW_BALANCE_VALUES, fun ?MODULE:low_balance/1),
    amqp_util:notifications_publish(?NOTIFY_LOW_BALANCE, Payload, ContentType).

-spec publish_topup(api_terms()) -> 'ok'.
-spec publish_topup(api_terms(), ne_binary()) -> 'ok'.
publish_topup(JObj) -> publish_topup(JObj, ?DEFAULT_CONTENT_TYPE).
publish_topup(API, ContentType) ->
    {'ok', Payload} = wh_api:prepare_api_payload(API, ?TOPUP_VALUES, fun ?MODULE:topup/1),
    amqp_util:notifications_publish(?NOTIFY_TOPUP, Payload, ContentType).

-spec publish_transaction(api_terms()) -> 'ok'.
-spec publish_transaction(api_terms(), ne_binary()) -> 'ok'.
publish_transaction(JObj) -> publish_transaction(JObj, ?DEFAULT_CONTENT_TYPE).
publish_transaction(API, ContentType) ->
    {'ok', Payload} = wh_api:prepare_api_payload(API, ?TRANSACTION_VALUES, fun ?MODULE:transaction/1),
    amqp_util:notifications_publish(?NOTIFY_TRANSACTION, Payload, ContentType).

-spec publish_system_alert(api_terms()) -> 'ok'.
-spec publish_system_alert(api_terms(), ne_binary()) -> 'ok'.
publish_system_alert(JObj) -> publish_system_alert(JObj, ?DEFAULT_CONTENT_TYPE).
publish_system_alert(API, ContentType) ->
    {'ok', Payload} = wh_api:prepare_api_payload(API, ?SYSTEM_ALERT_VALUES, fun ?MODULE:system_alert/1),
    amqp_util:notifications_publish(?NOTIFY_SYSTEM_ALERT, Payload, ContentType).

-spec publish_webhook(api_terms()) -> 'ok'.
-spec publish_webhook(api_terms(), ne_binary()) -> 'ok'.
publish_webhook(JObj) -> publish_webhook(JObj, ?DEFAULT_CONTENT_TYPE).
publish_webhook(API, ContentType) ->
    {'ok', Payload} = wh_api:prepare_api_payload(API, ?WEBHOOK_VALUES, fun ?MODULE:webhook/1),
    amqp_util:notifications_publish(?NOTIFY_WEBHOOK_CALLFLOW, Payload, ContentType).

-spec publish_notify_update(ne_binary(), api_terms()) -> 'ok'.
-spec publish_notify_update(ne_binary(), api_terms(), ne_binary()) -> 'ok'.
publish_notify_update(RespQ, JObj) -> publish_notify_update(RespQ, JObj, ?DEFAULT_CONTENT_TYPE).
publish_notify_update(RespQ, API, ContentType) ->
    {'ok', Payload} = wh_api:prepare_api_payload(API, ?NOTIFY_UPDATE_VALUES, fun ?MODULE:notify_update/1),
    amqp_util:targeted_publish(RespQ, Payload, ContentType).
