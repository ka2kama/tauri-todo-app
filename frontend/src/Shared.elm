module Shared exposing
    ( Flags
    , Model
    , Msg(..)
    , Page(..)
    , init
    , subscriptions
    , update
    )

import Browser
import Browser.Navigation exposing (Key)
import Element exposing (..)
import Json.Decode as Decode
import Ports
import Url exposing (Url)


type alias Flags =
    Decode.Value


type alias Model =
    { url : Url
    , key : Key
    , page : Page
    , shared : Shared
    }


type Page
    = HomePage
    | AboutPage
    | TodoPage
    | CounterPage


type alias Shared =
    { counter : Int
    , saved : Bool
    }


type Msg
    = UrlChanged Url
    | LinkClicked Browser.UrlRequest
    | Increment
    | Decrement
    | SaveCounter
    | CounterSaved Bool
    | LoadedCounter Int
    | NoOp


init : Flags -> Url -> Key -> ( Model, Cmd Msg )
init _ url key =
    ( { url = url
      , key = key
      , page = HomePage
      , shared =
            { counter = 0
            , saved = False
            }
      }
    , Cmd.none
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UrlChanged url ->
            let
                page =
                    case url.path of
                        "/about" ->
                            AboutPage

                        "/todo" ->
                            TodoPage

                        "/counter" ->
                            CounterPage

                        _ ->
                            HomePage
            in
            ( { model | url = url, page = page }
            , Cmd.none
            )

        LinkClicked (Browser.Internal url) ->
            ( model, Browser.Navigation.pushUrl model.key (Url.toString url) )

        LinkClicked (Browser.External url) ->
            ( model, Browser.Navigation.load url )

        Increment ->
            ( { model
                | shared =
                    { counter = model.shared.counter + 1
                    , saved = model.shared.saved
                    }
              }
            , Cmd.none
            )

        Decrement ->
            ( { model
                | shared =
                    { counter = model.shared.counter - 1
                    , saved = model.shared.saved
                    }
              }
            , Cmd.none
            )

        SaveCounter ->
            ( { model
                | shared =
                    { counter = model.shared.counter
                    , saved = False
                    }
              }
            , Ports.saveCounter model.shared.counter
            )

        CounterSaved saved ->
            ( { model
                | shared =
                    { counter = model.shared.counter
                    , saved = saved
                    }
              }
            , Cmd.none
            )

        LoadedCounter value ->
            ( { model
                | shared =
                    { counter = value
                    , saved = True
                    }
              }
            , Cmd.none
            )

        NoOp ->
            ( model, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.batch
        [ Ports.counterSaved CounterSaved
        , Ports.loadedCounter LoadedCounter
        ]
