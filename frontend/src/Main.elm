module Main exposing (main)

import Browser
import Browser.Navigation as Nav
import Element exposing (..)
import Pages.About_
import Pages.Charts_
import Pages.Counter_
import Pages.Home_
import Pages.Todo_
import Request
import Router
import Shared
import Styles exposing (defaultTheme)
import Url exposing (Url)


type alias Model =
    { shared : Shared.Model
    , pageModel : PageModel
    }



-- A wrapper of each page models


type PageModel
    = TodoModel Pages.Todo_.Model
    | CounterModel Pages.Counter_.Model
    | ChartsModel Pages.Charts_.Model
    | StaticPage



-- A wrapper of each page messages


type Msg
    = SharedMsg Shared.Msg
    | TodoMsg Pages.Todo_.Msg
    | CounterMsg Pages.Counter_.Msg
    | ChartsMsg Pages.Charts_.Msg


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
init _ url key =
    let
        ( sharedModel, globalCmd ) =
            Shared.init (Request.create () url key)

        ( pageModel, pageCmd ) =
            initPageModel sharedModel.page
    in
    ( { shared = sharedModel
      , pageModel = pageModel
      }
    , Cmd.batch [ Cmd.map SharedMsg globalCmd, pageCmd ]
    )


initPageModel : Router.Page -> ( PageModel, Cmd Msg )
initPageModel page =
    case page of
        Router.TodoPage ->
            let
                ( initialModel, initialCmd ) =
                    Pages.Todo_.init
            in
            ( TodoModel initialModel, Cmd.map TodoMsg initialCmd )

        Router.CounterPage ->
            let
                ( initialModel, initialCmd ) =
                    Pages.Counter_.init
            in
            ( CounterModel initialModel, Cmd.map CounterMsg initialCmd )

        Router.ChartsPage ->
            let
                ( initialModel, initialCmd ) =
                    Pages.Charts_.init
            in
            ( ChartsModel initialModel, Cmd.map ChartsMsg initialCmd )

        _ ->
            ( StaticPage, Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model.pageModel ) of
        ( SharedMsg globalMsg, _ ) ->
            let
                ( newGlobal, updatedSharedCmd ) =
                    Shared.update globalMsg model.shared

                ( pageModel, pageCmd ) =
                    if newGlobal.page /= model.shared.page then
                        initPageModel newGlobal.page

                    else
                        ( model.pageModel, Cmd.none )
            in
            ( { model | shared = newGlobal, pageModel = pageModel }
            , Cmd.batch [ Cmd.map SharedMsg updatedSharedCmd, pageCmd ]
            )

        ( TodoMsg pageMsg, TodoModel pageModel ) ->
            let
                ( newTodoModel, todoCmd ) =
                    Pages.Todo_.update pageMsg pageModel
            in
            ( { model | pageModel = TodoModel newTodoModel }
            , Cmd.map TodoMsg todoCmd
            )

        ( CounterMsg pageMsg, CounterModel pageModel ) ->
            let
                ( newCounterModel, counterCmd ) =
                    Pages.Counter_.update pageMsg pageModel
            in
            ( { model | pageModel = CounterModel newCounterModel }
            , Cmd.map CounterMsg counterCmd
            )

        ( ChartsMsg pageMsg, ChartsModel pageModel ) ->
            let
                ( newChartsModel, chartsCmd ) =
                    Pages.Charts_.update pageMsg pageModel
            in
            ( { model | pageModel = ChartsModel newChartsModel }
            , Cmd.map ChartsMsg chartsCmd
            )

        _ ->
            ( model, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Sub.map SharedMsg (Shared.subscriptions model.shared)
        , case model.pageModel of
            TodoModel todoModel ->
                Sub.map TodoMsg (Pages.Todo_.subscriptions todoModel)

            CounterModel counterModel ->
                Sub.map CounterMsg (Pages.Counter_.subscriptions counterModel)

            ChartsModel chartsModel ->
                Sub.map ChartsMsg (Pages.Charts_.subscriptions chartsModel)

            StaticPage ->
                Sub.none
        ]


view : Model -> Browser.Document Msg
view model =
    { title = "Elm SPA Example"
    , body =
        [ Element.layout [] <|
            column [ width fill, height fill ]
                [ Styles.navBar defaultTheme
                    [ Styles.navLink defaultTheme { url = Router.toPath Router.HomePage, label = "Home" }
                    , Styles.navLink defaultTheme { url = Router.toPath Router.AboutPage, label = "About" }
                    , Styles.navLink defaultTheme { url = Router.toPath Router.TodoPage, label = "Todo" }
                    , Styles.navLink defaultTheme { url = Router.toPath Router.CounterPage, label = "Counter" }
                    , Styles.navLink defaultTheme { url = Router.toPath Router.ChartsPage, label = "Charts" }
                    ]
                , el [ width fill, height fill ] <|
                    case ( model.shared.page, model.pageModel ) of
                        ( Router.HomePage, _ ) ->
                            Element.map (\_ -> SharedMsg Shared.NoOp) <|
                                Pages.Home_.view {}

                        ( Router.AboutPage, _ ) ->
                            Element.map (\_ -> SharedMsg Shared.NoOp) <|
                                Pages.About_.view {}

                        ( Router.TodoPage, TodoModel todoModel ) ->
                            Element.map TodoMsg <|
                                Pages.Todo_.view todoModel

                        ( Router.CounterPage, CounterModel counterModel ) ->
                            Element.map CounterMsg <|
                                Pages.Counter_.view counterModel

                        ( Router.ChartsPage, ChartsModel chartsModel ) ->
                            Element.map ChartsMsg <|
                                Pages.Charts_.view chartsModel

                        _ ->
                            Element.none
                ]
        ]
    }
