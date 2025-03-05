module Pages.ChartsTest exposing (..)

import Expect
import Helpers.ElementHelpers exposing (hasText, renderView)
import Lib.Chart.Api.ChartApi exposing (StockPrice, StockPriceResponse)
import Pages.Charts_ exposing (Model, Msg(..), init, update, view)
import Test exposing (..)


-- HELPERS


mockStockPrices : List StockPrice
mockStockPrices =
    [ { label = "2024-01", value = 175.50 }
    , { label = "2024-02", value = 180.25 }
    , { label = "2024-03", value = 185.75 }
    ]


mockSuccessResponse : StockPriceResponse
mockSuccessResponse =
    { data = Just mockStockPrices
    , error = Nothing
    }


mockErrorResponse : StockPriceResponse
mockErrorResponse =
    { data = Nothing
    , error = Just "Failed to fetch stock prices"
    }


initialModel : Model
initialModel =
    { data = []
    , loading = True
    , error = Nothing
    }


-- TESTS


suite : Test
suite =
    describe "Charts Page"
        [ describe "Initial State"
            [ test "starts in loading state" <|
                \_ ->
                    let
                        ( model, _ ) =
                            init
                    in
                    Expect.all
                        [ .loading >> Expect.equal True
                        , .data >> Expect.equal []
                        , .error >> Expect.equal Nothing
                        ]
                        model
            , test "displays loading spinner when loading" <|
                \_ ->
                    renderView view initialModel
                        |> hasText "Loading..."
            ]
        , describe "Update"
            [ test "handles successful stock price response" <|
                \_ ->
                    let
                        ( updatedModel, _ ) =
                            update (GotStockPrices mockSuccessResponse) initialModel
                    in
                    Expect.all
                        [ .loading >> Expect.equal False
                        , .data >> Expect.equal mockStockPrices
                        , .error >> Expect.equal Nothing
                        ]
                        updatedModel
            , test "handles error response" <|
                \_ ->
                    let
                        ( updatedModel, _ ) =
                            update (GotStockPrices mockErrorResponse) initialModel
                    in
                    Expect.all
                        [ .loading >> Expect.equal False
                        , .data >> Expect.equal []
                        , .error >> Expect.equal (Just "Failed to fetch stock prices")
                        ]
                        updatedModel
            , test "resets state on LoadStockPrices" <|
                \_ ->
                    let
                        modelWithError =
                            { initialModel | error = Just "Previous error", loading = False }

                        ( updatedModel, _ ) =
                            update LoadStockPrices modelWithError
                    in
                    Expect.all
                        [ .loading >> Expect.equal True
                        , .error >> Expect.equal Nothing
                        ]
                        updatedModel
            ]
        , describe "View"
            [ test "displays chart title and description" <|
                \_ ->
                    renderView view initialModel
                        |> Expect.all
                            [ hasText "Stock Price Chart"
                            , hasText "Real-time IBM stock price data from Alpha Vantage API"
                            ]
            , test "displays error message and retry button when error occurs" <|
                \_ ->
                    let
                        errorModel =
                            { initialModel
                                | loading = False
                                , error = Just "Failed to fetch stock prices"
                            }
                    in
                    renderView view errorModel
                        |> Expect.all
                            [ hasText "Failed to fetch stock prices"
                            , hasText "Retry"
                            ]
            , test "displays chart when data is loaded" <|
                \_ ->
                    let
                        loadedModel =
                            { initialModel
                                | loading = False
                                , data = mockStockPrices
                            }
                    in
                    renderView view loadedModel
                        |> hasText "IBM Stock Price"
            ]
        ]
