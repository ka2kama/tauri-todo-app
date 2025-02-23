module Main exposing (main)

import Browser
import Browser.Navigation as Nav
import Element exposing (..)
import Pages.About_
import Pages.Counter_
import Pages.Home_
import Pages.Todo_
import Shared
import Url exposing (Url)


type alias Model =
    { shared : Shared.Model
    , todoModel : Maybe Pages.Todo_.Model
    , counterModel : Maybe Pages.Counter_.Model
    }


type Msg
    = SharedMsg Shared.Msg
    | TodoMsg Pages.Todo_.Msg
    | CounterMsg Pages.Counter_.Msg


mapCounterToShared : Pages.Counter_.Msg -> Shared.Msg
mapCounterToShared msg =
    case msg of
        Pages.Counter_.Increment ->
            Shared.Increment

        Pages.Counter_.Decrement ->
            Shared.Decrement

        Pages.Counter_.SaveCounter ->
            Shared.SaveCounter

        Pages.Counter_.CounterSaved saved ->
            Shared.CounterSaved saved


main : Program Shared.Flags Model Msg
main =
    Browser.application
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        , onUrlRequest = SharedMsg << Shared.LinkClicked
        , onUrlChange = SharedMsg << Shared.UrlChanged
        }


init : Shared.Flags -> Url -> Nav.Key -> ( Model, Cmd Msg )
init flags url key =
    let
        ( sharedModel, sharedCmd ) =
            Shared.init flags url key

        ( todoModel, todoCmd ) =
            if sharedModel.page == Shared.TodoPage then
                let
                    ( m, c ) =
                        Pages.Todo_.init key
                in
                ( Just m, Cmd.map TodoMsg c )

            else
                ( Nothing, Cmd.none )
    in
    ( { shared = sharedModel
      , todoModel = todoModel
      , counterModel = Nothing
      }
    , Cmd.batch [ Cmd.map SharedMsg sharedCmd, todoCmd ]
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SharedMsg sharedMsg ->
            let
                ( newShared, sharedCmd ) =
                    Shared.update sharedMsg model.shared

                ( todoModel, todoCmd ) =
                    if newShared.page == Shared.TodoPage && model.todoModel == Nothing then
                        let
                            ( m, c ) =
                                Pages.Todo_.init newShared.key
                        in
                        ( Just m, Cmd.map TodoMsg c )

                    else if newShared.page /= Shared.TodoPage then
                        ( Nothing, Cmd.none )

                    else
                        ( model.todoModel, Cmd.none )
            in
            ( { model | shared = newShared, todoModel = todoModel }
            , Cmd.batch [ Cmd.map SharedMsg sharedCmd, todoCmd ]
            )

        TodoMsg todoMsg ->
            case model.todoModel of
                Just todoModel_ ->
                    let
                        ( newTodoModel, todoCmd ) =
                            Pages.Todo_.update todoMsg todoModel_
                    in
                    ( { model | todoModel = Just newTodoModel }
                    , Cmd.map TodoMsg todoCmd
                    )

                Nothing ->
                    ( model, Cmd.none )

        CounterMsg _ ->
            ( model, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Sub.map SharedMsg (Shared.subscriptions model.shared)
        , case model.todoModel of
            Just todoModel_ ->
                Sub.map TodoMsg (Pages.Todo_.subscriptions todoModel_)

            Nothing ->
                Sub.none
        ]


view : Model -> Browser.Document Msg
view model =
    { title = "Elm SPA Example"
    , body =
        [ Element.layout [] <|
            column [ width fill, height fill ]
                [ row [ width fill, padding 20, spacing 20 ]
                    [ link [] { url = "/", label = text "Home" }
                    , link [] { url = "/about", label = text "About" }
                    , link [] { url = "/todo", label = text "Todo" }
                    , link [] { url = "/counter", label = text "Counter" }
                    ]
                , el [ width fill, height fill ] <|
                    case model.shared.page of
                        Shared.HomePage ->
                            Element.map (SharedMsg << (\_ -> Shared.NoOp)) <|
                                Pages.Home_.view {}

                        Shared.AboutPage ->
                            Element.map (SharedMsg << (\_ -> Shared.NoOp)) <|
                                Pages.About_.view {}

                        Shared.TodoPage ->
                            case model.todoModel of
                                Just todoModel_ ->
                                    Element.map TodoMsg <|
                                        Pages.Todo_.view todoModel_

                                Nothing ->
                                    Element.none

                        Shared.CounterPage ->
                            Element.map (SharedMsg << mapCounterToShared) <|
                                Pages.Counter_.view
                                    { counter = model.shared.shared.counter
                                    , saved = model.shared.shared.saved
                                    }
                ]
        ]
    }
