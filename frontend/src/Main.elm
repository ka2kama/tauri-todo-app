module Main exposing (main)

import Browser
import Browser.Navigation as Nav
import Element exposing (..)
import Pages.About_
import Pages.Counter_
import Pages.Home_
import Pages.Todo_
import Router
import Global
import Styles exposing (defaultTheme)
import Url exposing (Url)


type alias Model =
    { global : Global.Model
    , pageModel : PageModel
    }


type PageModel
    = TodoModel Pages.Todo_.Model
    | CounterModel Pages.Counter_.Model
    | StaticPage


type Msg
    = SharedMsg Global.Msg
    | TodoMsg Pages.Todo_.Msg
    | CounterMsg Pages.Counter_.Msg


main : Program Global.Flags Model Msg
main =
    Browser.application
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        , onUrlRequest = SharedMsg << Global.LinkClicked
        , onUrlChange = SharedMsg << Global.UrlChanged
        }


init : Global.Flags -> Url -> Nav.Key -> ( Model, Cmd Msg )
init flags url key =
    let
        ( globalModel, sharedCmd ) =
            Global.init flags url key

        ( pageModel, pageCmd ) =
            initPageModel globalModel.route.page
    in
    ( { global = globalModel
      , pageModel = pageModel
      }
    , Cmd.batch [ Cmd.map SharedMsg sharedCmd, pageCmd ]
    )


initPageModel : Router.Page -> ( PageModel, Cmd Msg )
initPageModel page  =
    case page of
        Router.TodoPage ->
            let
                ( model, cmd ) =
                    Pages.Todo_.init
            in
            ( TodoModel model, Cmd.map TodoMsg cmd )

        Router.CounterPage ->
            let
                ( model, cmd ) =
                    Pages.Counter_.init
            in
            ( CounterModel model, Cmd.map CounterMsg cmd )

        _ ->
            ( StaticPage, Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SharedMsg sharedMsg ->
            let
                ( newShared, sharedCmd ) =
                    Global.update sharedMsg model.global

                ( pageModel, pageCmd ) =
                    if newShared.route.page /= model.global.route.page then
                        initPageModel newShared.route.page

                    else
                        ( model.pageModel, Cmd.none )
            in
            ( { model | global = newShared, pageModel = pageModel }
            , Cmd.batch [ Cmd.map SharedMsg sharedCmd, pageCmd ]
            )

        TodoMsg todoMsg ->
            case model.pageModel of
                TodoModel todoModel ->
                    let
                        ( newTodoModel, todoCmd ) =
                            Pages.Todo_.update todoMsg todoModel
                    in
                    ( { model | pageModel = TodoModel newTodoModel }
                    , Cmd.map TodoMsg todoCmd
                    )

                _ ->
                    ( model, Cmd.none )

        CounterMsg counterMsg ->
            case model.pageModel of
                CounterModel counterModel ->
                    let
                        ( newCounterModel, counterCmd ) =
                            Pages.Counter_.update counterMsg counterModel
                    in
                    ( { model | pageModel = CounterModel newCounterModel }
                    , Cmd.map CounterMsg counterCmd
                    )

                _ ->
                    ( model, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
            [ Sub.map SharedMsg (Global.subscriptions model.global)
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
                    [ Styles.navLink defaultTheme { url = "/", label = "Home" }
                    , Styles.navLink defaultTheme { url = "/about", label = "About" }
                    , Styles.navLink defaultTheme { url = "/todo", label = "Todo" }
                    , Styles.navLink defaultTheme { url = "/counter", label = "Counter" }
                    ]
                , el [ width fill, height fill ] <|
                    case model.global.route.page of
                        Router.HomePage ->
                            Element.map (\_ -> SharedMsg Global.NoOp) <|
                                Pages.Home_.view {}

                        Router.AboutPage ->
                            Element.map (\_ -> SharedMsg Global.NoOp) <|
                                Pages.About_.view {}

                        Router.TodoPage ->
                            case model.pageModel of
                                TodoModel todoModel ->
                                    Element.map TodoMsg <|
                                        Pages.Todo_.view todoModel

                                _ ->
                                    Element.none

                        Router.CounterPage ->
                            case model.pageModel of
                                CounterModel counterModel ->
                                    Element.map CounterMsg <|
                                        Pages.Counter_.view counterModel

                                _ ->
                                    Element.none
                ]
        ]
    }
