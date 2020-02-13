module Decoders.LinkDecoderTest exposing (..)

import Expect
import Fuzz exposing (int)
import Json.Decode exposing (decodeString)
import Main exposing (OverlayContent(..), linkOverlayDecoder)
import String.Interpolate exposing (interpolate)
import Test exposing (..)


suite : Test
suite =
    describe "linkOverlayDecoder"
        [ test "maps to a Link overlay" <|
            \_ ->
                let
                    text =
                        "some text content"

                    href =
                        "https://example.com"

                    json_ =
                        """
                        {
                            "text": "{0}",
                            "href": "{1}"
                        }
                        """

                    json =
                        interpolate json_ [ text, href ]
                in
                decodeString linkOverlayDecoder json
                    |> Expect.equal
                        (Ok
                            (Link
                                { href = href
                                , text = text
                                }
                            )
                        )
        ]
