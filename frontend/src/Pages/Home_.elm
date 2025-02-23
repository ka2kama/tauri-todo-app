module Pages.Home_ exposing (Model, Msg(..), view)

import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Events exposing (onClick)
import Element.Font as Font
import Element.Input as Input


type alias Model =
    { counter : Int
    , saved : Bool
    }


type Msg
    = Increment
    | Decrement
    | SaveCounter
    | CounterSaved Bool


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
            (text "Counter Example with Ports")
        , el
            [ centerX
            , Font.size 48
            , Font.bold
            ]
            (text (String.fromInt model.counter))
        , row
            [ centerX
            , spacing 20
            ]
            [ button "-" Decrement
            , button "+" Increment
            ]
        , Input.button
            [ centerX
            , padding 10
            , Background.color (rgb255 0 120 215)
            , Font.color (rgb255 255 255 255)
            , Border.rounded 5
            , mouseOver
                [ Background.color (rgb255 0 100 195)
                ]
            ]
            { onPress = Just SaveCounter
            , label = text "Save Counter"
            }
        , if model.saved then
            el
                [ centerX
                , Font.color (rgb255 0 150 0)
                ]
                (text "Counter saved!")

          else
            none
        ]


button : String -> Msg -> Element Msg
button label msg =
    el
        [ padding 20
        , Background.color (rgb255 200 200 200)
        , Border.rounded 5
        , mouseOver
            [ Background.color (rgb255 180 180 180)
            ]
        , onClick msg
        , pointer
        ]
        (text label)
