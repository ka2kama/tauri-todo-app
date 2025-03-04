module Styles exposing
    ( Colors
    , Theme
    , button
    , checkbox
    , containerCard
    , customCheckbox
    , defaultTheme
    , deleteButton
    , featureItem
    , heading1
    , heading2
    , linkButton
    , navBar
    , navLink
    , paragraph
    , successText
    , textInput
    , todoItem
    )

import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Events exposing (onClick)
import Element.Font as Font
import Element.Input as Input


type alias Colors =
    { primary : Color
    , primaryHover : Color
    , secondary : Color
    , text : Color
    , textLight : Color
    , background : Color
    , white : Color
    , success : Color
    , border : Color
    , borderHover : Color
    , danger : Color
    , dangerHover : Color
    , error : Color
    , checkbox : Color
    , checkboxBorder : Color
    , todoItemBorder : Color
    }


type alias Theme =
    { colors : Colors
    , shadow : { offset : ( Float, Float ), size : Float, blur : Float, color : Color }
    , buttonShadow : { offset : ( Float, Float ), size : Float, blur : Float, color : Color }
    }


defaultTheme : Theme
defaultTheme =
    { colors =
        { primary = rgb255 0 120 215
        , primaryHover = rgb255 100 150 255
        , secondary = rgb255 59 130 246
        , text = rgb255 51 51 51
        , textLight = rgb255 71 71 71
        , background = rgb255 250 250 250
        , white = rgb255 255 255 255
        , success = rgb255 0 150 0
        , border = rgb255 230 230 230
        , borderHover = rgb255 130 180 255
        , danger = rgb255 255 100 100
        , dangerHover = rgba 255 100 100 0.1
        , error = rgb255 220 50 50
        , checkbox = rgb255 130 180 255
        , checkboxBorder = rgb255 200 200 200
        , todoItemBorder = rgb255 240 240 240
        }
    , shadow =
        { offset = ( 0, 2 )
        , size = 0
        , blur = 10
        , color = rgba 0 0 0 0.1
        }
    , buttonShadow =
        { offset = ( 0, 2 )
        , size = 0
        , blur = 4
        , color = rgba 0 0 0 0.05
        }
    }


containerCard : Theme -> List (Attribute msg) -> Element msg -> Element msg
containerCard theme additionalAttrs content =
    column
        ([ centerX
         , width (fill |> maximum 800)
         , height fill
         , padding 30
         , spacing 25
         , Background.color theme.colors.background
         , Border.rounded 15
         , Border.shadow theme.shadow
         ]
            ++ additionalAttrs
        )
        [ content ]


heading1 : Theme -> String -> Element msg
heading1 theme text_ =
    el
        [ centerX
        , Font.size 36
        , Font.bold
        , Font.color theme.colors.text
        , paddingXY 0 10
        ]
        (text text_)


heading2 : Theme -> String -> Element msg
heading2 theme text_ =
    el
        [ centerX
        , Font.size 48
        , Font.bold
        , Font.color theme.colors.text
        , paddingXY 0 20
        ]
        (text text_)


paragraph : Theme -> { text : String, maxWidth : Int } -> Element msg
paragraph theme config =
    Element.paragraph
        [ centerX
        , padding 20
        , width (fill |> maximum config.maxWidth)
        , Font.size 16
        , Font.color theme.colors.textLight
        ]
        [ text config.text ]


featureItem : Theme -> String -> Element msg
featureItem theme text_ =
    row
        [ spacing 10
        , Font.color theme.colors.textLight
        ]
        [ el
            [ Font.color theme.colors.borderHover
            , Font.size 18
            ]
            (text "•")
        , el
            [ Font.size 16 ]
            (text text_)
        ]


button :
    Theme
    ->
        { label : String
        , onClick : msg
        , size : { width : Int, height : Int }
        }
    -> Element msg
button theme config =
    el
        [ padding 15
        , Background.color theme.colors.white
        , Border.rounded 10
        , Border.width 1
        , Border.color theme.colors.border
        , mouseOver
            [ Border.color theme.colors.borderHover
            , Border.shadow theme.buttonShadow
            ]
        , onClick config.onClick
        , pointer
        , Font.size 20
        , Font.color theme.colors.text
        , width (px config.size.width)
        , height (px config.size.height)
        ]
        (el [ centerX, centerY ] (text config.label))


