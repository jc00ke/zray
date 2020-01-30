port module Main exposing (Model, outbound, view)

import Browser
import Dict exposing (Dict)
import Html exposing (..)
import Html.Attributes exposing (alt, class, classList, href, id, kind, src, srclang, target)
import Html.Events exposing (onClick)
import Html.Keyed as K
import Interval exposing (Interval)
import List.Extra
import Media exposing (PortMsg, load, mute, newVideo, pause, play, seek)
import Media.Attributes exposing (anonymous, autoplay, controls, crossOrigin, label, mode, playsInline)
import Media.Events
import Media.Source exposing (mediaCapture, source)
import Media.State exposing (PlaybackStatus(..), currentTime, duration, playbackStatus, played)


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
    { interval = Interval.from 22 30
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
    { interval = Interval.from 1 4
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
    div [ class "container", class "mx-auto" ]
        [ K.node
            "div"
            [ classList
                [ ( "relative", True )
                , ( "top-0", True )
                , ( "left-0", True )
                , ( "flex", True )
                , ( "border-red-600", True )
                , ( "border-2", True )
                ]
            ]
            [ videoElement
            , overlayControl model
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


videoOverlay : String -> Html Msg
videoOverlay src =
    div
        [ classList
            [ ( "flex", True )
            , ( "flex-col", True )
            , ( "flex-grow", True )
            ]
        ]
        [ div
            [ classList
                [ ( "absolute", True )
                , ( "w-full", True )
                , ( "h-full", True )
                , ( "left-0", True )
                , ( "top-0", True )
                , ( "bg-gray-800", True )
                , ( "opacity-100", True )
                ]
            ]
            [ K.node "div"
                []
                [ ( "video"
                  , Media.video
                        (newVideo "overlay video")
                        [ playsInline True, controls True, crossOrigin anonymous ]
                        [ ( "source", Media.Source.source src [] )
                        ]
                  )
                ]
            ]
        ]


photoOverlay : PhotoItem -> Html Msg
photoOverlay item =
    div
        [ classList
            [ ( "flex", True )
            , ( "flex-col", True )
            , ( "flex-grow", True )
            ]
        ]
        [ div
            [ classList
                [ ( "absolute", True )
                , ( "w-full", True )
                , ( "h-full", True )
                , ( "left-0", True )
                , ( "top-0", True )
                , ( "bg-gray_800", True )
                , ( "opacity-100", True )
                ]
            , onClick Close
            ]
            [ img [ src item.src, alt item.alt, class "object-cover", class "w-full", class "h-full" ] [] ]
        ]


linkOverlay : LinkItem -> Html Msg
linkOverlay item =
    div
        [ classList
            [ ( "flex", True )
            , ( "flex-col", True )
            , ( "flex-grow", True )
            ]
        ]
        [ div
            [ classList
                [ ( "absolute", True )
                , ( "w-full", True )
                , ( "h-full", True )
                , ( "left-0", True )
                , ( "top-0", True )
                , ( "bg-gray-800", True )
                , ( "opacity-75", True )
                , ( "text-center", True )
                ]
            , onClick Close
            ]
            [ a [ href item.href, target "_blank" ] [ text item.text ] ]
        ]


textOverlay : String -> Html Msg
textOverlay txt =
    div
        [ classList
            [ ( "flex", True )
            , ( "flex-col", True )
            , ( "flex-grow", True )
            ]
        ]
        [ div
            [ classList
                [ ( "absolute", True )
                , ( "w-full", True )
                , ( "h-full", True )
                , ( "left-0", True )
                , ( "top-0", True )
                , ( "bg-gray-800", True )
                , ( "opacity-50", True )
                , ( "text-center", True )
                ]
            , onClick Close
            ]
            [ text txt ]
        ]


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
                [ classList
                    [ ( "absolute", True )
                    , ( "bg-gray-800", True )
                    , ( "opacity-75", True )
                    , ( "px-4", True )
                    , ( "py-2", True )
                    , ( "text-center", True )
                    , ( "text-white", True )
                    , ( "top-0", True )
                    , ( toggleOverlayButtonVisibility model, True )
                    ]
                , onClick <| Show o
                ]
                [ text o.buttonText ]
            )


toggleOverlayButtonVisibility : Model -> String
toggleOverlayButtonVisibility model =
    case model.currentOverlay of
        Nothing ->
            "visible"

        Just _ ->
            "invisible"


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
