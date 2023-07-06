module Picshare exposing (main)

import Browser
import Html exposing (..)
import Html.Attributes exposing (class, disabled, placeholder, src, type_, value)
import Html.Events exposing (onClick, onInput, onSubmit)
import Http
import Json.Decode exposing (Decoder, bool, int, list, string, succeed)
import Json.Decode.Pipeline exposing (hardcoded, required)


type alias Id =
    Int


type alias Photo =
    { id : Id
    , url : String
    , caption : String
    , liked : Bool
    , comments : List String
    , newComment : String
    }


type alias Feed =
    List Photo


type alias Model =
    { feed : Maybe Feed
    }


photoDecoder : Decoder Photo
photoDecoder =
    succeed Photo
        |> required "id" int
        |> required "url" string
        |> required "caption" string
        |> required "liked" bool
        |> required "comments" (list string)
        |> hardcoded ""


baseUrl : String
baseUrl =
    "https://programming-elm.com/"


initialModel : Model
initialModel =
    { feed = Nothing }


init : () -> ( Model, Cmd Msg )
init () =
    ( initialModel, fetchFeed )


fetchFeed : Cmd Msg
fetchFeed =
    Http.get
        { url = baseUrl ++ "feed"
        , expect = Http.expectJson LoadFeed (list photoDecoder)
        }


viewLoveButton : Photo -> Html Msg
viewLoveButton photo =
    let
        buttonClass =
            if photo.liked then
                "fa-heart"

            else
                "fa-heart-o"
    in
    div [ class "like-button" ]
        [ i
            [ class "fa fa-2x"
            , class buttonClass

            -- , onClick ToggleLike
            ]
            []
        ]


viewComment : String -> Html Msg
viewComment comment =
    li []
        [ strong [] [ text "comment:" ]
        , text (" " ++ comment)
        ]


viewCommentList : List String -> Html Msg
viewCommentList comments =
    case comments of
        [] ->
            text ""

        _ ->
            div [ class "comment" ]
                [ ul []
                    (List.map viewComment comments)
                ]


viewComments : Photo -> Html Msg
viewComments photo =
    div []
        [ viewCommentList photo.comments
        , form
            [ class "new-comment"

            {- , onSubmit SaveComment -}
            ]
            [ input
                [ type_ "text"
                , placeholder "Add a comment…"
                , value photo.newComment

                -- , onInput UpdateComment
                ]
                []
            , button
                [ disabled (String.isEmpty photo.newComment) ]
                [ text "save" ]
            ]
        ]


viewDetailedPhoto : Photo -> Html Msg
viewDetailedPhoto photo =
    div [ class "detailed-photo" ]
        [ img [ src photo.url ] []
        , div [ class "photo-info" ]
            [ viewLoveButton photo
            , h2 [ class "caption" ] [ text photo.caption ]
            , viewComments photo
            ]
        ]


viewFeed : Maybe Feed -> Html Msg
viewFeed maybePhoto =
    case maybePhoto of
        Just feed ->
            div [] (List.map viewDetailedPhoto feed)

        Nothing ->
            div [ class "loading-feed" ]
                [ text "Loading Feed…" ]


view : Model -> Html Msg
view model =
    div []
        [ div [ class "header" ]
            [ h1 [] [ text "picshare" ] ]
        , div [ class "content-flow" ]
            [ viewFeed model.feed ]
        ]


type Msg
    = {- ToggleLike
         | UpdateComment String
         | SaveComment
         |
      -}
      LoadFeed (Result Http.Error Feed)


saveNewComment : Photo -> Photo
saveNewComment photo =
    let
        comment =
            String.trim photo.newComment
    in
    case comment of
        "" ->
            photo

        _ ->
            { photo
                | comments = photo.comments ++ [ comment ]
                , newComment = ""
            }


toggleLike : Photo -> Photo
toggleLike photo =
    { photo | liked = not photo.liked }


updateComment : String -> Photo -> Photo
updateComment comment photo =
    { photo | newComment = comment }


updateFeed : (Photo -> Photo) -> Maybe Photo -> Maybe Photo
updateFeed updatePhoto maybePhoto =
    Maybe.map updatePhoto maybePhoto


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        {-
           ToggleLike ->
               ( { model | photo = updateFeed toggleLike model.photo }
               , Cmd.none
               )

           UpdateComment comment ->
               ( { model | photo = updateFeed (updateComment comment) model.photo }
               , Cmd.none
               )

           SaveComment ->
               ( { model | photo = updateFeed saveNewComment model.photo }
               , Cmd.none
               )
        -}
        LoadFeed (Ok feed) ->
            ( { model | feed = Just feed }
            , Cmd.none
            )

        LoadFeed (Err _) ->
            ( model, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
