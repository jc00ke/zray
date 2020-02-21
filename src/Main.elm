port module Main exposing
    ( Model
    , OverlayContent(..)
    , flagsDecoder
    , formattedStringToIntInterval
    , intervalDecoder
    , linkOverlayDecoder
    , outbound
    , overlayDecoder
    , photoOverlayDecoder
    , textOverlayDecoder
    , videoOverlayDecoder
    , view
    )

import Browser
import Dict exposing (Dict)
import Html exposing (Attribute, Html, a, code, div, img, pre, text)
import Html.Attributes exposing (alt, attribute, class, href, src, target)
import Html.Events exposing (onClick)
import Html.Keyed as K
import Interval exposing (Interval)
import Json.Decode as D exposing (Decoder, field, int, string)
import List.Extra
import Media exposing (PortMsg, newVideo, pause, play)
import Media.Attributes exposing (anonymous, controls, crossOrigin, playsInline)
import Media.Events
import Media.Source exposing (source)
import Media.State exposing (PlaybackStatus(..), currentTime, duration)
import TW


port outbound : PortMsg -> Cmd msg


type alias Flags =
    { mainVideoUrl : String
    , videoLength : Int
    , overlays : List Overlay
    }


type MediaSource
    = VideoSource


type alias LinkItem =
    { href : String
    , text : String
    }


type alias PhotoItem =
    { alt : String
    , src : String
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
    , err : Maybe String
    , mainVideoUrl : String
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


errModel : D.Error -> Model
errModel err =
    { state = newVideo "err"
    , mediaSource = VideoSource
    , overlays = []
    , data = Dict.empty
    , currentOverlay = Nothing
    , err = Just (D.errorToString err)
    , mainVideoUrl = ""
    }


getOverlayIndexBySecond : Int -> List Overlay -> Maybe Int
getOverlayIndexBySecond s overlays =
    List.Extra.findIndex
        (\o ->
            Interval.contains s o.interval
        )
        overlays


prepareOverlayData : Flags -> Dict Int (Maybe Int)
prepareOverlayData flags =
    let
        duration_ =
            flags.videoLength

        range =
            List.range 0 duration_
    in
    -- Becomes a Dict of (second, Maybe index of the overlay)
    List.Extra.zip
        range
        (List.map (\s -> getOverlayIndexBySecond s flags.overlays) range)
        |> Dict.fromList


init : D.Value -> ( Model, Cmd Msg )
init flags =
    case D.decodeValue flagsDecoder flags of
        Ok f ->
            let
                state =
                    newVideo "dance"

                overlays =
                    f.overlays

                model =
                    { state = state
                    , mediaSource = VideoSource
                    , overlays = overlays
                    , data = prepareOverlayData f
                    , currentOverlay = Nothing
                    , err = Nothing
                    , mainVideoUrl = f.mainVideoUrl
                    }
            in
            ( model, Cmd.none )

        Err err ->
            ( errModel err, Cmd.none )


view : Model -> Html Msg
view model =
    case model.err of
        Nothing ->
            let
                videoElement =
                    ( "video"
                    , Media.video
                        model.state
                        (Media.Events.allEvents MediaStateUpdate
                            ++ [ playsInline True, controls True, crossOrigin anonymous ]
                        )
                        [ ( "source", Media.Source.source model.mainVideoUrl [] )
                        ]
                    )
            in
            div [ TW.container, TW.mx_auto ]
                [ K.node
                    "div"
                    [ TW.relative
                    , TW.top_0
                    , TW.left_0
                    , TW.flex
                    ]
                    [ videoElement
                    , overlayControl model
                    , overlayCloseControl model
                    , overlay model
                    ]
                ]

        Just err ->
            div [ TW.container, TW.mx_auto ]
                [ div [ role "alert" ]
                    [ div [ class "bg-red-500 text-white font-bold rounded-t px-4 py-2" ] [ text "Error!" ]
                    , div [ class "border border-t-0 border-red-400 rounded-b bg-red-100 px-4 py-3 text-red-700" ]
                        [ pre []
                            [ code []
                                [ text err ]
                            ]
                        ]
                    ]
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
            , TW.text_center
            , TW.text_gray_200
            ]
            [ element ]
        ]


videoOverlay : String -> Html Msg
videoOverlay src =
    contentOverlay <|
        K.node
            "div"
            [ TW.m_4 ]
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
    contentOverlay <|
        img
            [ src item.src
            , alt item.alt
            , TW.object_cover
            , TW.w_full
            , TW.h_full
            , TW.m_4
            ]
            []


linkOverlay : LinkItem -> Html Msg
linkOverlay item =
    contentOverlay <|
        a
            [ href item.href
            , TW.underline
            , TW.hover_no_underline
            , target "_blank"
            ]
            [ text item.text ]


textOverlay : String -> Html Msg
textOverlay txt =
    contentOverlay <| text txt


overlayCloseControl : Model -> ( String, Html Msg )
overlayCloseControl model =
    case model.currentOverlay of
        Nothing ->
            ( "div", div [] [] )

        Just _ ->
            ( "div"
            , div
                [ TW.top_0
                , TW.absolute
                , TW.z_10
                , TW.p_2
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
                , TW.p_2
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


main : Program D.Value Model Msg
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


overlayDecoder : Decoder Overlay
overlayDecoder =
    D.map3
        Overlay
        (field "interval" intervalDecoder)
        (field "buttonText" string)
        (field "overlay" overlayContentDecoder)


overlayContentDecoder : Decoder OverlayContent
overlayContentDecoder =
    D.oneOf
        [ linkOverlayDecoder, textOverlayDecoder, photoOverlayDecoder, videoOverlayDecoder ]


textOverlayDecoder : Decoder OverlayContent
textOverlayDecoder =
    D.map Text (field "text" string)


linkOverlayDecoder : Decoder OverlayContent
linkOverlayDecoder =
    D.map
        Link
        (D.map2
            LinkItem
            (field "href" string)
            (field "text" string)
        )


photoOverlayDecoder : Decoder OverlayContent
photoOverlayDecoder =
    D.map
        Photo
        (D.map2
            PhotoItem
            (field "alt" string)
            (field "src" string)
        )


videoOverlayDecoder : Decoder OverlayContent
videoOverlayDecoder =
    D.map Video (field "url" string)


flagsDecoder : Decoder Flags
flagsDecoder =
    D.map3
        Flags
        (field "mainVideoUrl" string)
        (field "videoLength" int)
        (field "overlays" (D.list overlayDecoder))


role : String -> Attribute msg
role =
    attribute "role"



{-
   {
       "mainVideoUrl": "https://example.com/video.mp4",
       "videoLength": 50,
       "overlays": [
           {
               "interval": "1|4",
               "buttonText": "Click me!",
               "overlay": {
                   "content": "Lorem ipsum..."
                }
           },
           {
               "interval": "1|4",
               "buttonText": "Click me!",
               "overlay": {
                   "href": "https://example.com/link",
                   "text": "Lorem ipsum..."
                }
           },
           {
               "interval": "1|4",
               "buttonText": "Click me!",
               "overlay": {
                   "alt": "Lorem ipsum...",
                   "src": "https://example.com/photo.jpg"
                }
           },
           {
               "interval": "1|4",
               "buttonText": "Click me!",
               "overlay": {
                   "url": "https://example.com/another-video.mp4"
                }
           },
       ]
-}
