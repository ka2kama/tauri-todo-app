module Pages.Counter_ exposing (Model, Msg(..), view)

import Element exposing (..)
import Styles exposing (defaultTheme)


type alias Model =
    { counter : Int -- Current counter value
    , saved : Bool -- Indicates if the counter was successfully saved
    }


type Msg
    = Increment
    | Decrement
    | SaveCounter
    | CounterSaved Bool


view : Model -> Element Msg
view model =
    Styles.containerCard defaultTheme [ spacing 25 ] <|
        column [ width fill, spacing 25 ]
            [ Styles.heading1 defaultTheme "Counter Example with Ports"
            , Styles.heading2 defaultTheme (String.fromInt model.counter)
            , row
                [ centerX
                , spacing 20
                ]
                [ Styles.button defaultTheme
                    { label = "-"
                    , onClick = Decrement
                    , size = { width = 50, height = 50 }
                    }
                , Styles.button defaultTheme
                    { label = "+"
                    , onClick = Increment
                    , size = { width = 50, height = 50 }
                    }
                ]
            , Styles.button defaultTheme
                { label = "Save Counter"
                , onClick = SaveCounter
                , size = { width = 150, height = 40 }
                }
            , if model.saved then
                Styles.successText defaultTheme "Counter saved!"

              else
                none
            ]