linkButton : Theme -> { url : String, label : String } -> Element msg
linkButton theme config =
    link
        [ Background.color theme.colors.secondary
        , Font.color theme.colors.white
        , padding 15
        , Border.rounded 8
        , mouseOver
            [ Background.color theme.colors.primaryHover ]
        ]
        { url = config.url
        , label = text config.label
        }


successText : Theme -> String -> Element msg
successText theme text_ =
    el
        [ centerX
        , Font.color theme.colors.success
        , Font.size 14
        , paddingXY 0 10
        ]
        (text text_)


navBar : Theme -> List (Element msg) -> Element msg
navBar theme items =
    row
        [ width fill
        , padding 20
        , spacing 20
        , Background.color theme.colors.white
        , Border.shadow
            { offset = ( 0, 2 )
            , size = 0
            , blur = 4
            , color = rgba 0 0 0 0.1
            }
        ]
        items


navLink : Theme -> { url : String, label : String } -> Element msg
navLink theme config =
    link
        [ Font.color theme.colors.text
        , Font.size 16
        , mouseOver
            [ Font.color theme.colors.borderHover ]
        ]
        { url = config.url
        , label = text config.label
        }


textInput : Theme -> { onChange : String -> msg, text : String, placeholder : String, label : String } -> Element msg
textInput theme config =
    Input.text
        [ width fill
        , padding 12
        , Border.rounded 10
        , Border.width 1
        , Border.color theme.colors.border
        , focused
            [ Border.color theme.colors.borderHover
            , Border.shadow
                { offset = ( 0, 0 )
                , size = 0
                , blur = 4
                , color = rgba 100 150 255 0.3
                }
            ]
        ]
        { onChange = config.onChange
        , text = config.text
        , placeholder = Just (Input.placeholder [] (text config.placeholder))
        , label = Input.labelHidden config.label
        }


todoItem : Theme -> { todo : { a | completed : Bool, title : String }, onDelete : msg, onToggle : Bool -> msg } -> Element msg
todoItem theme config =
    row
        [ width fill
        , padding 15
        , spacing 15
        , Background.color theme.colors.white
        , Border.rounded 10
        , Border.width 1
        , Border.color theme.colors.todoItemBorder
        , mouseOver
            [ Border.color theme.colors.border
            , Border.shadow theme.buttonShadow
            ]
        ]
        [ checkbox theme
            { onChange = config.onToggle
            , checked = config.todo.completed
            , label = "Todo completion status"
            }
        , el
            [ width fill
            , Font.color
                (if config.todo.completed then
                    theme.colors.textLight

                 else
                    theme.colors.text
                )
            , if config.todo.completed then
                Font.strike

              else
                Font.regular
            , Font.size 16
            ]
            (text config.todo.title)
        , deleteButton theme { onPress = config.onDelete }
        ]


checkbox : Theme -> { onChange : Bool -> msg, checked : Bool, label : String } -> Element msg
checkbox theme config =
    Input.checkbox
        [ padding 10
        , Border.color theme.colors.checkbox
        ]
        { onChange = config.onChange
        , icon = customCheckbox theme
        , checked = config.checked
        , label = Input.labelHidden config.label
        }


customCheckbox : Theme -> Bool -> Element msg
customCheckbox theme checked =
    el
        [ width (px 20)
        , height (px 20)
        , Border.rounded 6
        , Border.width 2
        , Border.color
            (if checked then
                theme.colors.checkbox

             else
                theme.colors.checkboxBorder
            )
        , Background.color
            (if checked then
                theme.colors.checkbox

             else
                theme.colors.white
            )
        ]
        (if checked then
            el
                [ centerX
                , centerY
                , Font.color theme.colors.white
                ]
                (text "✓")

         else
            none
        )


deleteButton : Theme -> { onPress : msg } -> Element msg
deleteButton theme config =
    Input.button
        [ padding 10
        , Background.color (rgba 255 100 100 0)
        , Font.color theme.colors.danger
        , Border.rounded 8
        , mouseOver
            [ Background.color theme.colors.dangerHover
            ]
        ]
        { onPress = Just config.onPress
        , label = text "Delete"
        }
