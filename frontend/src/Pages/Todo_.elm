module Pages.Todo_ exposing (Model, Msg(..), view)

import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Events exposing (onClick)
import Element.Font as Font
import Element.Input as Input


type alias Todo =
    { id : Int
    , title : String
    , completed : Bool
    }


type alias Model =
    { todos : List Todo
    , newTodoInput : String
    }


type Msg
    = LoadTodos (List Todo)
    | AddTodo
    | DeleteTodo Int
    | UpdateTodo Todo
    | SetNewTodoInput String


view : Model -> Element Msg
view model =
    column
        [ centerX
        , width (fill |> maximum 800)
        , height fill
        , padding 20
        , spacing 20
        ]
        [ el
            [ centerX
            , Font.size 32
            , Font.bold
            , paddingXY 0 20
            ]
            (text "Todo List")
        , row
            [ width fill
            , spacing 10
            ]
            [ Input.text
                [ width fill ]
                { onChange = SetNewTodoInput
                , text = model.newTodoInput
                , placeholder = Just (Input.placeholder [] (text "Add new todo..."))
                , label = Input.labelHidden "New todo input"
                }
            , Input.button
                [ padding 10
                , Background.color (rgb255 0 120 215)
                , Font.color (rgb255 255 255 255)
                , Border.rounded 5
                , mouseOver
                    [ Background.color (rgb255 0 100 195)
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
            (List.map viewTodoItem model.todos)
        ]


viewTodoItem : Todo -> Element Msg
viewTodoItem todo =
    row
        [ width fill
        , padding 10
        , spacing 10
        , Background.color (rgb255 240 240 240)
        , Border.rounded 5
        ]
        [ Input.checkbox
            [ padding 10 ]
            { onChange = \isChecked -> UpdateTodo { todo | completed = isChecked }
            , icon = Input.defaultCheckbox
            , checked = todo.completed
            , label = Input.labelHidden "Todo completion status"
            }
        , el
            [ width fill
            , Font.color
                (if todo.completed then
                    rgb255 128 128 128

                 else
                    rgb255 0 0 0
                )
            , if todo.completed then
                Font.strike

              else
                Font.regular
            ]
            (text todo.title)
        , Input.button
            [ padding 10
            , Background.color (rgb255 220 53 69)
            , Font.color (rgb255 255 255 255)
            , Border.rounded 5
            , mouseOver
                [ Background.color (rgb255 200 35 51)
                ]
            ]
            { onPress = Just (DeleteTodo todo.id)
            , label = text "Delete"
            }
        ]
