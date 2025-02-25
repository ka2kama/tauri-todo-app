module Pages.Todo_ exposing (Model, Msg(..), Todo, init, subscriptions, update, view)

import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Element.Input as Input
import Ports
import Styles exposing (defaultTheme)


type alias Todo =
    { id : Int
    , title : String
    , completed : Bool
    }


type alias Model =
    { todos : List Todo
    , newTodoInput : String
    }


init : ( Model, Cmd Msg )
init =
    ( { todos = []
      , newTodoInput = ""
      }
    , Ports.getTodos ()
    )


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.batch
        [ Ports.todosLoaded LoadTodos
        , Ports.todoAdded TodoAdded
        , Ports.todoDeleted TodoDeleted
        , Ports.todoUpdated TodoUpdated
        ]


type Msg
    = LoadTodos (List Todo)
    | AddTodo
    | DeleteTodo Int
    | UpdateTodo Todo
    | SetNewTodoInput String
    | TodoAdded Bool
    | TodoDeleted Bool
    | TodoUpdated Bool
    | NoOp


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        LoadTodos todos ->
            ( { model | todos = todos }
            , Cmd.none
            )

        AddTodo ->
            if String.trim model.newTodoInput |> String.isEmpty then
                ( model, Cmd.none )

            else
                ( { model | newTodoInput = "" }
                , Ports.addTodo (String.trim model.newTodoInput)
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
            ( { model | newTodoInput = input }
            , Cmd.none
            )

        TodoAdded success ->
            if success then
                ( model
                , Ports.getTodos ()
                )

            else
                ( model, Cmd.none )

        TodoDeleted success ->
            if success then
                ( model
                , Ports.getTodos ()
                )

            else
                ( model, Cmd.none )

        TodoUpdated success ->
            if success then
                ( model
                , Ports.getTodos ()
                )

            else
                ( model, Cmd.none )

        NoOp ->
            ( model, Cmd.none )


view : Model -> Element Msg
view model =
    let
        activeTodos =
            List.length (List.filter (not << .completed) model.todos)
    in
    Styles.containerCard defaultTheme [ spacing 25 ] <|
        column [ width fill, spacing 25 ]
            [ Styles.heading1 defaultTheme "Tasks"
            , el
                [ centerX
                , Font.size 14
                , Font.color defaultTheme.colors.textLight
                , paddingXY 0 5
                ]
                (text (String.fromInt activeTodos ++ " tasks remaining"))
            , row
                [ width fill
                , spacing 15
                ]
                [ Styles.textInput defaultTheme
                    { onChange = SetNewTodoInput
                    , text = model.newTodoInput
                    , placeholder = "What needs to be done?"
                    , label = "New todo input"
                    }
                , Input.button
                    [ padding 12
                    , Background.color defaultTheme.colors.checkbox
                    , Font.color defaultTheme.colors.white
                    , Border.rounded 10
                    , mouseOver
                        [ Background.color defaultTheme.colors.borderHover
                        , Border.shadow defaultTheme.buttonShadow
                        ]
                    ]
                    { onPress = Just AddTodo
                    , label = text "Add Task"
                    }
                ]
            , column
                [ width fill
                , spacing 12
                , paddingXY 0 10
                ]
                (List.map viewTodoItem model.todos)
            ]


viewTodoItem : Todo -> Element Msg
viewTodoItem todo =
    Styles.todoItem defaultTheme
        { todo = todo
        , onDelete = DeleteTodo todo.id
        , onToggle = \isChecked -> UpdateTodo { todo | completed = isChecked }
        }
