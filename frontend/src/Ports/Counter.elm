port module Ports.Counter exposing
    ( counterSaved
    , loadedCounter
    , saveCounter
    )


port saveCounter : Int -> Cmd msg


port counterSaved : (Bool -> msg) -> Sub msg


port loadedCounter : (Int -> msg) -> Sub msg
