module Main exposing (main)

import Browser
import Browser.Navigation as Nav
import Element exposing (..)
import Global
import Pages.About_
import Pages.Counter_
import Pages.Home_
import Pages.Todo_
import Request
import Router
import Styles exposing (defaultTheme)
import Url exposing (Url)


type alias Model =
    { global : Global.Model
    , pageModel : PageModel
    }



-- A wrapper of each page models


type PageModel
    = TodoModel Pages.Todo_.Model
    | CounterModel Pages.Counter_.Model
    | StaticPage



-- A wrapper of each page messages


type Msg
    = GlobalMsg Global.Msg
    | TodoMsg Pages.Todo_.Msg
    | CounterMsg Pages.Counter_.Msg


main : Program Global.Flags Model Msg
main =
    Browser.application
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        , onUrlRequest = GlobalMsg << Global.LinkClicked
        , onUrlChange = GlobalMsg << Global.UrlChanged
        }


init : Global.Flags -> Url -> Nav.Key -> ( Model, Cmd Msg )
init _ url key =
    let
        ( globalModel, globalCmd ) =
            Global.init (Request.create () url key)

        ( pageModel, pageCmd ) =
            initPageModel globalModel.page
    in
    ( { global = globalModel
      , pageModel = pageModel
      }
    , Cmd.batch [ Cmd.map GlobalMsg globalCmd, pageCmd ]
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

        _ ->
            ( StaticPage, Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model.pageModel ) of
        ( GlobalMsg globalMsg, _ ) ->
            let
                ( newGlobal, updatedGlobalCmd ) =
                    Global.update globalMsg model.global

                ( pageModel, pageCmd ) =
                    if newGlobal.page /= model.global.page then
                        initPageModel newGlobal.page

                    else
                        ( model.pageModel, Cmd.none )
            in
            ( { model | global = newGlobal, pageModel = pageModel }
            , Cmd.batch [ Cmd.map GlobalMsg updatedGlobalCmd, pageCmd ]
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

        _ ->
            ( model, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Sub.map GlobalMsg (Global.subscriptions model.global)
        , case model.pageModel of
            TodoModel todoModel ->
                Sub.map TodoMsg (Pages.Todo_.subscriptions todoModel)

            CounterModel counterModel ->
                Sub.map CounterMsg (Pages.Counter_.subscriptions counterModel)

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
                    ]
                , el [ width fill, height fill ] <|
                    case ( model.global.page, model.pageModel ) of
                        ( Router.HomePage, _ ) ->
                            Element.map (\_ -> GlobalMsg Global.NoOp) <|
                                Pages.Home_.view {}

                        ( Router.AboutPage, _ ) ->
                            Element.map (\_ -> GlobalMsg Global.NoOp) <|
                                Pages.About_.view {}

                        ( Router.TodoPage, TodoModel todoModel ) ->
                            Element.map TodoMsg <|
                                Pages.Todo_.view todoModel

                        ( Router.CounterPage, CounterModel counterModel ) ->
                            Element.map CounterMsg <|
                                Pages.Counter_.view counterModel

                        _ ->
                            Element.none
                ]
        ]
    }
