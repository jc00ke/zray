module Decoders.OverlayDecoderTest exposing (..)

import Expect exposing (Expectation)
import Interval
import Json.Decode exposing (decodeString)
import Main exposing (OverlayContent(..), overlayDecoder)
import String.Interpolate exposing (interpolate)
import Test exposing (..)


suite : Test
suite =
    describe "overlayDecoder"
        [ test "maps text to a text overlay" <|
            \_ ->
                let
                    content =
                        "some content"

                    buttonText =
                        "some buttonText"

                    json_ =
                        """
                        {
                            "interval": "1|4",
                            "buttonText": "{0}",
                            "overlay": {
                                "text": "{1}"
                            }
                        }
                        """

                    json =
                        interpolate json_ [ buttonText, content ]
                in
                decodeString overlayDecoder json
                    |> Expect.equal
                        (Ok
                            { interval = Interval.from 1 4
                            , buttonText = buttonText
                            , content = Text content
                            }
                        )
        , test "maps link to a link overlay" <|
            \_ ->
                let
                    content =
                        "some content"

                    buttonText =
                        "some buttonText"

                    href =
                        "https://example.com"

                    json_ =
                        """
                        {
                            "interval": "1|4",
                            "buttonText": "{0}",
                            "overlay": {
                                "href": "{2}",
                                "text": "{1}"
                            }
                        }
                        """

                    json =
                        interpolate json_ [ buttonText, content, href ]
                in
                decodeString overlayDecoder json
                    |> Expect.equal
                        (Ok
                            { interval = Interval.from 1 4
                            , buttonText = buttonText
                            , content = Link { href = href, text = content }
                            }
                        )
        , test "maps photo to a photo overlay" <|
            \_ ->
                let
                    alt =
                        "some alt content"

                    buttonText =
                        "some buttonText"

                    src =
                        "https://example.com/photo.jpg"

                    json_ =
                        """
                        {
                            "interval": "1|4",
                            "buttonText": "{0}",
                            "overlay": {
                                "src": "{2}",
                                "alt": "{1}"
                            }
                        }
                        """

                    json =
                        interpolate json_ [ buttonText, alt, src ]
                in
                decodeString overlayDecoder json
                    |> Expect.equal
                        (Ok
                            { interval = Interval.from 1 4
                            , buttonText = buttonText
                            , content = Photo { alt = alt, src = src }
                            }
                        )
        , test "maps video to a video overlay" <|
            \_ ->
                let
                    buttonText =
                        "some buttonText"

                    url =
                        "https://example.com/video.mp4"

                    json_ =
                        """
                        {
                            "interval": "1|4",
                            "buttonText": "{0}",
                            "overlay": {
                                "url": "{1}"
                            }
                        }
                        """

                    json =
                        interpolate json_ [ buttonText, url ]
                in
                decodeString overlayDecoder json
                    |> Expect.equal
                        (Ok
                            { interval = Interval.from 1 4
                            , buttonText = buttonText
                            , content = Video url
                            }
                        )
        ]
