port module Lib.Chart.Api.ChartApi exposing (ChartData, ChartResponse, chartDataLoaded, getChartData)


type alias ChartData =
    { label : String
    , value : Float
    }


type alias ChartResponse =
    { data : Maybe (List ChartData)
    , error : Maybe String
    }


port getChartData : () -> Cmd msg


port chartDataLoaded : (ChartResponse -> msg) -> Sub msg
