module Shared exposing
    ( Flags
    , Model
    , Msg(..)
    , init
    , subscriptions
    , update
    )

import Browser
import Browser.Navigation exposing (Key)
import Json.Decode as Decode
import Router exposing (Route)
import Url exposing (Url)


type alias Flags =
    Decode.Value


type alias Model =
    { url : Url
    , key : Key
    , route : Route
    }


type Msg
    = UrlChanged Url
    | LinkClicked Browser.UrlRequest
    | NoOp


init : Flags -> Url -> Key -> ( Model, Cmd Msg )
init _ url key =
    ( { url = url
      , key = key
      , route = Router.fromUrl url
      }
    , Cmd.none
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UrlChanged url ->
            ( { model
                | url = url
                , route = Router.fromUrl url
              }
            , Cmd.none
            )

        LinkClicked urlRequest ->
            case urlRequest of
                Browser.Internal url ->
                    ( model
                    , Browser.Navigation.pushUrl model.key (Url.toString url)
                    )

                Browser.External url ->
                    ( model
                    , Browser.Navigation.load url
                    )

        NoOp ->
            ( model, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none
