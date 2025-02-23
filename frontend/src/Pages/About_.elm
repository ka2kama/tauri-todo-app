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
view model =
    column
        [ centerX
        , centerY
        , spacing 20
        , padding 20
        , Background.color (rgb255 240 240 240)
        , Border.rounded 10
        ]
        [ el
            [ centerX
            , Font.size 24
            , Font.bold
            ]
            (text "About")
        , paragraph
            [ centerX
            , padding 20
            , width (fill |> maximum 600)
            , Font.size 16
            ]
            [ text "Welcome to our Elm Single Page Application! This is a sample project demonstrating the power and simplicity of Elm for building web applications." ]
        , paragraph
            [ centerX
            , padding 20
            , width (fill |> maximum 600)
            , Font.size 16
            ]
            [ text "The application showcases various Elm features including:" ]
        , column
            [ centerX
            , spacing 10
            , padding 20
            , width (fill |> maximum 600)
            ]
            [ el [] (text "• Type-safe routing")
            , el [] (text "• Component-based architecture")
            , el [] (text "• Ports for JavaScript interop")
            , el [] (text "• Elegant UI with elm-ui")
            ]
        ]
