port module Main exposing
    ( Model
    , OverlayContent(..)
    , formattedStringToIntInterval
    , intervalDecoder
    , outbound
    , overlayDecoder
    , textOverlayDecoder
    , view
    )

import Browser
import Dict exposing (Dict)
import Html exposing (Html, a, div, img, p, text)
import Html.Attributes exposing (alt, href, src, target)
import Html.Events exposing (onClick)
import Html.Keyed as K
import Interval exposing (Interval)
import Json.Decode as D exposing (Decoder, field, string)
import Json.Decode.Pipeline exposing (custom, required)
import List.Extra
import Media exposing (PortMsg, newVideo, pause, play)
import Media.Attributes exposing (anonymous, controls, crossOrigin, playsInline)
import Media.Events
import Media.Source exposing (source)
import Media.State exposing (PlaybackStatus(..), currentTime, duration)
import TW


port outbound : PortMsg -> Cmd msg


type MediaSource
    = VideoSource


type alias LinkItem =
    { href : String
    , text : String
    }


type alias PhotoItem =
    { src : String
    , alt : String
    }


type OverlayContent
    = Text String
    | Link LinkItem
    | Photo PhotoItem
    | Video String


type alias Model =
    { state : Media.State
    , mediaSource : MediaSource
    , overlays : List Overlay
    , data : Dict Int (Maybe Int)
    , currentOverlay : Maybe Overlay
    }


type alias Overlay =
    { interval : Interval Int
    , buttonText : String
    , content : OverlayContent
    }


type Msg
    = NoOp
    | MediaStateUpdate Media.State
    | Play
    | Pause
    | Show Overlay
    | Close


testTextOverlay =
    { interval = Interval.from 1 4
    , buttonText = "Click for Location"
    , content = Text "Filmed at the Orcas Center, Madrona Room on December 19, 2019"
    }


testLinkOverlay =
    { interval = Interval.from 5 10
    , buttonText = "Click for Link"
    , content = Link { href = "http://www.orcas.dance", text = "www.orcas.dance" }
    }


testPhotoOverlay =
    { interval = Interval.from 15 20
    , buttonText = "Click for Photo"
    , content = Photo { src = "assets/po1.jpg", alt = "Dancer!" }
    }


testVideoOverlay =
    { interval = Interval.from 41 44
    , buttonText = "Click for Video"
    , content = Video "assets/vo1.mp4"
    }


testOverlays : List Overlay
testOverlays =
    [ testTextOverlay
    , testLinkOverlay
    , testPhotoOverlay
    , testVideoOverlay
    ]


getOverlayIndexBySecond : Int -> List Overlay -> Maybe Int
getOverlayIndexBySecond s overlays =
    List.Extra.findIndex
        (\o ->
            Interval.contains s o.interval
        )
        overlays


init : () -> ( Model, Cmd Msg )
init _ =
    let
        state =
            newVideo "dance"

        duration_ =
            -- TODO: figure out how to get this info
            -- out of the video. Or, pass it in (not optimal)
            --durationInSeconds state
            82

        range =
            List.range 0 duration_

        overlays =
            testOverlays

        data =
            -- Becomes a Dict of (second, Maybe index of the overlay)
            List.Extra.zip
                range
                (List.map (\s -> getOverlayIndexBySecond s overlays) range)
                |> Dict.fromList

        model =
            { state = state
            , mediaSource = VideoSource
            , overlays = overlays
            , data = data
            , currentOverlay = Nothing
            }
    in
    ( model, Cmd.none )


view : Model -> Html Msg
view model =
    let
        videoElement =
            ( "video"
            , Media.video
                model.state
                (Media.Events.allEvents MediaStateUpdate
                    ++ [ playsInline True, controls True, crossOrigin anonymous ]
                )
                [ ( "source", Media.Source.source "/assets/master.mp4" [] )
                ]
            )

        mediaInfo =
            [ p [] [ text ("current time: " ++ (String.fromFloat <| currentTime model.state)) ]
            , p [] [ text ("current second: " ++ (String.fromInt <| currentSecond model.state)) ]
            , p [] [ text ("duration: " ++ (String.fromFloat <| duration model.state)) ]
            , p [] [ text ("duration in seconds: " ++ (model.state |> duration |> truncate |> String.fromInt)) ]
            ]
    in
    div [ TW.container, TW.mx_auto ]
        [ K.node
            "div"
            [ TW.relative
            , TW.top_0
            , TW.left_0
            , TW.flex
            , TW.border_red_600
            , TW.border_2
            ]
            [ videoElement
            , overlayControl model
            , overlayCloseControl model
            , overlay model
            ]
        , div [] mediaInfo
        ]


overlay : Model -> ( String, Html Msg )
overlay model =
    case model.currentOverlay of
        Nothing ->
            ( "div", div [] [] )

        Just o ->
            case o.content of
                Text t ->
                    ( "div", textOverlay t )

                Link item ->
                    ( "div", linkOverlay item )

                Photo item ->
                    ( "div", photoOverlay item )

                Video src ->
                    ( "div", videoOverlay src )


contentOverlay : Html Msg -> Html Msg
contentOverlay element =
    div
        [ TW.flex
        , TW.flex_col
        , TW.flex_grow
        ]
        [ div
            [ TW.absolute
            , TW.w_full
            , TW.h_full
            , TW.left_0
            , TW.top_0
            , TW.bg_gray_800
            , TW.opacity_100
            , TW.p_10
            ]
            [ element ]
        ]


