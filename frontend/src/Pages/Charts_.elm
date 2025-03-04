module Pages.Charts_ exposing (Model, Msg, init, subscriptions, update, view)

import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Element.Input as Input
import Lib.Chart.Api.ChartApi as ChartApi exposing (ChartData, ChartResponse)
import Styles exposing (Theme, defaultTheme)


type alias Model =
    { data : List ChartData
    , loading : Bool
    , error : Maybe String
    }


type Msg
    = LoadChartData
    | GotChartData ChartResponse


init : ( Model, Cmd Msg )
init =
    ( { data = []
      , loading = True
      , error = Nothing
      }
    , ChartApi.getChartData ()
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        LoadChartData ->
            ( { model | loading = True, error = Nothing }
            , ChartApi.getChartData ()
            )

        GotChartData response ->
            case response.data of
                Just chartData ->
                    ( { model | data = chartData, loading = False, error = Nothing }
                    , Cmd.none
                    )

                Nothing ->
                    ( { model | loading = False, error = response.error }
                    , Cmd.none
                    )


subscriptions : Model -> Sub Msg
subscriptions _ =
    ChartApi.chartDataLoaded GotChartData


barChart : Theme -> List ChartData -> Element Msg
barChart theme data =
    let
        maxValue =
            List.map .value data
                |> List.maximum
                |> Maybe.withDefault 100

        barWidth =
            600 // List.length data - 20

        chartHeight =
            300

        toHeight value =
            round (value / maxValue * toFloat chartHeight)

        bar chartData =
            column
                [ width (px barWidth)
                , height fill
                , spacing 10
                , padding 10
                ]
                [ el
                    [ width fill
                    , height (px (chartHeight - toHeight chartData.value))
                    ]
                    none
                , el
                    [ width fill
                    , height (px (toHeight chartData.value))
                    , Background.color theme.colors.primary
                    , Border.rounded 6
                    , mouseOver
                        [ Background.color theme.colors.primaryHover ]
                    ]
                    none
                , el
                    [ centerX
                    , Font.size 14
                    , Font.color theme.colors.text
                    ]
                    (text chartData.label)
                , el
                    [ centerX
                    , Font.size 14
                    , Font.color theme.colors.textLight
                    ]
                    (text (String.fromFloat chartData.value))
                ]
    in
    column
        [ width fill
        , height (px chartHeight)
        , padding 20
        , spacing 20
        , Background.color theme.colors.white
        , Border.rounded 10
        , Border.width 1
        , Border.color theme.colors.border
        ]
        [ row
            [ width fill
            , height fill
            , spacing 10
            ]
            (List.map bar data)
        ]


loadingSpinner : Theme -> Element msg
loadingSpinner theme =
    el
        [ width fill
        , height (px 300)
        , Background.color (rgba 0 0 0 0.05)
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
        , Background.color (rgba 255 0 0 0.05)
        , Border.rounded 10
        ]
        [ el [ centerX, centerY, Font.color theme.colors.error ] (text errorMsg)
        , Input.button
            [ centerX
            , padding 10
            , Background.color theme.colors.primary
            , Font.color theme.colors.white
            , Border.rounded 6
            , mouseOver [ Background.color theme.colors.primaryHover ]
            ]
            { onPress = Just LoadChartData
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
                    barChart defaultTheme model.data
            ]
