module Pages.Charts_ exposing (Model, Msg(..), init, subscriptions, update, view)

import Chart as C
import Chart.Attributes as CA
import Element exposing (..)
import Element.Border as Border
import Element.Font as Font
import Element.Input as Input
import Html.Attributes
import Lib.Chart.Api.ChartApi as StockApi exposing (StockPrice, StockPriceResponse)
import Styles exposing (Theme, defaultTheme)


type alias Model =
    { data : List StockPrice
    , loading : Bool
    , error : Maybe String
    }


type Msg
    = LoadStockPrices
    | GotStockPrices StockPriceResponse


init : ( Model, Cmd Msg )
init =
    ( { data = []
      , loading = True
      , error = Nothing
      }
    , StockApi.getStockPrices ()
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        LoadStockPrices ->
            ( { model | loading = True, error = Nothing }
            , StockApi.getStockPrices ()
            )

        GotStockPrices response ->
            case response.data of
                Just stockPrices ->
                    ( { model | data = stockPrices, loading = False, error = Nothing }
                    , Cmd.none
                    )

                Nothing ->
                    ( { model | loading = False, error = response.error }
                    , Cmd.none
                    )


subscriptions : Model -> Sub Msg
subscriptions _ =
    StockApi.stockPricesLoaded GotStockPrices


type alias Point =
    { x : Float
    , y : Float
    , label : String
    }


toPoints : List StockPrice -> List Point
toPoints data =
    List.indexedMap
        (\i d ->
            { x = toFloat i
            , y = d.value
            , label = d.label
            }
        )
        data


formatPrice : Float -> String
formatPrice price =
    "$" ++ String.fromFloat (toFloat (round (price * 100)) / 100)


stockPriceChart : List StockPrice -> Element msg
stockPriceChart data =
    let
        points =
            toPoints data

        chartConfig =
            [ CA.width 600
            , CA.height 300
            , CA.margin { top = 30, bottom = 50, left = 60, right = 40 }
            , CA.padding { top = 20, bottom = 10, left = 10, right = 10 }
            ]

        chart =
            C.chart chartConfig
                [ C.xLabels
                    [ CA.withGrid
                    , CA.amount 6
                    , CA.fontSize 12
                    , CA.rotate 45
                    , CA.format (\x -> Maybe.withDefault "" (List.head (List.drop (round x) (List.map .label data))))
                    ]
                , C.yLabels
                    [ CA.withGrid
                    , CA.format formatPrice
                    , CA.fontSize 12
                    ]
                , C.series .x
                    [ C.interpolated .y
                        [ CA.color "#4299e1"
                        , CA.width 2
                        ]
                        [ CA.circle ]
                    ]
                    points
                ]
    in
    column
        [ width fill
        , spacing 10
        ]
        [ el
            [ width fill
            , height (px 300)
            , Border.rounded 10
            , Border.width 1
            , Border.color defaultTheme.colors.border
            ]
            (html chart)
        , el
            [ centerX
            , Font.size 14
            , Font.color defaultTheme.colors.textLight
            ]
            (text "IBM Stock Price")
        ]


loadingSpinner : Theme -> Element msg
loadingSpinner _ =
    el
        [ width fill
        , height (px 300)
        , htmlAttribute (Html.Attributes.style "background-color" "rgba(0, 0, 0, 0.05)")
        , Border.rounded 10
        ]
        (el [ centerX, centerY ] (text "Loading..."))


errorView : Theme -> String -> Element Msg
errorView theme errorMsg =
    column
        [ width fill
        , height (px 300)
        , spacing 20
        , padding 20
        , htmlAttribute (Html.Attributes.style "background-color" "rgba(255, 0, 0, 0.05)")
        , Border.rounded 10
        ]
        [ el [ centerX, centerY, Font.color theme.colors.error ] (text errorMsg)
        , Input.button
            [ centerX
            , padding 10
            , htmlAttribute (Html.Attributes.style "background-color" "#4299e1")
            , Font.color theme.colors.white
            , Border.rounded 6
            ]
            { onPress = Just LoadStockPrices
            , label = text "Retry"
            }
        ]


view : Model -> Element Msg
view model =
    Styles.containerCard defaultTheme [ spacing 25 ] <|
        column [ width fill, spacing 25 ]
            [ Styles.heading1 defaultTheme "Stock Price Chart"
            , Styles.paragraph defaultTheme
                { text = "Real-time IBM stock price data from Alpha Vantage API, showing monthly closing prices"
                , maxWidth = 600
                }
            , case ( model.loading, model.error ) of
                ( True, _ ) ->
                    loadingSpinner defaultTheme

                ( False, Just error ) ->
                    errorView defaultTheme error

                ( False, Nothing ) ->
                    stockPriceChart model.data
            ]
