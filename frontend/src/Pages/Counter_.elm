module Pages.Counter_ exposing (Model, Msg(..), init, subscriptions, update, view)

import Element exposing (..)
import Ports
import Styles exposing (defaultTheme)


type alias Model =
    { counter : Int
    , saved : Bool
    }


type Msg
    = Increment
    | Decrement
    | SaveCounter
    | CounterSaved Bool
    | LoadedCounter Int


init : ( Model, Cmd Msg )
init =
    ( { counter = 0
      , saved = False
      }
    , Cmd.none
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Increment ->
            ( { model | counter = model.counter + 1 }
            , Cmd.none
            )

        Decrement ->
            ( { model | counter = model.counter - 1 }
            , Cmd.none
            )

        SaveCounter ->
            ( { model | saved = False }
            , Ports.saveCounter model.counter
            )

        CounterSaved saved ->
            ( { model | saved = saved }
            , Cmd.none
            )

        LoadedCounter value ->
            ( { model | counter = value, saved = True }
            , Cmd.none
            )


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.batch
        [ Ports.counterSaved CounterSaved
        , Ports.loadedCounter LoadedCounter
        ]


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
