module Pages.Charts_ exposing (Model, Msg, init, subscriptions, update, view)

import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Lib.Chart.Api.ChartApi as ChartApi exposing (ChartData)
import Styles exposing (Theme, defaultTheme)


type alias Model =
    { data : List ChartData
    , loading : Bool
    }


type Msg
    = LoadChartData
    | GotChartData (List ChartData)


init : ( Model, Cmd Msg )
init =
    ( { data = []
      , loading = True
      }
    , ChartApi.getChartData ()
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        LoadChartData ->
            ( { model | loading = True }
            , ChartApi.getChartData ()
            )

        GotChartData data ->
            ( { model | data = data, loading = False }
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


view : Model -> Element Msg
view model =
    Styles.containerCard defaultTheme [ spacing 25 ] <|
        column [ width fill, spacing 25 ]
            [ Styles.heading1 defaultTheme "Charts Example"
            , Styles.paragraph defaultTheme
                { text = "A simple bar chart visualization using elm-ui"
                , maxWidth = 600
                }
            , barChart defaultTheme model.data
            ]
