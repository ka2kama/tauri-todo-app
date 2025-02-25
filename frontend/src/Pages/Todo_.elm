module Pages.Todo_ exposing (Model, Msg(..), init, subscriptions, update, view)

import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Element.Input as Input
import Global
import Lib.Todo.Api.TodoApi as TodoApi
import Lib.Todo.Domain.Todo as Todo exposing (Todo)
import Styles exposing (defaultTheme)


type alias Model =
    { todos : List Todo
    , newTodoInput : String
    , loadingState : Global.LoadingState
    }


init : ( Model, Cmd Msg )
init =
    ( { todos = []
      , newTodoInput = ""
      , loadingState = Global.Loading
      }
    , TodoApi.getTodos ()
    )


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.batch
        [ TodoApi.todosLoaded LoadTodos
        , TodoApi.todoAdded TodoAdded
        , TodoApi.todoDeleted TodoDeleted
        , TodoApi.todoUpdated TodoUpdated
        ]


type Msg
    = LoadTodos (List Todo)
    | AddTodo
    | DeleteTodo Todo.TodoId
    | UpdateTodo Todo
    | SetNewTodoInput String
    | TodoAdded Bool
    | TodoDeleted Bool
    | TodoUpdated Bool
    | SetLoadingState Global.LoadingState
    | NoOp


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        LoadTodos todos ->
            ( { model
                | todos = todos
                , loadingState = Global.NotLoading
              }
            , Cmd.none
            )

        AddTodo ->
            if String.trim model.newTodoInput |> String.isEmpty then
                ( model, Cmd.none )

            else
                ( { model
                    | newTodoInput = ""
                    , loadingState = Global.Loading
                  }
                , TodoApi.addTodo (String.trim model.newTodoInput)
                )

        DeleteTodo id ->
            ( { model | loadingState = Global.Loading }
            , TodoApi.deleteTodo id
            )

        UpdateTodo todo ->
            ( { model | loadingState = Global.Loading }
            , TodoApi.updateTodo todo
            )

        SetNewTodoInput input ->
            ( { model | newTodoInput = input }
            , Cmd.none
            )

        TodoAdded success ->
            if success then
                ( model
                , TodoApi.getTodos ()
                )

            else
                ( { model
                    | loadingState = Global.LoadingFailed (Global.NetworkError "Failed to add todo")
                  }
                , Cmd.none
                )

        TodoDeleted success ->
            if success then
                ( model
                , TodoApi.getTodos ()
                )

            else
                ( { model
                    | loadingState = Global.LoadingFailed (Global.NetworkError "Failed to delete todo")
                  }
                , Cmd.none
                )

        TodoUpdated success ->
            if success then
                ( model
                , TodoApi.getTodos ()
                )

            else
                ( { model
                    | loadingState = Global.LoadingFailed (Global.NetworkError "Failed to update todo")
                  }
                , Cmd.none
                )

        SetLoadingState state ->
            ( { model | loadingState = state }
            , Cmd.none
            )

        NoOp ->
            ( model, Cmd.none )


view : Model -> Element Msg
view model =
    let
        activeTodos =
            List.length (List.filter (not << .completed) model.todos)

        errorMessage =
            case model.loadingState of
                Global.LoadingFailed (Global.NetworkError msg) ->
                    Just msg

                _ ->
                    Nothing
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
            , case errorMessage of
                Just msg ->
                    el
                        [ centerX
                        , Font.color defaultTheme.colors.danger
                        , Font.size 14
                        , paddingXY 0 5
                        ]
                        (text msg)

                Nothing ->
                    none
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
        , onToggle =
            \isChecked ->
                if isChecked then
                    UpdateTodo (Todo.markAsCompleted todo)

                else
                    UpdateTodo (Todo.markAsUncompleted todo)
        }
