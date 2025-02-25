module Global exposing
    ( Error(..)
    , Flags
    , LoadingState(..)
    , Model
    , Msg(..)
    , Theme
    , init
    , subscriptions
    , update
    )

import Browser
import Browser.Navigation exposing (Key)
import Json.Decode as Decode
import Router exposing (Route)
import Url exposing (Url)


type alias Theme =
    { colors :
        { primary : String
        , secondary : String
        , background : String
        , text : String
        , textLight : String
        , error : String
        , success : String
        }
    }


type Error
    = NetworkError String
    | ValidationError String
    | NotFoundError String


type LoadingState
    = NotLoading
    | Loading
    | LoadingFailed Error


type alias Model =
    { url : Url
    , key : Key
    , route : Route
    , theme : Theme
    , loadingState : LoadingState
    , error : Maybe Error
    }


type alias Flags =
    Decode.Value


type Msg
    = UrlChanged Url
    | LinkClicked Browser.UrlRequest
    | SetTheme Theme
    | SetError (Maybe Error)
    | SetLoadingState LoadingState
    | NoOp


init : Flags -> Url -> Key -> ( Model, Cmd Msg )
init _ url key =
    ( { url = url
      , key = key
      , route = Router.fromUrl url
      , theme = defaultTheme
      , loadingState = NotLoading
      , error = Nothing
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

        SetTheme theme ->
            ( { model | theme = theme }
            , Cmd.none
            )

        SetError error ->
            ( { model | error = error }
            , Cmd.none
            )

        SetLoadingState state ->
            ( { model | loadingState = state }
            , Cmd.none
            )

        NoOp ->
            ( model, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none


defaultTheme : Theme
defaultTheme =
    { colors =
        { primary = "#1a73e8"
        , secondary = "#5f6368"
        , background = "#ffffff"
        , text = "#202124"
        , textLight = "#5f6368"
        , error = "#d93025"
        , success = "#1e8e3e"
        }
    }
