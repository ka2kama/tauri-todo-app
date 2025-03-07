port module Lib.Chart.Api.ChartApi exposing (StockPrice, StockPriceResponse, getStockPrices, stockPricesLoaded)


type alias StockPrice =
    { label : String
    , value : Float
    }


type alias StockPriceResponse =
    { data : Maybe (List StockPrice)
    , error : Maybe String
    }


port getStockPrices : () -> Cmd msg


port stockPricesLoaded : (StockPriceResponse -> msg) -> Sub msg
