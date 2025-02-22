port module Main exposing (main)

import Browser
import Browser.Navigation as Nav
import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Element.Input as Input
import Json.Decode as D
import Json.Encode as E
import Url
import Url.Parser as Parser exposing ((</>), Parser)



-- PORTS


port invoke : E.Value -> Cmd msg


port receiveTodos : (D.Value -> msg) -> Sub msg



-- ROUTING


type Page
    = TodoPage
    | SettingsPage
    | NotFoundPage


pageParser : Parser (Page -> a) a
pageParser =
    Parser.oneOf
        [ Parser.map TodoPage Parser.top
        , Parser.map TodoPage (Parser.s "todos")
        , Parser.map SettingsPage (Parser.s "settings")
        ]


toPage : Url.Url -> Page
toPage url =
    Maybe.withDefault NotFoundPage (Parser.parse pageParser url)



-- MAIN


main : Program () Model Msg
main =
    Browser.application
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        , onUrlRequest = UrlRequested
        , onUrlChange = UrlChanged
        }



-- TYPES


type alias Todo =
    { id : Int
    , title : String
    , completed : Bool
    }


todoDecoder : D.Decoder Todo
todoDecoder =
    D.map3 Todo
        (D.field "id" D.int)
        (D.field "title" D.string)
        (D.field "completed" D.bool)



-- MODEL


type alias Model =
    { key : Nav.Key
    , page : Page
    , todos : List Todo
    , newTodoInput : String
    , error : Maybe String
    }


init : () -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init _ url key =
    ( { key = key
      , page = toPage url
      , todos = []
      , newTodoInput = ""
      , error = Nothing
      }
    , getTodos
    )


getTodos : Cmd Msg
getTodos =
    invoke <|
        E.object
            [ ( "cmd", E.string "get_todos" ) ]



-- UPDATE


type Msg
    = UpdateNewTodo String
    | AddTodo
    | DeleteTodo Int
    | ToggleTodo Todo
    | ReceiveTodos D.Value
    | UrlRequested Browser.UrlRequest
    | UrlChanged Url.Url


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UrlRequested urlRequest ->
            case urlRequest of
                Browser.Internal url ->
                    ( model, Nav.pushUrl model.key (Url.toString url) )

                Browser.External href ->
                    ( model, Nav.load href )

        UrlChanged url ->
            ( { model | page = toPage url }, Cmd.none )

        UpdateNewTodo input ->
            ( { model | newTodoInput = input }
            , Cmd.none
            )

        AddTodo ->
            if String.isEmpty (String.trim model.newTodoInput) then
                ( model, Cmd.none )

            else
                ( { model | newTodoInput = "" }
                , invoke <|
                    E.object
                        [ ( "cmd", E.string "add_todo" )
                        , ( "params"
                          , E.object
                                [ ( "title", E.string (String.trim model.newTodoInput) )
                                ]
                          )
                        ]
                )

        DeleteTodo id ->
            ( model
            , invoke <|
                E.object
                    [ ( "cmd", E.string "delete_todo" )
                    , ( "params"
                      , E.object
                            [ ( "id", E.int id )
                            ]
                      )
                    ]
            )

        ToggleTodo todo ->
            ( model
            , invoke <|
                E.object
                    [ ( "cmd", E.string "update_todo" )
                    , ( "params"
                      , E.object
                            [ ( "id", E.int todo.id )
                            , ( "title", E.string todo.title )
                            , ( "completed", E.bool (not todo.completed) )
                            ]
                      )
                    ]
            )

        ReceiveTodos value ->
            case D.decodeValue (D.list todoDecoder) value of
                Ok todos ->
                    ( { model | todos = todos, error = Nothing }
                    , Cmd.none
                    )

                Err error ->
                    ( { model | error = Just (D.errorToString error) }
                    , Cmd.none
                    )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    receiveTodos ReceiveTodos



-- VIEW


view : Model -> Browser.Document Msg
view model =
    { title = "Todo App - " ++ pageTitle model.page
    , body =
        [ layout
            [ Background.color (rgb255 246 246 246)
            , Font.family
                [ Font.typeface "Inter"
                , Font.typeface "Avenir"
                , Font.typeface "Helvetica"
                , Font.typeface "Arial"
                , Font.sansSerif
                ]
            , Font.size 16
            , Font.color (rgb255 15 15 15)
            ]
            (case model.page of
                TodoPage ->
                    viewTodoPage model

                SettingsPage ->
                    viewSettingsPage

                NotFoundPage ->
                    viewNotFoundPage
            )
        ]
    }


