module Pages.Home_ exposing (Model, Msg(..), view)

import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Element.Input as Input


type alias Model =
    {}


type Msg
    = NoOp


view : Model -> Element Msg
view _ =
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
            (text "Welcome to Tauri Todo App")
        , paragraph
            [ centerX
            , Font.size 18
            , Font.color (rgb255 102 102 102)
            , paddingXY 0 20
            , width (fill |> maximum 600)
            , Font.center
            ]
            [ text "This is a simple todo application built with Tauri, Elm, and SQLite. Use the navigation menu to explore different features." ]
        , row
            [ centerX
            , spacing 20
            , paddingXY 0 10
            ]
            [ link
                [ Background.color (rgb255 59 130 246)
                , Font.color (rgb255 255 255 255)
                , padding 15
                , Border.rounded 8
                , mouseOver
                    [ Background.color (rgb255 37 99 235) ]
                ]
                { url = "/counter"
                , label = text "Counter"
                }
            , link
                [ Background.color (rgb255 59 130 246)
                , Font.color (rgb255 255 255 255)
                , padding 15
                , Border.rounded 8
                , mouseOver
                    [ Background.color (rgb255 37 99 235) ]
                ]
                { url = "/todo"
                , label = text "Todo"
                }
            , link
                [ Background.color (rgb255 59 130 246)
                , Font.color (rgb255 255 255 255)
                , padding 15
                , Border.rounded 8
                , mouseOver
                    [ Background.color (rgb255 37 99 235) ]
                ]
                { url = "/about"
                , label = text "About"
                }
            ]
        ]
