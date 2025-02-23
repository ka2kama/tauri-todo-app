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


type alias Todo =
    { id : Int
    , title : String
    , completed : Bool
    }


type alias Shared =
    { counter : Int
    , saved : Bool
    , todos : List Todo
    , newTodoInput : String
    }


type Msg
    = UrlChanged Url
    | LinkClicked Browser.UrlRequest
    | Increment
    | Decrement
    | SaveCounter
    | CounterSaved Bool
    | LoadedCounter Int
    | LoadTodos (List Todo)
    | AddTodo
    | DeleteTodo Int
    | UpdateTodo Todo
    | SetNewTodoInput String
    | TodoAdded Bool
    | TodoDeleted Bool
    | TodoUpdated Bool
    | NoOp


init : Flags -> Url -> Key -> ( Model, Cmd Msg )
init _ url key =
    ( { url = url
      , key = key
      , page = HomePage
      , shared =
            { counter = 0
            , saved = False
            , todos = []
            , newTodoInput = ""
            }
      }
    , Ports.getTodos ()
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

                        _ ->
                            HomePage
            in
            ( { model | url = url, page = page }
            , if page == TodoPage then
                Ports.getTodos ()

              else
                Cmd.none
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
                    , todos = model.shared.todos
                    , newTodoInput = model.shared.newTodoInput
                    }
              }
            , Cmd.none
            )

        Decrement ->
            ( { model
                | shared =
                    { counter = model.shared.counter - 1
                    , saved = model.shared.saved
                    , todos = model.shared.todos
                    , newTodoInput = model.shared.newTodoInput
                    }
              }
            , Cmd.none
            )

        SaveCounter ->
            ( { model
                | shared =
                    { counter = model.shared.counter
                    , saved = False
                    , todos = model.shared.todos
                    , newTodoInput = model.shared.newTodoInput
                    }
              }
            , Ports.saveCounter model.shared.counter
            )

        CounterSaved saved ->
            ( { model
                | shared =
                    { counter = model.shared.counter
                    , saved = saved
                    , todos = model.shared.todos
                    , newTodoInput = model.shared.newTodoInput
                    }
              }
            , Cmd.none
            )

        LoadedCounter value ->
            ( { model
                | shared =
                    { counter = value
                    , saved = True
                    , todos = model.shared.todos
                    , newTodoInput = model.shared.newTodoInput
                    }
              }
            , Cmd.none
            )

        LoadTodos todos ->
            ( { model
                | shared =
                    { counter = model.shared.counter
                    , saved = model.shared.saved
                    , todos = todos
                    , newTodoInput = model.shared.newTodoInput
                    }
              }
            , Cmd.none
            )

        AddTodo ->
            ( { model
                | shared =
                    { counter = model.shared.counter
                    , saved = model.shared.saved
                    , todos = model.shared.todos
                    , newTodoInput = ""
                    }
              }
            , Ports.addTodo model.shared.newTodoInput
            )

        DeleteTodo id ->
            ( model
            , Ports.deleteTodo id
            )

        UpdateTodo todo ->
            ( model
            , Ports.updateTodo todo
            )

        SetNewTodoInput input ->
            ( { model
                | shared =
                    { counter = model.shared.counter
                    , saved = model.shared.saved
                    , todos = model.shared.todos
                    , newTodoInput = input
                    }
              }
            , Cmd.none
            )

        TodoAdded _ ->
            ( model
            , Ports.getTodos ()
            )

        TodoDeleted _ ->
            ( model
            , Ports.getTodos ()
            )

        TodoUpdated _ ->
            ( model
            , Ports.getTodos ()
            )

        NoOp ->
            ( model, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.batch
        [ Ports.counterSaved CounterSaved
        , Ports.loadedCounter LoadedCounter
        , Ports.todosLoaded LoadTodos
        , Ports.todoAdded TodoAdded
        , Ports.todoDeleted TodoDeleted
        , Ports.todoUpdated TodoUpdated
        ]
