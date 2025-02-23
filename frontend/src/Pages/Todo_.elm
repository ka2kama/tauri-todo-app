module Pages.Todo_ exposing (Model, Msg(..), view)

import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
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
    let
        activeTodos =
            List.length (List.filter (not << .completed) model.todos)
    in
    column
        [ centerX
        , width (fill |> maximum 800)
        , height fill
        , padding 30
        , spacing 25
        , Background.color (rgb255 250 250 250)
        , Border.rounded 15
        , Border.shadow
            { offset = ( 0, 2 )
            , size = 0
            , blur = 10
            , color = rgba 0 0 0 0.1
            }
        ]
        [ el
            [ centerX
            , Font.size 36
            , Font.bold
            , Font.color (rgb255 51 51 51)
            , paddingXY 0 10
            ]
            (text "Tasks")
        , el
            [ centerX
            , Font.size 14
            , Font.color (rgb255 130 130 130)
            , paddingXY 0 5
            ]
            (text (String.fromInt activeTodos ++ " tasks remaining"))
        , row
            [ width fill
            , spacing 15
            ]
            [ Input.text
                [ width fill
                , padding 12
                , Border.rounded 10
                , Border.width 1
                , Border.color (rgb255 230 230 230)
                , focused
                    [ Border.color (rgb255 130 180 255)
                    , Border.shadow
                        { offset = ( 0, 0 )
                        , size = 0
                        , blur = 4
                        , color = rgba 100 150 255 0.3
                        }
                    ]
                ]
                { onChange = SetNewTodoInput
                , text = model.newTodoInput
                , placeholder = Just (Input.placeholder [] (text "What needs to be done?"))
                , label = Input.labelHidden "New todo input"
                }
            , Input.button
                [ padding 12
                , Background.color (rgb255 130 180 255)
                , Font.color (rgb255 255 255 255)
                , Border.rounded 10
                , mouseOver
                    [ Background.color (rgb255 100 150 255)
                    , Border.shadow
                        { offset = ( 0, 2 )
                        , size = 0
                        , blur = 4
                        , color = rgba 0 0 0 0.1
                        }
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
    row
        [ width fill
        , padding 15
        , spacing 15
        , Background.color (rgb255 255 255 255)
        , Border.rounded 10
        , Border.width 1
        , Border.color (rgb255 240 240 240)
        , mouseOver
            [ Border.color (rgb255 230 230 230)
            , Border.shadow
                { offset = ( 0, 2 )
                , size = 0
                , blur = 4
                , color = rgba 0 0 0 0.05
                }
            ]
        ]
        [ Input.checkbox
            [ padding 10
            , Border.color (rgb255 130 180 255)
            ]
            { onChange = \isChecked -> UpdateTodo { todo | completed = isChecked }
            , icon = customCheckbox
            , checked = todo.completed
            , label = Input.labelHidden "Todo completion status"
            }
        , el
            [ width fill
            , Font.color
                (if todo.completed then
                    rgb255 160 160 160

                 else
                    rgb255 51 51 51
                )
            , if todo.completed then
                Font.strike

              else
                Font.regular
            , Font.size 16
            ]
            (text todo.title)
        , Input.button
            [ padding 10
            , Background.color (rgba 255 100 100 0)
            , Font.color (rgb255 255 100 100)
            , Border.rounded 8
            , mouseOver
                [ Background.color (rgba 255 100 100 0.1)
                ]
            ]
            { onPress = Just (DeleteTodo todo.id)
            , label = text "Delete"
            }
        ]


customCheckbox : Bool -> Element msg
customCheckbox checked =
    el
        [ width (px 20)
        , height (px 20)
        , Border.rounded 6
        , Border.width 2
        , Border.color
            (if checked then
                rgb255 130 180 255

             else
                rgb255 200 200 200
            )
        , Background.color
            (if checked then
                rgb255 130 180 255

             else
                rgb255 255 255 255
            )
        ]
        (if checked then
            el
                [ centerX
                , centerY
                , Font.color (rgb255 255 255 255)
                ]
                (text "✓")

         else
            none
        )
