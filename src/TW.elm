module TW exposing (..)

import Html
import Html.Attributes as A


classList : List ( Html.Attribute msg, Bool ) -> List (Html.Attribute msg)
classList classes =
    List.map Tuple.first <| List.filter Tuple.second classes


absolute : Html.Attribute msg
absolute =
    A.class "absolute"


bg_blue_500 : Html.Attribute msg
bg_blue_500 =
    A.class "bg-blue-500"


bg_gray_800 : Html.Attribute msg
bg_gray_800 =
    A.class "bg-gray-800"


border_2 : Html.Attribute msg
border_2 =
    A.class "border-2"


border_red_600 : Html.Attribute msg
border_red_600 =
    A.class "border-red-600"


container : Html.Attribute msg
container =
    A.class "container"


flex : Html.Attribute msg
flex =
    A.class "flex"


flex_col : Html.Attribute msg
flex_col =
    A.class "flex-col"


flex_grow : Html.Attribute msg
flex_grow =
    A.class "flex-grow"


font_bold : Html.Attribute msg
font_bold =
    A.class "font-bold"


h_full : Html.Attribute msg
h_full =
    A.class "h-full"


hover_bg_blue_600 : Html.Attribute msg
hover_bg_blue_600 =
    A.class "hover:bg-blue-600"


invisible : Html.Attribute msg
invisible =
    A.class "invisible"


left_0 : Html.Attribute msg
left_0 =
    A.class "left-0"


mx_auto : Html.Attribute msg
mx_auto =
    A.class "mx-auto"


object_cover : Html.Attribute msg
object_cover =
    A.class "object-cover"


opacity_75 : Html.Attribute msg
opacity_75 =
    A.class "opacity-75"


opacity_100 : Html.Attribute msg
opacity_100 =
    A.class "opacity-100"


p_10 : Html.Attribute msg
p_10 =
    A.class "p-10"


px_4 : Html.Attribute msg
px_4 =
    A.class "px-4"


py_2 : Html.Attribute msg
py_2 =
    A.class "py-2"


relative : Html.Attribute msg
relative =
    A.class "relative"


rounded : Html.Attribute msg
rounded =
    A.class "rounded"


text_center : Html.Attribute msg
text_center =
    A.class "text-center"


text_right : Html.Attribute msg
text_right =
    A.class "text-right"


text_white : Html.Attribute msg
text_white =
    A.class "text-white"


top_0 : Html.Attribute msg
top_0 =
    A.class "top-0"


visible : Html.Attribute msg
visible =
    A.class "visible"


w_full : Html.Attribute msg
w_full =
    A.class "w-full"


z_10 : Html.Attribute msg
z_10 =
    A.class "z-10"
