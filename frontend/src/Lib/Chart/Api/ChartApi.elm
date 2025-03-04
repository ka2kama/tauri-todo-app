port module Lib.Chart.Api.ChartApi exposing (ChartData, chartDataLoaded, getChartData)


type alias ChartData =
    { label : String
    , value : Float
    }


port getChartData : () -> Cmd msg


port chartDataLoaded : (List ChartData -> msg) -> Sub msg