videoOverlay : String -> Html Msg
videoOverlay src =
    contentOverlay <|
        K.node
            "div"
            []
            [ ( "video"
              , Media.video
                    (newVideo "overlay video")
                    [ playsInline True, controls True, crossOrigin anonymous ]
                    [ ( "source", Media.Source.source src [] )
                    ]
              )
            ]


photoOverlay : PhotoItem -> Html Msg
photoOverlay item =
    contentOverlay <| img [ src item.src, alt item.alt, TW.object_cover, TW.w_full, TW.h_full ] []


linkOverlay : LinkItem -> Html Msg
linkOverlay item =
    contentOverlay <| a [ href item.href, target "_blank" ] [ text item.text ]


textOverlay : String -> Html Msg
textOverlay txt =
    contentOverlay <| text txt


overlayCloseControl : Model -> ( String, Html Msg )
overlayCloseControl model =
    case model.currentOverlay of
        Nothing ->
            ( "div", div [] [] )

        Just o ->
            ( "div"
            , div
                [ TW.top_0
                , TW.absolute
                , TW.z_10
                ]
                [ button "Close" Close ]
            )


button : String -> Msg -> Html Msg
button txt action =
    Html.button
        [ onClick action
        , TW.bg_blue_500
        , TW.hover_bg_blue_600
        , TW.text_white
        , TW.font_bold
        , TW.py_2
        , TW.px_4
        , TW.rounded
        ]
        [ text txt ]


overlayControl : Model -> ( String, Html Msg )
overlayControl model =
    let
        s =
            currentSecond model.state

        overlayIndex =
            case Dict.get s model.data of
                Nothing ->
                    Nothing

                Just i ->
                    i

        overlay_ =
            case overlayIndex of
                Nothing ->
                    Nothing

                Just index ->
                    List.Extra.getAt index model.overlays
    in
    case overlay_ of
        Nothing ->
            ( "div", div [] [] )

        Just o ->
            ( "div"
            , div
                [ TW.top_0
                , TW.absolute
                , toggleOverlayButtonVisibility model
                , onClick <| Show o
                ]
                [ button o.buttonText (Show o) ]
            )


toggleOverlayButtonVisibility : Model -> Html.Attribute msg
toggleOverlayButtonVisibility model =
    case model.currentOverlay of
        Nothing ->
            TW.visible

        Just _ ->
            TW.invisible


currentSecond : Media.State -> Int
currentSecond state =
    state |> currentTime |> truncate


durationInSeconds : Media.State -> Int
durationInSeconds state =
    state |> duration |> truncate


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        MediaStateUpdate state ->
            ( { model | state = state }, Cmd.none )

        Play ->
            ( { model | currentOverlay = Nothing }, play model.state outbound )

        Pause ->
            ( model, pause model.state outbound )

        Show o ->
            ( { model | currentOverlay = Just o }, pause model.state outbound )

        Close ->
            ( { model | currentOverlay = Nothing }, play model.state outbound )


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.batch []


main =
    Browser.element
        { init = init
        , subscriptions = subscriptions
        , update = update
        , view = view
        }


formattedStringToIntInterval : String -> Interval Int
formattedStringToIntInterval s =
    let
        toInt =
            \str ->
                str
                    |> String.toInt
                    |> Maybe.withDefault 0

        list =
            s |> String.split "|" |> List.map toInt
    in
    case list of
        [ a, b ] ->
            Interval.from a b

        _ ->
            Interval.from 0 0


intervalDecoder : Decoder (Interval Int)
intervalDecoder =
    string
        |> D.andThen
            (\s ->
                D.succeed <| formattedStringToIntInterval s
            )


overlayContentDecoder : Decoder OverlayContent
overlayContentDecoder =
    field "type" string
        |> D.andThen
            (\t ->
                case t of
                    "text" ->
                        D.succeed (Text t)

                    _ ->
                        D.fail "Unknown overlay type"
            )


textOverlayDecoder : Decoder OverlayContent
textOverlayDecoder =
    string
        |> D.andThen
            (\s ->
                D.succeed (Text s)
            )


overlayDecoder : Decoder Overlay
overlayDecoder =
    D.succeed Overlay
        |> custom (field "interval" intervalDecoder)
        |> required "buttonText" string
        |> required "overlay" overlayContentDecoder



{-
   {
       "mainVideoUrl": "https://example.com/video.mp4",
       "videoLength": 50,
       "overlays": [
           {
               "interval": "1|4",
               "buttonText": "Click me!",
               "overlay": {
                   "type": "text",
                   "content": "Lorem ipsum..."
           },
           {
               "interval": "1|4",
               "buttonText": "Click me!",
               "overlay": {
                   "type": "link",
                   "href": "https://example.com/link",
                   "text": "Lorem ipsum..."
           },
           {
               "interval": "1|4",
               "buttonText": "Click me!",
               "overlay": {
                   "type": "photo",
                   "alt": "Lorem ipsum...",
                   "src": "https://example.com/photo.jpg"
           },
           {
               "interval": "1|4",
               "buttonText": "Click me!",
               "overlay": {
                   "type": "video",
                   "url": "https://example.com/another-video.mp4"
           },
       ]
-}
