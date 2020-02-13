module Decoders.PhotoOverlayDecoderTest exposing (..)

import Expect
import Fuzz exposing (int)
import Json.Decode exposing (decodeString)
import Main exposing (OverlayContent(..), photoOverlayDecoder)
import String.Interpolate exposing (interpolate)
import Test exposing (..)


suite : Test
suite =
    describe "photoOverlayDecoder"
        [ test "maps to a Photo overlay" <|
            \_ ->
                let
                    alt =
                        "some text content"

                    src =
                        "https://example.com/image.jpog"

                    json_ =
                        """
                        {
                            "alt": "{0}",
                            "src": "{1}"
                        }
                        """

                    json =
                        interpolate json_ [ alt, src ]
                in
                decodeString photoOverlayDecoder json
                    |> Expect.equal
                        (Ok
                            (Photo
                                { alt = alt
                                , src = src
                                }
                            )
                        )
        ]