pageTitle : Page -> String
pageTitle page =
    case page of
        TodoPage ->
            "Todos"

        SettingsPage ->
            "Settings"

        NotFoundPage ->
            "Not Found"


viewTodoPage : Model -> Element Msg
viewTodoPage model =
    column
        [ width fill
        , spacing 20
        , padding 40
        ]
        [ row
            [ width fill
            , spacing 20
            ]
            [ el
                [ Font.size 32
                , centerX
                , Font.center
                ]
                (text "Todos")
            , viewNavigation
            ]
        , row
            [ width fill
            , spacing 10
            ]
            [ Input.text
                [ width fill
                , Border.rounded 8
                , Border.width 1
                , Border.color (rgba 0 0 0 0)
                , padding 10
                , Background.color (rgb255 255 255 255)
                , Font.color (rgb255 15 15 15)
                , mouseOver
                    [ Border.color (rgb255 57 108 216)
                    ]
                ]
                { onChange = UpdateNewTodo
                , text = model.newTodoInput
                , placeholder = Just (Input.placeholder [] (text "Add a new todo..."))
                , label = Input.labelHidden "New todo input"
                }
            , Input.button
                [ Border.rounded 8
                , Border.width 1
                , Border.color (rgba 0 0 0 0)
                , padding 10
                , Background.color (rgb255 57 108 216)
                , Font.color (rgb255 255 255 255)
                , mouseOver
                    [ Background.color (rgb255 41 92 200)
                    ]
                ]
                { onPress = Just AddTodo
                , label = text "Add"
                }
            ]
        , column
            [ width fill
            , spacing 10
            ]
            (List.map viewTodo model.todos)
        , case model.error of
            Just error ->
                el
                    [ Font.color (rgb255 200 0 0)
                    , centerX
                    ]
                    (text error)

            Nothing ->
                none
        ]


viewNavigation : Element Msg
viewNavigation =
    row
        [ spacing 20
        , alignRight
        ]
        [ link
            [ Font.color (rgb255 57 108 216)
            , mouseOver [ Font.color (rgb255 41 92 200) ]
            ]
            { url = "/todos"
            , label = text "Todos"
            }
        , link
            [ Font.color (rgb255 57 108 216)
            , mouseOver [ Font.color (rgb255 41 92 200) ]
            ]
            { url = "/settings"
            , label = text "Settings"
            }
        ]


viewSettingsPage : Element Msg
viewSettingsPage =
    column
        [ width fill
        , spacing 20
        ]
        [ row
            [ width fill
            , spacing 20
            ]
            [ el
                [ Font.size 32
                , Font.center
                ]
                (text "Settings")
            , viewNavigation
            ]
        , el
            [ centerX
            , Font.size 16
            ]
            (text "Settings page coming soon...")
        ]


viewNotFoundPage : Element Msg
viewNotFoundPage =
    column
        [ width fill
        , spacing 20
        , centerY
        ]
        [ el
            [ centerX
            , Font.size 32
            ]
            (text "Page Not Found")
        , el
            [ centerX
            ]
            (link
                [ Font.color (rgb255 57 108 216)
                , mouseOver [ Font.color (rgb255 41 92 200) ]
                ]
                { url = "/todos"
                , label = text "Go to Todos"
                }
            )
        ]


viewTodo : Todo -> Element Msg
viewTodo todo =
    row
        [ width fill
        , spacing 10
        , padding 10
        , Background.color (rgb255 255 255 255)
        , Border.rounded 8
        , Border.shadow
            { offset = ( 0, 2 )
            , size = 0
            , blur = 4
            , color = rgba 0 0 0 0.1
            }
        ]
        [ Input.checkbox
            [ width (px 24)
            , height (px 24)
            ]
            { onChange = \_ -> ToggleTodo todo
            , icon = Input.defaultCheckbox
            , checked = todo.completed
            , label = Input.labelHidden "Toggle todo"
            }
        , el
            [ width fill
            , Font.color
                (if todo.completed then
                    rgb255 128 128 128

                 else
                    rgb255 15 15 15
                )
            , if todo.completed then
                Font.strike

              else
                Font.regular
            ]
            (text todo.title)
        , Input.button
            [ padding 5
            , Border.rounded 4
            , Background.color (rgb255 255 200 200)
            , mouseOver
                [ Background.color (rgb255 255 150 150)
                ]
            ]
            { onPress = Just (DeleteTodo todo.id)
            , label = text "Delete"
            }
        ]
