module Pages.About_ exposing (Model, Msg, view)

import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font


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
        , Background.color (rgb255 240 240 240)
        , Border.rounded 10
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
            (text "About")
        , paragraph
            [ centerX
            , padding 20
            , width (fill |> maximum 600)
            , Font.size 16
            , Font.color (rgb255 71 71 71)
            ]
            [ text "Welcome to our Elm Single Page Application! This is a sample project demonstrating the power and simplicity of Elm for building web applications." ]
        , paragraph
            [ centerX
            , paddingXY 20 10
            , width (fill |> maximum 600)
            , Font.size 16
            , Font.color (rgb255 71 71 71)
            ]
            [ text "The application showcases various Elm features including:" ]
        , column
            [ centerX
            , spacing 12
            , padding 20
            , width (fill |> maximum 600)
            ]
            (List.map featureItem
                [ "Type-safe routing"
                , "Component-based architecture"
                , "Ports for JavaScript interop"
                , "Elegant UI with elm-ui"
                ]
            )
        ]


featureItem : String -> Element msg
featureItem text_ =
    row
        [ spacing 10
        , Font.color (rgb255 71 71 71)
        ]
        [ el
            [ Font.color (rgb255 130 180 255)
            , Font.size 18
            ]
            (text "•")
        , el
            [ Font.size 16 ]
            (text text_)
        ]
