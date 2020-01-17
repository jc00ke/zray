port module Main exposing (Model, outbound, view)

import Browser
import Dict exposing (Dict)
import Html exposing (Html, button, div, p, text, track)
import Html.Attributes exposing (id, kind, src, srclang)
import Html.Events exposing (onClick)
import Html.Keyed exposing (node)
import Interval exposing (Interval)
import List.Extra
import Media exposing (PortMsg, load, mute, newVideo, pause, play, seek, video)
import Media.Attributes exposing (anonymous, autoplay, controls, crossOrigin, label, mode, playsInline)
import Media.Events
import Media.Source exposing (mediaCapture, source)
import Media.State exposing (PlaybackStatus(..), currentTime, duration, playbackStatus, played)
import TW


port outbound : PortMsg -> Cmd msg


type MediaSource
    = VideoSource


type OverlayContent
    = Text String
    | Link { href : String, text : String }
    | Photo { src : String, alt : String }
    | Video String


type alias Model =
    { state : Media.State
    , mediaSource : MediaSource
    , overlays : List Overlay
    , data : Dict Int (Maybe Int)
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


testTextOverlay =
    { interval = Interval.from 2 25
    , buttonText = "Click for Location"
    , content = Text "Filmed at the Orcas Center, Madrona Room on December 19, 2019"
    }


testLinkOverlay =
    { interval = Interval.from 26 35
    , buttonText = "Click for Link"
    , content = Link { href = "http://www.orcas.dance", text = "www.orcas.dance" }
    }


testPhotoOverlay =
    { interval = Interval.from 36 45
    , buttonText = "Click for Photo"
    , content = Photo { src = "assets/po1.jpg", alt = "Dancer!" }
    }


testVideoOverlay =
    { interval = Interval.from 46 80
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

        _ =
            Debug.log "DURATION" duration_

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

        _ =
            Debug.log "DATA" data

        model =
            { state = state
            , mediaSource = VideoSource
            , overlays = overlays
            , data = data
            }
    in
    ( model, Cmd.none )


view : Model -> Html Msg
view model =
    let
        playPauseButton =
            case playbackStatus model.state of
                Playing ->
                    button [ onClick Pause ] [ text "Pause" ]

                Paused ->
                    button [ onClick Play ] [ text "Play" ]

                _ ->
                    button [ onClick Play ] [ text "Other" ]

        videoElement =
            ( "video"
            , video
                model.state
                (Media.Events.allEvents MediaStateUpdate
                    ++ [ playsInline True, controls True, crossOrigin anonymous ]
                )
                [ ( "source", source "./assets/master.mp4" [] )
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
        [ node "div" [] [ videoElement ]
        , overlay model
        , div [] [ playPauseButton ]
        , div [] mediaInfo
        ]


overlay : Model -> Html Msg
overlay model =
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
            div [] []

        Just o ->
            --<div class="text-center">
            --<div class="inline-block relative">
            --<div class="absolute left-0 top-0 min-w-full bg-gray-800 min-h-full opacity-50">OVERLAY</div>
            --<video id="dance" controls="" crossorigin="anonymous" class=""><source src="./assets/master.mp4"></video>
            --</div>
            --</div>
            div
                [ TW.absolute
                , TW.bg_gray_800
                , TW.opacity_75
                , TW.px_4
                , TW.py_2
                , TW.text_center
                , TW.text_white
                , TW.top_0
                ]
                [ text o.buttonText ]


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
            ( model, play model.state outbound )

        Pause ->
            ( model, pause model.state outbound )


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
