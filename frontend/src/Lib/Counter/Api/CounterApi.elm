port module Lib.Counter.Api.CounterApi exposing
    ( counterLoaded
    , counterSaved
    , loadCounter
    , saveCounter
    )


port saveCounter : Int -> Cmd msg


port loadCounter : () -> Cmd msg


port counterSaved : (Bool -> msg) -> Sub msg


port counterLoaded : (Int -> msg) -> Sub msg
